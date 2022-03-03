open_vcd 
log_vcd [get_object /I2cReader_tb/*] 
log_vcd [get_object /I2cReader_tb/diagnostics_i/*] 
log_vcd [get_object /I2cReader_tb/diagnostics_i/i2c_driver_i/*] 
log_vcd [get_object /I2cReader_tb/diagnostics_i/i2c_reader_i/*] 
log_vcd [get_object /I2cReader_tb/diagnostics_i/pll_configurer_i/*] 
log_vcd [get_object /I2cReader_tb/diagnostics_i/pll_configurer_i/feeder_i/*] 
log_vcd [get_object /I2cReader_tb/diagnostics_i/pll_configurer_i/interpreter_i/*] 
log_vcd [get_object /I2cReader_tb/i2c_slave_i/*] 
run all
close_vcd
exit
