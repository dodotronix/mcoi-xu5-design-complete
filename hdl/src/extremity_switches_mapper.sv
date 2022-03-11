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
// Copyright (c) June 2019 CERN

//-----------------------------------------------------------------------------
// @file EXTREMITY_SWITCHES_MAPPER.SV
// @brief Maps the LED diodes data to extremity switches
// @author Dr. David Belohrad  <david@belohrad.ch>, CERN
// @date 28 June 2019
// @details This entity takes raw data from two extremity switches
// given, and through the manipulation depending of switchesconfig it
// generates signals for 2 led diodes on the gefe front panel. This
// entity assures that NO/NC switches will always turn the particular
// led on WHEN REACHED, and as well proper casting of left/right led
// diodes to OUT/IN
//
//
// @platform Altera Quartus
// @standard IEEE 1800-2012
//-----------------------------------------------------------------------------

import CKRSPkg::*;
import MCPkg::*;



module extremity_switches_mapper

  (
   // EXPECTING 25MHz oscillator on ClkRs_ix:
   input 	ckrs_t ClkRs_ix,
   input [1:0] 	rawswitches,
   // configuration of the switches
   input 	switchstate_t [1:0] switchesconfig,
   // input signal for led diodes blinking. It is better to get it
   // externally as it can be shared between instances of this module
   input 	blinker_i,
   // codenames: lg = left green, rr = right red
   output logic led_lg,
   output logic led_lr,
   output logic led_rg,
   output logic led_rr
   );

   // handle first the switches signal inversion (config vector
   // specifies that rawsw0 or rawsw1 is INVERTED before the data are
   // casted to muxer. See switchmanager.sv in VFC.

   logic [1:0] 	polarity_corrected_switches_b2;

   assign polarity_corrected_switches_b2 = {rawswitches[1] ^
					    switchesconfig[1].Polarity,
					    rawswitches[0] ^
					    switchesconfig[0].Polarity};

   // we continue with multiplexor. Following is the table of input
   // switches translation. This is SINGLE DIODE TRANSLATION, the
   // other should be exactly the same:
   // switches config input   |  led diode affected
   //      00                 |       no switches - both blink in red
   //                         |       and cast raw switches to each extremity
   //      01                 |       green left
   //      10                 |       green right
   //      11                 |       both or'ed to both
   always_ff @(posedge ClkRs_ix.clk)
     case(switchesconfig[1].SelectedInputSwitches_b2)
       2'b00: begin
	  led_lg <= rawswitches[1];
	  led_lr <= blinker_i;

       end
       2'b01: begin
	  led_lg <= polarity_corrected_switches_b2[0];
	  led_lr <= '0;
       end
       2'b10: begin
	  led_lg <= polarity_corrected_switches_b2[1];
	  led_lr <= '0;
       end
       2'b11: begin
	  led_lg <= polarity_corrected_switches_b2[0];
	  led_lr <= polarity_corrected_switches_b2[1];
       end
     endcase // case (switchesconfig[1].SelectedInputSwitches_b2)

   always_ff @(posedge ClkRs_ix.clk)
     case(switchesconfig[0].SelectedInputSwitches_b2)
       2'b00: begin
	  led_rg <= rawswitches[0];
	  led_rr <= blinker_i;
       end
       2'b01: begin
	  led_rg <= polarity_corrected_switches_b2[0];
	  led_rr <= '0;
       end
       2'b10: begin
	  led_rg <= polarity_corrected_switches_b2[1];
	  led_rr <= '0;
       end
       2'b11: begin
	  led_rg <= polarity_corrected_switches_b2[0];
	  led_rr <= polarity_corrected_switches_b2[1];
       end
     endcase // case (switchesconfig[1].SelectedInputSwitches_b2)





endmodule // extremity_switches_mapper
