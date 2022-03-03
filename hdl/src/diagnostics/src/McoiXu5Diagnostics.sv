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
// @file MCOIXU5DIAGNOSTICS.SV
// @brief
// @author Petr Pacner  <pepacner@cern.ch>, CERN
// @date 20 February 2022
// @details
//
//
// @platform Altera Quartus
// @standard IEEE 1800-2012
//-----------------------------------------------------------------------------

import CKRSPkg::*;

module McoiXu5Diagnostics #(parameter address=7'h20,
                            parameter i2c_divider=10'h3ff)
   (input ckrs_t ClkRs_ix,
    output done,
    inout  i2c_sda_pl,
    inout  i2c_scl_pl);

   /*AUTOWIRE*/
   /*AUTOREGINPUT*/
   /*AUTOINOUTPARAM(*McoiXu5Diagnostics*)*/

   logic [18:0] raw_data_19b;
   logic [15:0] data_to_i2c;
   logic [7:0]  data_from_i2c;

   // control and data signals
   // for i2c master
   logic        AckReceived_o,
                Done_o,
                SendStartBit_ip,
                SendByte_ip,
                GetByte_ip,
                SendStopBit_ip,
                AckToSend_i;

   logic [7:0]  Byte_ib8,
                Byte_ob8;

   logic        clk,
                rstp,
                rw,
                aval,
                bval,
                brdy;

   always_comb begin
      clk = ClkRs_ix.clk;
      rstp = ClkRs_ix.reset;
   end

   // TODO place the bram here instead of
   // instantiating it inside of the feeder
   feeder feeder_i(.raw_data_o19b(raw_data_19b),
                   .valid_o(aval),
                   .ready_i(ardy),
		   .*);

   // NOTE this interprets the data from
   // bram and cast it to the i2c master

   // TODO create an i2c interface with
   // wires to be able to connec the
   // interfaces together
   interpreter interpreter_i(.rstp(rstp),
                             .clk(clk),
                             .Ardy_o(ardy),
                             .Aval_i(aval),
                             .Adata_i19b(raw_data_19b),
                             .Brdy_i(brdy),
                             .Bval_o(bval),
                             .Finished_o(done),
                             .Bdata_i8b(data_from_i2c),
                             .Bdata_o16b(data_to_i2c),
                             .Brw_o(rw));

   I2cReader i2c_reader_i(.Done_i(Done_o),
                          .AckReceived_i(AckReceived_o),
                          .SendStartBit_o(SendStartBit_ip),
                          .SendByte_o(SendByte_ip),
                          .GetByte_o(GetByte_ip),
                          .SendStopBit_o(SendStopBit_ip),
                          .AckToSend_o(AckToSend_i),
                          .Byte_ib8(Byte_ob8),
                          .Byte_ob8(Byte_ib8),
                          .Data_i16b(data_to_i2c),
                          .Data_o8b(data_from_i2c),
                          .Rw_i(rw),
                          .Ready_o(brdy),
                          .Valid_i(bval),
                          .Dev_addr_i7b(address),
                          .rstp(rstp),
                          .clk(clk));

   I2cMasterGeneric #(.g_CycleLenght(i2c_divider))
   i2c_master_generic_i(.Clk_ik         (clk),
                        .Rst_irq        (rstp),
                        .Scl_ioz        (i2c_scl_pl),
                        .Sda_ioz        (i2c_sda_pl),
                        .*);

endmodule // McoiXu5Diagnostics
