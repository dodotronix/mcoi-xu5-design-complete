package types;
   typedef enum logic [7:0]  {IDLE,
			      START,
			      ADDRESS,
			      REGADDRESS,
			      ACK,
			      WRITESTOP,
			      STOP}
		i2c_state_t;
endpackage // types
