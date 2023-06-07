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
    parameter TX_OPTIMIZATION=0,
    parameter RX_OPTIMIZATION=0,
    parameter TX_ENCODING=0,
    parameter RX_ENCODING=0,
    parameter CLOCKING_SCHEME=0)(

    // interface connecting hardware to the gbt 
    t_gbt.producer gbt_x,

    // internal bus iface to readout data
    t_gbt_data.producer gbt_data_x,
    t_clocks.consumer clk_tree_x,

    input external_pll_source_120mhz 
);

logic mgt_rxreset;
logic mgt_txreset;
logic gbt_txreset;
logic gbt_rxreset;
logic mgt_txready;
logic mgt_rxready;

logic rx_frmclk;
logic tx_frmclk;
logic clk_40mhz;
logic clk_120mhz;
logic reset;

logic link_ready;
logic tx_ready;
logic rx_ready;

logic gbt_rxclkenLogic; 
logic mgt_headerflag;

always_comb begin
    clk_120mhz = clk_tree_x.ClkRs120MHz_ix.clk;
    clk_40mhz  = clk_tree_x.ClkRs40MHz_ix.clk;
    reset      = clk_tree_x.ClkRs40MHz_ix.reset | gbt_x.sfp1_los;

    gbt_data_x.tx_ready   = tx_ready;
    gbt_data_x.rx_ready   = rx_ready;
    gbt_data_x.link_ready = link_ready;
end

gbt_bank_reset #(
    .INITIAL_DELAY(40e6))
i_gbt_reset(
 .GBT_CLK_I (clk_40mhz),
 .TX_FRAMECLK_I(tx_frmclk),
 .TX_CLKEN_I(1'b1),
 .RX_FRAMECLK_I(rx_frmclk),
 .RX_CLKEN_I(gbt_rxclkenLogic),
 .MGTCLK_I(clk_120mhz),
 .GENERAL_RESET_I(reset),
 .TX_RESET_I(reset),
 .RX_RESET_I(reset),
 .MGT_TX_RESET_O(mgt_txreset),
 .MGT_RX_RESET_O(mgt_rxreset),
 .GBT_TX_RESET_O(gbt_txreset),
 .GBT_RX_RESET_O(gbt_rxreset),
 .MGT_TX_RSTDONE_I(mgt_txready),
 .MGT_RX_RSTDONE_I(mgt_rxready));

 gbt_rx_frameclk_phalgnr #(
     .DIV_SIZE_CONFIG(3),
     .METHOD(0),
     .TX_OPTIMIZATION(TX_OPTIMIZATION),
     .RX_OPTIMIZATION(RX_OPTIMIZATION),
     .CLOCKING_SCHEME(CLOCKING_SCHEME))
 i_frameclk_phalgnr(
        .RESET_I(~mgt_rxready),
        .RX_WORDCLK_I(1'b0),
        .FRAMECLK_I(frameclk_40mhz),
        .RX_FRAMECLK_O(rx_frmclk),
        .RX_CLKEn_o(gbt_rxclkenLogic),
        .SYNC_I(mgt_headerflag),
        .CLK_ALIGN_CONFIG(3'b000),
        .DEBUG_CLK_ALIGNMENT(),
        .PLL_LOCKED_O(),
        .DONE_O());

// module with extended pinout
gbt_extended_pinout #(
    .NUM_LINKS(1),
    .TX_OPTIMIZATION(TX_OPTIMIZATION),
    .RX_OPTIMIZATION(RX_OPTIMIZATION),
    .TX_ENCODING(TX_ENCODING),
    .RX_ENCODING(RX_ENCODING),
    .CLOCKING_SCHEME(CLOCKING_SCHEME))
gbt_extended_i(
        //clock
      .frameclk_40mhz(clk_40mhz),
      .xcvrclk(external_pll_source_120mhz),
      .rx_frameclk_i(rx_frmclk),
      .rx_wordclk_o(),

      .tx_frameclk_o(tx_frmclk),
      .tx_wordclk_o(),

      // INto gbt_xu5
      .gbtbank_mgt_rx_p(gbt_x.sfp1_gbitin_p),
      .gbtbank_mgt_rx_n(gbt_x.sfp1_gbitin_n),

      // OUT from gbt_xu5
      .gbtbank_mgt_tx_p(gbt_x.sfp1_gbitout_p),
      .gbtbank_mgt_tx_n(gbt_x.sfp1_gbitout_n),
      .pll_ila(clk_120mhz),

      // data
      .gbtbank_gbt_data_i(gbt_data_x.data_sent),
      .gbtbank_wb_data_i('0),

      .gbtbank_gbt_data_o(gbt_data_x.data_received),
      .gbtbank_wb_data_o(),

      // reconf.
      // NOTE test if it works with 120Mhz
      .gbtbank_mgt_drp_clk(clk_120mhz), //connected to 125Mhz

      // tx ctrl
      .tx_encoding_sel_i(1'b0),
      .gbtbank_tx_isdata_sel_i(1'b0),

      // rx ctrl
      .rx_encoding_sel_i(1'b0),
      .gbtbank_rxbitslit_rstoneven_i(1'b1),

      // tx status
      .gbtbank_tx_aligned_o(),
      .gbtbank_tx_aligncomputed_o(),

      .gbtbank_rx_isdata_sel_o(),
      .gbtbank_rx_errordetected_o(),
      .gbtbank_rx_bitmodified_flag_o(),
      .gbtbank_rxbitslip_rst_cnt_o(),

      .gbtbank_link_ready_o(link_ready),
      .gbtbank_gbtrx_ready_o(rx_ready),
      .gbtbank_gbttx_ready_o(tx_ready),

      //xcvr ctrl
      .gbtbank_loopback_i(3'b000),
      .gbtbank_tx_pol(1'b1),
      .gbtbank_rx_pol(1'b1),

      .mgt_txreset_s(mgt_txreset),
      .mgt_rxreset_s(mgt_rxreset),

      .gbt_txreset_s(gbt_txreset),
      .gbt_rxreset_s(gbt_rxreset),

      .mgt_rxready(mgt_rxready),
      .mgt_txready(mgt_txready),

      .mgt_headerflag(mgt_headerflag),
      .gbt_rxclkenLogic(gbt_rxclkenLogic)
);

assign gbt_x.sfp1_rateselect = 1'b0;
assign gbt_x.sfp1_txdisable = 1'b0;

endmodule
