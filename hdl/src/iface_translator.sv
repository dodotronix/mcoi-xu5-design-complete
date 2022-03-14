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
// @file IFACE_TRANSLATOR.SV
// @brief translates between t_motors and t_motors_structured
// @author Dr. David Belohrad  <david.belohrad@cern.ch>, CERN
// @date 14 March 2022
// @details
// That is needed as we cannot simply add
//
// @platform Altera Quartus
// @standard IEEE 1800-2012
//-----------------------------------------------------------------------------

import CKRSPkg::*;


module iface_translator

  (t_motors.producer motors_x,
   t_motors_structured.producer motors_structured_x
   );

   generate //motor diagnostics
      for(genvar i=1; i<17; ++i) begin: motor_i
	 always_comb begin
	    //overheat signal
	    motors_structured_x.motorsStatuses[i].OH_i = 1'b0;
	    //motor fail signal
	    motors_structured_x.motorsStatuses[i].StepPFail_i = motors_x.pl_pfail[i];
	    //motor feedback switches
	    motors_structured_x.motorsStatuses[i].RawSwitches_b2[0] = motors_x.pl_sw_outa[i];
	    motors_structured_x.motorsStatuses[i].RawSwitches_b2[1] = motors_x.pl_sw_outb[i];
	    motors_x.pl_boost[i] = motors_structured_x.motorsControls[i].StepBOOST_o;
	    motors_x.pl_dir[i] = motors_structured_x.motorsControls[i].StepDIR_o;
	    motors_x.pl_en[i] = motors_structured_x.motorsControls[i].StepDeactivate_o;
	    motors_x.pl_clk[i] = motors_structured_x.motorsControls[i].StepOutP_o;
	 end
      end
   endgenerate

endmodule // iface_translator
