//-----------------------------------------------------------------------------
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor
// Boston, MA  02110-1301, USA.
//
// You can dowload a copy of the GNU General Public License here:
// http://www.gnu.org/licenses/gpl.txt
//
// Copyright (c) March 2018 CERN

//-----------------------------------------------------------------------------
// @file TB_GEFEAPPLICATION.SV
// @brief Top-level simulation for gefe application
// @author Dr. David Belohrad  <david@belohrad.ch>, CERN
// @date 14 March 2018
// @details
//
//
// @platform Altera Quartus
// @standard IEEE 1800-2012
//-----------------------------------------------------------------------------

`include "vunit_defines.svh"

import CKRSPkg::*;
import MCPkg::*;
import constants::*;


// Top-level simulation for mcoi base 
module mcoi_base_tb;
   timeunit 1ns;
   timeprecision 1ps;

   localparam integer clk_period = 20; // clock period in ns
   ckrs_t ClkRs_ix;


   wire 	      GbtxI2cScl_io;
   wire 	      GbtxI2cSda_io;
   wire 	      FmcClkBidir2Cq_iokn;
   wire 	      FmcClkBidir2Cq_iokp;
   wire 	      FmcClkBidir3Qg_iokn;
   wire 	      FmcClkBidir3Qg_iokp;
   wire [23:0] 	      FmcHa_iob24n;
   wire [23:0] 	      FmcHa_iob24p;
   wire [21:0] 	      FmcHb_iob22n;
   wire [21:0] 	      FmcHb_iob22p;
   wire [33:0] 	      FmcLa_iob34n;
   wire [33:0] 	      FmcLa_iob34p;
   wire [0:9] 	      FmcDpC2m_iob10n;
   wire [0:9] 	      FmcDpC2m_iob10p;
   wire [0:9] 	      FmcDpM2c_iob10n;
   wire [0:9] 	      FmcDpM2c_iob10p;
   wire 	      FmcScl_io;
   wire 	      FmcSda_io;
   wire 	      FmcTdi_i;
   wire 	      MmcxClkIoCg_iokn;
   wire 	      MmcxClkIoCg_iokp;
   wire [0:3] 	      MmcxGpIoQg_iokb4;
   wire 	      LemoGpioQg_iok;
   wire [12:0] 	      GpioConnA_iob13;
   wire [23:0] 	      GpioConnB_iob24;
   wire [12:0] 	      BoardIdConn_iob13;
   logic 	      Osc25MhzCg_ik = 0;
   logic 	      GbtxElinksDclkCg_ik = 0;

   integer 	      inject;

   localparam g_pages = NUMBER_OF_MOTORS_PER_FIBER;
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   logic [1:0]		DataToGbtxSc_ob2;	// From DUT of GefeApplication.v
   logic [79:0]		DataToGbtx_ob80;	// From DUT of GefeApplication.v
   logic		GbtxReset_or;		// From DUT of GefeApplication.v
   logic		GbtxTxDataValid_o;	// From DUT of GefeApplication.v
   logic [0:5]		Leds_onb6;		// From DUT of GefeApplication.v
   logic		LemoGpioDir_o;		// From DUT of GefeApplication.v
   logic [31:0]		build_ob32;		// From i_build_number of build_number.v
   mcoutput_t [NUMBER_OF_MOTORS_PER_FIBER:1] motorControl_ob;// From i_reverse_pin_mapping of reverse_pin_mapping.v
   logic		mreset_o;		// From i_reverse_pin_mapping of reverse_pin_mapping.v
   logic [7:0]		test_ob8;		// From i_reverse_pin_mapping of reverse_pin_mapping.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   logic [1:0]		DataFromGbtxSc_ib2;	// To DUT of GefeApplication.v
   logic [79:0]		DataFromGbtx_ib80;	// To DUT of GefeApplication.v
   logic		GbtxRxDataValid_i;	// To DUT of GefeApplication.v
   logic		GbtxRxRdy_i;		// To DUT of GefeApplication.v
   logic		GbtxTxRdy_i;		// To DUT of GefeApplication.v
   logic		GeneralReset_iran;	// To DUT of GefeApplication.v
   logic		OptoLosReset_iran;	// To DUT of GefeApplication.v
   logic		V1p5PowerGood_i;	// To DUT of GefeApplication.v
   logic		V2p5PowerGood_i;	// To DUT of GefeApplication.v
   logic		V3p3PowerGood_i;	// To DUT of GefeApplication.v
   mcinput_t [NUMBER_OF_MOTORS_PER_FIBER:1] motorStatus_ib;// To i_reverse_pin_mapping of reverse_pin_mapping.v
   logic		supplyOK_i;		// To i_reverse_pin_mapping of reverse_pin_mapping.v
   // End of automatics
   // divider set to only 25 to see how the pwm works. in real
   // application this is set to 25000 to get 1ms resolution on pwm
   // signals. We should get factor of 1000 in speed, hence entire
   // cycle should be done in 1ms
   localparam		g_clock_divider = 25;

   // frame grabber for led matrix driver (to checkout how switches
   // are connected to the LED matrix)
   logic [7:0][15:0] 	frames_b;
   logic [15:0] sample;

   logic 		SerialLinkUp_o, newdata_o;
   logic [31:0] 	RXGefe_b32, page_selector;
   int 			motor;
   logic [15:0] 	mask;
   logic [3:0] 		PCBrevision_i4;

   // declaration of TXdata

   logic [15:0] tx_data;
   logic 	resync;
   logic [31:0] data_ib32[15:0];
   switchstate_t [1:0] SwitchesConfiguration_2o16[NUMBER_OF_MOTORS_PER_FIBER-1:0];
   switchstate_t [1:0] Q_sw[$];

   integer 	i1, i2;

   always forever #(20ns) Osc25MhzCg_ik <= ~Osc25MhzCg_ik;
   always forever #(12.5ns) GbtxElinksDclkCg_ik <= ~GbtxElinksDclkCg_ik;
   default clocking cb @(posedge ClkRs_ix.clk); endclocking

   assign ClkRs_ix.clk = Osc25MhzCg_ik;
   assign ClkRs_ix.reset = ~GeneralReset_iran;

   ckrs_t ClkRxGBT_x;
   assign ClkRxGBT_x.clk = GbtxElinksDclkCg_ik;
   assign ClkRxGBT_x.reset = ~OptoLosReset_iran;


   // used from within fork to propagate data to switches
   // configuration through 16bit fastlink
   task propagate_switches_config();
      forever begin
	 @(posedge ClkRxGBT_x.clk);
	 DataFromGbtx_ib80[15:0] = tx_data;
      end
   endtask // propagate_switches_config

   task waitLink();
      fork
	 begin
	    // first serial link gets up
	    @(posedge SerialLinkUp_o);
	    // and then it sends POR copy of data, but sends it twice (once
	    // because of POR, once because data iface changed. This happens
	    // only when link gets up)
	    @(posedge newdata_o);
	    @(posedge newdata_o);
	    `CHECK_EQUAL(RXGefe_b32[0], 1,
			 "POR - GEFE target missing");
	 end // fork begin
	 #1ms;
      join_any
      `CHECK_EQUAL(RXGefe_b32[0], 1,
		   "POR - GEFE target missing");

      $display("Link ready");

   endtask

   // process which grabs data from the led matrix driver and captures
   // them into frames_b
   initial forever begin
      @(posedge display.blank_o);
      for(int i = 0; i < 16; i++) begin
	 @(posedge display.sclk_o);
	 sample = {sample[14:0], display.data_o};
      end
      @(posedge display.latch_o);
      frames_b[display.csel_ob3] = sample;
   end

   `TEST_SUITE begin

      `TEST_SUITE_SETUP begin
	 inject = 0;
	 GeneralReset_iran = 0;
	 OptoLosReset_iran = 0;
	 page_selector = 0;
	 DataFromGbtx_ib80 <= '0;
	 SwitchesConfiguration_2o16 = '{16{'0}};

	 #(2us);
	 ##1;

	 GeneralReset_iran = 1;
	 OptoLosReset_iran = 1;

	 @(posedge ClkRxGBT_x.clk);


      end

      `TEST_CASE("link_setup") begin
	 // test of loopback mode
	 waitLink();

      end

      `TEST_CASE("blinker_in_action") begin
	 // checks blinking rate - as it is setup it should generate 3
	 // pulses of length 1, separated by 2ccs AT 25MHZ CLOCK!
	 // sync to the very first blink:
	 repeat(100) begin
	    @(posedge DUT.blinker);
	    repeat(3) begin
	       repeat(GEFE_LED_BLINKER_ON_TIME) begin
		  @(posedge Osc25MhzCg_ik);
		  `CHECK_EQUAL(DUT.blinker, 1);
	       end
	       repeat(GEFE_LED_BLINKER_OFF_TIME) begin
		  @(posedge Osc25MhzCg_ik);
		  `CHECK_EQUAL(DUT.blinker, 0);
	       end
	    end
	    // empty space between periods must be larger than sum of
	    // on/off times to see that this is period start:
	    repeat(GEFE_LED_BLINKER_OFF_TIME +
	    	   GEFE_LED_BLINKER_ON_TIME) begin
	       @(posedge Osc25MhzCg_ik);
	       `CHECK_EQUAL(DUT.blinker, 0);
	    end
	 end // repeat (100)
      end // UNMATCHED !!

      `TEST_CASE("single_switch_config_test") begin
	 fork
	    // casts data to fastlink so switches info propagates:
	    propagate_switches_config();
	    begin
	       // randomly select two switches and configure them, then cast
	       // input signals into them and observe leds statuses
	       assert(std::randomize(i1) with {i1>=0; i1<16;});
	       assert(std::randomize(i2) with {i2>=0; i2<16;});
	       i1 = 0;
	       i2 = 1;

	       $display("Configuring switch %d to 101110", i1);
	       $display("Configuring switch %d to 010001", i2);
	       SwitchesConfiguration_2o16[i1] = 6'b101110;
	       SwitchesConfiguration_2o16[i2] = 6'b010001;
	       repeat(1000) @(posedge ClkRxGBT_x.clk);
	       // now check outputs for raw switches
	       inject = 1;
	       // the point with the switches: they have to be
	       // internally inverted because led diode emits light
	       // when output is at logic low. Hence if we don't turn
	       // on the inversion in the switches configuration,
	       // setting rawswitches to zero should turn on the led
	       // by setting the output to high. IF inversion is
	       // turned on the output data should be at zero. Motor
	       // status is indexed starting at 1, hence we add 1:
	       motorStatus_ib[i1+1].RawSwitches_b2 = '0;
	       motorStatus_ib[i2+1].RawSwitches_b2 = '0;
	       ##1000;
	       inject = 0;
	       // i1 switches config:
	       `CHECK_EQUAL(DUT.led_rr[i1], '0);
	       `CHECK_EQUAL(DUT.led_lr[i1], '0);
	       `CHECK_EQUAL(DUT.led_rg[i1], '1);
	       `CHECK_EQUAL(DUT.led_lg[i1], '1);
	       // i2 switches config:
	       `CHECK_EQUAL(DUT.led_rr[i2], '0);
	       `CHECK_EQUAL(DUT.led_lr[i2], '0);
	       `CHECK_EQUAL(DUT.led_rg[i2], '0);
	       `CHECK_EQUAL(DUT.led_lg[i2], '0);
	       // tweak raw switches:
	       motorStatus_ib[i1+1].RawSwitches_b2 = 2'b01;
	       motorStatus_ib[i2+1].RawSwitches_b2 = 2'b01;
	       ##1000;
	       `CHECK_EQUAL(DUT.led_rr[i1], '0);
	       `CHECK_EQUAL(DUT.led_lr[i1], '0);
	       `CHECK_EQUAL(DUT.led_rg[i1], '1);
	       `CHECK_EQUAL(DUT.led_lg[i1], '0);
	       // i2 switches config:
	       `CHECK_EQUAL(DUT.led_rr[i2], '0);
	       `CHECK_EQUAL(DUT.led_lr[i2], '0);
	       `CHECK_EQUAL(DUT.led_rg[i2], '1);
	       `CHECK_EQUAL(DUT.led_lg[i2], '0);
	       motorStatus_ib[i1+1].RawSwitches_b2 = 2'b10;
	       motorStatus_ib[i2+1].RawSwitches_b2 = 2'b10;
	       ##1000;
	       `CHECK_EQUAL(DUT.led_rr[i1], '0);
	       `CHECK_EQUAL(DUT.led_lr[i1], '0);
	       `CHECK_EQUAL(DUT.led_rg[i1], '0);
	       `CHECK_EQUAL(DUT.led_lg[i1], '1);
	       // i2 switches config:
	       `CHECK_EQUAL(DUT.led_rr[i2], '0);
	       `CHECK_EQUAL(DUT.led_lr[i2], '0);
	       `CHECK_EQUAL(DUT.led_rg[i2], '0);
	       `CHECK_EQUAL(DUT.led_lg[i2], '1);
	       motorStatus_ib[i1+1].RawSwitches_b2 = 2'b11;
	       motorStatus_ib[i2+1].RawSwitches_b2 = 2'b11;
	       ##1000;
	       `CHECK_EQUAL(DUT.led_rr[i1], '0);
	       `CHECK_EQUAL(DUT.led_lr[i1], '0);
	       `CHECK_EQUAL(DUT.led_rg[i1], '0);
	       `CHECK_EQUAL(DUT.led_lg[i1], '0);
	       // i2 switches config:
	       `CHECK_EQUAL(DUT.led_rr[i2], '0);
	       `CHECK_EQUAL(DUT.led_lr[i2], '0);
	       `CHECK_EQUAL(DUT.led_rg[i2], '1);
	       `CHECK_EQUAL(DUT.led_lg[i2], '1);
	    end
	 join_any
      end // UNMATCHED !!


      `TEST_CASE("switchesconfig_propagation_to_gefe") begin

	 // let propagate random numbers into stream
	 $display("Randomizing swiches configuration");

	 assert(std::randomize(SwitchesConfiguration_2o16));
	 fork
	    propagate_switches_config();
	    begin
	       // check if switches propagate correctly
	       repeat(1000) @(posedge ClkRxGBT_x.clk);
	       `CHECK_EQUAL(SwitchesConfiguration_2o16,
			    DUT.SwitchesConfiguration_2b16);
	    end
	 join_any
      end // UNMATCHED !!

      `TEST_CASE("led_matrix_fail_signal") begin
	 // checking if fail signal propagates to correct diode
	 // CHECK POR STATE:
	 $display("Waiting initial display frame loop");

	 @(posedge display.latch_o);
	 repeat(8) @(posedge display.latch_o);
	 `CHECK_EQUAL(frames_b, {16'h0, 16'h0, 16'h0, 16'hffff,
					16'hffff, 16'hffff, 16'h0,
				 16'hffff});
	 // rise _random_ fail signal and check if appropriate frame
	 // gets risen. we have to wait a bit more because there is
	 // debouncing on fail signal
	 assert(std::randomize(motor) with {motor > 0; motor <=
	    NUMBER_OF_MOTORS_PER_FIBER;});

	 $display("Checking if motor %d fail signal propagates to the\
 diodes array", motor);
	 mask = 2**(motor-1);
	 $display("Mask: 0x%.4x", mask);
	 // issue fail
	 motorStatus_ib[motor].StepPFail_i = '1;
	 // and wait for, say 10 frames. 8 to update complete cycle,
	 // and two to propagate fail. Note that fail signal is
	 // connected to column4 RED color diodes, this corresponds to
	 // column 6, hence all the changes have to be only to column
	 // 6.

	 repeat(10) @(posedge display.latch_o);
	 `CHECK_EQUAL(frames_b, {16'h0, mask, 16'h0, 16'hffff,
					16'hffff, 16'hffff, 16'h0,
				 16'hffff});


      end // repeat (8)

      `TEST_CASE("led_matrix_switch_connection") begin
	 // test whether appropriate switches trigger the led diodes.
	 // first we do nothing, and just grab frames and observe
	 // frames value. by default all switches are actuated so frame
	 // grabber should display just zero only in locations not
	 // dedicated to switches (column 1, 3 as columns 0 and 2 are
	 // dedicated to extremity switches)
	 // now we have to wait until all 8 csels propagate to frame
	 // let's wait for first latch, and then every 8th latch
	 // signal we might grab data
	 @(posedge display.latch_o);

	 repeat(8) @(posedge display.latch_o);
	 `CHECK_EQUAL(frames_b, {16'h0, 16'h0, 16'h0, 16'hffff,
					16'hffff, 16'hffff, 16'h0,
				 16'hffff});
	 // now let's check corner cases of switches. First switches
	 // for motor1:
	 ##1 motorStatus_ib[1].RawSwitches_b2[0] = '0;
	 repeat(8) @(posedge display.latch_o);
	 `CHECK_EQUAL(frames_b, {16'h0, 16'h0, 16'h0, 16'hfffe,
					16'hffff, 16'hffff, 16'h0,
				 16'hffff});
	 // other extremity of motor1
	 ##1 motorStatus_ib[1].RawSwitches_b2[1] = '0;
	 repeat(8) @(posedge display.latch_o);
	 `CHECK_EQUAL(frames_b, {16'h0, 16'h0, 16'hffff, 16'hfffe,
					16'hffff, 16'hffff, 16'hffff,
				 16'hfffe});
	 // motor 16, first [0] extremity, then [1]
	 ##1 motorStatus_ib[16].RawSwitches_b2[0] = '0;
	 repeat(8) @(posedge display.latch_o);
	 `CHECK_EQUAL(frames_b, {16'h0, 16'h0, 16'h0, 16'h7ffe,
					16'hffff, 16'hffff, 16'h0,
				 16'hfffe});
	 // other extremity of motor1
	 ##1 motorStatus_ib[16].RawSwitches_b2[1] = '0;
	 repeat(8) @(posedge display.latch_o);
	 `CHECK_EQUAL(frames_b, {16'h0, 16'h0, 16'hffff, 16'h7ffe,
					16'hffff, 16'hffff, 16'h0,
				 16'h7ffe});

      end // UNMATCHED !!

      `TEST_CASE("loopback_mode") begin
	 // test of loopback mode
	 waitLink();
	 // so these fancy data mean that all the motor switches are
	 // 'not actuated' (= they are at logic 'H'). The last 16bits
	 // is free and set to zero actually
	 `CHECK_EQUAL(DataToGbtx_ob80, 80'h33333333333333330000,
		      "LOOPBACK data fail");
	 // now let's write into DataFromGbtx_ib80 such that we can
	 // check that this is not loopback mode:
	 ##1;
	 DataFromGbtx_ib80 <= 80'h88227744882299883344;
	 GbtxRxDataValid_i <= '1;
	 ##1;
	 GbtxRxDataValid_i <= '0;

	 `CHECK_EQUAL(DataToGbtx_ob80, 80'h33333333333333330000,
		      "LOOPBACK data fail");
	 // turn on loopback mode - while checking again for build
	 // number. As well, with loopbackmode, system does not care
	 // about datavalid
	 ##1 page_selector = 32'h8000_0001;
	 #(200us);
	 `CHECK_EQUAL(DataToGbtx_ob80, 80'h88227744882299883344,
		      "LOOPBACK not working");
	 // one more check to see if data propagate within a clock cycle
	 DataFromGbtx_ib80 <= 80'h0123456789ABCDEFDEAD;
	 ##1;
	 `CHECK_EQUAL(DataToGbtx_ob80, 80'h88227744882299883344,
		      "LOOPBACK not working");
	 `CHECK_EQUAL(RXGefe_b32, build_ob32,
		      "Did not get back build number");
	 // turning off the link:
	 ##1 page_selector = 0;
	 #(200us);
	 `CHECK_EQUAL(DataToGbtx_ob80, 80'h33333333333333330000,
		      "LOOPBACK data fail");
      end

      `TEST_CASE("page_selector") begin
	 // after reset the page selector is at zero and should hence
	 // expose page0 of the register. This one is containing info
	 // about GEFE presence and loopback
	 waitLink();
	 // write new page selector
	 page_selector = 1;
	 fork
	    @(posedge newdata_o);
	    @(1ms);
	 join_any;
	 `CHECK_EQUAL(newdata_o, 1, "updated page did not come");
	 `CHECK_EQUAL(RXGefe_b32, build_ob32, "Build number does not\
 correspond");
	 // go back:
	 page_selector = 0;
	 fork
	    @(posedge newdata_o);
	    @(1ms);
	 join_any;
	 `CHECK_EQUAL(newdata_o, 1, "updated page did not come");
	 `CHECK_EQUAL(RXGefe_b32, 1, "GEFE not present");
      end

      `TEST_CASE("gefe_present") begin
	 // after reset the page selector is at zero and should hence
	 // expose page0 of the register. This one is containing info
	 // about GEFE presence and loopback
	 waitLink();
	 `CHECK_EQUAL(RXGefe_b32, 1, "GEFE not present");
      end

      `TEST_CASE("scec_link_up_and_running") begin
	 fork
	    waitLink();
	    #1ms;
	 join_any
	 `CHECK_EQUAL(SerialLinkUp_o, 1, "Serial link not up");
	 `CHECK_EQUAL(newdata_o, 1, "The channel was not updated");
      end // UNMATCHED !!

      `TEST_CASE("read_pcb_revision") begin
	 // setup link, write page register to read PCB revision and
	 // read the revision
	 fork
	    waitLink();
	    #1ms;
	 join_any
	 `CHECK_EQUAL(SerialLinkUp_o, 1, "Serial link not up");
	 `CHECK_EQUAL(newdata_o, 1, "The channel was not updated");
	 // write page:
	 page_selector = 2;
	 fork
	    @(posedge newdata_o);
	    @(1ms);
	 join_any;
	 `CHECK_EQUAL(newdata_o, 1, "updated page did not come");
	 `CHECK_EQUAL(RXGefe_b32, 'ha, "PCB revision readout not working");

      end

      `TEST_CASE("pwm_mreset_visual") begin
	 // just running the test to see visually. unused as abv as
	 // this functionality is not required!
	 #2ms;
      end // UNMATCHED !!

   end;

   // The watchdog macro is optional, but recommended. If present, it
   // must not be placed inside any initial or always-block.
   `WATCHDOG(100000ms);

   GefeApplication #(/*AUTOINSTPARAM*/
		     // Parameters
		     .g_clock_divider	(g_clock_divider)) DUT
     (.*);

   // this is here to decode what is sent over scec[0] link
   serial_register
   i_serial_register
     (
      // Outputs
      .data_ob32			(RXGefe_b32[31:0]),
      .Tx_o				(DataFromGbtxSc_ib2[0]),
      .SerialLinkUp_o			(SerialLinkUp_o),
      .RxLocked_o			(RxLocked_o),
      .TxBusy_o				(TxBusy_o),
      .newdata_o			(newdata_o),
      .TxEmptyFifo_o			(TxEmptyFifo_o),
      .txerror_o			(txerror_o),
      .rxlol_o				(rxlol_o),
      // Inputs
      .ClkRs_ix				(ClkRs_ix),
      .ClkRxGBT_ix			(ClkRxGBT_x),
      .ClkTxGBT_ix			(ClkRxGBT_x),
      .data_ib32			(page_selector),
      .resetflags_i			(1'b0),
      .Rx_i				(DataToGbtxSc_ob2[0]));

   build_number
     #(/*AUTOINSTPARAM*/)
   i_build_number
     (/*AUTOINST*/
      // Outputs
      .build_ob32			(build_ob32[31:0]));


   // display interface - dummy. we do not emulate this.
   display_x display();

   // connection of FMC mezzanine signals from GEFE to some
   // 'reasonable' structure, so we can format the motor control as we
   // want
   reverse_pin_mapping
     #(/*AUTOINSTPARAM*/)
   i_reverse_pin_mapping
     (/*AUTOINST*/
      // Interfaces
      .display				(display),
      // Outputs
      .motorControl_ob			(motorControl_ob[NUMBER_OF_MOTORS_PER_FIBER:1]),
      .mreset_o				(mreset_o),
      .test_ob8				(test_ob8[7:0]),
      // Inouts
      .FmcLa_iob34p			(FmcLa_iob34p[33:0]),
      .FmcLa_iob34n			(FmcLa_iob34n[33:0]),
      .FmcHb_iob22p			(FmcHb_iob22p[21:0]),
      .FmcHb_iob22n			(FmcHb_iob22n[21:0]),
      .FmcHa_iob24p			(FmcHa_iob24p[23:0]),
      .FmcHa_iob24n			(FmcHa_iob24n[23:0]),
      // Inputs
      .motorStatus_ib			(motorStatus_ib[NUMBER_OF_MOTORS_PER_FIBER:1]),
      .supplyOK_i			(supplyOK_i),
      .PCBrevision_i4			(PCBrevision_i4[3:0]));


   // initialization of motor control structures. This thing will
   // initialize all FMC pins for direction from motor to VFC.
   initial for(int i = 1; i <= NUMBER_OF_MOTORS_PER_FIBER; i++) begin
      motorStatus_ib[i].OH_i = '0;
      motorStatus_ib[i].StepPFail_i = '0;
      motorStatus_ib[i].RawSwitches_b2 = '1;
   end

   // assign PCB revision - to be read through paging
   assign PCBrevision_i4 = 4'ha;


   // generate TX iface such, that tx_data can be used in GBT stream
   // to pass switches configuration data
   genvar 	gi;
   generate
      for (gi = 0; gi < NUMBER_OF_MOTORS_PER_FIBER; gi++) begin : genassign
	 assign data_ib32[gi] = SwitchesConfiguration_2o16[gi];
      end
   endgenerate

   // generate fast switchconfig data
   tx_memory
     #(
       // Parameters
       .g_pages				(NUMBER_OF_MOTORS_PER_FIBER))
   i_tx_memory (
		// Outputs
		.data_ob16		(tx_data),
		.resync			(resync),
		// Inputs
		.ClkRs_ix		(ClkRxGBT_x),
		.data_ib32		(data_ib32/*[31:0].[g_pages-1:0]*/));


endmodule
