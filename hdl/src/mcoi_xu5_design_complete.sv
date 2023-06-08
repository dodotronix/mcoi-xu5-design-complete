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
// @platform Xilinx Vivado 
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


   bit [20:0] reset_cntr = 21'd0;
   logic master_reset;
   logic Clk120MHz_fromgte4;
   logic txready, rxready;
   logic rx_frmclk, tx_frmclk;

   t_clocks clk_tree_x();
   t_gbt_data gbt_data_x(.ClkRs_ix(clk_tree_x.ClkRs40MHz_ix));

   always_ff @(posedge clk_tree_x.ClkRs100MHz_ix.clk)
     if (~&reset_cntr)
       reset_cntr <= reset_cntr + $size(reset_cntr)'(1);
   always_comb master_reset = ~&reset_cntr;

   // reset synchronization into the respective clock domains
   vme_reset_sync_and_filter u_100MHz_reset_sync
     (.rst_ir   (1'b0),
      .clk_ik   (clk_tree_x.ClkRs100MHz_ix.clk),
      .cen_ie   (1'b1),
      .data_i   (master_reset),
      .data_o   (clk_tree_x.ClkRs100MHz_ix.reset));

   vme_reset_sync_and_filter u_40MHzMGMT_reset_sync
     (.rst_ir   (1'b0),
      .clk_ik   (clk_tree_x.ClkRs40MHz_ix.clk),
      .cen_ie   (1'b1),
      .data_i   (master_reset),
      .data_o   (clk_tree_x.ClkRs40MHz_ix.reset));

   /* vme_reset_sync_and_filter u_Var_reset_sync
     (.rst_ir   (1'b0),
      .clk_ik   (clk_tree_x.ClkRsVar_ix.clk),
      .cen_ie   (1'b1),
      .data_i   (master_reset),
      .data_o   (clk_tree_x.ClkRsVar_ix.reset)); */

  // *!! because we cannot access internals of t_motors !!
  /* t_motors_structured motors_structured_x();
  iface_translator i_iface_translator (.*);
  */

   logic [31:0] cnt_120mhz;
   logic tick_120;

   logic [31:0] cnt_100mhz; 
   logic tick_100;

   // assign clk_tree_x.ClkRsVar_ix.clk = pl_varclk;
   assign diag_x.test[0] = clk_tree_x.ClkRs40MHz_ix.clk;
   assign diag_x.test[1] = clk_tree_x.ClkRs120MHz_ix.clk;
   assign diag_x.test[2] = tick_120;
   assign diag_x.test[3] = tick_100;
   assign diag_x.test[4] = 1'b1;

   // HELLO WORLD WITH LED
   always_ff@(posedge clk_tree_x.ClkRs100MHz_ix.clk) begin
       cnt_100mhz <= cnt_100mhz + $size(cnt_100mhz)'(1);
       if(cnt_100mhz == 32'd10000000) begin
           cnt_100mhz <= '0;
           tick_100 <= tick_100 ^ 1'b1;
       end
   end
   assign mled[0] = tick_100;
   
   always_ff @(posedge clk_tree_x.ClkRs120MHz_ix.clk) begin
       cnt_120mhz <= cnt_120mhz + $size(cnt_120mhz)'(1);
       if(cnt_120mhz == 32'd120000000) begin
           cnt_120mhz <= '0;
           tick_120 <= tick_120 ^ 1'b1;
       end
   end

   assign mled[1] = tick_120;

   //logic system part
   /* McoiXu5System i_mcoi_xu5_system (
       .gbt_los(gbt_x.sfp1_los), .*); */

   // ps part just for storing data to qspi
   mcoi_xu5_ps_part i_mcoi_xu5_ps_part();

   // clock generation
   // 100MHz oscillator and associated reset
   IBUFDS ibufds_i(
       .O(clk_tree_x.ClkRs100MHz_ix.clk),
       .I(clk100m_pl_p),
       .IB(clk100m_pl_n));

   logic ExternalPll120MHzMGT;
   // 120MHz coming from MGT oscillator
   IBUFDS_GTE4 #(.REFCLK_EN_TX_PATH(1'b0),
		 .REFCLK_HROW_CK_SEL(2'b00),
		 .REFCLK_ICNTL_RX(2'b00))
   ibufds_gte4_i (
          .O(ExternalPll120MHzMGT),
		  .ODIV2(Clk120MHz_fromgte4),
		  .CEB(1'b0),
		  .I(mgt_clk_p),
		  .IB(mgt_clk_n));

   // 120MHz PLL buffer clock copier
   BUFG_GT ibuf_txpll_i (
       .O(clk_tree_x.ClkRs120MHz_ix.clk),
       .CE(1'b1),
       .CEMASK(1'b0),
       .CLR(1'b0),
       .CLRMASK(1'b0),
       .DIV(3'b000),
       .I(Clk120MHz_fromgte4));

   // 40MHz PLL derived from MGT clock
   gbt_pll40m gbt_pll40m_i (
       .clk120m_i(clk_tree_x.ClkRs120MHz_ix.clk),
       .clk40m_o(clk_tree_x.ClkRs40MHz_ix.clk),
       .reset(0),
       .locked());

    logic [31:0] dynamic_data;
    always_ff @(posedge gbt_data_x.tx_frameclk) begin
        if(gbt_x.sfp1_los) dynamic_data <= '0;
        else dynamic_data <= dynamic_data + $size(dynamic_data)'(1);
    end

    assign gbt_data_x.data_sent.motor_data_b64 = {dynamic_data, dynamic_data};

   // GBT instance
   gbt_xu5 gbt_xu5_ins(
       .external_pll_source_120mhz(ExternalPll120MHzMGT),
       .*);

   assign mled[2] = | gbt_data_x.data_received;

endmodule // mcoi_xu5_design_complete
