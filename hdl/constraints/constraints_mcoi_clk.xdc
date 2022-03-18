# CLOCK CONFIGURATION CONSTRAINTS

# MCOI XU5 PINGROUP: PL_VARCLK; IOSTANDARD: LVCMOS18
set_property PACKAGE_PIN L3 [get_ports {pl_varclk}]
set_property IOSTANDARD LVCMOS18 [get_ports {pl_varclk}]


create_clock -period 20.000 -name  pl_varclk [get_ports {pl_varclk}]

# MCOI XU5 PINGROUP: MGT_CLK; IOSTANDARD: DIFF_SSTL12_DCI
set_property PACKAGE_PIN Y5 [get_ports {mgt_clk_n}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {mgt_clk_n}]


set_property PACKAGE_PIN Y6 [get_ports {mgt_clk_p}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {mgt_clk_p}]


create_clock -period 8.333 -name  mgt_clk [get_ports {mgt_clk_p}]

