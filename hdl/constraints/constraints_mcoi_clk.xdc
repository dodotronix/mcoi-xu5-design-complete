# CLOCK CONFIGURATION CONSTRAINTS

# MCOI XU5 PINGROUP: PL_VARCLK; IOSTANDARD: LVCMOS18
set_property PACKAGE_PIN L3 [get_ports {pl_varclk}]
set_property IOSTANDARD LVCMOS18 [get_ports {pl_varclk}]


# pl_varclk goes 50MHz
create_clock -period 20.000 -name  pl_varclk [get_ports {pl_varclk}]
# define external 100mhz clock
create_clock -period 10.000 -name clk100m_pl [get_ports {clk100m_pl_p}]



# MCOI XU5 PINGROUP: MGT_CLK; IOSTANDARD:
set_property PACKAGE_PIN Y5 [get_ports {mgt_clk_n}]
set_property PACKAGE_PIN Y6 [get_ports {mgt_clk_p}]

# MGT CLK
create_clock -period 8.333 -name  mgt_clk [get_ports {mgt_clk_p}]
create_generated_clock -name Clk120Odiv2 -period 8.333 [get_ports clk120m_i]
