import MCPkg::*;

module motor_pingroup(
    //motors
    output [1:16] StepBOOST_o,
    output [1:16] StepDIR_o,
    output [1:16] StepDeactivate_o,
    output [1:16] StepOutP_o,
    input [1:16] StepPFail_i,
    input [1:16] RawSwitchesA,
    input [1:16] RawSwitchesB,
    //input [1:16] [1:0] RawSwitches_b2,

    //display
    output latch_o,
    output blank_o,
    output [2:0] csel_ob3,
    output sclk_o,
    output data_o,

    //pin groups
    output mcinput_t [NUMBER_OF_MOTORS_PER_FIBER:1] motorStatus_ob,
    input mcoutput_t [NUMBER_OF_MOTORS_PER_FIBER:1] motorControl_ib,
    display_x display 
);

//display
assign latch_o = display.latch_o;
assign blank_o = display.blank_o;
assign csel_ob3 = display.csel_ob3;
assign sclk_o = display.sclk_o;
assign data_o = display.data_o;

generate //motor diagnostics
for(genvar i=1; i<17; ++i) begin: motor_i 
    //overheat signal
    assign motorStatus_ob[i].OH_i = 1'b0;
    //motor fail signal
    assign motorStatus_ob[i].StepPFail_i = StepPFail_i[i];
    //motor feedback switches
    assign motorStatus_ob[i].RawSwitches_b2[0] = RawSwitchesA[i];
    assign motorStatus_ob[i].RawSwitches_b2[1] = RawSwitchesB[i];
end
endgenerate

generate //motor control casting
for(genvar i=1; i<17; ++i) begin: motor_o
    assign StepBOOST_o[i] = motorControl_ib[i].StepBOOST_o;
    assign StepDIR_o[i] = motorControl_ib[i].StepDIR_o;
    assign StepDeactivate_o[i] = motorControl_ib[i].StepDeactivate_o;
    assign StepOutP_o[i] = motorControl_ib[i].StepOutP_o;
end
endgenerate

endmodule
