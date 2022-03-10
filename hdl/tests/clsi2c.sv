package clsi2c;
   import types::*;

class i2c_driver;
   virtual interface t_i2c.debugger i2c_x;

   int 	   speed;
   logic [6:0] address_b6;
   string      ident;


   event       ack;

   int       thdstamin, timeout, thighmin, tlowmin, tvdackmin;

   function new(int bus_speed = 100e3,
		int address = 7'h70,
		string identifier = "I2C");
      speed = bus_speed;
      $display("Driver %s registered with address %.2x",
	       identifier, address);

      address_b6 = address;
      ident = identifier;
      // timeout is by default 25ms
      timeout = 25e6;

      // SEE UM10204 I2C bus specs
      if (bus_speed == 100e3) begin
	 // setup timing, in nanoseconds
	 thdstamin = 4000;
	 thighmin = 4000;
	 tlowmin = 4700;
	 tvdackmin = 3450;

      end else
	// fill in another ones if needed
	$error("Timing not supported");


      $display("Initializing I2C reader %s: %dkHz clock speed, address\
 %.8x", ident, speed, address_b6);
   endfunction // new

   // spawns RUN process
   task run();
      fork
	 listen();
      join_none
   endtask // receiver

   // this task detects the movement on the interface and decodes
   // 8-byte communication. It does nothing except verification of
   // timing and printing the frames on display. The REAL any chip
   // emulation must happen by instantiation of this driver and
   // implementation of callback routines for data write and data read

   // placeholder to implement top-level chip register map/command
   // when user WRITES through I2c into register
   task data_write(input int address,
		   input int data);
      $display("Write %.8x to %.16x", data, address);
   endtask // data_write

   // placeholder to implement readout from top-level chip
   // register. This function returns 0xaa
   function logic [7:0] data_read(input int address);
      $display("Reading from %.16x (returning fake 0xaa)", address);
   endfunction // data_read

   task wait_stop_bit();
      i2c_x.state = STOP;
      do
	@(posedge i2c_x.sda);
      while (i2c_x.scl != '1);
   endtask // wait_stop_bit


   task wait_start_bit();
      i2c_x.state = IDLE;

      // startbit: both signals at logic high, sda goes low and after
      // thdstamin the scl can go low with first scl. We use fork to
      // verify the timing
      do
	@(negedge i2c_x.sda);
      while (i2c_x.scl != '1);
      i2c_x.state = START;

      // here when sda transitioned low, this is proper start bit, but
      // timing-wise next scl edge has to appear soonest thdstamin
      fork : sbit
	 @(negedge i2c_x.scl);
	 #(thdstamin * 1ns);
      join_any
      disable sbit;

      // if SCL is still high after thdstamin, we're fine and wait for
      // scl low BUT MAX
      assert (i2c_x.scl != '0) else $warning("I2C start bit SCL negedge\
 came too soon");
      fork : sbitscl
	 @(negedge i2c_x.scl);
	 #(timeout * 1ns);
      join_any;
      disable sbitscl;
      assert (i2c_x.scl == '0) else $warning("I2C start bit timeout");
      // this is real end of start bit. We have SCL at low, sda was
      // low as well.
   endtask // wait_start_bit

   task read_address();
      fork : addrfetch
	 begin
	    // data fetch:
	    repeat(8) begin
	       // data pick
	       i2c_x.address_received_b8 = {i2c_x.address_received_b8[6:0],
					    i2c_x.sda};
	       @(posedge i2c_x.scl);
	    end
	    i2c_x.address_received_b8 = {i2c_x.address_received_b8[6:0],
					 i2c_x.sda};
	    // transaction always ends in low-clock
	    @(negedge i2c_x.scl);
	 end // fork

	 // checks t-high of SCL
	 forever begin
	    @(posedge i2c_x.scl);
	    fork : thi
	       @(negedge i2c_x.scl);
	       #(thighmin * 1ns);
	    join_any
	    disable thi;

	    assert (i2c_x.scl != '0) else $warning("clock HIGH time\
 not respected");
	 end // forever begin

	 // checks t-low of SCL
	 forever begin
	    @(negedge i2c_x.scl);
	    fork : tlol
	       @(posedge i2c_x.scl);
	       #(tlowmin * 1ns);
	    join_any
	    disable tlol;

	    assert (i2c_x.scl == '0) else $warning ("clock LOW time\
 not respected");
	 end // forever begin
      join_any
      disable addrfetch;
   endtask // read_address

   task send_ack();
      // we drop SDATA here and wait for SCL going up/down before we
      // release
      assert (i2c_x.scl == '0) else $warning ("SCL not low before\
 scheduling ACK");
      ->ack;
      i2c_x.state = ACK;
      // wait for i2c specs
      #(tvdackmin * 1ns);
      i2c_x.sda_reg = '0;
      // wait until clock registers the ACK
      @(posedge i2c_x.scl);
      @(negedge i2c_x.scl);
      #200ns;
      i2c_x.sda_reg = 'z;
      #1ns;

   endtask // send_ack


   task read_byte();
      wait_start_bit();
      // reads 8 bits, i.e. 7bit address + r/w stored in LSB
      i2c_x.state = ADDRESS;
      read_address();
      // we ack ONLY if address matches
      if (i2c_x.address_received_b8[7:1] == address_b6) begin
	 $display("Address matches our driver, ACKing");
	 send_ack();
	 // now register address should be received
	 i2c_x.state = REGADDRESS;
	 read_address();
	 // store last registe address
	 i2c_x.register_address_received_b8 =
					     i2c_x.address_received_b8;
	 send_ack();
	 // now if the next item is NOT stop bit, it means that we're
	 // writing data into that particular register. If there's
	 // stop we finish the operation. This is decided on next SDA
	 // edge: if SDA low-to-high transition appears when SCL=1,
	 // then this is stop bit.
/* -----\/----- EXCLUDED -----\/-----
	 fork
	    begin : waitstop
	       @(posedge i2c_x.sda);
	       if (i2c_x.scl == '1) begin
		  $display("Stop bit detected");
	       end
	       disable readdata;
	    end
 -----/\----- EXCLUDED -----/\----- */
	    begin : readdata
	       // tentative reading of data to write
	       i2c_x.state = WRITESTOP;
	       read_address();
	       wait_stop_bit();
	       // real register write happened
	       data_write(i2c_x.register_address_received_b8,
			  i2c_x.address_received_b8);

	       // end other part of fork
/* -----\/----- EXCLUDED -----\/-----
	       disable waitstop;
 -----/\----- EXCLUDED -----/\----- */
	    end
/* -----\/----- EXCLUDED -----\/-----
	 join
 -----/\----- EXCLUDED -----/\----- */
      end else
	// skipping, and waiting for another startbit
	$display("Address %.2x does not match this driver, ignoring",
		 i2c_x.address_received_b8[7:1]);

   endtask // read_byte


   task listen();
      forever read_byte();

   endtask // listen



endclass // i2c_driver

endpackage // clsi2c
