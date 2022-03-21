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
// @file MCOIXU5SYSTEM.SV
// @brief
// @author Petr Pacner  <petr.pacner@cern.ch>, CERN
// @date 20 February 2022
// @details
//
//
// @platform Altera Quartus
// @standard IEEE 1800-2012
//-----------------------------------------------------------------------------

import MCPkg::*;
import CKRSPkg::*;
import constants::*;
import types::*;

// NOTE: original GEFE design uses GBT frame clock of 40MHz and local
// oscillator of 25MHz. These are here mimicked by using 40MHz from
// MGT PLL clocks and 25MHz going from LOCAL OSCILLATOR 100MHz passing
// through PLL clock (ClkRs40MHz_ix in clock tree). This is because
// MGT pll might not work when not programmed while local oscillator
// works every time

module McoiXu5System (t_diag.producer diag_x,
                      //clocks
		      t_clocks.consumer clk_tree_x,
                      t_display.producer display_x,
                      input logic gbt_los,
		      t_gbt_data.consumer gbt_data_x,
		      t_motors_structured.consumer motors_structured_x,
                      //input ps_clk,
                      //serial
		      t_i2c i2c_x
                      //input rs485_pl_di,
                      //output rs485_pl_ro
		      );


   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   logic		done;			// From i_McoiXu5Diagnostics of McoiXu5Diagnostics.v
   // End of automatics
   /*AUTOREGINPUT*/

   logic 		SFP_reset;
   logic [31:0] 	SwitchesConfiguration_b32 [NUMBER_OF_MOTORS_PER_FIBER-1:0];
   switchstate_t [1:0] SwitchesConfiguration_2b16 [NUMBER_OF_MOTORS_PER_FIBER-1:0];
   // led arrays from switches decoding
   logic [NUMBER_OF_MOTORS_PER_FIBER-1:0] led_lg,led_lr,led_rg,led_rr;
   // step signal extension to get orange color when motor moves
   logic [NUMBER_OF_MOTORS_PER_FIBER-1:0] stepout_diode;
   logic [1:0] 				  VFCDataArrived_b2;
   logic [31:0] 			  build_ob32, RegLoopback_b32;
   logic [3:0][1:0][15:0] ledData_b; //4 rows, 2states, 16 columns
   logic [1:0][31:0]  SerialDataToSend_b32x2;
   logic [1:0][31:0]  SerialDataReceived_b32x2;
   logic StreamTxDataValid;
   logic [1:0] locked_b2;



   // SFP LOS is connected to reset of the module
   vme_reset_sync_and_filter u_SFP_reset_sync
     (.rst_ir   (1'b0),
      .clk_ik   (gbt_data_x.ClkRs_ix.clk),
      .cen_ie   (1'b1),
      .data_i   (~gbt_los),
      .data_o   (SFP_reset)
      );

   // interfacing motors by casting directly the 80-bit data from
   // motor, but blanking when LOS not to cast wrong data:
   t_sfp_stream DataGbt;
   always_ff @(posedge gbt_data_x.ClkRs_ix.clk or
	       posedge gbt_data_x.ClkRs_ix.reset)
     if (gbt_data_x.ClkRs_ix.reset)
       //@TODO: check sc/ic default bits:
       DataGbt <= '0;
     else begin
	if (SFP_reset || ~StreamTxDataValid)
	  DataGbt <= '0;
	else
	  DataGbt <= gbt_data_x.data_received;
     end

   // motor controller only if loopback
   always_ff @(posedge gbt_data_x.ClkRs_ix.clk)
     if (SerialDataReceived_b32x2[1] == GEFE_INTERLOCK)
       motors_structured_x.motorsControls = DataGbt.motor_data_b64;
     else
       motors_structured_x.motorsControls = '0;

   // use default typecast:
   motorsStatuses_t [2:0] debouncing_status;
   motorsStatuses_t debounced_motorStatus_b;


   assert property (@(posedge gbt_data_x.ClkRs_ix.clk)
		    disable iff (gbt_data_x.ClkRs_ix.reset)
		    (SFP_reset ||
		     SerialDataReceived_b32x2[1] != GEFE_INTERLOCK) |=> ##[1:2]
		    ~|motors_structured_x.motorsControls) else $error ("SFP LOS\
 shall turn off data to motor");

   always_ff @(posedge gbt_data_x.ClkRs_ix.clk)
     debouncing_status <= {debouncing_status[1:0],
			   motors_structured_x.motorsStatuses};
   assign debounced_motorStatus_b = debouncing_status[2];


   // memory storing switches configuration for the display (otherwise
   // we would not be show on LED display unconfigured stream
   rx_memory #(
	       .g_pages(NUMBER_OF_MOTORS_PER_FIBER))
   i_rx_memory(
	       .data_ob32(SwitchesConfiguration_b32),
	       .resync(),
	       .data_valid_o(),
	       .data_ib16(DataGbt.mem_data_b16),
	       .ClkRs_ix(gbt_data_x.ClkRs_ix));

   logic blinker;
   led_blinker#(
		.g_totalPeriod(GEFE_LED_BLINKER_PERIOD), //1s period
		.g_blinkOn(GEFE_LED_BLINKER_ON_TIME),
		.g_blinkOff(GEFE_LED_BLINKER_OFF_TIME))
   i_led_blinker(
		 .led_o(blinker),
		 .period_o(),
		 .ClkRs_ix(clk_tree_x.ClkRs100MHz_ix),
		 .forceOne_i('0),
		 .amount_ib(8'(3)));


   genvar motor;
   generate
      for(motor=0; motor<NUMBER_OF_MOTORS_PER_FIBER; motor++) begin : discast

	 assign SwitchesConfiguration_2b16[motor] = SwitchesConfiguration_b32[motor];
	 // each assigned motor has to decode the information for the
	 // diodes depending of switchesconfig
	 extremity_switches_mapper
	   i_extremity_switches_mapper(
				       .led_lg(led_lg[motor]),
				       .led_lr(led_lr[motor]),
				       .led_rg(led_rg[motor]),
				       .led_rr(led_rr[motor]),
				       // Inputs
				       // 25MHz!
				       .ClkRs_ix(clk_tree_x.ClkRs100MHz_ix),
				       .rawswitches(debounced_motorStatus_b[motor+1].RawSwitches_b2),
				       .switchesconfig(SwitchesConfiguration_2b16[motor]),
				       .blinker_i(blinker));

	 // 4th column: if RED present, FAIL signal is emitted by
	 // driver. if GREEN present (i.e orange as well), BOOST is
	 // engaged:
	 // fail signal - any red on 4th column
	 assign ledData_b[3][0][motor] =
					debounced_motorStatus_b[motor+1].StepPFail_i;
	 // green connected to boost signal on 4th colum
	 assign ledData_b[3][1][motor] = motors_structured_x.motorsControls[motor+1].StepBOOST_o;
	 // extremity switches red diodes - columns 1 and 3:
	 assign ledData_b[0][0][motor] = led_lg[motor];
	 assign ledData_b[0][1][motor] = led_lr[motor];
	 assign ledData_b[2][0][motor] = led_rg[motor];
	 assign ledData_b[2][1][motor] = led_rr[motor];
	 // diode on column1 shows the functionality of the
	 // motor. Green one when motor enabled, red one when
	 // moves. Hence move produces orange color
	 assign ledData_b[1][0][motor] = !stepout_diode[motor];
	 assign ledData_b[1][1][motor] = !motors_structured_x.motorsControls[motor+1].StepDeactivate_o;

	 // generate MKO for each stepout signal to cast to diode,
	 // react on falling edge as stepper does. this extends 5us
	 // pulse to 100ms
	 mko#(
	      .g_CounterBits(22))
	 i_mko_stepout(
		       .q_o(),
		       .q_on(stepout_diode[motor]),
		       // 25MHz !
		       .ClkRs_ix(clk_tree_x.ClkRs100MHz_ix),
		       .enable_i('1),
		       .width_ib(22'(4000000)),
		       .start_i(!motors_structured_x.motorsControls[motor+1].StepOutP_o));

      end // block: discast
   endgenerate


   assign StreamTxDataValid = (SerialDataReceived_b32x2[1] == GEFE_INTERLOCK
                               && !SerialDataReceived_b32x2[0][31])? '1 : '0;


// drive leds on front panel
   assign diag_x.led[0] = ~done;
   assign diag_x.led[1] = ~SFP_reset; //los of signal
   assign diag_x.led[2] = ~&locked_b2; // RX/TX serial channels locked
   assign diag_x.led[3] = 1'b1;
   assign diag_x.led[4] = ~StreamTxDataValid;
   assign diag_x.led[5] = 1'b1;


   // bar led-diode driver, 10MHz clock
   tlc5920 #(.g_divider (9))
   tlc_5920_i(.ClkRs_ix(clk_tree_x.ClkRs100MHz_ix),
   	      .*);

   // PLL 120MHz MGT programmer
   localparam address = 7'b1110000;
   localparam i2c_divider = 500;
   McoiXu5Diagnostics
     #(.address(address),
     .i2c_divider(i2c_divider))
   i_McoiXu5Diagnostics (.ClkRs_ix(clk_tree_x.ClkRs100MHz_ix),
			 .*);

   genvar 	      register;
   generate
      for (register=0; register < 2; register++) begin : funk
	 serial_register i_serial_register_feedback
		    (// Outputs
		     .data_ob32(SerialDataReceived_b32x2[register]),
		     .Tx_o(gbt_data_x.data_sent.sc_data_b2[register]),
		     .SerialLinkUp_o(),
		     .RxLocked_o(locked_b2[register]),
		     .TxBusy_o(),
		     .newdata_o(VFCDataArrived_b2[register]),
		     .TxEmptyFifo_o(),
		     .txerror_o(),
		     .rxlol_o(),

		     // Inputs
		     .ClkRs_ix(gbt_data_x.ClkRs_ix),
		     .ClkRxGBT_ix(gbt_data_x.ClkRs_ix),
		     .ClkTxGBT_ix(gbt_data_x.ClkRs_ix),
		     .data_ib32(SerialDataToSend_b32x2[register]),
		     .resetflags_i(1'b0),
		     .Rx_i(gbt_data_x.data_received.sc_data_b2[register]));
      end

   endgenerate

   // serial loopback
   always_ff @(posedge gbt_data_x.ClkRs_ix.clk) begin
      SerialDataToSend_b32x2[1] <= SerialDataReceived_b32x2[1];
   end

   // - channel 0 return value is the same as 'pageselector', but with
   // lsb set to '1' to indicate 'GEFE present'
   // construct register with loopback - copy loopback setting from
   // VFC, and add '1' to identify that GEFE firmware is present.
   always_ff @(posedge gbt_data_x.ClkRs_ix.clk or posedge gbt_data_x.ClkRs_ix.reset) begin
      if (gbt_data_x.ClkRs_ix.reset)
	RegLoopback_b32 <= 1; //GEFE present (POR)
      else begin
         if (VFCDataArrived_b2[0])
           RegLoopback_b32 <= {SerialDataReceived_b32x2[0][31], 30'b0, 1'b1};
      end
   end

   // loopback on ScEc links when pageselector MSB is '1'
   always_comb begin
      if (SerialDataReceived_b32x2[0][31]) begin
	 gbt_data_x.data_sent.motor_data_b64 = gbt_data_x.data_received.motor_data_b64;
	 gbt_data_x.data_sent.mem_data_b16 = gbt_data_x.data_received.mem_data_b16;
      end else begin
	 gbt_data_x.data_sent.motor_data_b64 = debounced_motorStatus_b;
	 gbt_data_x.data_sent.mem_data_b16 = '0;
      end
   end

   initial begin
      $display("motorStatus_ib pack size: ", $size(motors_structured_x.motorsStatuses));
      $display("motorStatus_ib bits size: ", $bits(motors_structured_x.motorsStatuses));
   end


   //@TODO generate dynamically build number
   build_number i_build_number(
			       .build_ob32 (build_ob32[31:0]));


   //@TODO finish casting UID,temperature and power data
   logic [63:0] UniqueID_oqb64 = 64'h1111_2222_3333_4444;
   logic [31:0] temperature32b_i = 32'hdeadbeef;
   logic [31:0] power32b_i = 32'hcafebeef;


   //// MUX for page data:
   always_ff @(posedge gbt_data_x.ClkRs_ix.clk) begin
      case (SerialDataReceived_b32x2[0][7:0])
        // loopback data
        0: SerialDataToSend_b32x2[0] <= RegLoopback_b32;
        // build number
        1: SerialDataToSend_b32x2[0] <= build_ob32;
        // PCB revision:
        2: SerialDataToSend_b32x2[0] <= {27'b0, diag_x.pcbrev};
        4: SerialDataToSend_b32x2[0] <= UniqueID_oqb64[63:32];
        5: SerialDataToSend_b32x2[0] <= UniqueID_oqb64[31:0];
        6: SerialDataToSend_b32x2[0] <= temperature32b_i; //temperature
        7: SerialDataToSend_b32x2[0] <= power32b_i; //consumption of board
        // 16 to 31 are MOTORS statuses. This is somewhat redundant
        // info to 80 bits data stream returned back to VFC, but - why
        // not, does not cost anything here ....
        16: SerialDataToSend_b32x2[0] <= {28'b0, debounced_motorStatus_b[1]};
        17: SerialDataToSend_b32x2[0] <= {28'b0, debounced_motorStatus_b[2]};
        18: SerialDataToSend_b32x2[0] <= {28'b0, debounced_motorStatus_b[3]};
        19: SerialDataToSend_b32x2[0] <= {28'b0, debounced_motorStatus_b[4]};
        20: SerialDataToSend_b32x2[0] <= {28'b0, debounced_motorStatus_b[5]};
        21: SerialDataToSend_b32x2[0] <= {28'b0, debounced_motorStatus_b[6]};
        22: SerialDataToSend_b32x2[0] <= {28'b0, debounced_motorStatus_b[7]};
        23: SerialDataToSend_b32x2[0] <= {28'b0, debounced_motorStatus_b[8]};
        24: SerialDataToSend_b32x2[0] <= {28'b0, debounced_motorStatus_b[9]};
        25: SerialDataToSend_b32x2[0] <= {28'b0, debounced_motorStatus_b[10]};
        26: SerialDataToSend_b32x2[0] <= {28'b0, debounced_motorStatus_b[11]};
        27: SerialDataToSend_b32x2[0] <= {28'b0, debounced_motorStatus_b[12]};
        28: SerialDataToSend_b32x2[0] <= {28'b0, debounced_motorStatus_b[13]};
        29: SerialDataToSend_b32x2[0] <= {28'b0, debounced_motorStatus_b[14]};
        30: SerialDataToSend_b32x2[0] <= {28'b0, debounced_motorStatus_b[15]};
        31: SerialDataToSend_b32x2[0] <= {28'b0, debounced_motorStatus_b[16]};
        default: SerialDataToSend_b32x2[0] <= 32'hdeadbeef;
      endcase
   end


endmodule // McoiXu5System
