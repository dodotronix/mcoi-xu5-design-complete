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
// Copyright (c) January 2020 CERN

//-----------------------------------------------------------------------------
// @file MCOI_XU5_DESIGN_COMPLETE.SV
// @brief
// @author Petr Pacner  <petr.pacner@cern.ch>, CERN
// @date  January 2020
// @details
// docs xilinx:
// https://www.xilinx.com/support/documentation/sw_manuals/xilinx2014_1/ug974-
// vivado-ultrascale-libraries.pdf
//
//
// @platform Altera Quartus
// @standard IEEE 1800-2012
//-----------------------------------------------------------------------------

import MCPkg::*;
import CKRSPkg::*;
import types::*;


module mcoi_xu5_design_complete (//motors
                                 /* t_motors.producer motors_x,
                                 //optical interface
                                 //diagnostics */
                                 t_gbt.producer gbt_x,
                                 t_diag.producer diag_x,
                                 /* //display
                                 t_display.producer display_x,
                                 output logic mreset_vadj, */
                                 // clocks - MGT 120MHz
                                 input logic         mgt_clk_p,
                                 input logic         mgt_clk_n,
                                 output logic [2:0] mled,
				 // clocks - MGT derived 50MHz
                                 // input logic         pl_varclk,
				 // localosc 100MHz
                                 input logic         clk100m_pl_p,
                                 input logic        clk100m_pl_n
				 // SFP interface

                 // serial interfaces
                 // t_i2c.endpoint i2c_x,
                 // input logic         rs485_pl_di,
                 // output logic        rs485_pl_ro
                                );


   bit [20:0] 				       reset_cntr = '0;
   // logic 				       master_reset;
   logic Clk120MHz_fromgte4, Clk120MHz;
   t_clocks clk_tree_x();

   t_gbt_data gbt_data_x(.ClkRs_ix(clk_tree_x.ClkRs40MHzMGMT_ix));
   logic txready, rxready;
   logic rx_frmclk, tx_frmclk;

   // *!! because we cannot access internals of t_motors !!
   /* t_motors_structured motors_structured_x();
   iface_translator i_iface_translator (.*);

   always_ff @(posedge clk_tree_x.ClkRs100MHz_ix.clk)
     if (~&reset_cntr)
       reset_cntr <= reset_cntr + 21'(1);
   always_comb master_reset = ~&reset_cntr;



   // reset synchronization into the respective clock domains
   vme_reset_sync_and_filter u_100MHz_reset_sync
     (.rst_ir   (1'b0),
      .clk_ik   (clk_tree_x.ClkRs100MHz_ix.clk),
      .cen_ie   (1'b1),
      .data_i   (master_reset),
      .data_o   (clk_tree_x.ClkRs100MHz_ix.reset)
      );

   vme_reset_sync_and_filter u_120MHzMGMT_reset_sync
     (.rst_ir   (1'b0),
      .clk_ik   (clk_tree_x.ClkRs120MHzMGMT_ix.clk),
      .cen_ie   (1'b1),
      .data_i   (master_reset),
      .data_o   (clk_tree_x.ClkRs120MHzMGMT_ix.reset)
      );

   vme_reset_sync_and_filter u_40MHzMGMT_reset_sync
     (.rst_ir   (1'b0),
      .clk_ik   (clk_tree_x.ClkRs40MHzMGMT_ix.clk),
      .cen_ie   (1'b1),
      .data_i   (master_reset),
      .data_o   (clk_tree_x.ClkRs40MHzMGMT_ix.reset)
      );

   vme_reset_sync_and_filter u_Var_reset_sync
     (.rst_ir   (1'b0),
      .clk_ik   (clk_tree_x.ClkRsVar_ix.clk),
      .cen_ie   (1'b1),
      .data_i   (master_reset),
      .data_o   (clk_tree_x.ClkRsVar_ix.reset)
      ); */

   logic [31:0] cnt_120mhz;
   logic tick_120;

   logic [31:0] cnt_100mhz; 
   logic tick_100;

   // assign clk_tree_x.ClkRsVar_ix.clk = pl_varclk;
   assign diag_x.test[0] = clk_tree_x.ClkRs40MHzMGMT_ix.clk;
   assign diag_x.test[1] = tick_120;
   assign diag_x.test[2] = tick_100;
   assign diag_x.test[3] = 1'b0;
   assign diag_x.test[4] = 1'b0;
   /* assign mled[0] = 1'b0;
   assign mled[1] = 1'b0;
   assign mled[2] = 1'b0; */

   // HELLO WORLD WITH LED
   always_ff@(posedge clk_tree_x.ClkRs100MHz_ix.clk) begin
       cnt_100mhz <= cnt_100mhz + $size(cnt_100mhz)'(1);
       if(cnt_100mhz == 32'd10000000) begin
           cnt_100mhz <= '0;
           tick_100 <= tick_100 ^ 1'b1;
       end
   end
   assign mled[0] = tick_100;
   
   always_ff @(posedge Clk120MHz) begin
       cnt_120mhz <= cnt_120mhz + $size(cnt_120mhz)'(1);
       if(cnt_120mhz == 32'd120000000) begin
           cnt_120mhz <= '0;
           tick_120 <= tick_120 ^ 1'b1;
       end
   end

   assign mled[1] = tick_120;
   assign mled[2] = 1'b1;

   //logic system part
   /* McoiXu5System i_mcoi_xu5_system (
       .gbt_los(gbt_x.sfp1_los), .*); */

   // ps part just for storing data to qspi
   mcoi_xu5_ps_part i_mcoi_xu5_ps_part();


   // clock generation
   // 100MHz oscillator and associated reset
   IBUFDS ibufds_i(.O(clk_tree_x.ClkRs100MHz_ix.clk),
                   .I(clk100m_pl_p),
                   .IB(clk100m_pl_n));

   // 120MHz coming from MGMT oscillator
   IBUFDS_GTE4 #(.REFCLK_EN_TX_PATH(1'b0),
		 .REFCLK_HROW_CK_SEL(2'b00),
		 .REFCLK_ICNTL_RX(2'b00))
   ibufds_gte4_i (
          .O(clk_tree_x.ClkRs120MHzMGMT_ix.clk),
		  .ODIV2(Clk120MHz_fromgte4),
		  .CEB(1'b0),
		  .I(mgt_clk_p),
		  .IB(mgt_clk_n));

   // 120MHz PLL buffer clock copier
   BUFG_GT ibuf_txpll_i (.O(Clk120MHz),
			 .CE(1'b1),
			 .CEMASK(1'b0),
			 .CLR(1'b0),
			 .CLRMASK(1'b0),
			 .DIV(3'b000),
			 .I(Clk120MHz_fromgte4));

   // 40MHz PLL derived from MGMT clock
   gbt_pll40m gbt_pll40m_i (.clk120m_i(Clk120MHz),
			    .clk40m_o(clk_tree_x.ClkRs40MHzMGMT_ix.clk),
			    .reset(0),
			    .locked());

    logic clk125mhz;
     test_pll i_testpll (
        .clk_out1(clk125mhz),
        .clk_in1(clk_tree_x.ClkRs100MHz_ix.clk)
    );

    logic [31:0] dynamic_data;

   always_ff @(posedge tx_frmclk) begin
       if(gbt_x.sfp1_los) dynamic_data <= '0;
       else dynamic_data <= dynamic_data + $size(dynamic_data)'(1);
   end

   assign gbt_data_x.data_sent.motor_data_b64 = dynamic_data;

   logic gbt_rxclkenLogic; 
   logic mgt_txreset_s, mgt_rxreset_s;
   logic mgt_txready, mgt_rxready;
   logic gbt_txreset_s, gbt_rxreset_s;
   logic mgt_headerflag;

   // GBT instance
   gbt_xu5 gbt_xu5_inst
     (//clock
      .frameclk_40mhz(clk_tree_x.ClkRs40MHzMGMT_ix.clk),
      .xcvrclk(clk_tree_x.ClkRs120MHzMGMT_ix.clk),
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
      .pll_ila(Clk120MHz),

      // data
      .gbtbank_gbt_data_i(gbt_data_x.data_sent),
      .gbtbank_wb_data_i('0),

      .gbtbank_gbt_data_o(gbt_data_x.data_received),
      .gbtbank_wb_data_o(),

      // reconf.
      .gbtbank_mgt_drp_clk(clk125mhz), //connected to 125Mhz

      // tx ctrl
      .tx_encoding_sel_i(1'b0),
      .gbtbank_tx_isdata_sel_i(1'b0),

      // rx ctrl
      .rx_encoding_sel_i(1'b0),
      .gbtbank_rxbitslit_rstoneven_i(1'b1),

      // tx status
      .gbtbank_tx_aligned_o(),
      .gbtbank_tx_aligncomputed_o(),

      // rx status
      
      /* .gbtbank_gbttx_ready_o(txready),
      .gbtbank_gbtrx_ready_o(rxready),
      .gbtbank_link_ready_o(), */

      .gbtbank_rx_isdata_sel_o(),
      .gbtbank_rx_errordetected_o(),
      .gbtbank_rx_bitmodified_flag_o(),
      .gbtbank_rxbitslip_rst_cnt_o(),

      //xcvr ctrl
      .gbtbank_loopback_i(3'b000),
      .gbtbank_tx_pol(1'b1),
      .gbtbank_rx_pol(1'b1),

      //exclude reset block from the gbt block 
      .mgt_txreset_s(mgt_txreset_s),
      .mgt_rxreset_s(mgt_rxreset_s),
      .gbt_txreset_s(gbt_txreset_s),
      .gbt_rxreset_s(gbt_rxreset_s),
      .mgt_rxready(mgt_rxready),
      .mgt_txready(mgt_txready),
      .mgt_headerflag(mgt_headerflag),
      .gbt_rxclkenLogic(gbt_rxclkenLogic)
      );

      // excluded reset block
      gbt_bank_reset #(.INITIAL_DELAY(40e6))
      i_gbt_reset(
         .GBT_CLK_I (clk_tree_x.ClkRs40MHzMGMT_ix.clk),
         .TX_FRAMECLK_I(tx_frmclk),
         .TX_CLKEN_I(1'b1),
         .RX_FRAMECLK_I(rx_frmclk),
         .RX_CLKEN_I(gbt_rxclkenLogic),
         .MGTCLK_I(clk125mhz),
         .GENERAL_RESET_I(gbt_x.sfp1_los),
         .TX_RESET_I(gbt_x.sfp1_los),
         .RX_RESET_I(gbt_x.sfp1_los),
         .MGT_TX_RESET_O(mgt_txreset_s),
         .MGT_RX_RESET_O(mgt_rxreset_s),
         .GBT_TX_RESET_O(gbt_txreset_s),
         .GBT_RX_RESET_O(gbt_rxreset_s),
         .MGT_TX_RSTDONE_I(mgt_txready),
         .MGT_RX_RSTDONE_I(mgt_rxready)
         );

    logic pll_testovani, rx_frameclk_rdy;

     gbt_rx_frameclk_phalgnr #(
         .TX_OPTIMIZATION(0),
         .RX_OPTIMIZATION(0),
         .DIV_SIZE_CONFIG(3),
         .METHOD(0),
         .CLOCKING_SCHEME(0))
     i_frameclk_phalgnr(
            .RESET_I(~mgt_rxready),
            .RX_WORDCLK_I(1'b0),
            .FRAMECLK_I(clk_tree_x.ClkRs40MHzMGMT_ix.clk),
            .RX_FRAMECLK_O(rx_frmclk),
            .RX_CLKEn_o(gbt_rxclkenLogic),
            .SYNC_I(mgt_headerflag),
            .CLK_ALIGN_CONFIG(3'b000),
            .DEBUG_CLK_ALIGNMENT(),
            .PLL_LOCKED_O(pll_testovani),
            .DONE_O(rx_frameclk_rdy));

    /* illa_gbtcore outside_ila(
        .clk(Clk120MHz),
        .probe0(gbt_data_x.data_received.motor_data_b64),
        .probe1(gbt_data_x.data_sent.motor_data_b64),
        .probe2(tx_frmclk),
        .probe3(rx_frmclk),
        .probe4(rx_frameclk_rdy),
        .probe5(pll_testovani),
        .probe6(mgt_txready),
        .probe7(mgt_rxready)); */

   assign gbt_x.sfp1_rateselect = 1'b0;
   assign gbt_x.sfp1_txdisable = 1'b0;

endmodule // mcoi_xu5_design_complete
