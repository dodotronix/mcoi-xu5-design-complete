target = "xilinx"
action = "synthesis"

syn_device = "xczu4ev"
syn_grade = "-1"
syn_package = "sfvc784"
syn_top = "mcoi-xu5-design-complete"
syn_project = "mcoi-xu5-design-complete"
syn_tool = "vivado"
syn_properties = [
        {"name" : "PRE_MAPPING_RESYNTHESIS", "value" : "ON"},
        {"name": "FITTER_EFFORT", "value": "STANDARD FIT"}]

# syn_pre_project_cmd = 

include_dirs = ["../hdl/modules"]

# syn_instance_assignments = []

modules = {"local" : ["../"]}
