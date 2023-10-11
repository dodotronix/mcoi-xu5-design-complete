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
// Copyright (c) June 2023 CERN

//-----------------------------------------------------------------------------
// @file GBT_XU5.SV
// @brief
// @author Petr Pacner  <petr.pacner@cern.ch>, CERN
// @date 6 June 2023
// @details
// docs xilinx:
// https://www.xilinx.com/support/documentation/sw_manuals/xilinx2014_1/ug974-
// vivado-ultrascale-libraries.pdf
//
//
// @platform Xilinx Vivado
// @standard IEEE 1800-2012
//-----------------------------------------------------------------------------

module gbt_xu5 #(
    parameter DEBUG=0,
    parameter TX_OPTIMIZATION=0,
    parameter RX_OPTIMIZATION=0,
    parameter TX_ENCODING=0,
    parameter RX_ENCODING=0,
    parameter CLOCKING_SCHEME=0)(
    input logic external_pll_source_120mhz,

    // interface connecting hardware to the gbt
    t_gbt.producer gbt_x,

    // internal bus iface to readout data
    t_gbt_data.producer gbt_data_x,
    t_clocks.consumer clk_tree_x);

    logic tx_ready, rx_ready, link_ready, rx_frameclk_ready;
    assign gbt_data_x.tx_ready = tx_ready;
    assign gbt_data_x.rx_ready = rx_ready;
    assign gbt_data_x.link_ready = link_ready;
    assign gbt_data_x.rx_frameclk_ready = rx_frameclk_ready;

   gbt_expanded_pinout #(
       .NUM_LINKS(1),
       .TX_OPTIMIZATION (TX_OPTIMIZATION),
       .RX_OPTIMIZATION (RX_OPTIMIZATION),
       .TX_ENCODING (TX_ENCODING),
       .RX_ENCODING (RX_ENCODING),
       .CLOCKING_SCHEME (CLOCKING_SCHEME))
       gbt_expanded_inst (
           .frameclk_40mhz(clk_tree_x.ClkRs40MHz_ix.clk),
           .xcvrclk(external_pll_source_120mhz),
           .rx_frameclk_o(gbt_data_x.rx_frameclk),
           .rx_wordclk_o(),
           .tx_frameclk_o(gbt_data_x.tx_frameclk),
           .tx_wordclk_o(),
           .rx_frameclk_rdy_o(rx_frameclk_ready),

           // .gbtbank_general_reset_i(reset_from_design_reset),
           .gbtbank_general_reset_i(gbt_x.sfp1_los),
           .gbtbank_manual_reset_tx_i(1'b0),
           .gbtbank_manual_reset_rx_i(1'b0),

           .gbtbank_mgt_rx_p(gbt_x.sfp1_gbitin_p),
           .gbtbank_mgt_rx_n(gbt_x.sfp1_gbitin_n),
           .gbtbank_mgt_tx_p(gbt_x.sfp1_gbitout_p),
           .gbtbank_mgt_tx_n(gbt_x.sfp1_gbitout_n),

           .gbtbank_gbt_data_i(gbt_data_x.data_sent),
           .gbtbank_wb_data_i(116'd0),
           .tx_data_o(),
           .wb_data_o(),
           .gbtbank_gbt_data_o(gbt_data_x.data_received),
           .gbtbank_wb_data_o(),

           .gbtbank_mgt_drp_clk(clk_tree_x.ClkRs120MHz_ix.clk),

           .tx_encoding_sel_i(1'b0),
           .gbtbank_tx_isdata_sel_i(1'b1),

           .rx_encoding_sel_i(1'b0),
           .gbtbank_rxframeclk_alignpatter_i(3'b000),
           .gbtbank_rxbitslit_rstoneven_i(gbt_data_x.bitslip_reset),

           .gbtbank_gbttx_ready_o(tx_ready),
           .gbtbank_gbtrx_ready_o(rx_ready),
           .gbtbank_link_ready_o(link_ready),
           .gbtbank_tx_aligned_o(),
           .gbtbank_tx_aligncomputed_o(),

           .gbtbank_rx_isdata_sel_o(),
           .gbtbank_rx_errordetected_o(),
           .gbtbank_rx_bitmodified_flag_o(),
           .gbtbank_rxbitslip_rst_cnt_o(),

           .gbtbank_loopback_i(3'b000),
           .gbtbank_tx_pol(1'b0),
           .gbtbank_rx_pol(1'b0));

    generate
    if (DEBUG == 1) begin : gen_gbtx_debugging_ila
    gbt_ila inside_ila (
        .clk(clk_tree_x.ClkRs120MHz_ix.clk),
        .probe0(gbt_data_x.data_received.motor_data_b64),
        .probe1(gbt_data_x.data_sent.motor_data_b64),
        .probe2(gbt_x.sfp1_los),
        .probe3(tx_ready),
        .probe4(rx_ready),
        .probe5(link_ready),
        .probe6(rx_frameclk_ready),
        .probe7(1'b0));
    end
    endgenerate

    assign gbt_x.sfp1_rateselect = 1'b0;
    assign gbt_x.sfp1_txdisable = 1'b0;

endmodule
