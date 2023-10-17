target = "xilinx"
action = "synthesis"

syn_device = "xczu4ev"
syn_grade = "-1-i"
syn_package = "-sfvc784"
syn_top = "mcoi_xu5_design_complete"
syn_project = "mcoi_xu5"
syn_tool = "vivado"

# this picks only the components the projects requires
bi_hdl_cores = ["serdes"]

include_dirs = ["../hdl/src"]
incl_makefiles = ["../extra_rules.mk"]

# syn_instance_assignments = []
syn_pre_project_cmd = "source ../hdl/constraints/get_constraints.sh >> files.tcl;"

# TODO add BRAM to the design and fill it with information about the build
syn_pre_synthesize_cmd = "echo \"HERE WE GENERATE THE TIME and GET THE GIT COMMIT NUMBER\""

modules = {"local" : ["../"]}
