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

module mcoi_xu5_design_complete (//motors
                                 motors_x.producer motors,
                                 //optical interface
                                 //gbt_x.producer gbt,
                                 //diagnostics
                                 diag_x.producer diag,
                                 //display
                                 display_x.producer display,
                                 output        mreset_vadj,
                                 // clocks
                                 input         mgt_clk_p,
                                 input         mgt_clk_n,
                                 input         pl_varclk,
                                 input         clk100m_pl_p,
                                 input         clk100m_pl_n,

                                 // serial interfaces
                                 inout         i2c_sda_pl,
                                 inout         i2c_scl_pl,
                                 input         rs485_pl_di,
                                 output        rs485_pl_ro);


   t_clocks clk_tree_x();

   // 100MHz oscillator and associated reset
   IBUFDS ibufds_i(.O(clk_tree_x.ClkRs100MHz_ix.clk),
                   .I(clk100m_pl_p),
                   .IB(clk100m_pl_n));

   vme_reset_sync_and_filter u_125MHz_reset_sync
     (.rst_ir   (1'b0),
      .clk_ik   (clk_tree_x.ClkRs100MHz_ix.clk),
      .cen_ie   (1'b1),
      // @TODO: do reset thingy here - which pin if any?
      .data_i   ('0),
      .data_o   (clk_tree_x.ClkRs100MHz_ix.reset)
      );

   //logic system part
   McoiXu5System i_mcoi_xu5_system (.*);

   // logic application part
   // McoiXu5Application i_mcoi_xu5_app(.*);

   // ps part just for storing data to qspi
   mcoi_xu5_ps_part i_mcoi_xu5_ps_part();

   //TODO fpga_supply_ok??
   //assign led[6] = 1'b0;
   //


endmodule // mcoi_xu5_design_complete
