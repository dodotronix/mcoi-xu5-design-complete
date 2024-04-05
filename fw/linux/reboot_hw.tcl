connect -url tcp:pcsy169:3121
targets 5

after 1000
rst -srst

# source ../vitis/build/mcoi_platform/tempdsa/psu_init.tcl
# psu_init
# after 1000
# psu_ps_pl_isolation_removal
# after 1000
# psu_ps_pl_reset_config

# targets 10
# rst -processor
