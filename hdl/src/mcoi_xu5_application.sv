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
// @file MCOI_XU5_APPLICATION.SV
// @brief
// @author Petr Pacner  <pepacner@cern.ch>, CERN
// @date 20 February 2022
// @details
//
//
// @platform Xilinx Vivado
// @standard IEEE 1800-2012
//-----------------------------------------------------------------------------

import types::*;
import MCPkg::*;
import CKRSPkg::*;
import constants::*;

module mcoi_xu5_application #(parameter g_clock_divider = 40000)(
    output logic mreset_vadj,
    t_gbt_data.consumer gbt_data_x,
    t_clocks.consumer clk_tree_x,
    t_display.producer display_x,
    t_motors.producer motors_x,
    // TODO maybe add signals to check voltage on the board
    t_diag.producer diag_x
);

/*AUTOWIRE*/
// Beginning of automatic wires outputs (for undeclared instantiated-module outputs)
logic [31:0] build_number_b32;           // From i_build_number of build_number.sv
// End of automatics

/*AUTOREGINPUT*/

// module namespace for of the signals
logic clock, reset, supply_ok, vfc_data_arrived, data_arrived;
logic tick_120;
logic [31:0] cnt_120mhz;
logic [31:0] page_selector_b32,
             serial_feedback_b32,
             mux_b32, loopback_b32,
             serial_feedback_cc_b32;

logic [3:0] sc_idata, sc_odata;
logic [15:0] ValidRXMemData_b16;
logic [4:0] amplitude_ib;
logic blinker, cycleStart_o, increaseAmplitude, ClkRs1ms_e;


// when all at one, leds should be turned on
logic [3:0][1:0][15:0] ledData_b;

logic [NUMBER_OF_MOTORS_PER_FIBER-1:0] stepout_diode;
logic [NUMBER_OF_MOTORS_PER_FIBER-1:0] led_lg, led_lr, led_rg, led_rr;
logic [NUMBER_OF_MOTORS_PER_FIBER-1:0] [31:0] SwitchesConfiguration_b32;

logic [63:0] UniqueID_oqb64 = 64'h1111_2222_3333_4444;
logic [31:0] temperature32b_i = 32'hdeadbeef;
logic [31:0] power32b_i = 32'hcafebeef;

motorsStatuses_t motorStatus_ob, debounced_motorStatus_b;
motorsControls_t motorControl_ib;
switchstate_t [NUMBER_OF_MOTORS_PER_FIBER-1:0] [1:0] SwitchesConfiguration_2b16;

ckrs_t gbt_rx_clkrs;

always_comb begin
    clock = clk_tree_x.ClkRs40MHz_ix.clk;
    reset = clk_tree_x.ClkRs40MHz_ix.reset;
    supply_ok = diag_x.fpga_supply_ok;

    // TODO use the whole width of 4bits in the communication
    sc_idata = gbt_data_x.data_received.sc_data_b4;
    // gbt_data_x.data_sent.sc_data_b4 = {{2{1'b0}}, sc_odata[1:0]};
    gbt_data_x.data_sent.sc_data_b4 = {{2{1'b0}}, sc_odata[1:0]};

    gbt_rx_clkrs.clk = gbt_data_x.rx_frameclk;
    gbt_rx_clkrs.reset = !gbt_data_x.rx_ready;
end

    // assign through interlocking - control data are casted to the
    // motor _only_ if loop is closed _and_ data are valid. Then with
    // each data valid we capture the data at the output and leave them
    // until next data enable comes:
    always_ff @(posedge gbt_rx_clkrs.clk) begin
        // to deactivate motor SET ALL BITS TO 1 because it will
        // trigger StepDeactivate. This will prevent the motors to go
        // nuts when the link is not yet established
        motorControl_ib <= '1;
        if (serial_feedback_b32 == GEFE_INTERLOCK) begin
            ValidRXMemData_b16 <= gbt_data_x.data_received.mem_data_b16;
            motorControl_ib <= gbt_data_x.data_received.motor_data_b64;
        end
    end

    rx_memory #(.g_pages(NUMBER_OF_MOTORS_PER_FIBER)) i_rx_memory (
        .data_ob32(SwitchesConfiguration_b32),
        .resync(),
        .data_valid_o(),
        .data_ib16(ValidRXMemData_b16),
        .ClkRs_ix(gbt_rx_clkrs), .*);

    led_blinker #(
        .g_totalPeriod(GEFE_LED_BLINKER_PERIOD),
        .g_blinkOn(GEFE_LED_BLINKER_ON_TIME),
        .g_blinkOff(GEFE_LED_BLINKER_OFF_TIME))
        i_led_blinker (
            .led_o(blinker),
            .period_o(),
            .ClkRs_ix(clk_tree_x.ClkRs100MHz_ix),
            .forceOne_i('0),
            .amount_ib(8'(3)));

    // let's assign diodes: column4 red is a fail signal from
    // motors. columns 1 and 3 in green are extremity switches
    genvar   motor;
    generate
      for(motor=0; motor<NUMBER_OF_MOTORS_PER_FIBER; motor++) begin : g_discast
          // generate MKO for each stepout signal to cast to diode,
          // react on falling edge as stepper does. this extends 5us
          // pulse to 100ms
          mko #( .g_CounterBits(22)) i_mko_stepout (
              .q_o(),
              .q_on(stepout_diode[motor]),
              .ClkRs_ix(clk_tree_x.ClkRs100MHz_ix),
              .enable_i ('1),
              .width_ib(22'(4000000)),
              .start_i(!motorControl_ib[motor+1].StepOutP_o));

          // each assigned motor has to decode the information for the
          // diodes depending of switchesconfig
          extremity_switches_mapper
          i_extremity_switches_mapper (
              .led_lg(led_lg[motor]),
              .led_lr(led_lr[motor]),
              .led_rg(led_rg[motor]),
              .led_rr(led_rr[motor]),
              .ClkRs_ix(clk_tree_x.ClkRs100MHz_ix),
              .rawswitches(debounced_motorStatus_b[motor+1].RawSwitches_b2),
              .switchesconfig(SwitchesConfiguration_2b16[motor]),
              .blinker_i(blinker));

          /* assign ledData_b[0][0][motor] = 1'b1;
          assign ledData_b[0][1][motor] = blinker;
          assign ledData_b[1][0][motor] = 1'b0;
          assign ledData_b[1][1][motor] = 1'b1;
          assign ledData_b[2][0][motor] = 1'b1;
          assign ledData_b[2][1][motor] = 1'b0;
          assign ledData_b[3][0][motor] = 1'b0;
          assign ledData_b[3][1][motor] = 1'b0; */

          // 4th column: if RED present, FAIL signal is emitted by
          // driver. if GREEN present (i.e orange as well), BOOST is
          // engaged:
          // fail signal - any red on 4th column
          assign ledData_b[3][0][motor] = debounced_motorStatus_b[motor+1].StepPFail_i;
          // green connected to boost signal on 4th colum
          assign ledData_b[3][1][motor] = motorControl_ib[motor+1].StepBOOST_o;
          // extremity switches red diodes - columns 1 and 3:
          assign ledData_b[0][0][motor] = led_lg[motor];
          assign ledData_b[0][1][motor] = led_lr[motor];
          assign ledData_b[2][0][motor] = led_rg[motor];
          assign ledData_b[2][1][motor] = led_rr[motor];
          // diode on column1 shows the functionality of the
          // motor. Green one when motor enabled, red one when
          // moves. Hence move produces orange color
          assign ledData_b[1][0][motor] = !stepout_diode[motor];
          assign ledData_b[1][1][motor] = !motorControl_ib[motor+1].StepDeactivate_o;

    end
    endgenerate

   // re-cast the data to the original switches structure (so that if
   // it changes, the change propagates to both VFC and GEFE designs)
   genvar gi;
   for (gi = 0; gi < NUMBER_OF_MOTORS_PER_FIBER; gi++) begin : g_bit
      assign SwitchesConfiguration_2b16[gi] = SwitchesConfiguration_b32[gi];

   end

    // STATUS INDICATION (LEDs)
    assign diag_x.mled[0] = (serial_feedback_b32 == GEFE_INTERLOCK
                             && !page_selector_b32[31])? '0 : '1;
    assign diag_x.mled[1] = motorStatus_ob[1].RawSwitches_b2[0];
    assign diag_x.mled[2] = motorStatus_ob[1].RawSwitches_b2[1];


    logic [8:0] snake;
    logic [22:0] snake_div;
    assign diag_x.led[0] = snake[0];
    assign diag_x.led[2] = snake[1];
    assign diag_x.led[4] = snake[2];
    assign diag_x.led[6] = snake[3];
    assign diag_x.led[5] = snake[4];
    assign diag_x.led[3] = snake[5];
    assign diag_x.led[1] = snake[6];

    always_ff @(posedge clk_tree_x.ClkRs100MHz_ix.clk) begin
        if(clk_tree_x.ClkRs100MHz_ix.reset) begin
            snake <= 9'b111000000;
            snake_div <= '0;
        end else begin
            if(!snake_div) snake <= {snake[7:0], snake[8]};
            snake_div <= snake_div + $size(snake_div)'(1);
        end
    end

    // indication that the 120M clock is running
    always_ff @(posedge clk_tree_x.ClkRs120MHz_ix.clk) begin
        cnt_120mhz <= cnt_120mhz + $size(cnt_120mhz)'(1);
        if(cnt_120mhz == 32'd120000000) begin
            cnt_120mhz <= '0;
            tick_120 <= tick_120 ^ 1'b1;
        end
    end

    assign diag_x.test[0] = clk_tree_x.ClkRs40MHz_ix.clk;
    assign diag_x.test[1] = clk_tree_x.ClkRs120MHz_ix.clk;
    assign diag_x.test[2] = gbt_data_x.rx_frameclk;
    assign diag_x.test[3] = gbt_data_x.tx_frameclk;
    assign diag_x.test[4] = '1;

    always_ff @(posedge gbt_rx_clkrs.clk)
        if (gbt_rx_clkrs.reset) loopback_b32 <= 1;
        else if (vfc_data_arrived)
            loopback_b32 <= {page_selector_b32[31], 30'b0, 1'b1};

   serial_register i_serial_register (
       .Rx_i(sc_idata[0]),
       .Tx_o(sc_odata[0]),
       .data_ib32(mux_b32),
       .data_ob32(page_selector_b32),
       .newdata_o(vfc_data_arrived),
       .resetflags_i(1'b0),
       .ClkRs_ix(gbt_rx_clkrs),
       .ClkRxGBT_ix(gbt_rx_clkrs),
       .ClkTxGBT_ix(gbt_rx_clkrs),
       .TxBusy_o(),
       .TxEmptyFifo_o(),
       .txerror_o(),
       .SerialLinkUp_o(),
       .RxLocked_o()
   );

   always_ff @(posedge gbt_rx_clkrs.clk)
       serial_feedback_cc_b32 <= serial_feedback_b32;

   serial_register i_serial_register_feedback (
       .Rx_i(sc_idata[1]),
       .Tx_o(sc_odata[1]),
       .data_ib32(serial_feedback_cc_b32),
       .data_ob32(serial_feedback_b32),
       .resetflags_i(1'b0),
       .ClkRs_ix(gbt_rx_clkrs),
       .ClkRxGBT_ix(gbt_rx_clkrs),
       .ClkTxGBT_ix(gbt_rx_clkrs),
       .newdata_o(data_arrived),
       .TxBusy_o(),
       .TxEmptyFifo_o(),
       .txerror_o(),
       .SerialLinkUp_o(),
       .RxLocked_o()
   );

   logic [$bits(motorStatus_ob)-1:0] metain, metaout;
   assign metain = motorStatus_ob;
   assign debounced_motorStatus_b = metaout;

   genvar ms;
   generate
   for (ms = 0; ms < $bits(metain); ms++) begin : g_data_reindexing
       manyff #(.g_Latency(3)) i_manyff (
           .ClkRs_ix(gbt_rx_clkrs),
           .d_i(metain[ms]),
           .d_o(metaout[ms]));
       end
    endgenerate

   build_number i_build_number (.*);

   // mux
   always_ff @(posedge gbt_rx_clkrs.clk) begin
       if (gbt_data_x.rx_clken) begin
           case (page_selector_b32[7:0])
               0: mux_b32 <= loopback_b32;
               1: mux_b32 <= build_number_b32;
               2: mux_b32 <= {28'b0, diag_x.pcbrev};
               3: mux_b32 <= UniqueID_oqb64[63:32];
               4: mux_b32 <= UniqueID_oqb64[31:0];
               5: mux_b32 <= temperature32b_i;
               6: mux_b32 <= power32b_i;
               7: mux_b32 <= 32'd1;
               16: mux_b32 <= {28'b0, debounced_motorStatus_b[1]};
               17: mux_b32 <= {28'b0, debounced_motorStatus_b[2]};
               18: mux_b32 <= {28'b0, debounced_motorStatus_b[3]};
               19: mux_b32 <= {28'b0, debounced_motorStatus_b[4]};
               20: mux_b32 <= {28'b0, debounced_motorStatus_b[5]};
               21: mux_b32 <= {28'b0, debounced_motorStatus_b[6]};
               22: mux_b32 <= {28'b0, debounced_motorStatus_b[7]};
               23: mux_b32 <= {28'b0, debounced_motorStatus_b[8]};
               24: mux_b32 <= {28'b0, debounced_motorStatus_b[9]};
               25: mux_b32 <= {28'b0, debounced_motorStatus_b[10]};
               26: mux_b32 <= {28'b0, debounced_motorStatus_b[11]};
               27: mux_b32 <= {28'b0, debounced_motorStatus_b[12]};
               28: mux_b32 <= {28'b0, debounced_motorStatus_b[13]};
               29: mux_b32 <= {28'b0, debounced_motorStatus_b[14]};
               30: mux_b32 <= {28'b0, debounced_motorStatus_b[15]};
               31: mux_b32 <= {28'b0, debounced_motorStatus_b[16]};
               default: mux_b32 <= 32'hdeadbeef;
           endcase
       end
   end

   // inactive display
   tlc5920 #(.g_divider (9)) tlc_5920_i (
       .ClkRs_ix(clk_tree_x.ClkRs100MHz_ix), .*);


   // get 1ms timing out of 25MHz (25000)
   clock_divider #( .g_divider(g_clock_divider)) i_clock_divider (
       .enable_o(ClkRs1ms_e), .ClkRs_ix(clk_tree_x.ClkRs100MHz_ix));

   // let's do 'alive mreset' it will slowly turn on/off using PWM we
   // can do it. Using 1ms clock should do the job. Nothing fancy,
   // implemented 'easiest' possible way, not restricting in period.


   get_edge i_get_edge (
       .rising_o(increaseAmplitude),
       .falling_o(),
       .data_o(),
       .ClkRs_ix(clk_tree_x.ClkRs100MHz_ix),
       .data_i(cycleStart_o));

   always_ff @(posedge clk_tree_x.ClkRs100MHz_ix.clk) begin
       if(clk_tree_x.ClkRs100MHz_ix.reset) amplitude_ib <= '0;
       if (increaseAmplitude) amplitude_ib <= amplitude_ib + 5'h1;
   end

   // pwm uses 5 bits, meaning that each pwm cycle takes 32 enable
   // cycles, if enable is 1ms, then 1 cycle takes 32milliseconds. If
   // with each cycle we increase amplitude by 1 bin, the total
   // overflow happens in 32 * 32ms = 1024ms, so 1second.
   pwm #(.g_CounterBits(5)) i_pwm (
   .cycleStart_o(cycleStart_o),
   .pwm_o(),
   .pwm_on(mreset_vadj),
   .ClkRs_ix(clk_tree_x.ClkRs100MHz_ix),
   .amplitude_ib(amplitude_ib),
   .forceOne_i('0),
   .enable_i(ClkRs1ms_e));

    /* assign dynamic_data = 32'hdeadbeef;
    logic [31:0] dynamic_data;
    assign gbt_data_x.data_sent.motor_data_b64 = {dynamic_data, dynamic_data};
    assign gbt_data_x.data_sent.mem_data_b16 = '0; */

    // cast read motor stats back to the stream
    assign gbt_data_x.data_sent.motor_data_b64 = metaout;
    assign gbt_data_x.data_sent.mem_data_b16 = '0;

   // pin mapping
   genvar m_group;
   generate
   for (m_group = 1; m_group < NUMBER_OF_MOTORS_PER_FIBER+1; m_group++) begin
       assign motors_x.pl_boost[m_group] = motorControl_ib[m_group].StepBOOST_o;
       assign motors_x.pl_dir[m_group] = motorControl_ib[m_group].StepDIR_o;
       assign motors_x.pl_en[m_group] = motorControl_ib[m_group].StepDeactivate_o;
       assign motors_x.pl_clk[m_group] = motorControl_ib[m_group].StepOutP_o;

       assign motorStatus_ob[m_group].StepPFail_i = !motors_x.pl_pfail[m_group];
       assign motorStatus_ob[m_group].RawSwitches_b2[0] = !motors_x.pl_sw_outa[m_group];
       assign motorStatus_ob[m_group].RawSwitches_b2[1] = !motors_x.pl_sw_outb[m_group];
       assign motorStatus_ob[m_group].OH_i = 1'b0; //overheat signal deactivated
   end
   endgenerate

endmodule
