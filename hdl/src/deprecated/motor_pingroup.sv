import MCPkg::*;

module motor_pingroup(
    //motors
    output [1:16] pl_boost,
    output [1:16] pl_dir,
    output [1:16] pl_en,
    output [1:16] pl_clk,
    input [1:16] pl_fail,
    input [1:16] pl_sw_outa,
    input [1:16] pl_sw_outb,
    //input [1:16] [1:0] RawSwitches_b2,

    //display
    output latch,
    output blank,
    output [2:0] csel_b3,
    output sclk,
    output sin,

    //pin groups
    output mcinput_t [NUMBER_OF_MOTORS_PER_FIBER:1] motorStatus,
    input mcoutput_t [NUMBER_OF_MOTORS_PER_FIBER:1] motorControl,
    display_x display
);

//display
assign latch = display.latch_o;
assign blank = display.blank_o;
assign csel_b3 = display.csel_ob3;
assign sclk = display.sclk_o;
assign sin = display.data_o;

generate //motor diagnostics
for(genvar i=1; i<17; ++i) begin: motor_i
    //overheat signal
    assign motorStatus[i].OH_i = 1'b0;
    //motor fail signal
    assign motorStatus[i].StepPFail_i = pl_fail[i];
    //motor feedback switches
    assign motorStatus[i].RawSwitches_b2[0] = pl_sw_outa[i];
    assign motorStatus[i].RawSwitches_b2[1] = pl_sw_outb[i];
end
endgenerate

generate //motor control casting
for(genvar i=1; i<17; ++i) begin: motor_o
    assign pl_boost[i] = motorControl[i].StepBOOST_o;
    assign pl_dir[i] = motorControl[i].StepDIR_o;
    assign pl_en[i] = motorControl[i].StepDeactivate_o;
    assign pl_clk[i] = motorControl[i].StepOutP_o;
end
endgenerate

endmodule
