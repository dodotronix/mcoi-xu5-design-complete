//------------------------------------------------------------------------------
// Petr Pacner | CERN | 2020-01-13 Mo 10:37   
// docs xilinx:
// https://www.xilinx.com/support/documentation/sw_manuals/xilinx2014_1/ug974-
// vivado-ultrascale-libraries.pdf
//------------------------------------------------------------------------------

//import MCPkg::*;
//import CKRSPkg::*;

module mcoi_xu5_design_complet(
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

    inout i2c_sda_pl,
    inout i2c_scl_pl,

    input rs485_pl_di,
    output rs485_pl_ro
);

////signals
//mcinput_t [NUMBER_OF_MOTORS_PER_FIBER:1] motorStatus; 
//mcoutput_t [NUMBER_OF_MOTORS_PER_FIBER:1] motorControl;

////interface
//display_x display();
//logic clk40m_l;

////module structure
//motor_pingroup i_pg_motors(
    ////motors
    //.StepBOOST_o(pl_boost), 
    //.StepDIR_o(pl_dir),
    //.StepDeactivate_o(pl_en),
    //.StepOutP_o(pl_clk),
    //.StepPFail_i(pl_pfail),
    //.RawSwitchesA(pl_sw_outa),
    //.RawSwitchesB(pl_sw_outb),

    ////display
    //.latch_o(latch),
    //.blank_o(blank),
    //.csel_ob3(csel),
    //.sclk_o(sclk),
    //.data_o(sin),

    ////pin groups
    //.motorStatus_ob(motorStatus),
    //.motorControl_ib(motorControl),
    //.display(display));

//logic [83:0] data_to_mcoi, data_from_mcoi; 
//logic [3:0] rev_num_b4;
//logic [31:0]temp_val, power_val;
//logic [63:0] id_val; 

//mcoi_base i_mcoi_base(
    ////motors
    //.motorStatus_ib(motorStatus),
    //.motorControl_ob(motorControl),

    ////diagnostics
    //.display(display),
    //.led6_no(led[5:0]),
    //.pinhead(test),
    //.pcbrev4b_i(rev_num_b4),
    //.UniqueID_oqb64(id_val),
    //.temperature32b_i(temp_val),
    //.power32b_i(power_val),

    ////user input (optical link)
    //.reset_ni(sfp1_los),
    //.optsig_los_i(sfp1_los),
    //.mreset_no(mreset_vadj),
    //.clk40m_i(clk40m_l),
    //.clk25m_i(clk40m_l), //TODO use clk25mhz

    //.data_from_stream_ib80(data_to_mcoi[79:0]),
    //.data_to_stream_ob80(data_from_mcoi[79:0]),
    //.sc_from_stream_ib2(data_to_mcoi[81:80]), 
    //.sc_to_stream_ob2(data_from_mcoi[81:80]));

//gbt_pingroup i_pg_gbt(
    ////hw pins sfp
    //.sfp_rx_p(sfp1_gbitin_p),
    //.sfp_rx_n(sfp1_gbitin_n),
    //.sfp_tx_p(sfp1_gbitout_p),
    //.sfp_tx_n(sfp1_gbitout_n),
    //.sfp_rats_o(sfp1_rateselect),
    //.sfp_txdis_o(sfp1_txdisable),
    //.sfp_los_i(sfp1_los),
    //.mgt_clk120m_ip(mgt_clk_p),
    //.mgt_clk120m_in(mgt_clk_n),
    //.clk40m_o(clk40m_l),

    ////pin group
    //.gbt_data_o(data_to_mcoi),
    //.gbt_data_i(data_from_mcoi));

//TODO fpga_supply_ok??
//assign led[6] = 1'b0; 

//System part
//McoiXu5System i_McoiXu5System();

//____________________________ NEW STRUCTURE ____________________________

//Application part
//McoiXu5Application i_McoiXu5Application();

//ps part

endmodule
