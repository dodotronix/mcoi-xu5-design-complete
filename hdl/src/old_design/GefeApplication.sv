//                              -*- Mode: Verilog -*-
// Filename        : GefeApplication.sv
// Description     : GEFE MCOI frontend
// Author          : Dr. David Belohrad
// Created On      : Fri Apr 20 09:44:57 2018
// Last Modified By: Dr. David Belohrad
// Last Modified On: Fri Apr 20 09:44:57 2018
// Update Count    : 0
// Status          : Unknown, Use with caution!

import CKRSPkg::*;
import MCPkg::*;
import constants::*;


module GefeApplication
  #(
      // number of clock cycles on 25MHz clock to get 1ms resolution
      // timer. Used exclusively to generate diodes PWM
      parameter g_clock_divider = 25000)
  //========================================  I/O ports  =======================================\\
  (
   //==== Resets Scheme ====\\

   // Opto Loss Of Signal (LOS) reset:
   // Comment: This reset is asserted when there is not enough optical signal in the
   //          receiver of the optical transceiver (either VTRx or
   //          SFP+). If LOS is experienced, this signal returns '0'
   input 	  OptoLosReset_iran,

   //==== GBTx ====\\

   // I2C:
   //inout 	  GbtxI2cSda_io,
   //inout 	  GbtxI2cScl_io,

   // Control:
   output 	  GbtxReset_or,
   input 	  GbtxRxDataValid_i,
   output 	  GbtxTxDataValid_o,
   input 	  GbtxRxRdy_i,
   input 	  GbtxTxRdy_i,

   // Clocks:
   // Comments: - GbtxElinksDclkCg is the clock used by the GBTx I/O registers.
   //             GbtxElinksDclkCg is connected to the "Chip global" (Cg) clock network.
   //             GbtxElinksDclkQg[0:1] are connected to "Quadrant global" (Qg) clock networks.
   //           - In GEFE, the SC Elink uses the same reference clock as the normal Elinks (GbtxElinksDclkCg).
   //             GbtxElinksScClkQg is connected to the 1st "Quadrant global" (Qg) clock network.
   //           - GbtxClockDesCg is connected to the "Chip global" (Cg) clock network.
   //             GbtxClockDesQg[0:2] are connected to "Quadrant global" (Qg) clock networks.
   //             GbtxClockDes[4] goes directly to the FMC connector bypassing the ProAsic3 FPGA.
   //input [ 0: 1]  GbtxElinksDclkQg_ikb2p,
   //input [ 0: 1]  GbtxElinksDclkQg_ikb2n,
   //input 	  GbtxElinksScClkQg_ikp,
   //input 	  GbtxElinksScClkQg_ikn,
   //input 	  GbtxClockDesCg_ikp,
   //input 	  GbtxClockDesCg_ikn,
   //input [ 0: 2]  GbtxClockDesQg_ikb3p,
   //input [ 0: 2]  GbtxClockDesQg_ikb3n,

   //==== FMC Connector ====\\

   // Comment: All clocks as well as the LA, HA and DP pins are powered by Vadj,
   //          whilst the HB pins are powered by VioBM2c.

   // Clocks:
   // Comments: - FmcClkM2c0Cg    is connected to the "Chip global" (Cg) clock network.
   //             FmcClkM2c1Qg    is connected to the 2th "Quadrant global" (Qg) clock network.
   //           - FmcClkBidir2Cq  is connected to the "Chip global" (Cg) clock network.
   //             FmcClkBidir3Qg  is connected to the 1st "Quadrant global" (Qg) clock network.
   //           - FmcGbtClkM2c0Qg is connected to the 1th "Quadrant global" (Qg) clock network.
   //             FmcGbtClkM2c1Qg is connected to the 3th "Quadrant global" (Qg) clock network.
   //input 	  FmcClkM2c0Cg_ikp,
   //input 	  FmcClkM2c0Cg_ikn,
   //input 	  FmcClkM2c1Qg_ikp,
   //input 	  FmcClkM2c1Qg_ikn,
   //inout 	  FmcClkBidir2Cq_iokp,
   //inout 	  FmcClkBidir2Cq_iokn,
   //inout 	  FmcClkBidir3Qg_iokp,
   //inout 	  FmcClkBidir3Qg_iokn,
   //input 	  FmcGbtClkM2c0Qg_ikp,
   //input 	  FmcGbtClkM2c0Qg_ikn,
   //input 	  FmcGbtClkM2c1Qg_ikp,
   //input 	  FmcGbtClkM2c1Qg_ikn,

   // LA pins:
   // Comment: Please note that the following pins are Clock Capable (CC): 0, 1, 17.
   inout [33: 0]  FmcLa_iob34p,
   inout [33: 0]  FmcLa_iob34n,

   // HA pins:
   // Comment: Please note that the following pins are Clock Capable (CC): 0, 1, 17.
   inout [23: 0]  FmcHa_iob24p,
   inout [23: 0]  FmcHa_iob24n,

   // HB pins:
   // Comments: - Please note that the following pins are Clock Capable (CC): 0, 6, 17.
   //           - Referenced voltage levels may only be used by HB pins.
   inout [21: 0]  FmcHb_iob22p,
   inout [21: 0]  FmcHb_iob22n,

   // DP lanes:
   // Comment: The high-speed (DP) lanes do not complain the FMC standard (VITA 57.1)
   //          since they are used as standard IOs and some of them are also used for
   //          special purposes.
   //inout [ 0: 9]  FmcDpM2c_iob10p,
   //inout [ 0: 9]  FmcDpM2c_iob10n,
   //inout [ 0: 9]  FmcDpC2m_iob10p,
   //inout [ 0: 9]  FmcDpC2m_iob10n,

   // I2C:
   //inout 	  FmcSda_io,
   //inout 	  FmcScl_io,

   // JTAG:
   //output 	  FmcTck_o,
   //inout 	  FmcTdi_i,
   //output 	  FmcTdo_o,
   //output 	  FmcTms_o,
   //output 	  FmcTrstL_on,

   // Control:
   //input 	  FmcClkDir_i,
   //input 	  FmcPowerGoodM2c_i,
   //output 	  FmcPowerGoodC2m_o,
   //input 	  FmcPrsntM2cL_in,

   //==== Miscellaneous ====\\

   // Clock feedback:
   // Comment: ClkFeedback is connected to the "Chip global" (Cg) clock network.
   //input 	  ClkFeedbackI_ikp,
   //input 	  ClkFeedbackI_ikn,
   //output 	  ClkFeedbackO_okp,
   //output 	  ClkFeedbackO_okn,

   // MMCX Clocks & GPIOs:
   // Comments: - MmcxClkIoCg is connected to the "Chip global" (Cg) clock network.
   //           - MmcxGpIo[3:0] are connected to different "Quadrant global" (Qg) clock networks.
   //inout 	  MmcxClkIoCg_iokp,
   //inout 	  MmcxClkIoCg_iokn,
   //inout [ 0: 3]  MmcxGpIoQg_iokb4,

   // LEMO GPIO:
   // Comment: LemoGpio is connected to the 4th quadrant clock network.
   output 	  LemoGpioDir_o,
   inout 	  LemoGpioQg_iok,

   // Push button:
   //input 	  PushButton_i,

   // DIP switch:
   //input [ 7: 0]  DipSwitch_ib8,

   // User LEDs:
   output [ 0: 5] Leds_onb6,

   // GPIO connectors:
   //inout [12: 0]  GpioConnA_iob13,
   //inout [23: 0]  GpioConnB_iob24,

   // Board ID connector:
   //inout [12: 0]  BoardIdConn_iob13,

   // GEFE configuration ID:
   //input [ 9: 0]  GefeConfigId_ib10,

   // Electrical serial link:
   //input 	  ElectSerialLinkRx_i,
   //output 	  ElectSerialLinkTx_o,

   //==== Powering ====\\

   input 	  V1p5PowerGood_i,
   input 	  V2p5PowerGood_i,
   input 	  V3p3PowerGood_i,
   //output 	  V3p3Inhibit_o,
   //input 	  V3p3OverCurMon_i,

   //==== System Module Interface ====\\

   // Resets scheme:
   // Comment: See Microsemi application note AC380.
   input 	  GeneralReset_iran,

   // Crystal oscillator (25MHz):
   // Comment: - Osc25MhzCg is connected to the "Chip global" (Cg) clock network.
   input 	  Osc25MhzCg_ik,

   // GBTx:
   // Comments: - GbtxElinksDclkCg is the clock used by the GBTx I/O registers.
   //             GbtxElinksDclkCg is connected to the "Chip global" (Cg) clock network.
   input 	  GbtxElinksDclkCg_ik,
   //--
   input [79: 0]  DataFromGbtx_ib80,
   output [79: 0] DataToGbtx_ob80,
   input [ 1: 0]  DataFromGbtxSc_ib2,
   output [ 1: 0] DataToGbtxSc_ob2
   ) /* synthesis syn_preserve=1 */;

   timeunit 1ns;
   timeprecision 1ps;

   //======================================  Declarations  ======================================\\

   //==== Wires & Regs ====\\

   // GBTx Elinks:
   logic [79: 0]  DataGbtxElinks_qb80, ValidMotorData_b80;
   logic [31:0] build_ob32, RegLoopback_b32, MuxOut_b32;
   logic [31:0] PageSelector_b32;
   logic 	SerialLinkUp;
   logic 	VFCDataArrived;
   logic [79:0] MotorsData_b80, DataToGbtx_b80;
   logic [31:0] SerialFeedback_b32;
   logic 	RxDataValid;
   logic [3:0] 	PCBrevision_o4;

   logic ds18b20_pll_locked, ds18b20_pll_1MHz_clk;
   logic [63:0] UniqueID_oqb64, Scratchpad_oqb64;
   logic [31:0] SwitchesConfiguration_b32
		[NUMBER_OF_MOTORS_PER_FIBER-1:0];
   switchstate_t [1:0] SwitchesConfiguration_2b16 [NUMBER_OF_MOTORS_PER_FIBER-1:0];

   // led arrays from switches decoding
   logic [NUMBER_OF_MOTORS_PER_FIBER-1:0] led_lg,
					  led_lr,
					  led_rg,
					  led_rr;





   //=======================================  User Logic  =======================================\\

   // generate clock structure - this design uses ONLY RX CLOCK as
   // system clock. This is 40MHz. It is used for all parts of the
   // design, which somehow interact with optics.
   ckrs_t ClkRxGBT_x;
   assign ClkRxGBT_x.clk = GbtxElinksDclkCg_ik;

   ckrs_t ClkRs_x;
   assign ClkRs_x.clk = Osc25MhzCg_ik;

   // GBTx Control - TURN ON POWER SUPPLY!! (how about this?:)
   assign GbtxReset_or      =  1'b0;

   // supply:
   logic 	supplyOK_o;


   // motor input and output signals
   mcinput_t [NUMBER_OF_MOTORS_PER_FIBER:1] motorStatus_ob, debounced_motorStatus_b;
   mcoutput_t [NUMBER_OF_MOTORS_PER_FIBER:1] motorControl_ib;

   // transporting reset signal into appropriate clock domain
   // all gbtx operations are reseted by missing optical clock,
   // all non-gbtx are reseted by general FPGA reset.
   manyff
     #(
       .g_Latency			(2))
   i_manyff
     (
      .d_o				(ClkRxGBT_x.reset),
      .ClkRs_ix				(ClkRxGBT_x),
      .d_i				(~OptoLosReset_iran));

   manyff
     #(
       .g_Latency			(2))
   i_manyff_rx
     (
      .d_o				(ClkRs_x.reset),
      .ClkRs_ix				(ClkRs_x),
      .d_i				(~GeneralReset_iran));

   ////////////////////////////////////////////////////////////////////////////////
   // CASTING MAIN DATA TO THE MOTOR CONTROLS
   ////////////////////////////////////////////////////////////////////////////////
   // - registering the motor data and the data valid:
   always_ff @(posedge ClkRxGBT_x.clk or posedge ClkRxGBT_x.reset)
     if (ClkRxGBT_x.reset) begin
	DataGbtxElinks_qb80  <= '0;
	RxDataValid <= '0;
     end else begin
	DataGbtxElinks_qb80  <= DataFromGbtx_ib80;
	RxDataValid <= GbtxRxDataValid_i;
     end

   logic [15:0] ValidRXMemData_b16;

   // - casting motor data to ValidMotorData_b80 IF THE DATAVALID FLAG
   // is associated with the data:
   localparam GBTWIDTH = $bits(DataGbtxElinks_qb80);
   localparam MCWIDTH = $bits(motorControl_ib);
   // assign through interlocking - control data are casted to the
   // motor _only_ if loop is closed _and_ data are valid. Then with
   // each data valid we capture the data at the output and leave them
   // until next data enable comes:
   always_ff @(posedge ClkRxGBT_x.clk) begin
      //if (RxDataValid)
      ValidMotorData_b80 <= DataGbtxElinks_qb80[GBTWIDTH-1:
						GBTWIDTH-MCWIDTH];
      ValidRXMemData_b16 <= DataGbtxElinks_qb80[15:0];
      if (SerialFeedback_b32 == GEFE_INTERLOCK)
	motorControl_ib = ValidMotorData_b80[$bits(motorControl_ib)-1:0];
      else
	// to deactivate motor SET ALL BITS TO 1 because it will
	// trigger StepDeactivate. This will prevent the motors to go
	// nuts when the link is not yet established
	motorControl_ib = '1;

   end


   ////////////////////////////////////////////////////////////////////////////////
   // SC-EC channels setting up GEFE behaviour
   ////////////////////////////////////////////////////////////////////////////////]
   // - instantiation of two ScEc serial registers:
   // Serial register is used to pass the information FROM/TO VFC. The
   // GEFE RX at channel0 contains page selector and registers
   // control,
   // GEFE TX at channel0 returns information requested by page
   // selector
   // CHANNEL1 does only feedback for the moment, but is reserved for
   // future usage.
   serial_register
     i_serial_register
       (
	// Outputs
	.data_ob32			(PageSelector_b32),
	.Tx_o				(DataToGbtxSc_ob2[0]),
	.SerialLinkUp_o			(SerialLinkUp),
	.RxLocked_o			(),
	.TxBusy_o				(),
	.newdata_o			(VFCDataArrived),
	.TxEmptyFifo_o			(),
	.txerror_o			(),
	.rxlol_o				(),
	// Inputs
	.ClkRs_ix				(ClkRxGBT_x),
	.ClkRxGBT_ix			(ClkRxGBT_x),
	.ClkTxGBT_ix			(ClkRxGBT_x),
	.data_ib32			(MuxOut_b32),
	.resetflags_i			(1'b0),
	.Rx_i				(DataFromGbtxSc_ib2[0]));

   logic [31:0] SerialFeedback1cc_b32;

   // Serial register on channel1 is used as a 'feedback', which
   // identifies if GEFE is connected to proper VFC target. In
   // addition the feedback is used to interlock the data casted TO
   // the motor (not from)
   serial_register
     i_serial_register_feedback
       (
	// Outputs
	.data_ob32			(SerialFeedback_b32),
	.Tx_o				(DataToGbtxSc_ob2[1]),
	.SerialLinkUp_o			(),
	.RxLocked_o			(),
	.TxBusy_o				(),
	.newdata_o			(),
	.TxEmptyFifo_o			(),
	.txerror_o			(),
	.rxlol_o				(),
	// Inputs
	.ClkRs_ix				(ClkRxGBT_x),
	.ClkRxGBT_ix			(ClkRxGBT_x),
	.ClkTxGBT_ix			(ClkRxGBT_x),
	.data_ib32			(SerialFeedback1cc_b32),
	.resetflags_i			(1'b0),
	.Rx_i				(DataFromGbtxSc_ib2[1]));

   // we have to clock-in the data from SerialFeedback_b32 because
   // serial register then triggers timing errors
   always_ff @(posedge ClkRxGBT_x.clk)
     SerialFeedback1cc_b32 <= SerialFeedback_b32;

   // - loopback on ScEc links when pageselector MSB is set ot '1':
   // this realizes loopback mode on 80-bit iface IF that one is
   // enabled. In other state just cast the motors data into the GBT
   // stream.
   always_comb begin
      if (PageSelector_b32[31])
	DataToGbtx_b80 = DataGbtxElinks_qb80;
      else
	DataToGbtx_b80 = MotorsData_b80;
   end
   assign DataToGbtx_ob80 = DataToGbtx_b80;
   // - channel0 TX - when VFC provides us with PageSelector_b32, this
   // mux casts the TX data to VFC:
   // MUX for page data:
   always_ff @(posedge ClkRxGBT_x.clk) begin
      case (PageSelector_b32[7:0])
	// loopback data
	0: MuxOut_b32 <= RegLoopback_b32;
	// build number
	1: MuxOut_b32 <= build_ob32;
	// PCB revision:
	2: MuxOut_b32 <= {28'b0, PCBrevision_o4};
	// PLL lock and other status:
	3: MuxOut_b32 <= {31'b0, ds18b20_pll_locked};
	// 4,5 = serial number:
	4: MuxOut_b32 <= UniqueID_oqb64[63:32];
	5: MuxOut_b32 <= UniqueID_oqb64[31:0];
	// scratchpad (temperature readout)
	6: MuxOut_b32 <= Scratchpad_oqb64[63:32];
	7: MuxOut_b32 <= Scratchpad_oqb64[31:0];
	// 16 to 31 are MOTORS statuses. This is somewhat redundant
	// info to 80 bits data stream returned back to VFC, but - why
	// not, does not cost anything here ....
	16: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[1]};
	17: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[2]};
	18: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[3]};
	19: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[4]};
	20: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[5]};
	21: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[6]};
	22: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[7]};
	23: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[8]};
	24: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[9]};
	25: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[10]};
	26: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[11]};
	27: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[12]};
	28: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[13]};
	29: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[14]};
	30: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[15]};
	31: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[16]};
	default:
	  MuxOut_b32 <= 32'hdeadbeef;
      endcase
   end // always_comb
   // - channel 0 return value is the same as 'pageselector', but with
   // lsb set to '1' to indicate 'GEFE present'
   // construct register with loopback - copy loopback setting from
   // VFC, and add '1' to identify that GEFE firmware is present.
   always_ff @(posedge ClkRxGBT_x.clk or posedge ClkRxGBT_x.reset) begin
      if (ClkRxGBT_x.reset) begin
	 // POR - indication that GEFE is present
	 RegLoopback_b32 <= 1;
      end else begin
	 if (VFCDataArrived)
	   RegLoopback_b32 <= {PageSelector_b32[31], 30'b0, 1'b1};
      end
   end
   // - data valid provided to VFC - this can be read through the VME
   // registers, and if the VFC-GEFE loop is correctly closed, '1' can
   // be read from VFC
   // TXdata valid: link loop closed _and_ no loopback mode. In
   // loopbackmode data are marked 'not valid'. This has no practical
   // meaning except that VFC exports this flag in VME space and we
   // can identify by reading through VME that 'gefe thinks that all
   // is OK'
   assign GbtxTxDataValid_o =  (SerialFeedback_b32 == GEFE_INTERLOCK
				&& !PageSelector_b32[31])? '1 : '0;


   ////////////////////////////////////////////////////////////////////////////////
   // LED diodes
   ////////////////////////////////////////////////////////////////////////////////

   logic forceOne_in;

   // LED DIODES ASSIGNMENT - logic low = diode emits light
   // 0 = POK, power OK
   assign Leds_onb6[0] = ~(V1p5PowerGood_i &
			   V2p5PowerGood_i &
			   V3p3PowerGood_i &
			   supplyOK_o);

   // 1 = DATA IN - turn on when VFC sends data
   assign Leds_onb6[1] = forceOne_in;
   // 2 = reset - turns on when reset happens due to optics
   assign Leds_onb6[2] = OptoLosReset_iran;
   // 3 = tx ready - transmit read turn on when correctly aligned
   assign Leds_onb6[3] = ~GbtxTxRdy_i;
   // 4 = loop closed - when VFC did all the configuration steps
   assign Leds_onb6[4] = ~GbtxTxDataValid_o;
   // 5 = rx ready
   assign Leds_onb6[5] = ~GbtxRxRdy_i;

   // to show 'rxdatavalid' requires more than this. First, this
   // signal is in 40MHz domain, we need to transport it into 25MHz
   // domain. Hence the pulse has to be extended by, let's say factor
   // of two. Then we pass it into Osc25MhzCg_ok domain by two 2ffs
   // and then we can use it in our MKO.
   logic RxDataValid1cc, RxDataValidExtended, RxDataValidOsc25MHz;

   always_ff @(posedge ClkRxGBT_x.clk) begin
      RxDataValid1cc <= RxDataValid;
      RxDataValidExtended <= RxDataValid | RxDataValid1cc;
   end

   logic DValidLed;
   assign DValidLed = GbtxTxRdy_i &
		      GbtxRxRdy_i &
		      RxDataValidExtended
		      & ~ClkRxGBT_x.reset;

   // generate rxdatavalid for led diode only when gbtx not in reset
   // condition. if in reset, diode should not be turned on
   manyff #(.g_Latency(3)) i_dvalidled
     (.ClkRs_ix(ClkRs_x),
      .d_i(DValidLed),
      .d_o(RxDataValidOsc25MHz));


   // mko will extend the rxdatavalid pulse and let's the LOS diode
   // blink with full intensity. Each rxdatavalid will generate 10ms
   // (this is not much, but theoretically these come quite often as
   // motors move)
   mko
     #(	       .g_CounterBits		(18))
   i_mko
     (
      // Outputs
      .q_o				(),
      .q_on				(forceOne_in),
      // Inputs
      .ClkRs_ix				(ClkRs_x),
      .enable_i ('1),
      .width_ib				(18'(250000)),
    .start_i				(RxDataValidOsc25MHz));

   build_number
     i_build_number
       (
	// Outputs
	.build_ob32			(build_ob32[31:0]));

   ////////////////////////////////////////////////////////////////////////////////
   // DISPLAY
   ////////////////////////////////////////////////////////////////////////////////
   // receiving swiches configuration (no matter what VFC displays, it
   // is only valid when loop is closed, othewise GEFE shall display
   // all the information 'as usually', but modulate with
   // blinking. Once closed loop is established, blinking goes off
   // indicating that system is correctly setup...
   rx_memory
     #(
       // Parameters
       .g_pages				(NUMBER_OF_MOTORS_PER_FIBER))
   i_rx_memory (
		.data_ob32		(SwitchesConfiguration_b32),
		.resync			(),
		.data_valid_o		(),
		.data_ib16		(ValidRXMemData_b16),
		.ClkRs_ix		(ClkRxGBT_x)
		/*AUTOINST*/);

   // re-cast the data to the original switches structure (so that if
   // it changes, the change propagates to both VFC and GEFE designs)
   genvar 	gi;
   for (gi = 0; gi < NUMBER_OF_MOTORS_PER_FIBER; gi++) begin : genbit
      assign SwitchesConfiguration_2b16[gi] =
					     SwitchesConfiguration_b32[gi];

   end

   // some info about switches configuration. Following assignment of
   // the signals below to ledData_b assigns extremity swiches led
   // diodes as well. Two types of extremity switches exists: normally
   // opened (NO), normally closed (NC) and their usage depends of
   // equipment. Hence if a particular switch is in one of the
   // configurations (not sure now which one :), we have to INVERT the
   // led diode signal such, that the LED is turned on (= emits light)
   // only when such switch is actuated. The information about whether
   // is NO/NC comes from VFC SwitchesConfig register stored in each
   // register block, and is transported through RX_MEMORY module here
   // into SwitchesConfiguration_2b16. We can USE this information to
   // cast both extremity diodes inversions. In addition this register
   // permits to configure which swiches actuate which position.

   logic blinker;

   // generate blinking signal. we use the same settings as in VFC
   // except that vfc runs 100MHz clock and we use 25MHz clock, hence
   // we need to divide data by 4. THESE CONSTANTS ARE DIFFERENT FOR
   // SIMULATION AND SYNTHESIS!. Generate three blinks
   led_blinker
     #(
       // Parameters
       // 1 second blinking period
       .g_totalPeriod			(GEFE_LED_BLINKER_PERIOD),
       .g_blinkOn			(GEFE_LED_BLINKER_ON_TIME),
       .g_blinkOff			(GEFE_LED_BLINKER_OFF_TIME))
   i_led_blinker (
		  // Outputs
		  .led_o		(blinker),
		  .period_o		(),
		  // Inputs
		  .ClkRs_ix		(ClkRs_x),
		  .forceOne_i		('0),
		  .amount_ib		(8'(3)));


   display_x display();
   // when all at one, leds should be turned on
   logic [3:0][1:0][15:0] ledData_b;

   // step signal extension to get orange color when motor moves
   logic [NUMBER_OF_MOTORS_PER_FIBER-1:0] stepout_diode;

   

   // let's assign diodes: column4 red is a fail signal from
   // motors. columns 1 and 3 in green are extremity switches
   genvar 		  motor;
   generate
      for(motor=0; motor<NUMBER_OF_MOTORS_PER_FIBER; motor++) begin : discast
	 // generate MKO for each stepout signal to cast to diode,
	 // react on falling edge as stepper does. this extends 5us
	 // pulse to 100ms
	 mko
		#(	       .g_CounterBits		(22))
	 i_mko_stepout
		(
		 // Outputs
		 .q_o				(),
		 .q_on				(stepout_diode[motor]),
		 // Inputs
		 .ClkRs_ix				(ClkRs_x),
		 .enable_i ('1),
		 .width_ib				(22'(4000000)),
		 .start_i				(!motorControl_ib[motor+1].StepOutP_o));
	 // each assigned motor has to decode the information for the
	 // diodes depending of switchesconfig
	 extremity_switches_mapper
	 i_extremity_switches_mapper (
				      // Outputs
				      .led_lg		(led_lg[motor]),
				      .led_lr		(led_lr[motor]),
				      .led_rg		(led_rg[motor]),
				      .led_rr		(led_rr[motor]),
				      // Inputs
				      .ClkRs_ix		(ClkRs_x),
				      .rawswitches	(debounced_motorStatus_b[motor+1].RawSwitches_b2),
				      .switchesconfig	(SwitchesConfiguration_2b16[motor]),
				      .blinker_i	(blinker));

	 // 4th column: if RED present, FAIL signal is emitted by
	 // driver. if GREEN present (i.e orange as well), BOOST is
	 // engaged:
	 // fail signal - any red on 4th column
	 assign ledData_b[3][0][motor] =
					debounced_motorStatus_b[motor+1].StepPFail_i;
	 // green connected to boost signal on 4th colum
	 assign ledData_b[3][1][motor] = motorControl_ib[motor+1].StepBOOST_o;
	 // extremity switches red diodes - columns 1 and 3:
	 assign ledData_b[0][0][motor] = led_lg[motor];
	 assign ledData_b[0][1][motor] = led_lr[motor];
	 assign ledData_b[2][0][motor] = led_rg[motor];
	 assign ledData_b[2][1][motor] = led_rr[motor];
	 // diode on column1 shows the functionality of the
	 // motor. Green one when motor enabled, red one when
	 // moves. Hence move produces orange color
	 assign ledData_b[1][0][motor] = !stepout_diode[motor];
	 assign ledData_b[1][1][motor] = !motorControl_ib[motor+1].StepDeactivate_o;
      end
   endgenerate

   // make it quite slower. This could go with twice faster, but no
   // need.
   tlc5920 #(.g_divider (4)) tlc_5920_i
     (
      // Interfaces
      .display				(display),
      // Inputs
      .ClkRs_ix				(ClkRs_x),
      .data_ib				(ledData_b/*[3:0][1:0][15:0]*/));

   // reset of drivers is in this case undefined as the backplane does
   // not support it. we can however toggle the diode of reset (nice
   // and shiny red) to asknowledge that we're alive
   logic mreset_i;

   pin_mapping
     i_pin_mapping_1
       (
	.test_ib8	({4'b0,
			  supplyOK_o,
			  V3p3PowerGood_i,
			  V2p5PowerGood_i,
			  V1p5PowerGood_i}),

	// Interfaces
	.display	(display),
	// Outputs
	.motorStatus_ob	(motorStatus_ob[NUMBER_OF_MOTORS_PER_FIBER:1]),
	.supplyOK_o	(supplyOK_o),
	.PCBrevision_o4 (PCBrevision_o4),
	// Inouts
	.FmcLa_iob34p	(FmcLa_iob34p[33:0]),
	.FmcLa_iob34n	(FmcLa_iob34n[33:0]),
	.FmcHb_iob22p	(FmcHb_iob22p[21:0]),
	.FmcHb_iob22n	(FmcHb_iob22n[21:0]),
	.FmcHa_iob24p	(FmcHa_iob24p[23:0]),
	.FmcHa_iob24n	(FmcHa_iob24n[23:0]),
	// Inputs
	.motorControl_ib(motorControl_ib[NUMBER_OF_MOTORS_PER_FIBER:1]),
	.mreset_i	(mreset_i));

   logic [$bits(motorStatus_ob)-1:0] metain, metaout;
   // use default typecast:
   assign metain = motorStatus_ob;
   assign debounced_motorStatus_b = metaout;

   // 1ms clock enable signal derived from ClkRs
   logic 			     ClkRs1ms_e;


   // get 1ms timing out of 25MHz (25000)
   clock_divider
     #(
       // Parameters
       .g_divider			(g_clock_divider))
   i_clock_divider
     (
      // Outputs
      .enable_o				(ClkRs1ms_e),
      // Inputs
      .ClkRs_ix				(ClkRs_x));

   // let's do 'alive mreset' it will slowly turn on/off using PWM we
   // can do it. Using 1ms clock should do the job. Nothing fancy,
   // implemented 'easiest' possible way, not restricting in period.
   logic [4:0] 			     amplitude_ib = '0;
   logic 			     cycleStart_o, increaseAmplitude;


   get_edge
   i_get_edge
     (
      // Outputs
      .rising_o				(increaseAmplitude),
      .falling_o			(),
      .data_o				(),
      // Inputs
      .ClkRs_ix				(ClkRs_x),
      .data_i				(cycleStart_o));

   always_ff @(posedge ClkRs_x.clk)
     if (increaseAmplitude)
       amplitude_ib <= amplitude_ib + 5'h1;

   // pwm uses 5 bits, meaning that each pwm cycle takes 32 enable
   // cycles, if enable is 1ms, then 1 cycle takes 32milliseconds. If
   // with each cycle we increase amplitude by 1 bin, the total
   // overflow happens in 32 * 32ms = 1024ms, so 1second.
   pwm
     #(
       // Parameters
       .g_CounterBits			(5))
   i_pwm
     (
      // Outputs
      .cycleStart_o			(cycleStart_o),
      .pwm_o				(),
      .pwm_on				(mreset_i),
      // Inputs
      .ClkRs_ix				(ClkRs_x),
      .amplitude_ib			(amplitude_ib),
      .forceOne_i			('0),
      .enable_i				(ClkRs1ms_e));


   // EACH INPUT SIGNAL CAN BE INDEPENDENTLY DEBOUNCED. This is
   // required to avoid metastability on switch and fail signals as
   // all of them cause instant stop of the motor movement.
   genvar ms;
   generate
      for (ms = 0; ms < $bits(metain); ms++)
	manyff #(.g_Latency(3)) i_manyff
			   (.ClkRs_ix(ClkRxGBT_x),
			    .d_i(metain[ms]),
			    .d_o(metaout[ms]));
   endgenerate

   // casting motor's data into 80bit stream
   // of input data from the motors drivers (fail/switches/oh)
   assign MotorsData_b80 = {metaout,
			    ($bits(MotorsData_b80)-$bits(metaout))'(0)};

   // assign stepper driver 1 output to be able to see the signals
   assign LemoGpioDir_o = '1;
   assign LemoGpioQg_iok = motorControl_ib[1].StepOutP_o;

   initial begin
      $display("motorStatus_ob pack size: ", $size(motorStatus_ob));
      $display("motorStatus_ob bits size: ", $bits(motorStatus_ob));
      $display("MotorsData_b80 bits size: ", $bits(MotorsData_b80));
   end

   // serial number handling - using 1MHz PLL generated from GBTX
   // clock, this avoid syncing
   ds18b20_dynpll
     i_ds18b20_pll (.POWERDOWN('1),
		    .CLKA(ClkRxGBT_x.clk),
		    .LOCK(ds18b20_pll_locked),
		    .GLA(ds18b20_pll_1MHz_clk));

   // onewire is hooked to FmcHa_iob24n[13]
   OneWire
   i_onewire (.Rst_irq(ClkRxGBT_x.reset),
	      .Clk_ik(ds18b20_pll_1MHz_clk),
	      .OneWireBus_io(FmcHa_iob24n[13]),
	      .*);



endmodule
