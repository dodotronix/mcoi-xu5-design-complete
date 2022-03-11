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
// Copyright (c) February 2022 CERN

//-----------------------------------------------------------------------------
// @file TB_MCOIXU5SYSTEM.SV
// @brief
// @author Dr. David Belohrad  <david@belohrad.ch>, CERN
// @date 23 February 2022
// @details
//
//
// @platform Altera Quartus
// @standard IEEE 1800-2012
//-----------------------------------------------------------------------------

`include "vunit_defines.svh"

import CKRSPkg::*;
import clsclk::*;
import clsi2c::*;
import MCPkg::*;



//
module tb_McoiXu5System;
   timeunit 1ns;
   timeprecision 100ps;

   logic [1:0] 	      locked_b2, busy_b2;


   /*AUTOWIRE*/
   /*AUTOREGINPUT*/
   /*AUTOINOUTPARAM("McoiXu5System")*/

   t_diag diag_x();
   t_display display_x();

   t_clocks clk_tree_x();
   clock_generator clkg;

   t_gbt gbt_x();
   // GBT data stream runs in frame clock
   t_gbt_data gbt_data_x(.ClkRs_ix(clk_tree_x.ClkRs40MHzMGMT_ix));

   // connects to motor pins
   t_motors motors_x();

   logic [2:0][1:16]  rnd_b16x3;


   // I2c interface emulates start/stop bits
   t_i2c i2c_x();
   i2c_driver i2cg;
   pullup (i2c_x.sda);
   pullup (i2c_x.scl);

   logic [63:0]       rnd_b64;


   // CH1 is SERIAL FEEDBACK - what is sent is returned
   // CH0 is MEMORY IFACE
   logic [1:0][31:0]  SerialDataToSend_b32x2;
   logic [1:0][31:0]  SerialDataReceived_b32x2;

   task writeChannel(int channel, logic [31:0] data);
      while (busy_b2[channel]) ##1;
      SerialDataToSend_b32x2[channel] = data;
      #500us;
   endtask // writeChannel

   task writeSerialLoopback(logic [31:0] data);
      writeChannel(1, data);
   endtask // writeSerialLoopback

   task writeSerialMemory(logic [31:0] data);
      writeChannel(0, data);
   endtask // writeSerialMemory


   task checkChannel(int channel, logic [31:0] data);
      `CHECK_EQUAL(SerialDataReceived_b32x2[channel], data);
   endtask // checkChannel

   mcinput_t [NUMBER_OF_MOTORS_PER_FIBER:1] motorsStatus;

   assign motorsStatus = gbt_data_x.data_sent.motor_data_b64;


   localparam g_Address = 7'h70;
   default clocking cb @(posedge gbt_data_x.ClkRs_ix.clk); endclocking

   `TEST_SUITE begin

      `TEST_SUITE_SETUP begin
	 // these are static:
	 gbt_x.sfp1_los = '0;
	 gbt_x.sfp1_txdisable = '0;
	 gbt_x.sfp1_rateselect = '1;
	 // init motors
	 motors_x.pl_pfail = '0;
	 motors_x.pl_sw_outa = '0;
	 motors_x.pl_sw_outb = '0;
	 // GBT data to send:
	 SerialDataToSend_b32x2 = '0;

	 // classes:
	 clkg = new;
	 clkg.clk_tree_x = clk_tree_x;
	 clkg.run();
	 i2cg = new (100e3, 7'h70, "PLL I2C");
	 i2cg.i2c_x = i2c_x;
	 i2cg.run();

	 // wait for SCEC ready
	 do ##1;
	 while (~&locked_b2);

      end



      `TEST_CASE("debug_test") begin
	 // propagate motor status signals from outside to GBT iface


	 // random direct motors signals shall propagate directly into
	 // output
	 repeat(500) begin
	    assert(std::randomize(rnd_b16x3));
	    motors_x.pl_pfail = rnd_b16x3[0];
	    motors_x.pl_sw_outa = rnd_b16x3[1];
	    motors_x.pl_sw_outb = rnd_b16x3[2];

	    ##10;
	    for(int motor=1; motor <= NUMBER_OF_MOTORS_PER_FIBER;
		motor++) begin
	       `CHECK_EQUAL(motorsStatus[motor].OH_i, '0);
	       `CHECK_EQUAL(motorsStatus[motor].StepPFail_i, rnd_b16x3[0][motor]);
	       `CHECK_EQUAL(motorsStatus[motor].RawSwitches_b2[0], rnd_b16x3[1][motor]);
	       `CHECK_EQUAL(motorsStatus[motor].RawSwitches_b2[1], rnd_b16x3[2][motor]);
	    end
	 end // repeat (500)





      end // UNMATCHED !!


      `TEST_CASE("loopback_not_closed_no_signal_at_motors") begin
	 // loopback is not established - no data casted to motors

	 fork
	    repeat(500) begin
	       ##1;
	       assert(std::randomize(rnd_b64));
	       gbt_data_x.data_received.motor_data_b64 = rnd_b64;
	    end
	    forever begin
	       for(int motor=1; motor <= NUMBER_OF_MOTORS_PER_FIBER;
		   motor++) begin
		  `CHECK_EQUAL (motors_x.pl_boost[motor], '0);
		  `CHECK_EQUAL (motors_x.pl_dir[motor], '0);
		  `CHECK_EQUAL (motors_x.pl_en[motor], '0);
		  `CHECK_EQUAL (motors_x.pl_clk[motor], '0);
	       end
	       ##1;
	    end
	 join_any
      end // UNMATCHED !!


      `TEST_CASE("motors_bits_loopback") begin
	 // loopback copy of all motor and mem signals from 80-bit
	 // iface (excluded ic/sc links because these are needed to
	 // setup the loop)
	 writeSerialLoopback(32'h80000000);
	 checkChannel(1, 32'h80000000);


	 // the same with other channel - channel0 is page selector
	 // into the memory-like iface
	 // build number:
	 `CHECK_EQUAL(SerialDataReceived_b32x2[0], 32'h1);
	 writeSerialMemory(32'h80000000);
	 `CHECK_EQUAL(SerialDataReceived_b32x2[0], 32'h80000001);
	 // now we have turned on the motors GBT loopback. This
	 // concerns 80-bit directly casted to the motors, we can
	 // randomize the data being sent and they have to come back
	 // with cc delay

	 repeat(500) begin
	    assert(std::randomize(rnd_b64))
	    gbt_data_x.data_received.motor_data_b64 = rnd_b64;
	    ##1;
	    `CHECK_EQUAL(gbt_data_x.data_sent.motor_data_b64, gbt_data_x.data_received.motor_data_b64);
	 end

      end

      `TEST_CASE("sc_channels_data_propagation") begin
	 // loop link data propagation
	 writeChannel(1, 32'haabbccdd);
	 checkChannel(1, 32'haabbccdd);

	 // the same with other channel - channel0 is page selector
	 // into the memory-like iface
	 // build number:
	 writeChannel(0, 32'h1);
	 checkChannel(0, 32'haabbccdd);
      end

   end;

   // The watchdog macro is optional, but recommended. If present, it
   // must not be placed inside any initial or always-block.
   `WATCHDOG(200ms);

   McoiXu5System #(/*AUTOINSTPARAM*/) DUT
     (.*);


   // serial registers which do 'counterpart' of those in the
   // system. They use the same frame clocking
   genvar register;
   generate
      for (register=0; register<2; register++) begin
	 serial_register i_serial_register_feedback_ch1
		    (// Outputs
		     .data_ob32(SerialDataReceived_b32x2[register]),
		     .Tx_o(gbt_data_x.data_received.sc_data_b2[register]),
		     .SerialLinkUp_o(),
		     .RxLocked_o(locked_b2[register]),
		     .TxBusy_o(busy_b2[register]),
		     .newdata_o(),
		     .TxEmptyFifo_o(),
		     .txerror_o(),
		     .rxlol_o(),

		     // Inputs
		     .ClkRs_ix(gbt_data_x.ClkRs_ix),
		     .ClkRxGBT_ix(gbt_data_x.ClkRs_ix),
		     .ClkTxGBT_ix(gbt_data_x.ClkRs_ix),
		     .data_ib32(SerialDataToSend_b32x2[register]),
		     .resetflags_i(1'b0),
		     .Rx_i(gbt_data_x.data_sent.sc_data_b2[register]));
      end

   endgenerate
endmodule
