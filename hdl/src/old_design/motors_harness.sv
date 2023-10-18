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
// Copyright (c) April 2018 CERN

//-----------------------------------------------------------------------------
// @file MOTORS_HARNESS.SV
// @brief 16 motors are connected to FMC connector
// @author Dr. David Belohrad  <david@belohrad.ch>, CERN
// @date 20 April 2018
// @details
//
//
// @platform Altera Quartus
// @standard IEEE 1800-2012
//-----------------------------------------------------------------------------

import CKRSPkg::*;


module motors_harness (
		       inout [33: 0] FmcLa_iob34p,
		       inout [33: 0] FmcLa_iob34n,
		       inout [21: 0] FmcHb_iob22p,
		       inout [21: 0] FmcHb_iob22n,
		       inout [23: 0] FmcHa_iob24p,
		       inout [23: 0] FmcHa_iob24n
		       );

   logic [16:1] 		     StepENAB_ib,
				     StepBOOST_ib,
				     StepDIR_ib,
				     StepOutP_ib,
				     OH_ob,
				     StepPFail_ob;
   logic [16:1][1:0] 		     Switches_15b2;

   // 16 motors to go
   generate
      for(genvar i = 0; i < 16; i++)
	motor
		     #(
		       .g_CounterBits			(4),
		       .g_SwitchThreshold		(4))
      i_motor
		     (/*AUTOINST*/
		      // Outputs
		      .OH_o				(OH_ob[i]),
		      .StepPFail_o			(StepPFail_ob[i]),
		      .Switches_ob			(Switches_15b2[i]),
		      // Inputs
		      .StepOutP_i			(StepOutP_ib[i]),
		      .StepENAB_i			(StepENAB_ib[i]),
		      .StepBOOST_i			(StepBOOST_ib[i]),
		      .StepDIR_i			(StepDIR_ib[i]));
   endgenerate

   // and fancy pin mapping coming from motor drivers schematics
   // unfortunately, manual work required:
   // assignment of signals which are provided by motor controller:
   assign FmcLa_iob34n[18] = Switches_15b2[1] [0];
   assign FmcLa_iob34n[27] = Switches_15b2[1] [1];
   assign FmcLa_iob34n[23] = Switches_15b2[2] [0];
   assign FmcLa_iob34n[26] = Switches_15b2[2] [1];
   assign FmcHb_iob22p[5] = Switches_15b2[3] [0];
   assign FmcHb_iob22p[9] = Switches_15b2[3] [1];
   assign FmcHb_iob22p[4] = Switches_15b2[4] [0];
   assign FmcHb_iob22p[13] = Switches_15b2[4] [1];
   assign FmcLa_iob34n[17] = Switches_15b2[5] [0];
   assign FmcLa_iob34p[25] = Switches_15b2[5] [1];
   assign FmcHb_iob22p[3] = Switches_15b2[6] [0];
   assign FmcHb_iob22n[5] = Switches_15b2[6] [1];
   assign FmcLa_iob34p[23] = Switches_15b2[7] [0];
   assign FmcLa_iob34p[26] = Switches_15b2[7] [1];
   assign FmcLa_iob34p[18] = Switches_15b2[8] [0];
   assign FmcLa_iob34p[27] = Switches_15b2[8] [1];
   assign FmcLa_iob34n[10] = Switches_15b2[9] [0];
   assign FmcLa_iob34p[14] = Switches_15b2[9] [1];
   assign FmcLa_iob34n[9] = Switches_15b2[10][0];
   assign FmcLa_iob34n[13] = Switches_15b2[10][1];
   assign FmcHa_iob24p[16] = Switches_15b2[11][0];
   assign FmcLa_iob34n[14] = Switches_15b2[11][1];
   assign FmcLa_iob34p[13] = Switches_15b2[12][0];
   assign FmcLa_iob34p[17] = Switches_15b2[12][1];
   assign FmcHa_iob24n[9] = Switches_15b2[13][0];
   assign FmcLa_iob34n[5] = Switches_15b2[13][1];
   assign FmcLa_iob34p[6] = Switches_15b2[14][0];
   assign FmcHa_iob24p[13] = Switches_15b2[14][1];
   assign FmcLa_iob34p[5] = Switches_15b2[15][0];
   assign FmcLa_iob34p[9] = Switches_15b2[15][1];
   assign FmcLa_iob34n[6] = Switches_15b2[16][0];
   assign FmcLa_iob34p[10] = Switches_15b2[16][1];

   assign FmcHb_iob22p[20] = StepPFail_ob[1];
   assign FmcLa_iob34n[30] = StepPFail_ob[2];
   assign FmcHb_iob22n[10] = StepPFail_ob[3];
   assign FmcLa_iob34p[31] = StepPFail_ob[4];
   assign FmcHb_iob22p[10] = StepPFail_ob[5];
   assign FmcHb_iob22n[12] = StepPFail_ob[6];
   assign FmcHb_iob22n[7] = StepPFail_ob[7];
   assign FmcHb_iob22p[6] = StepPFail_ob[8];
   assign FmcLa_iob34n[24] = StepPFail_ob[9];
   assign FmcHb_iob22n[6] = StepPFail_ob[10];
   assign FmcHb_iob22n[11] = StepPFail_ob[11];
   assign FmcLa_iob34n[28] = StepPFail_ob[12];
   assign FmcLa_iob34p[30] = StepPFail_ob[13];
   assign FmcHb_iob22n[16] = StepPFail_ob[14];
   assign FmcLa_iob34p[32] = StepPFail_ob[15];
   assign FmcHb_iob22n[20] = StepPFail_ob[16];



   assign StepBOOST_ib[10] = FmcHb_iob22n[0];
   assign StepDIR_ib[10] = FmcLa_iob34p[15];
   assign StepENAB_ib[10] = FmcHb_iob22p[7];
   assign StepOutP_ib[10] = FmcHa_iob24p[17];
   assign StepBOOST_ib[11] = FmcHa_iob24p[10];
   assign StepDIR_ib[11] = FmcHa_iob24n[11];
   assign StepENAB_ib[11] = FmcHa_iob24n[7];
   assign StepOutP_ib[11] = FmcHa_iob24p[7];
   assign StepBOOST_ib[12] = FmcHa_iob24p[2];
   assign StepDIR_ib[12] = FmcHa_iob24n[3];
   assign StepENAB_ib[12] = FmcHb_iob22n[13];
   assign StepOutP_ib[12] = FmcHb_iob22p[12];
   assign StepBOOST_ib[13] = FmcLa_iob34p[29];
   assign StepDIR_ib[13] = FmcHb_iob22p[11];
   assign StepENAB_ib[13] = FmcLa_iob34n[25];
   assign StepOutP_ib[13] = FmcHb_iob22n[8];
   assign StepBOOST_ib[14] = FmcLa_iob34n[22];
   assign StepDIR_ib[14] = FmcHb_iob22p[8];
   assign StepENAB_ib[14] = FmcHb_iob22p[2];
   assign StepOutP_ib[14] = FmcLa_iob34p[22];
   assign StepBOOST_ib[15] = FmcHa_iob24p[19];
   assign StepDIR_ib[15] = FmcLa_iob34n[12];
   assign StepENAB_ib[15] = FmcHa_iob24n[8];
   assign StepOutP_ib[15] = FmcHa_iob24p[12];
   assign StepBOOST_ib[16] = FmcLa_iob34n[3];
   assign StepDIR_ib[16] = FmcLa_iob34p[7];
   assign StepENAB_ib[16] = FmcLa_iob34p[4];
   assign StepOutP_ib[16] = FmcLa_iob34n[4];
   assign StepBOOST_ib[1] = FmcLa_iob34n[8];
   assign StepDIR_ib[1] = FmcLa_iob34n[7];
   assign StepENAB_ib[1] = FmcHa_iob24p[8];
   assign StepOutP_ib[1] = FmcLa_iob34p[8];
   assign StepBOOST_ib[2] = FmcHa_iob24p[15];
   assign StepDIR_ib[2] = FmcLa_iob34p[16];
   assign StepENAB_ib[2] = FmcLa_iob34p[11];
   assign StepOutP_ib[2] = FmcLa_iob34p[12];
   assign StepBOOST_ib[3] = FmcLa_iob34n[20];
   assign StepDIR_ib[3] = FmcHb_iob22n[2];
   assign StepENAB_ib[3] = FmcLa_iob34n[16];
   assign StepOutP_ib[3] = FmcHb_iob22n[3];
   assign StepBOOST_ib[4] = FmcLa_iob34p[24];
   assign StepDIR_ib[4] = FmcHb_iob22n[9];
   assign StepENAB_ib[4] = FmcLa_iob34p[21];
   assign StepOutP_ib[4] = FmcHb_iob22n[4];
   assign StepBOOST_ib[5] = FmcHa_iob24p[3];
   assign StepDIR_ib[5] = FmcHa_iob24n[2];
   assign StepENAB_ib[5] = FmcLa_iob34n[29];
   assign StepOutP_ib[5] = FmcHb_iob22p[16];
   assign StepBOOST_ib[6] = FmcHa_iob24n[6];
   assign StepDIR_ib[6] = FmcHa_iob24p[11];
   assign StepENAB_ib[6] = FmcLa_iob34n[2];
   assign StepOutP_ib[6] = FmcHa_iob24p[6];
   assign StepBOOST_ib[7] = FmcHa_iob24p[18];
   assign StepDIR_ib[7] = FmcLa_iob34n[11];
   assign StepENAB_ib[7] = FmcHa_iob24p[14];
   assign StepOutP_ib[7] = FmcHa_iob24n[10];
   assign StepBOOST_ib[8] = FmcHb_iob22p[1];
   assign StepDIR_ib[8] = FmcLa_iob34n[19];
   assign StepENAB_ib[8] = FmcLa_iob34p[20];
   assign StepOutP_ib[8] = FmcLa_iob34n[15];
   assign StepBOOST_ib[9] = FmcLa_iob34n[21];
   assign StepDIR_ib[9] = FmcHb_iob22n[1];
   assign StepENAB_ib[9] = FmcHb_iob22p[0];
   assign StepOutP_ib[9] = FmcLa_iob34p[19];

endmodule // motors_harness
