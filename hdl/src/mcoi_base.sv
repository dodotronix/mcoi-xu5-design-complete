import MCPkg::*;
import CKRSPkg::*;
import constants::*;

//TODO licence

module mcoi_base#(
    parameter g_clock_divider = 25000
)(
 //motor links
 //TODO edit directions of the pins
 input mcinput_t [NUMBER_OF_MOTORS_PER_FIBER:1] motorStatus_ib,
 output mcoutput_t [NUMBER_OF_MOTORS_PER_FIBER:1] motorControl_ob,

 //diagnostics
 display_x display, //display
 output [5:0] led6_no,

 output [5:0] pinhead,
 input [3:0] pcbrev4b_i,
 input [63:0] UniqueID_oqb64,
 input [31:0] temperature32b_i,
 input [31:0] power32b_i,
 //TODO probably add i2c pll lock input as reset

 //api
 input optsig_los_i,
 input reset_ni,
 output mreset_no,
 input clk40m_i,
 input clk25m_i,

 input [79:0] data_from_stream_ib80,
 output [79:0] data_to_stream_ob80,
 input [1:0] sc_from_stream_ib2,
 output [1:0] sc_to_stream_ob2
);

logic [79:0] MotorsData_b80, DataToGbtx_b80;
logic [79: 0]  DataGbtxElinks_qb80, ValidMotorData_b80;
logic [31:0] build_ob32, RegLoopback_b32;
logic [31:0] MuxOut_b32;
logic [31:0] SerialFeedback_b32;
logic [31:0] PageSelector_b32;
logic VFCDataArrived;

logic [31:0] SwitchesConfiguration_b32 [NUMBER_OF_MOTORS_PER_FIBER-1:0];
switchstate_t [1:0] SwitchesConfiguration_2b16 [NUMBER_OF_MOTORS_PER_FIBER-1:0];
mcinput_t [NUMBER_OF_MOTORS_PER_FIBER:1] debounced_motorStatus_b;

mcoutput_t [NUMBER_OF_MOTORS_PER_FIBER:1] motorControl;
assign motorControl_ob = motorControl;

// led arrays from switches decoding
logic [NUMBER_OF_MOTORS_PER_FIBER-1:0] led_lg,led_lr,led_rg,led_rr;

ckrs_t ClkRxGBT_x;
assign ClkRxGBT_x.clk = clk40m_i;

ckrs_t ClkRs_x;
assign ClkRs_x.clk = clk25m_i;

// transporting reset signal into appropriate clock domain
// all gbtx operations are reseted by missing optical clock,
manyff #(.g_Latency (2))
i_manyff(
    .d_o (ClkRxGBT_x.reset),
    .ClkRs_ix (ClkRxGBT_x),
    .d_i (~optsig_los_i)
);

manyff#(
    .g_Latency(2))
i_manyff_rx(
    .d_o(ClkRs_x.reset),
    .ClkRs_ix(ClkRs_x),
    .d_i(~reset_ni));

//TODO add general reset?

//casting motor data to ValidMotorData_b80 if the data valid
always_ff @(posedge ClkRxGBT_x.clk or posedge ClkRxGBT_x.reset) begin
    if (ClkRxGBT_x.reset) DataGbtxElinks_qb80 <= '0;
    else DataGbtxElinks_qb80 <= data_from_stream_ib80;
end

localparam GBTWIDTH = $bits(DataGbtxElinks_qb80);
localparam MCWIDTH = $bits(motorControl);

logic [15:0] ValidRXMemData_b16;
always_ff @(posedge ClkRxGBT_x.clk) begin
 ValidMotorData_b80 <= DataGbtxElinks_qb80[GBTWIDTH-1:GBTWIDTH-MCWIDTH];
 ValidRXMemData_b16 <= DataGbtxElinks_qb80[15:0];
 if (SerialFeedback_b32 == GEFE_INTERLOCK) 
     motorControl = ValidMotorData_b80[$bits(motorControl)-1:0];
 else motorControl = '1;
end

//sc-ec channels settings up GEFE behaviour
serial_register i_serial_register(
    // Outputs
    .data_ob32(PageSelector_b32),
    .Tx_o(sc_to_stream_ob2[0]),
    .SerialLinkUp_o(),
    .RxLocked_o(),
    .TxBusy_o(),
    .newdata_o(VFCDataArrived),
    .TxEmptyFifo_o(),
    .txerror_o(),
    .rxlol_o(),

    // Inputs
    .ClkRs_ix(ClkRxGBT_x),
    .ClkRxGBT_ix(ClkRxGBT_x),
    .ClkTxGBT_ix(ClkRxGBT_x),
    .data_ib32(MuxOut_b32),
    .resetflags_i(1'b0),
    .Rx_i(sc_from_stream_ib2[0]));

logic [31:0] SerialFeedback1cc_b32;
serial_register i_serial_register_feedback(
    // Outputs
    .data_ob32(SerialFeedback_b32),
    .Tx_o(sc_to_stream_ob2[1]),
    .SerialLinkUp_o(),
    .RxLocked_o(),
    .TxBusy_o(),
    .newdata_o(),
    .TxEmptyFifo_o(),
    .txerror_o(),
    .rxlol_o(),

    // Inputs
    .ClkRs_ix(ClkRxGBT_x),
    .ClkRxGBT_ix(ClkRxGBT_x),
    .ClkTxGBT_ix(ClkRxGBT_x),
    .data_ib32(SerialFeedback1cc_b32),
    .resetflags_i(1'b0),
    .Rx_i(sc_from_stream_ib2[1]));

always_ff @(posedge ClkRxGBT_x.clk) begin 
    SerialFeedback1cc_b32 <= SerialFeedback_b32;
end

// loopback on ScEc links when pageselector MSB is '1'
assign data_to_stream_ob80 = DataToGbtx_b80;
always_comb begin
  if (PageSelector_b32[31]) DataToGbtx_b80 = DataGbtxElinks_qb80;
  else DataToGbtx_b80 = MotorsData_b80;
end

//// MUX for page data:
always_ff @(posedge ClkRxGBT_x.clk) begin
    case (PageSelector_b32[7:0])
        // loopback data
        0: MuxOut_b32 <= RegLoopback_b32;
        // build number
        1: MuxOut_b32 <= build_ob32;
        // PCB revision:
        2: MuxOut_b32 <= {27'b0, pcbrev4b_i};
        4: MuxOut_b32 <= UniqueID_oqb64[63:32];
        5: MuxOut_b32 <= UniqueID_oqb64[31:0];
        6: MuxOut_b32 <= temperature32b_i; //temperature
        7: MuxOut_b32 <= power32b_i; //consumption of board
        // 16 to 31 are MOTORS statuses. This is somewhat redundant
        // info to 80 bits data stream returned back to VFC, but - why
        // not, does not cost anything here ....
        16: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[1]};
        17: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[2]};
        18: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[3]};
        19: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[4]};
        20: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[5]};
        21: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[6]};
        22: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[7]};
        23: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[8]};
        24: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[9]};
        25: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[10]};
        26: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[11]};
        27: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[12]};
        28: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[13]};
        29: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[14]};
        30: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[15]};
        31: MuxOut_b32 <= {28'b0, debounced_motorStatus_b[16]};
        default: MuxOut_b32 <= 32'hdeadbeef;
    endcase
end 

// - channel 0 return value is the same as 'pageselector', but with
// lsb set to '1' to indicate 'GEFE present'
// construct register with loopback - copy loopback setting from
// VFC, and add '1' to identify that GEFE firmware is present.
always_ff @(posedge ClkRxGBT_x.clk or posedge ClkRxGBT_x.reset) begin
    if (ClkRxGBT_x.reset) RegLoopback_b32 <= 1; //GEFE present (POR)
    else begin
        if (VFCDataArrived)
            RegLoopback_b32 <= {PageSelector_b32[31], 30'b0, 1'b1};
    end
end

logic StreamTxDataValid;
assign StreamTxDataValid = (SerialFeedback_b32 == GEFE_INTERLOCK
                            && !PageSelector_b32[31])? '1 : '0;

// drive leds on front panel
assign led6_no[0] = 1'b0;
assign led6_no[1] = optsig_los_i; //los of signal
assign led6_no[2] = 1'b0;
assign led6_no[3] = 1'b0;
assign led6_no[4] = ~StreamTxDataValid;
assign led6_no[5] = 1'b0;


build_number i_build_number(
    .build_ob32 (build_ob32[31:0]));

//display
rx_memory #(
    .g_pages(NUMBER_OF_MOTORS_PER_FIBER))
i_rx_memory(
    .data_ob32(SwitchesConfiguration_b32),
    .resync(),
    .data_valid_o(),
    .data_ib16(ValidRXMemData_b16),
    .ClkRs_ix(ClkRxGBT_x));

genvar 	gi;
for (gi = 0; gi < NUMBER_OF_MOTORS_PER_FIBER; gi++) begin : genbit
  assign SwitchesConfiguration_2b16[gi] = SwitchesConfiguration_b32[gi];
end

logic blinker;
led_blinker#(
    .g_totalPeriod(GEFE_LED_BLINKER_PERIOD), //1s period
    .g_blinkOn(GEFE_LED_BLINKER_ON_TIME),
    .g_blinkOff(GEFE_LED_BLINKER_OFF_TIME))
i_led_blinker(
    .led_o(blinker),
    .period_o(),
    .ClkRs_ix(ClkRs_x),
    .forceOne_i('0),
    .amount_ib(8'(3)));

logic [3:0][1:0][15:0] ledData_b; //4 rows, 2states, 16 columns

// step signal extension to get orange color when motor moves
logic [NUMBER_OF_MOTORS_PER_FIBER-1:0] stepout_diode;

genvar motor;
generate
for(motor=0; motor<NUMBER_OF_MOTORS_PER_FIBER; motor++) begin : discast
// generate MKO for each stepout signal to cast to diode,
// react on falling edge as stepper does. this extends 5us
// pulse to 100ms
mko#(
 .g_CounterBits(22))
i_mko_stepout(
 .q_o(),
 .q_on(stepout_diode[motor]),
 .ClkRs_ix(ClkRs_x),
 .enable_i('1),
 .width_ib(22'(4000000)),
 .start_i(!motorControl[motor+1].StepOutP_o));

 // each assigned motor has to decode the information for the
 // diodes depending of switchesconfig
 extremity_switches_mapper
 i_extremity_switches_mapper(
     .led_lg(led_lg[motor]),
     .led_lr(led_lr[motor]),
     .led_rg(led_rg[motor]),
     .led_rr(led_rr[motor]),
     // Inputs
     .ClkRs_ix(ClkRs_x),
     .rawswitches(debounced_motorStatus_b[motor+1].RawSwitches_b2),
     .switchesconfig(SwitchesConfiguration_2b16[motor]),
     .blinker_i(blinker));

 // 4th column: if RED present, FAIL signal is emitted by
     // driver. if GREEN present (i.e orange as well), BOOST is
     // engaged:
     // fail signal - any red on 4th column
     assign ledData_b[3][0][motor] =
         debounced_motorStatus_b[motor+1].StepPFail_i;
     // green connected to boost signal on 4th colum
     assign ledData_b[3][1][motor] = motorControl[motor+1].StepBOOST_o;
     // extremity switches red diodes - columns 1 and 3:
     assign ledData_b[0][0][motor] = led_lg[motor];
     assign ledData_b[0][1][motor] = led_lr[motor];
     assign ledData_b[2][0][motor] = led_rg[motor];
     assign ledData_b[2][1][motor] = led_rr[motor];
     // diode on column1 shows the functionality of the
     // motor. Green one when motor enabled, red one when
     // moves. Hence move produces orange color
     assign ledData_b[1][0][motor] = !stepout_diode[motor];
     assign ledData_b[1][1][motor] = !motorControl[motor+1].StepDeactivate_o;
 end
endgenerate


tlc5920 #(
    .g_divider (4)) 
tlc_5920_i(
  // Interface
  .display(display),
  .ClkRs_ix(ClkRs_x),
  .data_ib(ledData_b));

logic [$bits(motorStatus_ib)-1:0] metain, metaout;
// use default typecast:
assign metain = motorStatus_ib;
assign debounced_motorStatus_b = metaout;

// 1ms clock enable signal derived from ClkRs
logic ClkRs1ms_e;

// get 1ms timing out of 25MHz (25000)
clock_divider#(
    .g_divider(g_clock_divider))
i_clock_divider(
    .enable_o(ClkRs1ms_e),
    .ClkRs_ix(ClkRs_x));


logic [4:0] amplitude_ib = '0;
logic cycleStart_o, increaseAmplitude;

get_edge i_get_edge(
    .rising_o(increaseAmplitude),
    .falling_o(),
    .data_o(),
    .ClkRs_ix(ClkRs_x),
    .data_i(cycleStart_o));

always_ff @(posedge ClkRs_x.clk)
    if (increaseAmplitude) amplitude_ib <= amplitude_ib + 5'h1;

logic mreset;
assign mreset_no = mreset;

pwm#(
    .g_CounterBits(5))
i_pwm(
    .cycleStart_o(cycleStart_o),
    .pwm_o(),
    .pwm_on(mreset),
    .ClkRs_ix(ClkRs_x),
    .amplitude_ib(amplitude_ib),
    .forceOne_i('0),
    .enable_i(ClkRs1ms_e));

genvar ms;
generate for (ms = 0; ms < $bits(metain); ms++)
manyff#(
    .g_Latency(3))
i_manyff(
    .ClkRs_ix(ClkRxGBT_x),
    .d_i(metain[ms]),
    .d_o(metaout[ms]));
endgenerate

assign MotorsData_b80 = {metaout,($bits(MotorsData_b80)-$bits(metaout))'(0)};

initial begin
  $display("motorStatus_ib pack size: ", $size(motorStatus_ib));
  $display("motorStatus_ib bits size: ", $bits(motorStatus_ib));
  $display("MotorsData_b80 bits size: ", $bits(MotorsData_b80));
end

// test pinheads 
assign pinhead[0] = 1'b0;
assign pinhead[1] = 1'b0;
assign pinhead[2] = 1'b0;
assign pinhead[3] = 1'b0;
assign pinhead[4] = 1'b0;
assign pinhead[5] = 1'b0;

endmodule
