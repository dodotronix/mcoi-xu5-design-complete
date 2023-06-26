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

import CKRSPkg::*;
import clsclk::*;
import MCPkg::*;

module tb_gbt_xu5;
   timeunit 1ns;
   timeprecision 100ps;

   /*AUTOWIRE*/
   /*AUTOREGINPUT*/
   // Beginning of automatic regs inputs (for undeclared instantiated-module inputs)
   logic external_pll_source_120mhz;       // To DUT of gbt_xu5.sv
   // End of automatics

   t_clocks clk_tree_x();
   clock_generator clkg;

   t_gbt gbt_x();
   // GBT data stream runs in frame clock
   t_gbt_data gbt_data_x(.ClkRs_ix(clk_tree_x.ClkRs40MHz_ix));

   default clocking cb @(posedge gbt_data_x.ClkRs_ix.clk);
   endclocking

   `TEST_SUITE begin
       `TEST_SUITE_SETUP begin
           gbt_x.sfp1_los = '0;

           // classes:
           clkg = new;
           clkg.clk_tree_x = clk_tree_x;
           clkg.run();
       end

       `TEST_CASE("link_verification") begin
           `CHECK_EQUAL (1,1);
       end
   end;

   // The watchdog macro is optional, but recommended. If present, it
   // must not be placed inside any initial or always-block.
   `WATCHDOG(200ms);

gbt_xu5 #(.DEBUG(0)) DUT (.*);

endmodule // tb_gbt_xu5
