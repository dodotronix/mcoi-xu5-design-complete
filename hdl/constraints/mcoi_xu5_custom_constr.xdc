# ------------------------------------------------------------------------------
# This file serves as a additional constraint file
# PLEASE IF YOU NEED TO ADJUST SOME CONSTRAINTS OR
# ADD NEW ONES, EDIT THIS FILE, OTHER FILES ARE
# AUTOMATICALY GENERATED SO IF YOU MAKE YOUR CHANGES
# IN THOSE, YOUR SETTINGS WILL BE OVERWITTEN BY THE
# NEXT "MAKE UPDATE"
#
# Xilix Docs
#
# vivado properties guide
# https://www.xilinx.com/support/documentation/sw_manuals/xilinx2021_2/ug912-vivado-properties.pdf
#
# constraints guide
# https://www.xilinx.com/support/documentation/sw_manuals/xilinx2021_1/ug903-vivado-using-constraints.pdf
# ------------------------------------------------------------------------------

# FIXME this constraint comes from the GBT core
# but there is probably a wrong name of the
# transceiver - this needs to be fixed
#set_property RXSLIDE_MODE "PMA" [get_cells -hier -filter {NAME =~ *gbt_inst*GTHE4_CHANNEL_PRIM_INST}]

# unused pins are set to high impedance.  # If the constraint is removed, all
set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN ENABLE [current_design]

# ------------------------------------------------------------------------------
# Important! Do not remove this constraint!  # This property ensures that all
# unused pins are set to high impedance.  # If the constraint is removed, all
# unused pins have to be set to HiZ in the top level file.
# ------------------------------------------------------------------------------
set_property BITSTREAM.CONFIG.UNUSEDPIN PULLUP [current_design]

# 100mhz crystal pl clock placed on module pcb
set_property PACKAGE_PIN AD5 [get_ports {clk100m_pl_p}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {clk100m_pl_p}]
set_property PACKAGE_PIN AD4 [get_ports {clk100m_pl_n}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {clk100m_pl_n}]
create_clock -period 10.000 -name clk100m_pl [get_ports {clk100m_pl_p}]

# Current limit for the LEDs
set_property DRIVE 4 [get_ports {diag_x\.led[*]}]
set_property PULLUP true [get_ports {i2c_x\.sda}]
set_property PULLUP true [get_ports {i2c_x\.scl}]

# PIN GROUPPING: I2C_SDA_PL
set_property PACKAGE_PIN C12 [get_ports {i2c_x\.sda}]
set_property IOSTANDARD LVCMOS18 [get_ports {i2c_x\.sda}]
# PIN GROUPPING: I2C_SCL_PL
set_property PACKAGE_PIN D12 [get_ports {i2c_x\.scl}]
set_property IOSTANDARD LVCMOS18 [get_ports {i2c_x\.scl}]

# PIN GROUPPING: MODULE LEDS
set_property PACKAGE_PIN P9 [get_ports {diag_x\.mled[0]}] 
set_property PACKAGE_PIN H2 [get_ports {diag_x\.mled[1]}] 
set_property PACKAGE_PIN K5 [get_ports {diag_x\.mled[2]}] 
set_property DRIVE 4 [get_ports {diag_x\.mled[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {diag_x\.mled[*]}]

################################################################################
## TIMING


# false path to display led diodes driven by 100MHz clk
set_false_path -to [get_pins -hierarchical *led_*g_reg*/D*]
# we don't care about inout delays to motors as these are sooo slooow
# to drive that it is better not to put any constraint on these. False
# path is defined, but vivado indeed complains about missing input
# delays, let's stick some dummy ones (taking into account 120MHz clocking)
set_false_path -from [get_ports "*pcbrev*"]
set_input_delay -clock [get_clocks mgt_clk] -min 0.0 [get_ports "*pcbrev*"]
set_input_delay -clock [get_clocks mgt_clk] -max 5.0 [get_ports "*pcbrev*"]

set_false_path -from [get_ports "*pl_pfail*"]
set_input_delay -clock [get_clocks mgt_clk] -min 0.0 [get_ports "*pl_pfail*"]
set_input_delay -clock [get_clocks mgt_clk] -max 5.0 [get_ports "*pl_pfail*"]

set_false_path -from [get_ports "*pl_sw_out*"]
set_input_delay -clock [get_clocks mgt_clk] -min 0.0 [get_ports "*pl_sw_out*"]
set_input_delay -clock [get_clocks mgt_clk] -max 5.0 [get_ports "*pl_sw_out*"]

set_false_path -from [get_ports "*sfp1_los*"]
set_input_delay -clock [get_clocks mgt_clk] -min 0.0 [get_ports "*sfp1_los*"]
set_input_delay -clock [get_clocks mgt_clk] -max 5.0 [get_ports "*sfp1_los*"]

# output diagnostics all false path
set diag [get_ports "diag_x*led[*]"]
set_false_path -to $diag
set_output_delay -clock [get_clocks mgt_clk] -min 0.0 $diag
set_output_delay -clock [get_clocks mgt_clk] -max 5.0 $diag

# serial interface for display
set dport [get_ports -filter { NAME =~  "*display_x*" && DIRECTION == "OUT" }]
set_output_delay -clock [get_clocks clk100m_pl] -min 0.0 $dport
set_output_delay -clock [get_clocks clk100m_pl] -max 5.0 $dport


#i2c:
# first cc to 100MHz clock:
set_input_delay -clock [get_clocks clk100m_pl] 0.0 [get_ports "*i2c_x*"]
set_output_delay -clock [get_clocks clk100m_pl] 0.0 [get_ports "*i2c_x*"]
# then create virt clock and relate sda to this clock
create_clock -name clki2c -period 1000 [get_ports "*i2c_x*scl*"]
set_input_delay  -clock clki2c -min   0.0 [get_ports "*i2c_x*sda*"]
set_input_delay  -clock clki2c -max 200.0 [get_ports "*i2c_x*sda*"]
# i2c is by-design timing issues free, so we can falsepath here:
set_false_path -from [get_clocks clki2c] -to [get_clocks clk100m_pl]

# all things going into display are irrelevant - just slow observation
set_false_path -to [get_pins -hierarchical "*data_b_reg*/D*"]
# reset
set_false_path -to [get_pins {u_40MHzMGMT_reset_sync/reset_msr_reg[0]/D}]
