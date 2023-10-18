module GefeTop
  //========================================  I/O ports  =======================================\\
  (
       //==== Resets Scheme ====\\

       // General Reset:
       // Comment: See Microsemi application note AC380.
       inout 	      FpgaReset_ira,

       // Opto Loss Of Signal (LOS) reset:
       // Comment: This reset is asserted when there is not enough optical signal in the
       //          receiver of the optical transceiver (either VTRx or SFP+).
       input 	      OptoLosReset_iran,

       //==== GBTx ====\\

       // Clocks:
       // Comment: - GbtxElinksDclk[1] is the clock used by the GBTx I/O registers.
       //            GbtxElinksDclk[1] is connected to the "Chip global" (Cg) clock network.
       //            GbtxElinksDclk[0] & GbtxElinksDclk[2] are connected to "Quadrant global" (Qg) clock networks.
       //          - In GEFE, the SC Elink uses the same reference clock as the normal Elinks (GbtxElinksDclk[1]).
       //            GbtxElinksScClk is connected to the 1st "Quadrant global" (Qg) clock network.
       //          - Only GbtxClockDes[1] is connected to the "Chip global" (Cg) clock network.
       //            The other GbtxClockDes are connected to "Quadrant global" (Qg) clock networks.
       //            GbtxClockDes[4] goes directly to the FMC connector bypassing the ProAsic3 FPGA.
       input 	      GbtxElinksDclk_ikp,
       input 	      GbtxElinksDclk_ikn,
       //input 	      GbtxElinksScClk_ikp,
       //input 	      GbtxElinksScClk_ikn,
       //input [ 0: 3]  GbtxClockDes_ikb4p,
       //input [ 0: 3]  GbtxClockDes_ikb4n,

       // this pin is mapped to INPUT and HAS TO STAY IN HIGH IMPEDANCE mode
       // to select that GBT clock selection is taken by jumper on GEFE
       inout 	      GbtxClkSelection_i,

       // Elinks:
       // Comment: In GEFE, the GbtxElinksDio pins are only used as INPUTs.
       input [15: 0]  GbtxElinksDio_ib16p,
       input [15: 0]  GbtxElinksDio_ib16n,
       input [39:16]  GbtxElinksDout_ib24p,
       input [39:16]  GbtxElinksDout_ib24n,
       output [39: 0] GbtxElinksDin_ob40p,
       output [39: 0] GbtxElinksDin_ob40n,

       // Slow Control (SC) Elink:
       input 	      GbtxElinksScOut_ip,
       input 	      GbtxElinksScOut_in,
       output 	      GbtxElinksScIn_op,
       output 	      GbtxElinksScIn_on,

       // I2C:
       //inout 	      GbtxI2cSda_io,
       //inout 	      GbtxI2cScl_io,

       // Control:
       output 	      GbtxReset_or,
       input 	      GbtxRxDataValid_i,
       output 	      GbtxTxDataValid_o,
       input 	      GbtxRxRdy_i,
       input 	      GbtxTxRdy_i,

       //==== FMC connector ====\\

       // Clocks:
       //input [ 0: 1]  FmcClkM2c_ikb2p,
       //input [ 0: 1]  FmcClkM2c_ikb2n,
       //inout [ 2: 3]  FmcClkBidir_iokb2p,
       //inout [ 2: 3]  FmcClkBidir_iokb2n,
       //input [ 0: 1]  FmcGbtClkM2c_ikb2p,
       //input [ 0: 1]  FmcGbtClkM2c_ikb2n,

       // Comment: The LA, HA and DP pins are powered by Vadj, whilst the HB pins are powered
       //          by VioBM2c.

       // LA pins:
       // Comment: Please note that the following pins are Clock Capable (CC): 0, 1, 17, 18.
       inout [33: 0]  FmcLa_iob34p,
       inout [33: 0]  FmcLa_iob34n,

       // HA pins:
       // Comment: Please note that the following pins are Clock Capable (CC): 0, 1, 17, 18.
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

       //==== I2C ====\\

       //inout 	      FmcSda_io,
       //inout 	      FmcScl_io,

       //==== JTAG ====\\

       //output 	      FmcTck_o,
       //inout 	      FmcTdi_i,
       //output 	      FmcTdo_o,
       //output 	      FmcTms_o,
       //output 	      FmcTrstL_on,

       //==== Control ====\\

       //input 	      FmcClkDir_i,
       //input 	      FmcPowerGoodM2c_i,
       //output 	      FmcPowerGoodC2m_o,
       //input 	      FmcPrsntM2cL_in,

       //==== Miscellaneous ====\\

       // Crystal oscillator (25MHz):
       // Comment: Osc25Mhz is connected to the "Chip global" (Cg) clock network.
       input 	      Osc25Mhz_ik,

       // Clock feedback:
       // Comment: ClkFeedbackI is connected to the "Chip global" (Cg) clock network.
       //input 	      ClkFeedbackI_ikp,
       //input 	      ClkFeedbackI_ikn,
       //output 	      ClkFeedbackO_okp,
       //output 	      ClkFeedbackO_okn,

       // MMCX Clocks & GPIOs:
       // Comment: - MmcxClkIo is connected to the "Chip global" (Cg) clock network.
       //          - MmcxGpIo[3:0] are connected to different "Quadrant global" (Qg) clock networks.
       //inout 	      MmcxClkIo_iokp,
       //inout 	      MmcxClkIo_iokn,
       //inout [ 0: 3]  MmcxGpIo_iokb4,

       // LEMO GPIO:
       // Comment: LemoGpio is connected to the 4th "Quadrant global" (Qg) clock network.
       output 	      LemoGpioDir_o,
       inout 	      LemoGpio_iok,

       // GPIO connectors:
       //inout [12: 0]  GpioConnA_iob13,
       //inout [23: 0]  GpioConnB_iob24,

       // Board ID connector:
       //inout [12: 0]  BoardIdConn_iob13,

       // GEFE configuration ID:
       //input [ 9: 0]  GefeConfigId_ib10,

       // Push button:
       //input 	      PushButton_i,

       // DIP switch:
       //input [ 7: 0]  DipSwitch_ib8,

       // User LEDs:
       output [ 0: 5] Leds_onb6,

       // Electrical serial link:
       //input 	      ElectSerialLinkRx_i,
       //output 	      ElectSerialLinkTx_o,

       //==== Powering ====\\

       input 	      V1p5PowerGood_i,
       input 	      V2p5PowerGood_i,
       input 	      V3p3PowerGood_i
       //output 	      V3p3Inhibit_o
       //input 	      V3p3OverCurMon_i
       );

   //======================================  Declarations  ======================================\\

   //==== Wires & Regs ====\\

   // Resets scheme:
   wire 	      GeneralReset_ran;

   // GBTx:
   wire 	      GbtxElinksDclkCg_k;
   wire [79: 0]       DataFromGbtx_b80;
   wire [79: 0]       DataToGbtx_b80;
   wire [ 1: 0]       DataFromGbtxSc_b2;
   wire [ 1: 0]       DataToGbtxSc_b2;

   // Miscellaneous:
   wire 	      Osc25MhzCg_k;

   //=======================================  User Logic  =======================================\\

   // System module:
   GefeSystem i_GefeSystem (
			    // Resets scheme:
			    .FpgaReset_ira          (FpgaReset_ira),
			    // GBTx:
			    .GbtxElinksDclkCg_ikp   (GbtxElinksDclk_ikp),
			    .GbtxElinksDclkCg_ikn   (GbtxElinksDclk_ikn),
			    //---
			    .GbtxElinksDio_ib16p    (GbtxElinksDio_ib16p), // Comment: In GEFE, the GbtxElinksDio pins are only used as INPUTs.
			    .GbtxElinksDio_ib16n    (GbtxElinksDio_ib16n), //
			    .GbtxElinksDout_ib24p   (GbtxElinksDout_ib24p),
			    .GbtxElinksDout_ib24n   (GbtxElinksDout_ib24n),
			    .GbtxElinksDin_ob40p    (GbtxElinksDin_ob40p),
			    .GbtxElinksDin_ob40n    (GbtxElinksDin_ob40n),
			    //---
			    .GbtxElinksScOut_ip     (GbtxElinksScOut_ip),
			    .GbtxElinksScOut_in     (GbtxElinksScOut_in),
			    .GbtxElinksScIn_op      (GbtxElinksScIn_op),
			    .GbtxElinksScIn_on      (GbtxElinksScIn_on),
			    // Miscellaneous:
			    .Osc25Mhz_ik            (Osc25Mhz_ik),
			    // User module interface:
			    .GeneralReset_oran      (GeneralReset_ran),
			    //--
			    .GbtxElinksDclkCg_ok    (GbtxElinksDclkCg_k),
			    //--
			    .DataFromGbtx_ob80      (DataFromGbtx_b80),
			    .DataToGbtx_ib80        (DataToGbtx_b80),
			    .DataFromGbtxSc_ob2     (DataFromGbtxSc_b2),
			    .DataToGbtxSc_ib2       (DataToGbtxSc_b2),
			    //--
			    .Osc25MhzCg_ok          (Osc25MhzCg_k));

   // Application Module:
   GefeApplication i_GefeApplication (
					  // Resets scheme:
					  .OptoLosReset_iran      (OptoLosReset_iran),
					  // GBTx:
					  //.GbtxI2cSda_io          (GbtxI2cSda_io),
					  //.GbtxI2cScl_io          (GbtxI2cScl_io),
					  //--
					  .GbtxReset_or           (GbtxReset_or),
					  .GbtxRxDataValid_i      (GbtxRxDataValid_i),
					  .GbtxTxDataValid_o      (GbtxTxDataValid_o),
					  .GbtxRxRdy_i            (GbtxRxRdy_i),
					  .GbtxTxRdy_i            (GbtxTxRdy_i),
					  //
					  //.GbtxElinksDclkQg_ikb2p ({GbtxElinksDclk_ikb3p[0], GbtxElinksDclk_ikb3p[2]}),
					  //.GbtxElinksDclkQg_ikb2n ({GbtxElinksDclk_ikb3n[0], GbtxElinksDclk_ikb3n[2]}),
					  //.GbtxElinksScClkQg_ikp  (GbtxElinksScClk_ikp),
					  //.GbtxElinksScClkQg_ikn  (GbtxElinksScClk_ikn),
					  //.GbtxClockDesCg_ikp     (GbtxClockDes_ikb4p[1]),
					  //.GbtxClockDesCg_ikn     (GbtxClockDes_ikb4n[1]),
					  //.GbtxClockDesQg_ikb3p   ({GbtxClockDes_ikb4p[0], GbtxClockDes_ikb4p[2], GbtxClockDes_ikb4p[3]}),
					  //.GbtxClockDesQg_ikb3n   ({GbtxClockDes_ikb4n[0], GbtxClockDes_ikb4n[2], GbtxClockDes_ikb4n[3]}),
					  // FMC connector:
					  //.FmcClkM2c0Cg_ikp       (FmcClkM2c_ikb2p   [0]),
					  //.FmcClkM2c0Cg_ikn       (FmcClkM2c_ikb2n   [0]),
					  //.FmcClkM2c1Qg_ikp       (FmcClkM2c_ikb2p   [1]),
					  //.FmcClkM2c1Qg_ikn       (FmcClkM2c_ikb2n   [1]),
					  //.FmcClkBidir2Cq_iokp    (FmcClkBidir_iokb2p[2]),
					  //.FmcClkBidir2Cq_iokn    (FmcClkBidir_iokb2n[2]),
					  //.FmcClkBidir3Qg_iokp    (FmcClkBidir_iokb2p[3]),
					  //.FmcClkBidir3Qg_iokn    (FmcClkBidir_iokb2n[3]),
					  //.FmcGbtClkM2c0Qg_ikp    (FmcGbtClkM2c_ikb2p[0]),
					  //.FmcGbtClkM2c0Qg_ikn    (FmcGbtClkM2c_ikb2n[0]),
					  //.FmcGbtClkM2c1Qg_ikp    (FmcGbtClkM2c_ikb2p[1]),
					  //.FmcGbtClkM2c1Qg_ikn    (FmcGbtClkM2c_ikb2n[1]),
					  //--
					  .FmcLa_iob34p           (FmcLa_iob34p),
					  .FmcLa_iob34n           (FmcLa_iob34n),
					  //--
					  .FmcHa_iob24p           (FmcHa_iob24p),
					  .FmcHa_iob24n           (FmcHa_iob24n),
					  //--
					  .FmcHb_iob22p           (FmcHb_iob22p),
					  .FmcHb_iob22n           (FmcHb_iob22n),
					  //--
					  //.FmcDpM2c_iob10p        (FmcDpM2c_iob10p),
					  //.FmcDpM2c_iob10n        (FmcDpM2c_iob10n),
					  //.FmcDpC2m_iob10p        (FmcDpC2m_iob10p),
					  //.FmcDpC2m_iob10n        (FmcDpC2m_iob10n),
					  //--
					  //.FmcSda_io              (FmcSda_io),
					  //.FmcScl_io              (FmcScl_io),
					  //--
					  //.FmcTck_o               (FmcTck_o),
					  //.FmcTdi_i               (FmcTdi_i),
					  //.FmcTdo_o               (FmcTdo_o),
					  //.FmcTms_o               (FmcTms_o),
					  //.FmcTrstL_on            (FmcTrstL_on),
					  //--
					  //.FmcClkDir_i            (FmcClkDir_i),
					  //.FmcPowerGoodM2c_i      (FmcPowerGoodM2c_i),
					  //.FmcPowerGoodC2m_o      (FmcPowerGoodC2m_o),
					  //.FmcPrsntM2cL_in        (FmcPrsntM2cL_in),
					  // Miscellaneous:
					  //.ClkFeedbackI_ikp       (ClkFeedbackI_ikp),
					  //.ClkFeedbackI_ikn       (ClkFeedbackI_ikn),
					  //.ClkFeedbackO_okp       (ClkFeedbackO_okp),
					  //.ClkFeedbackO_okn       (ClkFeedbackO_okn),
					  //--
					  //.MmcxClkIoCg_iokp       (MmcxClkIo_iokp),
					  //.MmcxClkIoCg_iokn       (MmcxClkIo_iokn),
					  //.MmcxGpIoQg_iokb4       (MmcxGpIo_iokb4),
					  //--
					  .LemoGpioDir_o          (LemoGpioDir_o),
					  .LemoGpioQg_iok         (LemoGpio_iok),
					  //--
					  //.PushButton_i           (PushButton_i),
					  //--
					  //.DipSwitch_ib8          (DipSwitch_ib8),
					  //--
					  .Leds_onb6              (Leds_onb6),
					  //--
					  //.GpioConnA_iob13        (GpioConnA_iob13),
					  //.GpioConnB_iob24        (GpioConnB_iob24),
					  //--
					  //.BoardIdConn_iob13      (BoardIdConn_iob13),
					  //--
					  //.GefeConfigId_ib10      (GefeConfigId_ib10),
					  //--
					  //.ElectSerialLinkRx_i    (ElectSerialLinkRx_i),
					  //.ElectSerialLinkTx_o    (ElectSerialLinkTx_o),
					  // Powering:
					  .V1p5PowerGood_i        (V1p5PowerGood_i),
					  .V2p5PowerGood_i        (V2p5PowerGood_i),
					  .V3p3PowerGood_i        (V3p3PowerGood_i),
					  //.V3p3Inhibit_o          (V3p3Inhibit_o),
					  //.V3p3OverCurMon_i       (V3p3OverCurMon_i),
					  // System module interface:
					  .GeneralReset_iran      (GeneralReset_ran),
					  //--
					  .GbtxElinksDclkCg_ik    (GbtxElinksDclkCg_k),
					  //--
					  .DataFromGbtx_ib80      (DataFromGbtx_b80),
					  .DataToGbtx_ob80        (DataToGbtx_b80),
					  .DataFromGbtxSc_ib2     (DataFromGbtxSc_b2),
					  .DataToGbtxSc_ob2       (DataToGbtxSc_b2),
					  //--
					  .Osc25MhzCg_ik          (Osc25MhzCg_k));

   assign GbtxClkSelection_i = 1'b1;

endmodule
