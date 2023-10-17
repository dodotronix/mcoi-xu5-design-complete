# we're using simulation in VUnit
action = "simulation"
sim_tool = "vunit"

target = "xilinx"
syn_device =  "xczu4ev-sfvc784-1-i"
syn_family = "zynq uplus"
language = "verilog"

# VUnit will use modelsim
tool = "modelsim"

# this picks only the components the projects requires
bi_hdl_cores = ["serdes"]

# target script to run by makefile:
vunit_script = "sim_run.py"

include_dirs = ["../hdl/src"]


modules = {"local": ["../"]}

# IMPORTANT copy glbl.v (general set/reset block for Xilinx IPs) 
# https://www.xilinx.com/htmldocs/xilinx13_1/sim.pdf

# We assume that the vivado will be always in the 
# $XILINX_INSTALL/bin/vivado and glbl.sv in
# $XILINX_INSTALL/data/verilog/src
get_xilinx_root = ("which vivado | \\\n"
                   "\t\tsed \"s/\(.*\)\/bin\/vivado/\\1/\"")

sim_pre_cmd = ("@echo moving glbl.v to $(shell pwd)\n"
        f"\t@cp $(shell {get_xilinx_root})/data/verilog/src/glbl.v .\n")
