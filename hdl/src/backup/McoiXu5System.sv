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
// @file MCOIXU5SYSTEM.SV
// @brief
// @author Petr Pacner  <petr.pacner@cern.ch>, CERN
// @date 20 February 2022
// @details
//
//
// @platform Altera Quartus
// @standard IEEE 1800-2012
//-----------------------------------------------------------------------------

import MCPkg::*;
import CKRSPkg::*;
import constants::*;
import types::*;

// NOTE: original GEFE design uses GBT frame clock of 40MHz and local
// oscillator of 25MHz. These are here mimicked by using 40MHz from
// MGT PLL clocks and 25MHz going from LOCAL OSCILLATOR 100MHz passing
// through PLL clock (ClkRs40MHz_ix in clock tree). This is because
// MGT pll might not work when not programmed while local oscillator
// works every time

module McoiXu5System (
    // t_diag.producer diag_x,
    //clocks
    t_clocks.consumer clk_tree_x,
    // t_display.producer display_x,
    input logic gbt_los,
    input logic rxready,
    input logic txready,
    input logic tx_frmclk,
    input logic rx_frmclk, 
    t_gbt_data.consumer gbt_data_x
	);

    logic 		SFP_reset;
    logic [63:0] feed_cnt;

    // SFP LOS is connected to reset of the module
    vme_reset_sync_and_filter u_SFP_reset_sync
    (.rst_ir   (1'b0),
        .clk_ik   (gbt_data_x.ClkRs_ix.clk),
        .cen_ie   (1'b1),
        .data_i   (gbt_los),
        .data_o   (SFP_reset)
    );

    // TEST writing data
   t_sfp_stream DataGbt;
   always_ff @(posedge gbt_data_x.ClkRs_ix.clk) begin
       if(SFP_reset) begin
           feed_cnt <= '0; 
           DataGbt <= '0;
       end else begin
           feed_cnt <= feed_cnt + $size(feed_cnt)'(1);
           DataGbt.motor_data_b64 <= feed_cnt;
       end
   end

   always_comb begin
       gbt_data_x.data_sent.motor_data_b64 = DataGbt.motor_data_b64;
   end

/* illa_gbtcore illa_gbtcore_inst (
	.clk(gbt_data_x.ClkRs_ix.clk), // input wire clk
	.probe0(gbt_data_x.data_sent.motor_data_b64), // input wire [63:0]  probe0  
	.probe1(gbt_data_x.data_received.motor_data_b64), // input wire [63:0]  probe1 
	.probe2(rxready), // input wire [0:0]  probe2 
	.probe3(txready), // input wire [0:0]  probe3 
	.probe4(tx_frmclk), // input wire [0:0]  probe5 
	.probe5(rx_frmclk), // input wire [0:0]  probe6 
	.probe6(SFP_reset), // input wire [0:0]  probe4 
	.probe7(gbt_los) // input wire [0:0]  probe7
); */


endmodule // McoiXu5System
