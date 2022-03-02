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
set_property BITSTREAM.CONFIG.UNUSEDPIN PULLNONE [current_design]

# 100mhz crystal pl clock placed on module pcb
set_property PACKAGE_PIN AD5 [get_ports {clk100m_pl_p}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {clk100m_pl_p}]
set_property PACKAGE_PIN AD4 [get_ports {clk100m_pl_n}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {clk100m_pl_n}]

# define external 100mhz clock
create_clock -period 10.000 -name clk100m_pl [get_ports {clk100m_pl_p}]

# delay [ns] between all inputs and outputs
#set_max_delay 60 - from [all_inputs] - to [all_outputs]
#
set_max_delay 60 - from [display\.*] - to [display\.*]

# Current limit for the LEDs
set_property DRIVE 4 [get_ports {diag_x\.led[*]}]
