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
// @file TB_GBT_XU5.SV
// @brief
// @author Petr Pacner  <petr.pacner@cern.ch>, CERN
// @date 8 June 2023
// @details
//
//
// @platform Xilinx Vivado
// @standard IEEE 1800-2012
//-----------------------------------------------------------------------------

`timescale 1ps/1ps
//`include "vunit_defines.svh"

import CKRSPkg::*;
import clsclk::*;
import MCPkg::*;


module tb_gbt_xu5;
   timeunit 1ns;
   timeprecision 100ps;

   /*AUTOWIRE*/
   /*AUTOREGINPUT*/

   // wires to create a loopback
   wire sfp_xn;
   wire sfp_xp;

   t_clocks clk_tree_x();
   clock_generator clkg;

   t_gbt gbt_x();

   // GBT data stream runs in frame clock
   t_gbt_data gbt_data_x(.ClkRs_ix(clk_tree_x.ClkRs40MHz_ix));

   logic reset_from_design_reset;
   logic reset_from_user, reset_bitslip;
   logic link_ready;

   default clocking cb @(posedge gbt_data_x.ClkRs_ix.clk);
   endclocking

   logic [31:0] dynamic_data;
   task automatic generator();
       gbt_data_x.data_sent = 84'hc000babeac1dacdcfffff;
       // gbt_data_x.data_sent.motor_data_b64 = 64'd1000;
       fork begin
           forever begin
               @(posedge gbt_data_x.ClkRs_ix.clk);
               while(gbt_data_x.ClkRs_ix.reset) @(posedge gbt_data_x.ClkRs_ix.clk);
               dynamic_data = dynamic_data + 1;
               /* gbt_data_x.data_sent = '0;
               gbt_data_x.data_sent.motor_data_b64 = {dynamic_data, dynamic_data}; */
           end
       end join_none
   endtask : generator

  initial begin
    // gbt_x.sfp1_los = 1'b1;
    reset_bitslip = 1'b0;
    reset_from_user = 1'b1;

    // classes:
    clkg = new;
    clkg.clk_tree_x = clk_tree_x;
    clkg.run();

    #10us;
    reset_from_user = 1'b0;
    #10us;
    if (!link_ready) reset_bitslip = 1'b1;
    #1ms;

    $finish;
   end

   /* gbt_uscale #(.DEBUG(0)) DUT (.*,
   .external_pll_source_120mhz(clk_tree_x.ClkRs120MHz_ix.clk));

   */
//   `TEST_SUITE begin
//       `TEST_SUITE_SETUP begin
//           gbt_x.sfp1_los = 1'b1;
//           dynamic_data = '0;
//           generator();

//           // classes:
//           clkg = new;
//           clkg.clk_tree_x = clk_tree_x;
//           clkg.run();
//       end

//       `TEST_CASE("link_verification") begin
//           #5us;
//           gbt_x.sfp1_los = 1'b0;
//           #10us;
//           `CHECK_EQUAL (1,1);
//       end
//   end;

//   // The watchdog macro is optional, but recommended. If present, it
//   // must not be placed inside any initial or always-block.
//   `WATCHDOG(50us);

   logic clk_156mhz;
   initial begin
       clk_156mhz = 1'b0;
       forever begin
           clk_156mhz = #3.2ns ~clk_156mhz;
       end
   end

   xlx_ku_reset #(.CLK_FREQ(156e6)) design_reset (
       .CLK_I (clk_156mhz),
       .RESET1_B_I (1'b1),
       .RESET2_B_I(!reset_from_user),
       .RESET_O (reset_from_design_reset));

   xlx_ku_gbt_example_design #(
       .NUM_LINKS(1),
       .TX_OPTIMIZATION (0),
       .RX_OPTIMIZATION (0),
       .TX_ENCODING (0),
       .RX_ENCODING (0),
       .CLOCKING_SCHEME (0))
       DUT (
           .FRAMECLK_40MHZ(clk_tree_x.ClkRs40MHz_ix.clk),
           .XCVRCLK(clk_tree_x.ClkRs120MHz_ix.clk),
           .RX_FRAMECLK_O(),
           .RX_WORDCLK_O(),
           .TX_FRAMECLK_O(),
           .TX_WORDCLK_O(),
           .RX_FRAMECLK_RDY_O(),

           .GBTBANK_GENERAL_RESET_I(reset_from_design_reset),
           .GBTBANK_MANUAL_RESET_TX_I(1'b0),
           .GBTBANK_MANUAL_RESET_RX_I(1'b0),

           .GBTBANK_MGT_RX_P(gbt_x.sfp1_gbitin_p),
           .GBTBANK_MGT_RX_N(gbt_x.sfp1_gbitin_n),
           .GBTBANK_MGT_TX_P(gbt_x.sfp1_gbitout_p),
           .GBTBANK_MGT_TX_N(gbt_x.sfp1_gbitout_n),

           .GBTBANK_GBT_DATA_I(84'h000bebeac1dacdcfffff),
           .GBTBANK_WB_DATA_I(116'd0),
           .TX_DATA_O(),
           .WB_DATA_O(),
           .GBTBANK_GBT_DATA_O(),
           .GBTBANK_WB_DATA_O(),

           .GBTBANK_MGT_DRP_CLK(clk_tree_x.ClkRs120MHz_ix.clk),

           .TX_ENCODING_SEL_i(1'b0),
           .GBTBANK_TX_ISDATA_SEL_I(1'b1),

           .RX_ENCODING_SEL_i(1'b0),
           .GBTBANK_RXFRAMECLK_ALIGNPATTER_I(3'b000),
           .GBTBANK_RXBITSLIT_RSTONEVEN_I(reset_bitslip),

           .GBTBANK_GBTTX_READY_O(),
           .GBTBANK_GBTRX_READY_O(),
           .GBTBANK_LINK_READY_O(link_ready),
           .GBTBANK_TX_ALIGNED_O(),
           .GBTBANK_TX_ALIGNCOMPUTED_O(),

           .GBTBANK_RX_ISDATA_SEL_O(),
           .GBTBANK_RX_ERRORDETECTED_O(),
           .GBTBANK_RX_BITMODIFIED_FLAG_O(),
           .GBTBANK_RXBITSLIP_RST_CNT_O(),

           .GBTBANK_LOOPBACK_I(3'b000),
           .GBTBANK_TX_POL(1'b0),
           .GBTBANK_RX_POL(1'b0));

   /* gbt_xu5 #(.DEBUG(0)) DUT (.*,
   .external_pll_source_120mhz(clk_tree_x.ClkRs120MHz_ix.clk)); */

   // loopback
   assign gbt_x.sfp1_gbitin_n = sfp_xn;
   assign gbt_x.sfp1_gbitin_p = sfp_xp;
   assign sfp_xn = gbt_x.sfp1_gbitout_n;
   assign sfp_xp = gbt_x.sfp1_gbitout_p;

endmodule // tb_gbt_xu5
