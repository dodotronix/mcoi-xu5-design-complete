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
                                 t_motors.producer motors_x,
                                 //optical interface
                                 t_gbt.producer gbt_x,
                                 //diagnostics
                                 t_diag.producer diag_x,
                                 //display
                                 t_display.producer display_x,
                                 output        mreset_vadj,
                                 // clocks - MGT 120MHz
                                 input         mgt_clk_p,
                                 input         mgt_clk_n,
				 // clocks - MGT derived 50MHz
                                 input         pl_varclk,
				 // localosc 100MHz
                                 input         clk100m_pl_p,
                                 input         clk100m_pl_n,
				 // SFP interface

                                 // serial interfaces
				 t_i2c i2c_x,
                                 input         rs485_pl_di,
                                 output        rs485_pl_ro);


   bit [20:0] 				       reset_cntr = '0;
   logic 				       master_reset;
   logic Clk120MHz_fromgte4, Clk120MHz;
   t_gbt_data gbt_data_x(.ClkRs_ix(clk_tree_x.ClkRs40MHzMGMT_ix));

   always_ff @(posedge clk_tree_x.ClkRs100MHz_ix.clk)
     if (~&reset_cntr)
       reset_cntr <= reset_cntr + 21'(1);
   always_comb master_reset = ~&reset_cntr;


   t_clocks clk_tree_x();

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
      );


   assign clk_tree_x.ClkRsVar_ix.clk = pl_varclk;
   assign diag_x.test[0] = pl_varclk;
   assign diag_x.test[1] = Clk120MHz;


   //logic system part
   McoiXu5System i_mcoi_xu5_system (.*);

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
   ibufds_gte4_i (.O(clk_tree_x.ClkRs120MHzMGMT_ix.clk),
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

   // GBT instance
   gbt_xu5 gbt_xu5_inst
     (//clock
      .frameclk_40mhz(clk_tree_x.ClkRs40MHzMGMT_ix.clk),
      .xcvrclk(clk_tree_x.ClkRs120MHzMGMT_ix.clk),
      .rx_frameclk_o(),
      .rx_wordclk_o(),
      .tx_frameclk_o(),
      .tx_wordclk_o(),
      .rx_frameclk_rdy_o(),
      // reset
      .gbtbank_general_reset_i(clk_tree_x.ClkRs40MHzMGMT_ix.reset),
      .gbtbank_manual_reset_tx_i(1'b0),
      .gbtbank_manual_reset_rx_i(1'b0),

      // gbt transceiver inouts
      .gbtbank_mgt_rx_p(gbt_x.sfp1_gbitin_p),
      .gbtbank_mgt_rx_n(gbt_x.sfp1_gbitin_n),
      .gbtbank_mgt_tx_p(gbt_x.sfp1_gbitout_p),
      .gbtbank_mgt_tx_n(gbt_x.sfp1_gbitout_n),

      // data
      .gbtbank_gbt_data_i(gbt_x.data_sent),
      .gbtbank_wb_data_i('0),
      .tx_data_o(),
      .wb_data_o(),

      .gbtbank_gbt_data_o(gbt_data_x.data_received),
      .gbtbank_wb_data_o(),

      // reconf.
      .gbtbank_mgt_drp_rst(1'b0),
      .gbtbank_mgt_drp_clk(1'b0), //connected to 125Mhz

      // tx ctrl
      .tx_encoding_sel_i(1'b0),
      .gbtbank_tx_isdata_sel_i(1'b0),
      .gbtbank_test_pattern_sel_i(2'b11),

      // rx ctrl
      .rx_encoding_sel_i(1'b0),
      // @TODO: possibly connect as reset
      .gbtbank_reset_gbtrxready_lost_flag_i(gbt_x.sfp1_los),
      .gbtbank_reset_data_errorseen_flag_i('0),
      .gbtbank_rxframeclk_alignpatter_i(3'b000),
      .gbtbank_rxbitslit_rstoneven_i(1'b1),

      // tx status
      .gbtbank_link_ready_o(),
      .gbtbank_tx_aligned_o(),
      .gbtbank_tx_aligncomputed_o(),

      // rx status
      .gbtbank_gbttx_ready_o(),
      .gbtbank_gbtrx_ready_o(),
      .gbtbank_gbtrxready_lost_flag_o(),
      .gbtbank_rxdata_errorseen_flag_o(),
      .gbtbank_rxextradata_widebus_errorseen_flag_o(),
      .gbtbank_rx_isdata_sel_o(),
      .gbtbank_rx_errordetected_o(),
      .gbtbank_rx_bitmodified_flag_o(),
      .gbtbank_rxbitslip_rst_cnt_o(),

      //xcvr ctrl
      .gbtbank_loopback_i(3'b000),
      .gbtbank_tx_pol(1'b1),
      .gbtbank_rx_pol(1'b1));

   assign gbt_x.sfp1_rateselect = 1'b0;
   assign gbt_x.sfp1_txdisable = 1'b1;

endmodule // mcoi_xu5_design_complete
