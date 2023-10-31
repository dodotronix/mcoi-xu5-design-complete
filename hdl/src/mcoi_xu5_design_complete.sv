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
                                 t_motors.producer motors_x,

                                 // SFP interface
                                 t_gbt.producer gbt_x,

                                 //diagnostics
                                 t_diag.producer diag_x,

                                 //display
                                 t_display.producer display_x,

                                 output logic mreset_vadj,

                                 // clocks - MGT 120MHz
                                 input logic mgt_clk_p,
                                 input logic mgt_clk_n,

                                 // output logic [2:0] mled,

                                 // clocks - MGT derived 50MHz
                                 input logic clk100m_pl_p,
                                 input logic clk100m_pl_n,
                                 input logic pl_varclk,

                                 // serial interface
                                 input logic rs485_pl_di,
                                 output logic rs485_pl_ro
                                );

    logic ready;

   assign mreset_vadj = 1'b0;

   always_ff @(posedge clk_tree_x.ClkRs120MHz_ix.clk)
       if(clk_tree_x.ClkRs120MHz_ix.reset) rs485_pl_ro <= 1'b0;
       else rs485_pl_ro <= (rs485_pl_di) ? rs485_pl_di : rs485_pl_ro;

   t_clocks clk_tree_x();
   t_gbt_data gbt_data_x(.ClkRs_ix(clk_tree_x.ClkRs40MHz_ix));

    // in the system you find just buffers plls
    // and sync of resets with clock domains
    mcoi_xu5_system sys_i (.*);

    // application serving the stepper motors
    mcoi_xu5_application app_i (.*);

    // GBT instance
    gbt_zynq_usplus #(.DEBUG(1)) gbt_zynq_usplus_inst(
        .external_pll_source_120mhz(ExternalPll120MHzMGT),
        .*);

   // ps part just for storing data to qspi
   zynq_ultrasp_ps_system i_ps_system();

endmodule // mcoi_xu5_design_complete
