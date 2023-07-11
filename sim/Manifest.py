# we're using simulation in VUnit
action = "simulation"
sim_tool = "vunit"

target = "xilinx"
syn_device =  "xczu4ev-sfvc784-1-i"
syn_family = "zynq uplus"
language = "verilog"

# VUnit will use modelsim
tool = "modelsim"

# target script to run by makefile:
vunit_script = "sim_run.py"

include_dirs = ["../hdl/src"]

modules = {"local": ["../"]}
