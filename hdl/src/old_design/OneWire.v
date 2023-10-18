/*

Module that reads ID and temperature over 1-wire bus from the DS18B20U+ chip.

The code reads unique 64-bit ID of the chip and continuously updates temperature
readout. The temperature is available in the 16 LSB of the scratchpad readout.
The temperature value must be divided by 2^4 to be converted to degrees of Celsius.


*/


`timescale 1ns/100ps

module OneWire (
	input   Rst_irq,                      // reset
	input   Clk_ik,                       // 1MHz clock
	inout   OneWireBus_io,                // the bus
	output reg [63:0] UniqueID_oqb64,     // unique ID
	output reg [63:0] Scratchpad_oqb64    // chip scratchpad data
);

localparam dly = 1;

// output pull down
wire OutputPullDown_s;
reg IRPullDown_q = 0;
reg WPullDown_q = 0;
reg RPullDown_q = 0;

// couter regs
reg [19:0] Counter_b20 = 20'h0;
reg [8:0] IRCounter_c9 = 9'h0;
reg [5:0] WCounter_c6 = 6'h0;
reg [6:0] RCounter_c7 = 7'h0;
reg [2:0] WBitCounter_c3 = 3'b0;
reg [5:0] RBitCounter_c6 = 6'h0;

// reset signals
reg CRst_rq = 1'b1;
reg IRRst_rq = 1'b1;
reg WRst_rq = 1'b1;
reg RRst_rq = 1'b1;

// done signals
reg GotID_q = 1'b0;
reg TempConverted_q = 1'b1;
reg IRDone_q = 1'b0;
reg WDone_q = 1'b0;
reg RDone_q = 1'b0;

// presence signal from slave
//reg IRPresent_nq = 1'b1;

// data regs
reg [7:0] WData_qb8 = 8'h0;
reg [7:0] WShReg_qb8 = 8'h0;
reg [63:0] RShReg_qb64 = 64'h0;


// major state machine states
// read ID code after reset, convert and read temp in cycles later
localparam  s_InitReset = 3'h0;
localparam  s_ROMCommand = 3'h1;
localparam  s_ReadROM = 3'h2;
localparam  s_ConvertTemp = 3'h3;
localparam  s_ScratchpadCommand = 3'h4;
localparam  s_Wait = 3'h5;
localparam  s_ReadScratchpad = 3'h6;

// reset state machine states
localparam  s_IRReset = 2'b0,
            s_IRPresence = 2'b1,
            s_IRWait = 2'b10;

// read and write SMs
localparam  s_WInit = 2'b0,
            s_WWrite = 2'b1,
            s_WWait = 2'b10;

localparam  s_RInit = 2'b0,
            s_RRead = 2'b1,
            s_RWait = 2'b10;

// state regs
reg [2:0] State_q = s_Wait;
reg [1:0] IRState_q = 2'b0;
reg [1:0] WState_q = 2'b0;
reg [1:0] RState_q = 2'b0;


// pulldown composition, and of all possible state machines
assign OutputPullDown_s = |{IRPullDown_q, WPullDown_q, RPullDown_q};

// output and tristate
assign  OneWireBus_io = OutputPullDown_s ? 1'b0 : 1'bz;


// master state machine
always @(posedge Clk_ik or posedge Rst_irq) begin

	if( Rst_irq == 1'b1 ) begin
		// resets default on
		IRRst_rq <= #dly 1'b1;
		WRst_rq <= #dly 1'b1;
		RRst_rq <= #dly 1'b1;
		CRst_rq <= #dly 1'b1;

		// zero output and control
		GotID_q <= #dly 1'b0;
		TempConverted_q <= #dly 1'b1;  // first wait will flip it to 0
		UniqueID_oqb64 <= #dly 64'h0;
		Scratchpad_oqb64 <= #dly 64'h0;

		// start state Wait
		State_q <= #dly s_Wait;
	end
	else begin

		// counter increment
		if( CRst_rq == 1'b1 )
		  Counter_b20 <= #dly 20'h0;
		else
		  Counter_b20 <= #dly Counter_b20 + 20'h1;

		// resets default on
		IRRst_rq <= #dly 1'b1;
		WRst_rq <= #dly 1'b1;
		RRst_rq <= #dly 1'b1;
		CRst_rq <= #dly 1'b1;

		case( State_q )

		// release init reset and wait for it to finish
		s_InitReset: begin
			IRRst_rq <= #dly 1'b0;
			if( IRDone_q == 1'b1 )
				State_q <= #dly s_ROMCommand;
		end

		// write ROM command, either ROM read or skip
		// release write reset and wait for it to finish
		s_ROMCommand: begin
			WRst_rq <= #dly 1'b0;

			// read ROM if not done yet, else skip ROM
			if( GotID_q == 1'b0 )
				WData_qb8 <= #dly 8'h33;
			else
				WData_qb8 <= #dly 8'hCC;

			// read rom or convert temp as next
			if( WDone_q == 1'b1 ) begin
				WRst_rq <= #dly 1'b1;

				if( GotID_q == 1'b0 )
					State_q <= #dly s_ReadROM;
				else
					State_q <= #dly TempConverted_q ? s_ScratchpadCommand : s_ConvertTemp;
			end
		end

		// read ROM
		// release read reset and wait for it to finish
		s_ReadROM: begin
			RRst_rq <= #dly 1'b0;

			if( RDone_q == 1'b1 ) begin
				RRst_rq <= #dly 1'b1;

				UniqueID_oqb64 <= #dly RShReg_qb64;
				GotID_q <= #dly 1'b1;
				State_q <= #dly TempConverted_q ? s_ScratchpadCommand : s_ConvertTemp;
			end
		end

		// write command to convert temperature
		// release write reset and wait for it to finish
		s_ConvertTemp: begin
			WRst_rq <= #dly 1'b0;

			// convert temp
			WData_qb8 <= #dly 8'h44;

			// read rom or convert temp as next
			if( WDone_q == 1'b1 ) begin
				WRst_rq <= #dly 1'b1;
				State_q <= #dly s_Wait;
			end
		end

		// ~1s wait
		s_Wait: begin
			CRst_rq <= #dly 1'b0;
			if( Counter_b20 == 20'hF0000 ) begin
				TempConverted_q <= ~TempConverted_q;
				State_q <= #dly s_InitReset;
			end
		end

		// write command to read scratchpad
		// release write reset and wait for it to finish
		s_ScratchpadCommand: begin
			WRst_rq <= #dly 1'b0;

			// convert temp
			WData_qb8 <= #dly 8'hBE;

			// read rom or convert temp as next
			if( WDone_q == 1'b1 ) begin
				WRst_rq <= #dly 1'b1;
				State_q <= #dly s_ReadScratchpad;
			end
		end

		// read the scratchpad and start over
		// release read reset and wait for it to finish
		s_ReadScratchpad: begin
			RRst_rq <= #dly 1'b0;

			if( RDone_q == 1'b1 ) begin
				RRst_rq <= #dly 1'b1;

				Scratchpad_oqb64 <= #dly RShReg_qb64;
				State_q <= #dly s_InitReset;
			end
		end
		endcase
	end
end





// reset state machine
always @(posedge Clk_ik) begin
	IRPullDown_q <= #dly 1'b0;
	IRCounter_c9 <= #dly IRCounter_c9 + 9'h1;
	IRDone_q <= #dly 1'b0;

	if( IRRst_rq == 1'b1 ) begin
		IRState_q <= #dly s_IRReset;
		IRCounter_c9 <= #dly 9'h0;
		IRDone_q <= #dly 1'b0;
	end
	else begin
		case( IRState_q )
		// send 500us reset pulse
		s_IRReset: begin
			IRPullDown_q <= #dly 1'b1;

			if( IRCounter_c9 == 9'h1F4 ) begin
				IRState_q <= #dly s_IRPresence;
				IRCounter_c9 <= 9'h0;
			end
		end

		// wait, sample after 67us, report done after 500us
		s_IRPresence: begin
//			if( IRCounter_c9 == 9'h43 ) begin
//				IRPresent_nq <= #dly OneWireBus_io;
//			end
//			else
			if( IRCounter_c9 == 9'h1F4 ) begin
				IRDone_q <= #dly 1'b1;
			end
		end
		endcase
	end
end

// command write state machine
always @(posedge Clk_ik) begin
	WPullDown_q <= #dly 1'b0;
	WCounter_c6 <= #dly WCounter_c6 + 6'h1;
	WDone_q <= #dly 1'b0;

	if( WRst_rq == 1'b1 ) begin
		WState_q <= #dly s_WInit;
		WCounter_c6 <= #dly 6'h0;
		WShReg_qb8 <= #dly WData_qb8;
		WBitCounter_c3 <= #dly 3'b0;
	end
	else begin
		if( WBitCounter_c3 == 3'b000 )
			WShReg_qb8 <= #dly WData_qb8;

		case( WState_q )
		// pull down for 6 us
		s_WInit: begin
			WPullDown_q <= #dly 1'b1;

			if( WCounter_c6 == 6'h5 ) begin
				WCounter_c6 <= #dly 6'h0;
				WState_q <= #dly s_WWrite;
			end
		end

		// write for 55us
		s_WWrite: begin
			WPullDown_q <= #dly !WShReg_qb8[0];
			if( WCounter_c6 == 6'h37 ) begin
				WCounter_c6 <= #dly 6'h0;
				WState_q <= #dly s_WWait;
			end
		end

		// release and wait 5 us, send next bit or report done and wait for reset
		s_WWait: begin
			if( WCounter_c6 == 6'h5 ) begin
				WShReg_qb8 <= #dly {1'b0, WShReg_qb8[7:1]};

				if ( WBitCounter_c3 == 3'b111 ) begin
					WState_q <= #dly s_WWait;
				end
				else begin
				   WCounter_c6 <= #dly 6'h0;
					WState_q <= #dly s_WInit;
					WBitCounter_c3 <= WBitCounter_c3 + 3'h1;
				end
			end
			// signal done after ~30us delay
			if( WCounter_c6 == 6'h1f )
				WDone_q <= #dly 1'b1;
		end
		endcase
	end
end

// 8 byte read state machine
always @(posedge Clk_ik) begin
	RPullDown_q <= #dly 1'b0;
	RCounter_c7 <= #dly RCounter_c7 + 7'h1;
	RDone_q <= #dly 1'b0;

	if( RRst_rq == 1'b1 ) begin
		RState_q <= #dly s_RInit;
		RCounter_c7 <= #dly 7'h0;
		RBitCounter_c6 <= #dly 6'h0;
		RDone_q <= #dly 1'b0;
	end
	else begin
		case( RState_q )
		// pull down for 6 us
		s_RInit: begin
			RPullDown_q <= #dly 1'b1;

			if( RCounter_c7 == 7'h5 ) begin
				RCounter_c7 <= #dly 7'h0;
				RState_q <= #dly s_RRead;
			end
		end

		// wait for 6us and sample
		s_RRead: begin
			if( RCounter_c7 == 7'h6 ) begin
				RShReg_qb64 <= #dly {OneWireBus_io, RShReg_qb64[63:1]};
				RCounter_c7 <= #dly 7'h0;
				RState_q <= #dly s_RWait;
			end
		end

		// wait 57 us, read next bit or report done and wait for reset
		s_RWait: begin
			if( RCounter_c7 == 7'h39 ) begin

				if( RBitCounter_c6 == 6'h3f ) begin
					RState_q <= #dly s_RWait;
				end
				else begin
					RCounter_c7 <= #dly 7'h0;
					RState_q <= #dly s_RInit;
					RBitCounter_c6 <= RBitCounter_c6 + 6'h1;
				end
			end
			// report done after ~30us delay
			if( RCounter_c7 == 7'h58 )
				RDone_q <= #dly 1'b1;
		end
		endcase
	end
end

endmodule
