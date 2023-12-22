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
// @file LED_BLINKER.SV
// @brief blinks with diodes
// @author Dr. David Belohrad  <david@belohrad.ch>, CERN
// @date 12 April 2018
// @details
// This module is used to drive leds. It permits to specify total
// repetition period, single blink period and when appropriate amount
// of blinks is presented to amount_ib port, it blinks that many times
// when start_i is issued. Note that parameters are 64 bits because
// the clock period can be quite high and hence high division ration
// is required
//
// @platform Altera Quartus
// @standard IEEE 1800-2012
//-----------------------------------------------------------------------------

import CKRSPkg::*;


module led_blinker
  #(
    parameter longint g_totalPeriod = 256,
    parameter longint g_blinkOn = 2,
    parameter longint g_blinkOff = 3
    )
   (input ckrs_t ClkRs_ix,
    input 	      forceOne_i,
    input logic [7:0] amount_ib,
    output logic      led_o,
    output logic      period_o
    );


   localparam longint max_blinks = (g_totalPeriod /
				    (g_blinkOn + g_blinkOff));

   initial begin
      $display("LED blinker config: totalPeriod = %d, blinkOn = %d, blinkOff = %d", g_totalPeriod, g_blinkOn, g_blinkOff);
      $display("Maximum amount of blinks in period defined by amount_ib: %d",
	       2**$size(amount_ib));
      $display("amount_ib vector length: %d", $size(amount_ib));
      $display("Maximum value of amount_ib: %d", max_blinks);
      assert (g_blinkOn > 0);
      assert (g_blinkOff > 0);

   end

   // counter for led hits:
   logic [$size(amount_ib)-1:0] ledcount_b;
   // and timing counters, calculate length dynamically from length of
   // period counter, which is the largest value of all three
   logic [$clog2(g_totalPeriod):0] period_b, counthi_b, countlo_b;

   logic 			   led;
   // direct encoding state machine
   enum 			   logic[1:0]			{IDLE = 2'(0),
								 LEDHI = 2'(1),
								 LEDLO = 2'(2),
								 COUNTDOWN = 2'(3)} State_q;

   localparam one_amount_b = ($bits(period_b))'(1);
   localparam logic_on = ($bits(counthi_b))'(g_blinkOn);
   localparam logic_off = ($bits(countlo_b))'(g_blinkOff);

   initial begin
      assert (logic_on == g_blinkOn);
      assert (logic_off == g_blinkOff);
   end


   always_ff @(posedge ClkRs_ix.clk or posedge ClkRs_ix.reset) begin
      if (ClkRs_ix.reset) begin
	 ledcount_b <= '0;
	 counthi_b <= logic_on;
	 countlo_b <= logic_off;
	 period_o <= 0;
      end else begin
	 if (period_b != 0) begin
	    period_b <= period_b - ($size(period_b))'(1);
	    period_o <= 0;
	 end else begin
	    period_b <= ($size(period_b))'(g_totalPeriod);
	    period_o <= 1;
	 end
	 // counters:
	 if ((State_q == LEDHI) && (|counthi_b))
	   counthi_b <= counthi_b - one_amount_b;
	 if ((State_q == LEDLO) && (|countlo_b))
	   countlo_b <= countlo_b - one_amount_b;

	 // start treatment
	 if (period_o) begin
	    ledcount_b <= amount_ib;
	    counthi_b <= logic_on - one_amount_b;
	    countlo_b <= logic_off - ($size(countlo_b))'(2);
	 end
	 else if ((State_q == COUNTDOWN) && (|ledcount_b)) begin
	    ledcount_b <= ledcount_b - ($bits(ledcount_b))'(one_amount_b);
	    counthi_b <= logic_on - one_amount_b;
	    countlo_b <= logic_off - ($size(countlo_b))'(2);
	 end
      end
   end


   always_ff @(posedge ClkRs_ix.clk or posedge ClkRs_ix.reset) begin
      if (ClkRs_ix.reset) begin
	 State_q <= IDLE;
	 led <= 0;
      end else begin
	 case (State_q)
	   IDLE: begin
	      led <= '0;
	      // run only if amount is nonzero
	      if (period_o && (|amount_ib))
		State_q <= COUNTDOWN;
	   end

	   LEDHI: begin
	      led <= '1;
	      if (!(|counthi_b))
		State_q <= LEDLO;
	   end

	   LEDLO: begin
	      led <= '0;
	      if (!(|countlo_b))
		State_q <= COUNTDOWN;
	   end

	   COUNTDOWN: begin
	      if (!(|ledcount_b))
		State_q <= IDLE;
	      else
		State_q <= LEDHI;
	   end

	   default:
	     State_q <= IDLE;

	 endcase // case (State_q)
      end
   end

   assign led_o = (forceOne_i)?'1:led;


endmodule // led_blinker
