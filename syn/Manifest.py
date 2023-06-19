target = "xilinx"
action = "synthesis"

syn_device = "xczu4ev"
syn_grade = "-1"
syn_package = "sfvc784"
syn_top = "mcoi_xu5_design_complete"
syn_project = "mcoi_xu5"
syn_tool = "vivado"
# syn_properties = []

include_dirs = ["../hdl/src"]

# syn_pre_project_cmd = 
# syn_instance_assignments = []

modules = {"local" : ["../"]}

# NOTE hdlmake is going to print some warnings
# while checking the missing dependencies  
# the tmp folder is created so when the Makefile
# is generated, all the tmp content is going to
# be added
import os
if os.path.exists("../tmp"):
    modules['local'].append("../tmp") 
