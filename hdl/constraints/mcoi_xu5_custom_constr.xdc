# ------------------------------------------------------------------------------
# This file serves as a additional constraint file
# PLEASE IF YOU NEED TO ADJUST SOME CONSTRAINTS OR
# ADD NEW ONES, EDIT THIS FILE, OTHER FILES ARE
# AUTOMATICALY GENERATED SO IF YOU MAKE YOUR CHANGES
# IN THOSE, YOUR SETTINGS WILL BE OVERWITTEN BY THE
# NEXT "MAKE UPDATE"
# ------------------------------------------------------------------------------

# FIXME this constraint comes from the GBT core
# but there is probably a wrong name of the
# transceiver - this needs to be fixed
# set_property RXSLIDE_MODE "PMA" [get_cells -hier -filter {NAME =~ *gbt_inst*GTHE4_CHANNEL_PRIM_INST}]

# unused pins are set to high impedance.  # If the constraint is removed, all
set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN ENABLE [current_design]

# ------------------------------------------------------------------------------
# Important! Do not remove this constraint!  # This property ensures that all
# unused pins are set to high impedance.  # If the constraint is removed, all
# unused pins have to be set to HiZ in the top level file.
# ------------------------------------------------------------------------------
set_property BITSTREAM.CONFIG.UNUSEDPIN PULLNONE [current_design]

# 100mhz crystal pl clock placed on module pcb
set_property PACKAGE_PIN AD5 [get_ports {clk100_pl_p}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {clk100_pl_p}]
set_property PACKAGE_PIN AD4 [get_ports {clk100_pl_n}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {clk100_pl_n}]
