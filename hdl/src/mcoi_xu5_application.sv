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
// @file MCOI_XU5_APPLICATION.SV
// @brief
// @author Petr Pacner  <pepacner@cern.ch>, CERN
// @date 20 February 2022
// @details
//
//
// @platform Xilinx Vivado
// @standard IEEE 1800-2012
//-----------------------------------------------------------------------------

import MCPkg::*;
import CKRSPkg::*;
import constants::*;

module mcoi_xu5_application#(
    parameter g_clock_divider = 25000)(
    t_gbt_data.consumer gbt_data_x,
    c_clock clk_tree_x,
    t_motors motors_x,
    t_display.consumer display_x,
    // TODO maby add signals to check voltage on the board
    t_diag.consumer diag_x
);

    manyff #(.g_Latency (2))
    i_manyff (
        .d_o (ClkRxGBT_x.reset),
        .ClkRs_ix (ClkRxGBT_x),
        .d_i (~OptoLosReset_iran));

    manyff #(.g_Latency (2))
    i_manyff_rx (
        .d_o (ClkRs_x.reset),
        .ClkRs_ix (ClkRs_x),
        .d_i (~GeneralReset_iran));

   serial_register i_serial_register (.*);

   serial_register i_serial_register_feedback (.*);

   build_number i_build_number (.*);

   manyff #(.g_Latency(3)) i_dvalidled
     (.ClkRs_ix(ClkRs_x),
      .d_i(DValidLed),
      .d_o(RxDataValidOsc25MHz));

   // MUX
   always_ff @(posedge ClkRxGBT_x.clk) begin
       case (PageSelector_b32[7:0])
           // loopback data
           0: MuxOut_b32 <= RegLoopback_b32;
           // build number
           1: MuxOut_b32 <= build_number_ob32;
           // PCB revision:
           2: MuxOut_b32 <= {28'b0, PCBrevision_o4};
           // PLL lock and other status:
           // for the sake of script compatibility
           3: MuxOut_b32 <= 32'd1;
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

   /* mko #(.g_CounterBits (18)) i_mko (
       .q_o (),
       .q_on (forceOne_in),
       .ClkRs_ix (ClkRs_x),
       .enable_i ('1),
       .width_ib (18'(250000)),
       .start_i (RxDataValidOsc25MHz)); */


   /* led_blinker #(
       .g_totalPeriod (GEFE_LED_BLINKER_PERIOD),
       .g_blinkOn (GEFE_LED_BLINKER_ON_TIME),
       .g_blinkOff (GEFE_LED_BLINKER_OFF_TIME))
       i_led_blinker (
           .led_o (blinker),
           .period_o (),
           .ClkRs_ix (ClkRs_x),
           .forceOne_i ('0),
           .amount_ib (8'(3)));

   rx_memory #(.g_pages (NUMBER_OF_MOTORS_PER_FIBER))
   i_rx_memory (
       .data_ob32 (SwitchesConfiguration_b32),
       .resync (),
       .data_valid_o (),
       .data_ib16 (ValidRXMemData_b16),
       .ClkRs_ix (ClkRxGBT_x)); */

    // GENERATE this for each motor
    /* mko #(.g_CounterBits (22)) i_mko_stepout (
         .q_o (),
         .q_on (stepout_diode[motor]),
         .ClkRs_ix (ClkRs_x),
         .enable_i ('1),
         .width_ib (22'(4000000)),
         .start_i (!motorControl_ib[motor+1].StepOutP_o));

   extremity_switches_mapper i_extremity_switches_mapper (
       .led_lg (led_lg[motor]),
       .led_lr (led_lr[motor]),
       .led_rg (led_rg[motor]),
       .led_rr (led_rr[motor]),
       .ClkRs_ix (ClkRs_x),
       .rawswitches (debounced_motorStatus_b[motor+1].RawSwitches_b2),
       .switchesconfig (SwitchesConfiguration_2b16[motor]),
       .blinker_i (blinker)); */

//   tlc5920 #(.g_divider (4)) tlc_5920_i (
//       .display (display),
//       .ClkRs_ix (ClkRs_x),
//       .data_ib (ledData_b/*[3:0][1:0][15:0]*/));

/*

    clock_divider #(.g_divider (g_clock_divider)) i_clock_divider (
        .enable_o (),
        .ClkRs_ix ());

   get_edge i_get_edge (
      .rising_o (increaseAmplitude),
      .falling_o (),
      .data_o (),
      .ClkRs_ix (ClkRs_x),
      .data_i (cycleStart_o));

   pwm #( .g_CounterBits (5)) i_pwm (
       .cycleStart_o(cycleStart_o),
       .pwm_o (),
       .pwm_on (mreset_i),
       .ClkRs_ix (ClkRs_x),
       .amplitude_ib (amplitude_ib),
       .forceOne_i ('0),
       .enable_i (ClkRs1ms_e));

   genvar ms;
   generate
   for (ms = 0; ms < $bits(metain); ms++) begin : debouncing_
       manyff #(.g_Latency(3)) i_manyff
       (.ClkRs_ix(ClkRxGBT_x),
           .d_i(metain[ms]),
           .d_o(metaout[ms]));
   end
   endgenerate

   initial begin
      $display("motorStatus_ob pack size: ", $size(motorStatus_ob));
      $display("motorStatus_ob bits size: ", $bits(motorStatus_ob));
      $display("MotorsData_b80 bits size: ", $bits(MotorsData_b80));
   end */

endmodule
