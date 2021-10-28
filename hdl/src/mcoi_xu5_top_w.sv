//------------------------------------------------------------------------------
// Petr Pacner | CERN | 2020-01-13 Mo 10:37   
// docs xilinx:
// https://www.xilinx.com/support/documentation/sw_manuals/xilinx2014_1/ug974-
// vivado-ultrascale-libraries.pdf
//------------------------------------------------------------------------------

module mcoi_xu5_top_w(
    //motors
    output [1:16] pl_boost,
    output [1:16] pl_dir,
    output [1:16] pl_en,
    output [1:16] pl_clk,
    input [1:16] pl_pfail,
    input [1:16] pl_sw_outa, 
    input [1:16] pl_sw_outb, 

    //display
    output latch,
    output blank,
    output [0:2] csel,
    output sclk,
    output sin,
    output mreset_vadj,

    //optical interface
    input sfp1_gbitin_p,
    input sfp1_gbitin_n,
    input sfp1_los,
    output sfp1_gbitout_p,
    output sfp1_gbitout_n,
    output sfp1_rateselect,
    output sfp1_txdisable,

    input mgt_clk_p,
    input mgt_clk_n,
    input pl_varclk,

    //diagnostics
    output [6:0] led,
    output [0:5] test,
    input [3:0] pcbrev,
    input fpga_supply_ok,

    input clk100m_pl_p,
    input clk100m_pl_n,

    inout i2c_sda_pl,
    inout i2c_scl_pl,

    input rs485_pl_di,
    output rs485_pl_ro
);

logic clk100m_from_module;
IBUFDS ibufds_i(
.O(clk100m_from_module),
.I(clk100m_pl_p),
.IB(clk100m_pl_n));

mcoi_xu5_top mcoi_xu5_top_i(
    //motors
    .pl_boost(pl_boost),
    .pl_dir(pl_dir),
    .pl_en(pl_en),
    .pl_clk(pl_clk),
    .pl_pfail(pl_pfail),
    .pl_sw_outa(pl_sw_outa), 
    .pl_sw_outb(pl_sw_outb), 

    //display
    .latch(latch),
    .blank(blank),
    .csel(csel),
    .sclk(sclk),
    .sin(sin),
    .mreset_vadj(mreset_vadj),

    //optical interface
    .sfp1_gbitin_p(sfp1_gbitin_p),
    .sfp1_gbitin_n(sfp1_gbitin_n),
    .sfp1_los(sfp1_los),
    .sfp1_gbitout_p(sfp1_gbitout_p),
    .sfp1_gbitout_n(sfp1_gbitout_n),
    .sfp1_rateselect(sfp1_rateselect),
    .sfp1_txdisable(sfp1_txdisable),
    .mgt_clk_p(mgt_clk_p),
    .mgt_clk_n(mgt_clk_n),
    .pl_varclk(pl_varclk),
    .clk_from_ps(clk100m_from_module),

    //diagnostics
    .led(led),
    .test(test),
    .pcbrev(pcbrev),
    .fpga_supply_ok(fpga_supply_ok),

    .i2c_sda_pl(i2c_sda_pl),
    .i2c_scl_pl(i2c_scl_pl),

    .rs485_pl_di(rs485_pl_di),
    .rs485_pl_ro(rs485_pl_ro));

// ps part
mcoi_xu5_optics mcoi_xu5_optics_i();

endmodule
