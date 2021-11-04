module McoiXu5System();

//interfaces for motors

//gbt pll

//ps part

//rs232

//gbt core

//buffers

//leds

//Diagnostics block gathering information about board
McoiXu5Diagnostics mcoi_diagnostics_i(
    .clk(clk_from_ps),
    .rstn(1'b1), // TODO connect to ps reset 
    .temp_o(temp_val[15:0]),
    .power_o(power_val[15:0]),
    .rev_o(rev_num_b4),
    .id_o(id_val),
    .rs485_i(rs485_pl_di),
    .rs485_o(rs485_pl_ro),
    .revpins_i(pcbrev),
    .sda_io(i2c_sda_pl),
    .scl_io(i2c_scl_pl));



endmodule
