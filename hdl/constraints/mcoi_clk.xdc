
set_property PACKAGE_PIN Y5 [get_ports mgt_clk_n]
set_property PACKAGE_PIN Y6 [get_ports mgt_clk_p]
create_clock -period 8.333 -name mgt_clk [get_ports mgt_clk_p]

# pl_varclk already defined in pll constraints
#create_clock -period 10 -name pl_varclk [get_ports pl_varclk]
#set_property PACKAGE_PIN L3 [get_ports pl_varclk]
#set_property IOSTANDARD LVCMOS18 [get_ports pl_varclk]

# 100 mhz crystal pl clock 
set_property PACKAGE_PIN AD5 [get_ports {clk100m_pl_p}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {clk100m_pl_p}]

set_property PACKAGE_PIN AD4 [get_ports {clk100m_pl_n}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {clk100m_pl_n}]

create_clock -period 10 -name clk100m_pl [get_ports clk100m_pl_p]
