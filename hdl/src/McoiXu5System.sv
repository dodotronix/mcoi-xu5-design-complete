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

import CKRSPkg::*;


module McoiXu5System (//gbt_x gbt,
                      t_diag.producer diag_x,
                      //clocks
		      t_clocks.consumer clk_tree_x,
                      t_display.producer display_x,
                      //input ps_clk,
                      //input pl_varclk,
                      //serial
                      inout i2c_sda_pl,
                      inout i2c_scl_pl
                      //input rs485_pl_di,
                      //output rs485_pl_ro
		      );


   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   logic		done;			// From i_McoiXu5Diagnostics of McoiXu5Diagnostics.v
   // End of automatics
   /*AUTOREGINPUT*/

// TODO interfaces for motors

// TODO gbt pll

// TODO rs232

// TODO gbt core

// TODO buffers

// TODO leds

   // artificially too large to feed directly leds
   logic [127:0] cnt = '0;
   always@(posedge clk_tree_x.ClkRs100MHz_ix.clk)
      cnt <= cnt + 1;

   assign diag_x.led[0] = ~done;
   assign diag_x.led[1] = cnt[26];
   // roughly second
   assign diag_x.led[2] = cnt[27];

   logic [3:0][1:0][15:0] ledData_b; //4 rows, 2states, 16 columns

   // artificial assignment to see led diodes working ok
   assign ledData_b = cnt;


   // bar led-diode driver, 10MHz clock
   tlc5920 #(.g_divider (9))
   tlc_5920_i(.ClkRs_ix(clk_tree_x.ClkRs100MHz_ix),
	      .*);

   localparam address = 7'h80;
   localparam i2c_divider = 250;
   McoiXu5Diagnostics
     #(.address(address),
     .i2c_divider(i2c_divider))
   i_McoiXu5Diagnostics (.ClkRs_ix(clk_tree_x.ClkRs100MHz_ix),
			 .*);

////signals
//mcinput_t [NUMBER_OF_MOTORS_PER_FIBER:1] motorStatus;
//mcoutput_t [NUMBER_OF_MOTORS_PER_FIBER:1] motorControl;

////interface
//display_x display();
//logic clk40m_l;

////module structure


//motor_pingroup i_pg_motors(
    ////motors
    //.StepBOOST_o(pl_boost),
    //.StepDIR_o(pl_dir),
    //.StepDeactivate_o(pl_en),
    //.StepOutP_o(pl_clk),
    //.StepPFail_i(pl_pfail),
    //.RawSwitchesA(pl_sw_outa),
    //.RawSwitchesB(pl_sw_outb),

    ////display
    //.latch_o(latch),
    //.blank_o(blank),
    //.csel_ob3(csel),
    //.sclk_o(sclk),
    //.data_o(sin),

    ////pin groups
    //.motorStatus_ob(motorStatus),
    //.motorControl_ib(motorControl),
    //.display(display));

//logic [83:0] data_to_mcoi, data_from_mcoi;
//logic [3:0] rev_num_b4;
//logic [31:0]temp_val, power_val;
//logic [63:0] id_val;

//mcoi_base i_mcoi_base(
    ////motors
    //.motorStatus_ib(motorStatus),
    //.motorControl_ob(motorControl),

    ////diagnostics
    //.display(display),
    //.led6_no(led[5:0]),
    //.pinhead(test),
    //.pcbrev4b_i(rev_num_b4),
    //.UniqueID_oqb64(id_val),
    //.temperature32b_i(temp_val),
    //.power32b_i(power_val),

    ////user input (optical link)
    //.reset_ni(sfp1_los),
    //.optsig_los_i(sfp1_los),
    //.mreset_no(mreset_vadj),
    //.clk40m_i(clk40m_l),
    //.clk25m_i(clk40m_l), //TODO use clk25mhz

    //.data_from_stream_ib80(data_to_mcoi[79:0]),
    //.data_to_stream_ob80(data_from_mcoi[79:0]),
    //.sc_from_stream_ib2(data_to_mcoi[81:80]),
    //.sc_to_stream_ob2(data_from_mcoi[81:80]));

endmodule // McoiXu5System
