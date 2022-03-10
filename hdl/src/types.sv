package types;
   // I2c debugging interface
   typedef enum logic [7:0]  {IDLE,
			      START,
			      ADDRESS,
			      REGADDRESS,
			      ACK,
			      WRITESTOP,
			      STOP}
		i2c_state_t;

   // GBT data reception/transmission frame
   typedef struct packed {
      logic [1:0] sc_data_b2;
      logic [1:0] ic_data_b2;
      logic [79:0] data_b80;
   } t_sfp_stream;


endpackage // types
