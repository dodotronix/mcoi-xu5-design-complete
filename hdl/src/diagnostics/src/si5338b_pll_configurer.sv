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
// @file SI5338B_PLL_CONFIGURER.SV
// @brief
// @author Petr Pacner  <petr.pacner@cern.ch>, CERN
// @date 01 March 2022
// @details
//
//
// @platform Altera Quartus
// @standard IEEE 1800-2012
//-----------------------------------------------------------------------------

import CKRSPkg::*;


module si5338b_pll_configurer (input ckrs_t ClkRs_ix,
                               input en,
                               inout sda_io,
                               inout scl_io);

   // TODO place the bram here instead of
   // instantiating it inside of the feeder

   feeder feeder_i(.*);

   // NOTE this interprets the data from
   // bram and cast it to the i2c master

   // TODO create an i2c interface with
   // wires to be able to connec the
   // interfaces together
   interperter interpreter_i(.*);


endmodule // si5338b_pll_configurer
