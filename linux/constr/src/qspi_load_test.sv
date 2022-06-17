module qspi_load_test (
    input btn,
    output [2:0] dled,
    output clk_out,
    input clk100_pl_p,
    input clk100_pl_n
);

logic clk100m_ref, led;

IBUFDS ibufds_i(
.O(clk100m_ref),
.I(clk100_pl_p),
.IB(clk100_pl_n));

logic [23:0] cnt;
always@(posedge clk100m_ref or negedge btn) begin
    if(!btn) begin cnt <= '0;
                   led <= 1'b0; end
    else begin cnt <= cnt + 1;
               if (cnt > 10000000) begin led <= led ^ 1'b1; 
                                             cnt <= '0; end end end

mcoi_xu5_optics mcoi_xu5_optics_i();

assign dled[0] = (!btn) ? 1'b0 : 1'b1;
assign dled[1] = 1'b0;
assign dled[2] = led;
assign clk_out = clk100m_ref;

endmodule

