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
// Copyright (c) March 2022 CERN

//-----------------------------------------------------------------------------
// @file SI5338_CONFIGURER.SV
// @brief
// @author Petr Pacner  <petr.pacner@cern.ch>, CERN
// @date 04 March 2022
// @details
//
//
// @platform Altera Quartus
// @standard IEEE 1800-2012
//-----------------------------------------------------------------------------

module si5338_configurer
  (input logic Clk,
   input logic Rstp,
   input [7:0]   Data_i8b,
   input         Rdy_i,
   output logic  Finished_o,
   output logic  Rw_o,
   output [15:0] Data_o16b,
   output        Val_o
);

   logic         valid;
   logic         rdy;
   logic [18:0]  raw_data_19b;

   // TODO place the bram here instead of
   // instantiating it inside of the feeder
   feeder feeder_i(.raw_data_o19b(raw_data_19b),
                   .valid_o(valid),
                   .ready_i(rdy),
                   .clk(Clk),
                   .rstp(Rstp));

   // NOTE this interprets the data from
   // bram and cast it to the i2c master

   // TODO create an i2c interface with
   // wires to be able to connect the
   // interfaces together
   interpreter interpreter_i(.rstp(Rstp),
                             .clk(Clk),
                             .Ardy_o(rdy),
                             .Aval_i(valid),
                             .Adata_i19b(raw_data_19b),
                             .Brdy_i(Rdy_i),
                             .Bval_o(Val_o),
                             .Finished_o(Finished_o),
                             .Bdata_i8b(Data_i8b),
                             .Bdata_o16b(Data_o16b),
                             .Brw_o(Rw_o));

endmodule // si5338_configurer
