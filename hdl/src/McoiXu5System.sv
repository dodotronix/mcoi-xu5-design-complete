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


module McoiXu5System (gbt_x gbt,
                      diag_x diag,
                      //clocks
                      input mgt_clk_p,
                      input mgt_clk_n,
                      input clk100m_pl_p,
                      input clk100m_pl_n,
                      input ps_clk,
                      input pl_varclk,
                      //serial
                      inout i2c_sda_pl,
                      inout i2c_scl_pl,
                      input rs485_pl_di,
                      output rs485_pl_ro);

// TODO interfaces for motors

// TODO gbt pll

// TODO rs232

// TODO gbt core

// TODO buffers

// TODO leds

   // FOR NEW PCB - QUICK TEST
   logic clk100m_ref, led;
   IBUFDS ibufds_i(.O(clk100m_ref),
                   .I(clk100_pl_p),
                   .IB(clk100_pl_n));

   logic [23:0] cnt;
   always@(posedge clk100m_ref) begin
      cnt <= cnt + 1;
      if (cnt > 10000000) begin
         led <= led ^ 1'b1;
         cnt <= '0;
      end
   end

   assign diag.led[0] = 1'b0;
   assign diag.led[1] = 1'b0;
   assign diag.led[2] = led;
   assign diag.test[0] = clk100m_ref;

//Diagnostics block gathering information about board
// McoiXu5Diagnostics mcoi_diagnostics_i(
//     .clk(clk_from_ps),
//     .rstn(1'b1), // TODO connect to ps reset
//     .temp_o(temp_val[15:0]),
//     .power_o(power_val[15:0]),
//     .rev_o(rev_num_b4),
//     .id_o(id_val),
//     .rs485_i(rs485_pl_di),
//     .rs485_o(rs485_pl_ro),
//     .revpins_i(pcbrev),
//     .sda_io(i2c_sda_pl),
//     .scl_io(i2c_scl_pl));


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

//gbt_pingroup i_pg_gbt(
    ////hw pins sfp
    //.sfp_rx_p(sfp1_gbitin_p),
    //.sfp_rx_n(sfp1_gbitin_n),
    //.sfp_tx_p(sfp1_gbitout_p),
    //.sfp_tx_n(sfp1_gbitout_n),
    //.sfp_rats_o(sfp1_rateselect),
    //.sfp_txdis_o(sfp1_txdisable),
    //.sfp_los_i(sfp1_los),
    //.mgt_clk120m_ip(mgt_clk_p),
    //.mgt_clk120m_in(mgt_clk_n),
    //.clk40m_o(clk40m_l),

    ////pin group
    //.gbt_data_o(data_to_mcoi),
    //.gbt_data_i(data_from_mcoi));

endmodule // McoiXu5System
