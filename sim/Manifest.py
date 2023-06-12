# we're using simulation in VUnit
action = "simulation"
sim_tool = "vunit"

target = "xilinx"
syn_device =  "xczu4ev-sfvc784-1-i"
langugage = "verilog"

# VUnit will use modelsim
tool = "modelsim"

# target script to run by makefile:
vunit_script = "sim_run.py"

include_dirs = ["../hdl/modules"]

modules = {
    "local": ["../", ],
}

# this one assures that all the libraries for IP cores get compiled
# sim_pre_cmd = 
