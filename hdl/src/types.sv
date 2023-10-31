package types;
   import MCPkg::*;

   // I2c debugging interface
   typedef enum logic [7:0]  {
       IDLE,
       START,
       ADDRESS,
       REGADDRESS,
       ACK,
       WRITESTOP,
       STOP} i2c_state_t;

   // GBT data reception/transmission frame
   typedef struct packed {
      // entire SC/IC + data stream
      // SC lines are used for serial registers
      logic [3:0] sc_data_b4;
      // follows 64 bit 4x16 motors assignments
      logic [63:0] motor_data_b64;
      // and paged memory interface
      logic [15:0] mem_data_b16;
   } t_sfp_stream;

   typedef mcinput_t[NUMBER_OF_MOTORS_PER_FIBER:1] motorsStatuses_t;
   typedef mcoutput_t[NUMBER_OF_MOTORS_PER_FIBER:1] motorsControls_t;

endpackage // types
