`ifndef _MCPkg_PKG
 `define _MCPkg_PKG
package MCPkg;
   // parameters used in calculation of acceleration
   parameter SPEED_FRACTION = 18;
   parameter COUNT_INT = 18;

   // define number of motor controller units per optical line. Note that one
   // line can handle maximum 80 bits of data in a frame. Should we keep single
   // frame for all communication, all mc_x interfaces have to fit those 80
   // bits.
   parameter NUMBER_OF_MOTORS_PER_FIBER = 16;

   // number of registers in each stepper motor controller map
   // !!!!NOTE!!!! that if you change this value, you have to as well change
   // the registers declaration in wbmc.sv as increasing this value will make
   // the new registers UNDECLARED and they MIGHT POSSIBLY break the already
   // defined register structure
   parameter NUMBER_OF_MC_REGISTERS = 32;

   // number of registers exported for mclink control layer
   parameter NUMBER_OF_LINK_REGISTERS = 8;

   // calculate address space (in number of bits) required to cover the needs of
   // MCLINK interface. This is following equation. Explication: the total
   // address width is given by number of address bits required to address all
   // MC registers, add bitwidth of NUMBER_OF_MOTORS_PER_FIBER increased by one
   // because we implement
   parameter MCLINK_WB_ADDRESS_WIDTH =
				      $clog2(NUMBER_OF_MC_REGISTERS) +
				      $clog2(NUMBER_OF_MOTORS_PER_FIBER +
					     NUMBER_OF_LINK_REGISTERS);

   // define number of GBT links to be instantiated
   parameter NUMBER_OF_GBT_LINKS = 4;

   // IRQ FIFO bit width for each GBT LINK - when a single link fires
   // IRQ, it is stored to FIFO before casting to global IRQ
   // lines. This is because there might be parallel occurence of IRQs
   // from multiple links and we need to encode them to cast all of
   // them away one by one. Too small depth and FIFO will overflow and
   // start to 'forget' IRQs, too largs and we blow FPGA memory. Value
   // of 4 leaves us with 16 samples of 16 bits, so no big deal
   parameter IRQ_GBT_FIFO_BITWIDTH = 4;





   // these two functions realize division or multiplication of
   // speedIn input by 2**(SPEED_FRACTION). As speedIn is related to
   // the speed of the motor, this is equivalent of changing the speed
   // of the motor by 2**(SPEED_FRACTION)
   function [35:0] speedShiftUp(input logic [16:0] speedIn);
      speedShiftUp = speedIn << SPEED_FRACTION;
   endfunction

   function [16:0] speedShiftDown(input logic [35:0] speedIn);
      speedShiftDown = (17)'(speedIn >> SPEED_FRACTION);
   endfunction // speedShiftDown

   // typedef which declares motor input and output data
   typedef struct packed {
      logic OH_i;			// overheat
      logic StepPFail_i;		// stepper controller failure
      // input switches - RawSwitches_b2[0] corresponds to 'IN' switch
      // and RawSwitches_b2[1] corresponds to 'OUT' swich. This structure is
      // extensible to 'many' swiches, where 'many' corresponds to maximum of 3
      // swiches as the total length of mcinput_t for 16 motos must not exceed
      // 80bits, which is GBT frame
      logic [1:0] RawSwitches_b2;
   } mcinput_t;

   typedef struct packed {
      logic StepOutP_o;		// pulse to move stepper motor
      logic StepDeactivate_o;		// motor stepping enable
      logic StepBOOST_o;		// motor stepping boost
      logic StepDIR_o;		// direction of move
   } mcoutput_t;

   // typedef defines for each motor switch polarity
   typedef enum logic {NORMAL = 1'b0,
		       INVERT = 1'b1} polarity_t;
   // define structure for each output switch
   typedef struct packed {
      // switch is NORMAL or INVERTED?
      polarity_t Polarity;
      // NUMBER of switch to be selected as output from
      // the switchmatrix
      logic [1:0] SelectedInputSwitches_b2;
   } switchstate_t;

   typedef struct {
      // global external trigger
      logic 	  TrigMoveExt_i;
      // global internal trigger - by global register command
      logic 	  TrigMoveInt_i;
      // '1' when triggering is enabled
      logic 	  TriggerEnable_i;
   } triggers_t;

   // structure declaring for each _output switch_ the inputs
   typedef struct 					 {
      switchstate_t [1:0] ExtremitySwitches_b2;
      // declare how many motion steps is allowed for the motor when
      // the switch triggers. These are TWO separate registers because
      // number of steps in positive and negative direction can
      // differ. P denotes positive direction (= DIR pin and VME
      // direction register set to '0'), N denotes negative direction
      // (=DIR pin and VME direction registers set to '1')
      logic [5:0] 					 StepsAfterLimitSwitchP_b6;
      logic [5:0] 					 StepsAfterLimitSwitchN_b6;
      // having given clock, the SlowDown_b32 parameter will slow down the
      // communication process of the MC by factor of SlowDown_b32
      // during the motion of the motor.
      logic [31:0] 					 SlowDown_b32;
   } cntparam_t;



   // for triggering we use packed struct so we can easily clear out
   // the triggers.
   typedef struct 					 packed 					 {
      logic 						 StartMove;
      logic 						 StopMove;
      logic 						 DoQueue;
      logic 						 ResetCounterPos;
      logic 						 ResetQueue;
   } motorcommand_t;

   // structure defining status of the command queue
   typedef struct packed 					 {
      // set to '1' if the queue is filled with samples. In this case
      // any further attempt to write into the queue will be ignored
      logic 						 QueueFull;
      // shows how many items is in the queue. Zero means that queue
      // is empty and input command is just passed to the output
      // command, nonzero identifies number of records. This value can
      // never exceed the queue length
      logic [6:0] 					 QueueItems_u7;
   } queuestatus_t;



   // stepping controller status of the last operation
   typedef struct 					 packed {
      // which direction motor moved
      bit 						 Direction;
      // if the motor was stopped by limiting switch
      bit 						 StopLimit;
      // if the motor was stopped by stopmove trigger
      bit 						 StopMove;
      // if the motor stopped due to disable of move
      bit 						 EnableMove;
      // if OUT switch triggered
      bit 						 SW_N_triggered;
      // if IN switch triggered
      bit 						 SW_P_triggered;
      // if overheat condition appeared
      bit 						 OH;
      // if stepper failed
      bit 						 StepPFail;
   } abortstatus_t;


   // stepping controller status information
   typedef struct 					 {
      // position of the counter in # of steps pulsed out. Can be
      // reset to zero by a command in ITriggerParams_x
      bit [31:0] 					 PosCounter_b32;
      // state of the state machine
      bit [7:0] 					 State;
      // how many steps are still to be done to finish the movement
      bit [31:0] 					 StepsLeft_b32;
      // '1' for single cc when the movement is done
      bit 						 Done;
      bit 						 Interrupt;
      abortstatus_t 					 AbortStatus;
      // '1' during the movement to show that it is busy
      bit 						 Busy;
   } stepperstatus_t;

   // record containing description of a single motor movement. This
   // is used in combination with command queue. Each command in queue
   // describes one motor command based on this record.
   typedef struct packed 					 {
      // total number of steps, which are used for this particular cycle
      logic [31:0] 					 StepNumber_b32;
      logic 						 Direction;
      // speed of the motor before acceleration and during trailing
      logic [35:0] 					 LowSpeed_b36;
      // speed of the motor during high speed cruising
      logic [35:0] 					 HighSpeed_b36;
      // during acceleration or deceleration this parameter sets up
      // additional speed increase/decrease each cycle
      logic [18:0] 					 AccDeccRate_b19;

      logic [31:0] 					 Trail_b32;
      // bit 1 = ENABLE INTERNAL TRIGGER
      // bit 0 = ENABLE EXTERNAL TRIGGER
      struct 						 packed {
	 logic 						 internal;
	 logic 						 external;
      } globaltrigger;
      logic 						 GenInterrupt;
      // bit 2 = STANDBY
      // bit 1 = BOOST
      // bit 0 = ENABLE MOVE
      struct 						 packed {
	 logic 						 standby;
	 logic 						 boost;
	 logic 						 enable_move;
      } powerconfig;
   } command_t;

    // how many flip-flops will be used in the input signal
    // synchronization chain to avoid metastability
   parameter g_SynchronizationFlips = 3;

   // This is magic number, which is used to set ScEc channel 1 so
   // GEFE will start to listen to commands from VFC.
   parameter GEFE_INTERLOCK = 32'h84FE92AC;
endpackage

`endif
