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
// @file TB_MCOIXU5SYSTEM.SV
// @brief
// @author Dr. David Belohrad  <david@belohrad.ch>, CERN
// @date 23 February 2022
// @details
//
//
// @platform Altera Quartus
// @standard IEEE 1800-2012
//-----------------------------------------------------------------------------

`include "vunit_defines.svh"

import CKRSPkg::*;
import clsclk::*;


//
module tb_McoiXu5System;
   timeunit 1ns;
   timeprecision 100ps;

   localparam integer clk_period = 20; // clock period in ns
   ckrs_t ClkRs_ix = '{clk:'0, reset:'0};

   /*AUTOWIRE*/
   /*AUTOREGINPUT*/
   /*AUTOINOUTPARAM("McoiXu5System")*/

   t_diag diag_x();
   t_clocks clk_tree_x();
   clock_generator clkg;


   always forever #(clk_period/2 * 1ns) ClkRs_ix.clk <= ~ClkRs_ix.clk;
   default clocking cb @(posedge ClkRs_ix.clk); endclocking

   `TEST_SUITE begin

      `TEST_SUITE_SETUP begin
	 clkg = new;
	 clkg.clk_tree_x = clk_tree_x;
	 clkg.run();
      end

      `TEST_CASE("debug_test") begin

         $display("This test case is expected to pass");
         `CHECK_EQUAL(1, 1);
      end

   end;

   // The watchdog macro is optional, but recommended. If present, it
   // must not be placed inside any initial or always-block.
   `WATCHDOG(10ms);

   McoiXu5System #(/*AUTOINSTPARAM*/) DUT
     (.*);

endmodule
