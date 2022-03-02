//TODO license
`timescale 1ns/100ps 

// INST_SET (instruction set) format [{r/w & data}, {r/w & data}, ...]  
// read = log1
// write = log0

module I2cDev#( 
    parameter OUT_SIZE=2, //number of bytes on output
    parameter ARRAY_SIZE=2,
    parameter [16:0] INST_SET [ARRAY_SIZE] = '{17'h10001, 17'h10002}
)(
    input rstp,
    input clk,
    output valid_o,
    output rw_o,
    input ready_i,
    input [7:0] byte_i,
    output [15:0] byte_o,
    output [(OUT_SIZE*8)-1:0] data_o,
    output fin_o
);

localparam TRUE = 1'b1;
localparam FALSE = 1'b0;

localparam IDLE = 2'b00;
localparam RDWT = 2'b01;
localparam SAVE = 2'b10;
localparam INCR = 2'b11;

logic [1:0] next, state;
always@(posedge clk or posedge rstp) begin
    if(rstp) state <= IDLE;
    else state <= next; end

logic [$bits(ARRAY_SIZE)-1:0] cnt;
logic [1:0] delay;
logic valid, fin, rw, ready_cc;

always_comb begin
    next = state;
    case(state)
        IDLE : if(delay == 2'd3) next = RDWT; 
        RDWT : if(ready_i && !ready_cc) next = (!rw) ? INCR : SAVE;
        SAVE : next = INCR;
        INCR : next = (cnt < ARRAY_SIZE-1) ? RDWT : IDLE ;
    endcase end

logic [15:0] data_to_reader;
logic [(OUT_SIZE*8)-1:0] result;

assign valid_o = valid;
assign fin_o = fin;
assign rw_o = rw;
assign byte_o = data_to_reader;
assign data_o = result;

always@(posedge clk or posedge rstp) begin
    cnt <= cnt;
    rw <= rw;
    fin <= FALSE;
    valid <= FALSE;
    ready_cc <= ready_i;
    result <= result;

    if(rstp) begin valid <= FALSE;
                       rw <= FALSE;
                      fin <= TRUE;
                      result <= '0;
                      data_to_reader <= '0;
                      delay <= '0;
                      cnt <= '0;
    end else begin
        case(state)
            IDLE : begin if(delay == 2'd3) delay <= '0;
                         else delay <= delay + 1;
                         valid <= FALSE;
                         fin <= TRUE;
                         rw <= FALSE;
                         cnt <= '0;
                         data_to_reader <= '0; end
            RDWT : begin rw <= (^(INST_SET[cnt] & 17'h10000)) ? TRUE : FALSE;  
                         data_to_reader <= INST_SET[cnt][15:0]; 
                         if(ready_i && state == next) valid <= TRUE; end
            SAVE : result <= {result[$bits(result)-9:0], byte_i};
            INCR : if(cnt < ARRAY_SIZE-1) cnt <= cnt + 1;
        endcase 
    end end

endmodule
