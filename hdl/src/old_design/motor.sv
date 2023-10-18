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
// @file MOTOR.SV
// @brief emulates simple motor behaviour
// @author Dr. David Belohrad  <david@belohrad.ch>, CERN
// @date 20 April 2018
// @details motor has some counter, and some limits (there's much more
// advanced and synthesizable version in VFC part, but this model only
// emulates behaviour what what we currently have). Motor starts with
// a counter set to half of the value and both switches - which are
// 'normally opened' off. Then - when pulses come, counters get
// updated until they reach switching area, identified by 'distance'
// from zero and max of the counter. At these moments the motors will
// actuate the switches. If motor continues even further, fail signal
// is risen. No overheat is detected here. This simulator does not use
// mcinput_t and mcoutput_t structs, and it should be as close to the
// real signals as possible. These will be at later stage casted to
// correct FMC signals
//
//
// @platform Altera Quartus
// @standard IEEE 1800-2012
//-----------------------------------------------------------------------------

import CKRSPkg::*;


module motor
  #(
    // bitwidth of counter. MOTOR COUNTS TWICE THAT VALUE. Hence value
    // of 4 will make motor with 32 steps
    parameter g_CounterBits = 4,
    // threshold is defined as +- (2**g_CounterBits - g_SwitchThreshold)
    parameter g_SwitchThreshold = 4)
  (
   // pulses drive motor
   input logic 	      StepOutP_i,
   // if set to '1', then MOTOR IS DESACTIVATED! (at least according
   // to manual).
   input logic 	      StepENAB_i,
   // '1' to boost the motor (does nothing in this model)
   input logic 	      StepBOOST_i,
   // '1' to go positive direction (acting switch 0), '0' to go
   // negative direction (acting switch 1)
   input logic 	      StepDIR_i,
   // overheat - not simulated here
   output logic       OH_o,
   // setup to '1' when motor goes beyond functional parameters
   output logic       StepPFail_o,
   // switch0 for positive direction, switch1 for negative direction
   output logic [1:0] Switches_ob
   );
   timeunit 1ns;
   timeprecision 100ps;

   localparam integer threshold = 2**g_CounterBits - g_SwitchThreshold;

   // let's make huge counter:
   integer signed Counter = 0;
   logic 	  clk_k = 0;

   // generate local clock
   always forever #100ns clk_k <= ~clk_k;
      always_ff @(posedge clk_k) begin
	 if (!StepENAB_i) begin
	    if ($rose(StepOutP_i) && StepDIR_i)
	      Counter <= Counter + 1;
	    else if ($rose(StepOutP_i) && !StepDIR_i)
	      Counter <= Counter - 1;
	 end
      end

   assign OH_o = 1'b0;
   // if switches are inactive, they must pull to '1'. For default
   // parameters, counting more/equal 12 will trigger switch 0, counting
   // lessequal -12 will trigger switch 1 for default setting
   assign Switches_ob[0] = (Counter >= threshold) ? 1'b0 : 1'b1;
   assign Switches_ob[1] = (Counter <= -threshold) ? 1'b0 : 1'b1;
   assign StepPFail_o = ( (Counter >= 2**g_CounterBits) ||
			  (Counter <= -(2**g_CounterBits)) ) ? 1'b1 : 1'b0;






endmodule // motor
