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

module mcoi_xu5_application(
    t_gbt_data.consumer gbt_data_x,
    t_clocks.consumer clk_tree_x,
    t_display.producer display_x,
    t_motors motors_x,
    // TODO maybe add signals to check voltage on the board
    t_diag.producer diag_x
);

/*AUTOWIRE*/
// Beginning of automatic wires outputs (for undeclared instantiated-module outputs)
logic [31:0] build_number_b32;           // From i_build_number of build_number.sv
// End of automatics

/*AUTOREGINPUT*/

// module namespace for of the signals
logic clock, reset, supply_ok, vfc_data_arrived;
logic [31:0] page_selector_b32, serial_feedback_b32,
    mux_b32, loopback_b32, serial_feedback_cc_b32;
logic [3:0] sc_idata, sc_odata;
ckrs_t gbt_rx_clkrs;

always_comb begin
    clock = clk_tree_x.ClkRs40MHz_ix.clk;
    reset = clk_tree_x.ClkRs40MHz_ix.reset;
    supply_ok = diag_x.fpga_supply_ok;

    // TODO use the whole width of 4bits in the communication
    sc_idata = gbt_data_x.data_received.sc_data_b4;
    gbt_data_x.data_sent.sc_data_b4 = {{2{1'b0}}, sc_odata[1:0]};

    gbt_rx_clkrs.clk = gbt_data_x.rx_frameclk;
    gbt_rx_clkrs.reset = !gbt_data_x.rx_ready;
end

// STATUS INDICATION (LEDs)
assign diag_x.mled[0] = tick_120;
assign diag_x.mled[1] = (serial_feedback_b32 == GEFE_INTERLOCK
                         && !page_selector_b32[31])? '1 : '0;
assign diag_x.mled[2] = 1'b0;
assign diag_x.led = '0;

// indication that the 120M clock is running
logic [31:0] cnt_120mhz;
logic tick_120;
always_ff @(posedge clk_tree_x.ClkRs120MHz_ix.clk) begin
    cnt_120mhz <= cnt_120mhz + $size(cnt_120mhz)'(1);
    if(cnt_120mhz == 32'd120000000) begin
        cnt_120mhz <= '0;
        tick_120 <= tick_120 ^ 1'b1;
    end
end


assign diag_x.test[0] = clk_tree_x.ClkRs40MHz_ix.clk;
assign diag_x.test[1] = clk_tree_x.ClkRs120MHz_ix.clk;
assign diag_x.test[2] = 1'b1;
assign diag_x.test[3] = 1'b1;
assign diag_x.test[4] = 1'b1;


always_ff @(posedge gbt_rx_clkrs.clk)
    if (gbt_rx_clkrs.reset) loopback_b32 <= 1;
    else if (vfc_data_arrived)
        loopback_b32 <= {page_selector_b32[31], 30'b0, 1'b1};

   serial_register i_serial_register (
       .Rx_i(sc_idata[0]),
       .Tx_o(sc_odata[0]),
       .data_ib32(mux_b32),
       .data_ob32(page_selector_b32),
       .newdata_o(vfc_data_arrived),
       .resetflags_i(1'b0),
       .ClkRs_ix(gbt_rx_clkrs),
       .ClkRxGBT_ix(gbt_rx_clkrs),
       .ClkTxGBT_ix(gbt_rx_clkrs),
       .TxBusy_o(),
       .TxEmptyFifo_o(),
       .txerror_o(),
       .SerialLinkUp_o(),
       .RxLocked_o()
   );

   always_ff @(posedge gbt_rx_clkrs.clk)
       serial_feedback_cc_b32 <= serial_feedback_b32;

   serial_register i_serial_register_feedback (
       .Rx_i(sc_idata[1]),
       .Tx_o(sc_odata[1]),
       .data_ib32(serial_feedback_cc_b32),
       .data_ob32(serial_feedback_b32),
       .resetflags_i(1'b0),
       .ClkRs_ix(gbt_rx_clkrs),
       .ClkRxGBT_ix(gbt_rx_clkrs),
       .ClkTxGBT_ix(gbt_rx_clkrs),
       .newdata_o(),
       .TxBusy_o(),
       .TxEmptyFifo_o(),
       .txerror_o(),
       .SerialLinkUp_o(),
       .RxLocked_o()
   );

   build_number i_build_number (.*);

   // mux
   always_ff @(posedge gbt_rx_clkrs.clk) begin
       case (page_selector_b32[7:0])
           0: mux_b32 <= loopback_b32;
           1: mux_b32 <= build_number_b32;
           2: mux_b32 <= {28'b0, diag_x.pcbrev};
           3: mux_b32 <= 32'd1;
           4: mux_b32 <= 32'd1;
           5: mux_b32 <= 32'd1;
           6: mux_b32 <= 32'd1;
           7: mux_b32 <= 32'd1;
           16: mux_b32 <= 32'd1;
           17: mux_b32 <= 32'd1;
           18: mux_b32 <= 32'd1;
           19: mux_b32 <= 32'd1;
           20: mux_b32 <= 32'd1;
           21: mux_b32 <= 32'd1;
           22: mux_b32 <= 32'd1;
           23: mux_b32 <= 32'd1;
           24: mux_b32 <= 32'd1;
           25: mux_b32 <= 32'd1;
           26: mux_b32 <= 32'd1;
           27: mux_b32 <= 32'd1;
           28: mux_b32 <= 32'd1;
           29: mux_b32 <= 32'd1;
           30: mux_b32 <= 32'd1;
           31: mux_b32 <= 32'd1;
           default: mux_b32 <= 32'hdeadbeef;

       endcase
   end

   // inactive display
   tlc5920 #(.g_divider (4)) tlc_5920_i (
       .ClkRs_ix(clk_tree_x.ClkRs40MHz_ix),
       .ledData_b(32'd0),
       .*);

    // send dummy data for the motors
    logic [31:0] dynamic_data;
    always_ff @(posedge gbt_rx_clkrs.clk) begin
        if(gbt_rx_clkrs.reset) begin
            dynamic_data <= '0;
            gbt_data_x.bitslip_reset <= 1'b0;
        end else begin
            dynamic_data <= dynamic_data + $size(dynamic_data)'(1);
            gbt_data_x.bitslip_reset <= (!gbt_data_x.link_ready) ? 1'b0 : 1'b1;
        end
    end

    assign gbt_data_x.data_sent.motor_data_b64 = {dynamic_data, dynamic_data};
    assign gbt_data_x.data_sent.mem_data_b16 = '0;

endmodule
