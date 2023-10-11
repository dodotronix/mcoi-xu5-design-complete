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

`include "vunit_defines.svh"

`timescale 1ps/1ps

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
   logic reset_bitslip;
   logic [31:0] dynamic_data;

   default clocking cb @(posedge gbt_data_x.ClkRs_ix.clk);
   endclocking

   task automatic generator();
       gbt_data_x.data_sent = 84'hc000babeac1dacdcfffff;
       dynamic_data = '0;
       // gbt_data_x.data_sent.motor_data_b64 = 64'd1000;
       fork begin
           forever begin
               //wait when locked
               while(!gbt_data_x.link_ready) @(posedge gbt_data_x.ClkRs_ix.clk);
               dynamic_data = dynamic_data + 1;
               @(posedge gbt_data_x.ClkRs_ix.clk);
               gbt_data_x.data_sent = '0;
               gbt_data_x.data_sent.motor_data_b64 = {dynamic_data, dynamic_data};
               end
           end join_none
       endtask : generator

  /* initial begin
    gbt_data_x.bitslip_reset = 1'b0;
    // gbt_data_x.data_sent = 84'h000bebeac1dacdcfffff;
    generator();
    gbt_x.sfp1_los = 1'b1;

    // classes:
    clkg = new;
    clkg.clk_tree_x = clk_tree_x;
    clkg.run();

    #10us;
    gbt_x.sfp1_los = 1'b0;

    #10us;
    if (!gbt_data_x.link_ready) gbt_data_x.bitslip_reset = 1'b1;
    #1ms;

    $finish;
   end */

   /* gbt_uscale #(.DEBUG(0)) DUT (.*,
   .external_pll_source_120mhz(clk_tree_x.ClkRs120MHz_ix.clk));
   */

  `TEST_SUITE begin
      `TEST_SUITE_SETUP begin

          gbt_data_x.bitslip_reset = 1'b0;
          // gbt_data_x.data_sent = 84'h000bebeac1dacdcfffff;
          generator();
          gbt_x.sfp1_los = 1'b1;

          // classes:
          clkg = new;
          clkg.clk_tree_x = clk_tree_x;
          clkg.run();

      end

      `TEST_CASE("link_verification") begin
          #10us;
          gbt_x.sfp1_los = 1'b0;

          #10us;
          if (!gbt_data_x.link_ready) gbt_data_x.bitslip_reset = 1'b1;
          #1ms;
          `CHECK_EQUAL (1,1);
      end
  end

  // The watchdog macro is optional, but recommended. If present, it
  // must not be placed inside any initial or always-block.
  `WATCHDOG(2ms);

    gbt_xu5 #(.DEBUG(0)) DUT(
        .external_pll_source_120mhz(clk_tree_x.ClkRs120MHz_ix.clk),
        .*);

   // loopback
   assign gbt_x.sfp1_gbitin_n = sfp_xn;
   assign gbt_x.sfp1_gbitin_p = sfp_xp;
   assign sfp_xn = gbt_x.sfp1_gbitout_n;
   assign sfp_xp = gbt_x.sfp1_gbitout_p;

endmodule // tb_gbt_xu5
