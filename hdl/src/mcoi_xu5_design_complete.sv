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

                                 //rs485 programming interface
                                 t_rs485.producer rs485_x,

                                 output logic mreset_vadj,

                                 // clocks - MGT 120MHz (TX/RX)
                                 input logic mgt_fdbk_p,
                                 input logic mgt_fdbk_n,

                                 input logic mgt_clk_p,
                                 input logic mgt_clk_n,

                                 // clocks - MGT derived 50MHz
                                 input logic clk100m_pl_p,
                                 input logic clk100m_pl_n,

                                 // NOTE this input is just
                                 // for devkit design
                                 output logic pl_varclk_p,
                                 output logic pl_varclk_n
                                );

   logic gbt_pll_locked,
         ExternalPll120MHzMGT,
         recovered_clk;

   logic [31:0] shared_reg_tri_i;
   logic [31:0] shared_reg_tri_o;
   logic [31:0] shared_reg_tri_t;

   logic [31:0] shared_memory_port_addr;
   logic [31:0] shared_memory_port_din;
   logic [31:0] shared_memory_port_dout;
   logic [3:0] shared_memory_port_we;
   logic shared_memory_port_en;
   logic shared_memory_port_rst;
   logic shared_memory_port_clk;

   /* always_ff @(posedge clk_tree_x.ClkRs120MHz_ix.clk)
       if(clk_tree_x.ClkRs120MHz_ix.reset) rs485_pl_ro <= 1'b0;
       else rs485_pl_ro <= (rs485_pl_di) ? rs485_pl_di : rs485_pl_ro; */

   t_clocks clk_tree_x();
   t_register ps_register_x();
   t_buffer ps_buffer_x(clk_tree_x.ClkRs40MHz_ix);
   t_gbt_data #(.CLOCKING_SCHEME(0))
   gbt_data_x(.ClkRs_ix(clk_tree_x.ClkRs40MHz_ix),
              .ClkRsRx_ix(clk_tree_x.ClkRs120MHz_ix),
              .ClkRsTx_ix(clk_tree_x.ClkRsVar_ix),
              .refclk(ExternalPll120MHzMGT));

    // in the system you find just buffers plls
    // and sync of resets with clock domains
    mcoi_xu5_system sys_i (.*);

    // application serving the stepper motors
    mcoi_xu5_application app_i (.*);

    // GBT instance
    gbt_zynq_usplus #(.DEBUG(1), .GEFE_MODE(1)) gbt_zynq_usplus_inst(
        .*);

   zynq_ultrasp_ps_system i_ps_system(.*);

   // PS control register interface assignments
   assign ps_register_x.status = shared_reg_tri_o;
   assign shared_reg_tri_i = ps_register_x.control;

   // PS buffer interface assignments
   assign shared_memory_port_en = ps_buffer_x.en;
   assign ps_buffer_x.dout = shared_memory_port_dout;
   assign shared_memory_port_we = ps_buffer_x.we;
   assign shared_memory_port_addr = ps_buffer_x.addr;
   assign shared_memory_port_clk = ps_buffer_x.ClkRs_ix.clk;
   assign shared_memory_port_rst = ps_buffer_x.ClkRs_ix.reset;
   assign shared_memory_port_din = ps_buffer_x.din;

endmodule // mcoi_xu5_design_complete
