# If the constraint is removed, all
# unused pins are set to high impedance.  
set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN ENABLE [current_design]

# ------------------------------------------------------------------------------
# Important! Do not remove this constraint!  # This property ensures that all
# unused pins are set to high impedance.  # If the constraint is removed, all
# unused pins have to be set to HiZ in the top level file.
# ------------------------------------------------------------------------------
set_property BITSTREAM.CONFIG.UNUSEDPIN PULLNONE [current_design]

#DEBUG LEDS
set_property PACKAGE_PIN H2 [get_ports {dled[0]}]
set_property PACKAGE_PIN P9 [get_ports {dled[1]}]
set_property PACKAGE_PIN K5 [get_ports {dled[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dled}]

set_property PACKAGE_PIN E10 [get_ports btn]
set_property IOSTANDARD LVCMOS18 [get_ports btn]

# PE1 - con:B; num:15 (up; 8th pin)
set_property PACKAGE_PIN AF11 [get_ports clk_out]
set_property IOSTANDARD LVCMOS18 [get_ports clk_out]

# 100 mhz crystal pl clock 
set_property PACKAGE_PIN AD5 [get_ports {clk100_pl_p}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {clk100_pl_p}]
set_property PACKAGE_PIN AD4 [get_ports {clk100_pl_n}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {clk100_pl_n}]

