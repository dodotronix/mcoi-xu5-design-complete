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
// @file PIN_MAPPING.SV
// @brief Maps FMC pins to real motors' pin names
// @author Dr. David Belohrad  <david@belohrad.ch>, CERN
// @date 17 April 2018
// @details This module maps the FMC connector signals into real motor
// signals. These connections are defined by schematics in EDA-03150
// and EDA-03149
//
//
// @platform Altera Quartus
// @standard IEEE 1800-2012
//-----------------------------------------------------------------------------

import CKRSPkg::*;
import MCPkg::*;

module pin_mapping

  (
   // motor controller interface - signals converted from FMC to some
   // sensefull data stream. Registered packed array of these:
   output 	     mcinput_t [NUMBER_OF_MOTORS_PER_FIBER:1] motorStatus_ob,
   input 	     mcoutput_t [NUMBER_OF_MOTORS_PER_FIBER:1] motorControl_ib,
   // test output signals:
   input logic [7:0] test_ib8,
   // motor drivers common reset output:
   input logic 	     mreset_i,
   // indication of power supply OK if backplane permits. But this
   // signal can be now ignored because the backplane is as of now
   // (11/01/18 11:33:54) not implemented the way this signal can be
   // used. For the old-style backplane this signal will always return
   // '1' because the pins are grounded (and then go through schmitt inverter)
   output 	     supplyOK_o,
   output [3:0]      PCBrevision_o4,
		     // display interface
		     display_x display,
   // FMC side signals - interface to motor driver
   inout [33: 0]     FmcLa_iob34p,
   inout [33: 0]     FmcLa_iob34n,
   inout [21: 0]     FmcHb_iob22p,
   inout [21: 0]     FmcHb_iob22n,
   inout [23: 0]     FmcHa_iob24p,
   inout [23: 0]     FmcHa_iob24n
   );

   // and all overheat signals are for the moment just ignored
   assign motorStatus_ob[1].OH_i = 1'b0;
   assign motorStatus_ob[2].OH_i = 1'b0;
   assign motorStatus_ob[3].OH_i = 1'b0;
   assign motorStatus_ob[4].OH_i = 1'b0;
   assign motorStatus_ob[5].OH_i = 1'b0;
   assign motorStatus_ob[6].OH_i = 1'b0;
   assign motorStatus_ob[7].OH_i = 1'b0;
   assign motorStatus_ob[8].OH_i = 1'b0;
   assign motorStatus_ob[9].OH_i = 1'b0;
   assign motorStatus_ob[10].OH_i = 1'b0;
   assign motorStatus_ob[11].OH_i = 1'b0;
   assign motorStatus_ob[12].OH_i = 1'b0;
   assign motorStatus_ob[13].OH_i = 1'b0;
   assign motorStatus_ob[14].OH_i = 1'b0;
   assign motorStatus_ob[15].OH_i = 1'b0;
   assign motorStatus_ob[16].OH_i = 1'b0;
   // motor status casting - all fail signals
   assign motorStatus_ob[10].StepPFail_i = !FmcHb_iob22p[10];
   assign motorStatus_ob[11].StepPFail_i = !FmcHb_iob22n[11];
   assign motorStatus_ob[12].StepPFail_i = !FmcHb_iob22n[12];
   assign motorStatus_ob[13].StepPFail_i = !FmcHb_iob22n[6];
   assign motorStatus_ob[14].StepPFail_i = !FmcLa_iob34n[24];
   assign motorStatus_ob[15].StepPFail_i = !FmcHb_iob22p[6];
   assign motorStatus_ob[16].StepPFail_i = !FmcHb_iob22n[7];
   assign motorStatus_ob[1].StepPFail_i = !FmcHb_iob22n[20];
   assign motorStatus_ob[2].StepPFail_i = !FmcLa_iob34p[32];
   assign motorStatus_ob[3].StepPFail_i = !FmcHb_iob22p[20];
   assign motorStatus_ob[4].StepPFail_i = !FmcLa_iob34n[30];
   assign motorStatus_ob[5].StepPFail_i = !FmcHb_iob22n[16];
   assign motorStatus_ob[6].StepPFail_i = !FmcLa_iob34p[30];
   assign motorStatus_ob[7].StepPFail_i = !FmcLa_iob34p[31];
   assign motorStatus_ob[8].StepPFail_i = !FmcHb_iob22n[10];
   assign motorStatus_ob[9].StepPFail_i = !FmcLa_iob34n[28];
   // switches config. Note INVERSION OF THE PINS, that's because in
   // the hardware we use schmitt INVERTING trigger. Hence inversion
   // at this point will bring the switches to the original logic.
   assign motorStatus_ob[10].RawSwitches_b2[0] = !FmcLa_iob34n[9];
   assign motorStatus_ob[10].RawSwitches_b2[1] = !FmcLa_iob34n[13];
   assign motorStatus_ob[11].RawSwitches_b2[0] = !FmcHa_iob24p[16];
   assign motorStatus_ob[11].RawSwitches_b2[1] = !FmcLa_iob34n[14];
   assign motorStatus_ob[12].RawSwitches_b2[0] = !FmcLa_iob34p[13];
   assign motorStatus_ob[12].RawSwitches_b2[1] = !FmcLa_iob34p[17];
   assign motorStatus_ob[13].RawSwitches_b2[0] = !FmcHa_iob24n[9];
   assign motorStatus_ob[13].RawSwitches_b2[1] = !FmcLa_iob34n[5];
   assign motorStatus_ob[14].RawSwitches_b2[0] = !FmcLa_iob34p[6];
   assign motorStatus_ob[14].RawSwitches_b2[1] = !FmcHa_iob24p[13];
   assign motorStatus_ob[15].RawSwitches_b2[0] = !FmcLa_iob34p[5];
   assign motorStatus_ob[15].RawSwitches_b2[1] = !FmcLa_iob34p[9];
   assign motorStatus_ob[16].RawSwitches_b2[0] = !FmcLa_iob34n[6];
   assign motorStatus_ob[16].RawSwitches_b2[1] = !FmcLa_iob34p[10];
   assign motorStatus_ob[1].RawSwitches_b2[0] = !FmcLa_iob34n[18];
   assign motorStatus_ob[1].RawSwitches_b2[1] = !FmcLa_iob34n[27];
   assign motorStatus_ob[2].RawSwitches_b2[0] = !FmcLa_iob34n[23];
   assign motorStatus_ob[2].RawSwitches_b2[1] = !FmcLa_iob34n[26];
   assign motorStatus_ob[3].RawSwitches_b2[0] = !FmcHb_iob22p[5];
   assign motorStatus_ob[3].RawSwitches_b2[1] = !FmcHb_iob22p[9];
   assign motorStatus_ob[4].RawSwitches_b2[0] = !FmcHb_iob22p[4];
   assign motorStatus_ob[4].RawSwitches_b2[1] = !FmcHb_iob22p[13];
   assign motorStatus_ob[5].RawSwitches_b2[0] = !FmcLa_iob34n[17];
   assign motorStatus_ob[5].RawSwitches_b2[1] = !FmcLa_iob34p[25];
   assign motorStatus_ob[6].RawSwitches_b2[0] = !FmcHb_iob22p[3];
   assign motorStatus_ob[6].RawSwitches_b2[1] = !FmcHb_iob22n[5];
   assign motorStatus_ob[7].RawSwitches_b2[0] = !FmcLa_iob34p[23];
   assign motorStatus_ob[7].RawSwitches_b2[1] = !FmcLa_iob34p[26];
   assign motorStatus_ob[8].RawSwitches_b2[0] = !FmcLa_iob34p[18];
   assign motorStatus_ob[8].RawSwitches_b2[1] = !FmcLa_iob34p[27];
   assign motorStatus_ob[9].RawSwitches_b2[0] = !FmcLa_iob34n[10];
   assign motorStatus_ob[9].RawSwitches_b2[1] = !FmcLa_iob34p[14];
   // motor control casting:
   assign FmcHb_iob22n[0] = motorControl_ib[10].StepBOOST_o;
   assign FmcLa_iob34p[15] = motorControl_ib[10].StepDIR_o;
   assign FmcHb_iob22p[7] = motorControl_ib[10].StepDeactivate_o;
   assign FmcHa_iob24p[17] = motorControl_ib[10].StepOutP_o;

   assign FmcHa_iob24p[10] = motorControl_ib[11].StepBOOST_o;
   assign FmcHa_iob24n[11] = motorControl_ib[11].StepDIR_o;
   assign FmcHa_iob24n[7] = motorControl_ib[11].StepDeactivate_o;
   assign FmcHa_iob24p[7] = motorControl_ib[11].StepOutP_o;

   assign FmcHa_iob24p[2] = motorControl_ib[12].StepBOOST_o;
   assign FmcHa_iob24n[3] = motorControl_ib[12].StepDIR_o;
   assign FmcHb_iob22n[13] = motorControl_ib[12].StepDeactivate_o;
   assign FmcHb_iob22p[12] = motorControl_ib[12].StepOutP_o;

   assign FmcLa_iob34p[29] = motorControl_ib[13].StepBOOST_o;
   assign FmcHb_iob22p[11] = motorControl_ib[13].StepDIR_o;
   assign FmcLa_iob34n[25] = motorControl_ib[13].StepDeactivate_o;
   assign FmcHb_iob22n[8] = motorControl_ib[13].StepOutP_o;

   assign FmcLa_iob34n[22] = motorControl_ib[14].StepBOOST_o;
   assign FmcHb_iob22p[8] = motorControl_ib[14].StepDIR_o;
   assign FmcHb_iob22p[2] = motorControl_ib[14].StepDeactivate_o;
   assign FmcLa_iob34p[22] = motorControl_ib[14].StepOutP_o;

   assign FmcHa_iob24p[19] = motorControl_ib[15].StepBOOST_o;
   assign FmcLa_iob34n[12] = motorControl_ib[15].StepDIR_o;
   assign FmcHa_iob24n[8] = motorControl_ib[15].StepDeactivate_o;
   assign FmcHa_iob24p[12] = motorControl_ib[15].StepOutP_o;

   assign FmcLa_iob34n[3] = motorControl_ib[16].StepBOOST_o;
   assign FmcLa_iob34p[7] = motorControl_ib[16].StepDIR_o;
   assign FmcLa_iob34p[4] = motorControl_ib[16].StepDeactivate_o;
   assign FmcLa_iob34n[4] = motorControl_ib[16].StepOutP_o;

   assign FmcLa_iob34n[8] = motorControl_ib[1].StepBOOST_o;
   assign FmcLa_iob34n[7] = motorControl_ib[1].StepDIR_o;
   assign FmcHa_iob24p[8] = motorControl_ib[1].StepDeactivate_o;
   assign FmcLa_iob34p[8] = motorControl_ib[1].StepOutP_o;

   assign FmcHa_iob24p[15] = motorControl_ib[2].StepBOOST_o;
   assign FmcLa_iob34p[16] = motorControl_ib[2].StepDIR_o;
   assign FmcLa_iob34p[11] = motorControl_ib[2].StepDeactivate_o;
   assign FmcLa_iob34p[12] = motorControl_ib[2].StepOutP_o;

   assign FmcLa_iob34n[20] = motorControl_ib[3].StepBOOST_o;
   assign FmcHb_iob22n[2] = motorControl_ib[3].StepDIR_o;
   assign FmcLa_iob34n[16] = motorControl_ib[3].StepDeactivate_o;
   assign FmcHb_iob22n[3] = motorControl_ib[3].StepOutP_o;

   assign FmcLa_iob34p[24] = motorControl_ib[4].StepBOOST_o;
   assign FmcHb_iob22n[9] = motorControl_ib[4].StepDIR_o;
   assign FmcLa_iob34p[21] = motorControl_ib[4].StepDeactivate_o;
   assign FmcHb_iob22n[4] = motorControl_ib[4].StepOutP_o;

   assign FmcHa_iob24p[3] = motorControl_ib[5].StepBOOST_o;
   assign FmcHa_iob24n[2] = motorControl_ib[5].StepDIR_o;
   assign FmcLa_iob34n[29] = motorControl_ib[5].StepDeactivate_o;
   assign FmcHb_iob22p[16] = motorControl_ib[5].StepOutP_o;

   assign FmcHa_iob24n[6] = motorControl_ib[6].StepBOOST_o;
   assign FmcHa_iob24p[11] = motorControl_ib[6].StepDIR_o;
   assign FmcLa_iob34n[2] = motorControl_ib[6].StepDeactivate_o;
   assign FmcHa_iob24p[6] = motorControl_ib[6].StepOutP_o;

   assign FmcHa_iob24p[18] = motorControl_ib[7].StepBOOST_o;
   assign FmcLa_iob34n[11] = motorControl_ib[7].StepDIR_o;
   assign FmcHa_iob24p[14] = motorControl_ib[7].StepDeactivate_o;
   assign FmcHa_iob24n[10] = motorControl_ib[7].StepOutP_o;

   assign FmcHb_iob22p[1] = motorControl_ib[8].StepBOOST_o;
   assign FmcLa_iob34n[19] = motorControl_ib[8].StepDIR_o;
   assign FmcLa_iob34p[20] = motorControl_ib[8].StepDeactivate_o;
   assign FmcLa_iob34n[15] = motorControl_ib[8].StepOutP_o;

   assign FmcLa_iob34n[21] = motorControl_ib[9].StepBOOST_o;
   assign FmcHb_iob22n[1] = motorControl_ib[9].StepDIR_o;
   assign FmcHb_iob22p[0] = motorControl_ib[9].StepDeactivate_o;
   assign FmcLa_iob34p[19] = motorControl_ib[9].StepOutP_o;
   // test signals:
   assign FmcHa_iob24n[0] = test_ib8[0];
   assign FmcLa_iob34p[0] = test_ib8[1];
   assign FmcHa_iob24p[0] = test_ib8[2];
   assign FmcHa_iob24p[4] = test_ib8[3];
   assign FmcHa_iob24p[1] = test_ib8[4];
   assign FmcLa_iob34p[2] = test_ib8[5];
   assign FmcHa_iob24n[1] = test_ib8[6];
   assign FmcHa_iob24p[5] = test_ib8[7];
   // display interface:
   assign FmcHa_iob24p[9] = display.latch_o;
   assign FmcLa_iob34n[1] = display.blank_o;
   assign FmcLa_iob34p[1] = display.csel_ob3[2];
   assign FmcHa_iob24n[5] = display.csel_ob3[1];
   assign FmcHa_iob24n[4] = display.csel_ob3[0];
   assign FmcLa_iob34p[3] = display.sclk_o;
   assign FmcLa_iob34n[0] = display.data_o;
   // motors drivers reset. Drive Lan[31] to reset the motor drivers,
   // this is done through mreset_i signal:
   assign FmcLa_iob34n[31] = mreset_i;
   // if backplane supports this, supplyOK_o will indicate if the 56V
   // power supply (AC/DC converter) indicates OK
   assign supplyOK_o = FmcLa_iob34p[33];

   // PCB revision hardcoded by resistances:
   assign PCBrevision_o4 = {FmcHb_iob22p[14], FmcHb_iob22n[14],
			    FmcHb_iob22p[17], FmcHb_iob22n[17]};

   // temperature and serial number - just hook to 'Z'
   assign FmcHa_iob24n[13] = 'Z;

   // clear out unused
   assign FmcLa_iob34p[28] = '0;
   assign FmcLa_iob34n[33] = '0;
   assign FmcLa_iob34n[32] = '0;
   assign FmcHa_iob24p[23] = '0;
   assign FmcHa_iob24p[22] = '0;
   assign FmcHa_iob24p[21] = '0;
   assign FmcHa_iob24p[20] = '0;
   assign FmcHa_iob24n[23] = '0;
   assign FmcHa_iob24n[22] = '0;
   assign FmcHa_iob24n[21] = '0;
   assign FmcHa_iob24n[20] = '0;
   assign FmcHa_iob24n[19] = '0;
   assign FmcHa_iob24n[18] = '0;
   assign FmcHa_iob24n[17] = '0;
   assign FmcHa_iob24n[16] = '0;
   assign FmcHa_iob24n[15] = '0;
   assign FmcHa_iob24n[14] = '0;
   assign FmcHa_iob24n[12] = '0;
   assign FmcHb_iob22p[21] = '0;
   assign FmcHb_iob22p[19] = '0;
   assign FmcHb_iob22p[18] = '0;
   assign FmcHb_iob22p[15] = '0;
   assign FmcHb_iob22n[21] = '0;
   assign FmcHb_iob22n[19] = '0;
   assign FmcHb_iob22n[18] = '0;
   assign FmcHb_iob22n[15] = '0;


endmodule // pin_mapping
