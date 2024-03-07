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
// Copyright (c) October 2023 CERN

//-----------------------------------------------------------------------------
// @file MCOI_XU5_SYSTEM.SV
// @brief
// @author Petr Pacner  <petr.pacner@cern.ch>, CERN
// @date October 2023
// @details
// docs xilinx:
// https://www.xilinx.com/support/documentation/sw_manuals/xilinx2014_1/ug974-
// vivado-ultrascale-libraries.pdf
//
//
// @platform Xilinx Vivado
// @standard IEEE 1800-2012
//-----------------------------------------------------------------------------

import MCPkg::*;
import CKRSPkg::*;
import types::*;

module mcoi_xu5_system (
    t_clocks.producer clk_tree_x,
    t_gbt_data.control gbt_data_x,
    t_register.consumer ps_register_x,
    output logic ExternalPll120MHzMGT, // 120MHz coming from MGT oscillator
    output logic gbt_pll_locked,

    input logic mgt_fdbk_p,
    input logic mgt_fdbk_n,

    output logic pl_varclk_p,
    output logic pl_varclk_n,

    // input logic pl_varclk,
    input logic mgt_clk_p,
    input logic mgt_clk_n,
    input logic clk100m_pl_p,
    input logic clk100m_pl_n );

   logic Clk120MHz_fromgte4, clk_en;
   logic global_reset;

   // clock generation
   // 100MHz oscillator and associated reset
   IBUFDS ibufds_i(
       .O(clk_tree_x.ClkRs100MHz_ix.clk),
       .I(clk100m_pl_p),
       .IB(clk100m_pl_n));

   // test if the recovered clock works
   /* OBUFDS_GTE4 #(
       .REFCLK_EN_TX_PATH(1'b1),
       .REFCLK_ICNTL_TX(5'b00111))
   recclk_output_buffer (
       .O(mgt_fdbk_p),
       .OB(mgt_fdbk_n),
       .CEB(1'b0),
       .I(gbt_data_x.rx_recclk)); */

   // This passes the recovered clock from
   // the optical link to the Tx part of MGT
   OBUFDS rx_clk_out_buffer (
       .O(pl_varclk_p),
       .OB(pl_varclk_n),
       .I(gbt_data_x.rx_wordclk));

   logic recovered_clock;
   logic recovered_clock_buff;

   // MGT_REFCLK0
   IBUFDS_GTE4 #(
       .REFCLK_EN_TX_PATH(1'b0),
       .REFCLK_HROW_CK_SEL(2'b00),
       .REFCLK_ICNTL_RX(2'b00))
   ibufds_gte4_i0 (
        .O(gbt_data_x.rx_recclk),
        .ODIV2(recovered_clock_buff),
        .CEB(1'b0),
        .I(mgt_fdbk_p),
        .IB(mgt_fdbk_n));


   // MGT_REFCLK1
   IBUFDS_GTE4 #(
       .REFCLK_EN_TX_PATH(1'b0),
       .REFCLK_HROW_CK_SEL(2'b00),
       .REFCLK_ICNTL_RX(2'b00))
   ibufds_gte4_i1 (
        .O(ExternalPll120MHzMGT),
        .ODIV2(Clk120MHz_fromgte4),
        .CEB(1'b0),
        .I(mgt_clk_p),
        .IB(mgt_clk_n));

    // 120MHz PLL buffer clock copier
    BUFG_GT ibuf_rxpll_i (
        .O(clk_tree_x.ClkRs120MHz_ix.clk),
        .CE(1'b1),
        .CEMASK(1'b0),
        .CLR(1'b0),
        .CLRMASK(1'b0),
        .DIV(3'b000),
        .I(Clk120MHz_fromgte4));

    BUFG_GT ibuf_txpll_i (
        .O(recovered_clock),
        .CE(1'b1),
        .CEMASK(1'b0),
        .CLR(1'b0),
        .CLRMASK(1'b0),
        .DIV(3'b000),
        .I(recovered_clock_buff));

    // 40MHz PLL derived from MGT clock
    gbt_pll_clk40m gbt_pll40m_i (
        .clk120m_i(recovered_clock),
        .clk40m_o(clk_tree_x.ClkRs40MHz_ix.clk),
        .reset(global_reset),
        .locked(gbt_pll_locked));

   // get 1ms timing out of 120MHz
   clock_divider #( .g_divider(120000)) i_clock_divider (
       .enable_o(clk_en), .ClkRs_ix(clk_tree_x.ClkRs120MHz_ix));
    // gbt timeout before next reset when GTH LOL
    logic [10:0] timeout; // this timeout is aprox. 2.4s
    logic rst_pulse, finished;

    logic gbt_ready;
    always_ff @(posedge clk_tree_x.ClkRs120MHz_ix.clk) begin
        gbt_ready <= gbt_data_x.rx_ready || gbt_data_x.tx_ready;
    end

    always_ff @(posedge clk_tree_x.ClkRs120MHz_ix.clk) begin
        if(gbt_ready) begin
            timeout <= '0;
            rst_pulse <= '0;
            finished <= 0;
        end else begin
            if(clk_en) begin
                timeout <= timeout + $size(timeout)'(1);
                finished <= !timeout;
                rst_pulse <= (finished) ? 1'b1 : 1'b0;
            end
        end
    end

    // TODO add reset from the onboard button
    // needs to be implemented first on the pcb
    always_comb begin
        global_reset = rst_pulse | gbt_data_x.los | !ps_register_x.status[2];
        clk_tree_x.ClkRsVar_ix.clk = recovered_clock;
    end

    // reset synchronization into the respective clock domains
    vme_reset_sync_and_filter u_100MHz_reset_sync
    (.rst_ir (1'b0),
        .clk_ik (clk_tree_x.ClkRs100MHz_ix.clk),
        .cen_ie (1'b1),
        .data_i (global_reset),
        .data_o (clk_tree_x.ClkRs100MHz_ix.reset));

    vme_reset_sync_and_filter u_40MHzMGMT_reset_sync
      (.rst_ir (1'b0),
       .clk_ik (clk_tree_x.ClkRs40MHz_ix.clk),
       .cen_ie (1'b1),
       .data_i (global_reset),
       .data_o (clk_tree_x.ClkRs40MHz_ix.reset));

    vme_reset_sync_and_filter u_120MHz_reset_sync
      (.rst_ir (1'b0),
       .clk_ik (clk_tree_x.ClkRs120MHz_ix.clk),
       .cen_ie (1'b1),
       .data_i (global_reset),
       .data_o (clk_tree_x.ClkRs120MHz_ix.reset));

    vme_reset_sync_and_filter u_Var_reset_sync
    (.rst_ir (1'b0),
        .clk_ik (clk_tree_x.ClkRsVar_ix.clk),
        .cen_ie (1'b1),
        .data_i (global_reset),
        .data_o (clk_tree_x.ClkRsVar_ix.reset));

    assign gbt_data_x.rate_select = 1'b0;
    assign gbt_data_x.tx_disable = 1'b0;

endmodule
