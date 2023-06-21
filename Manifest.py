modules = {
        "git": ["ssh://git@gitlab.cern.ch:7999/vfc_components/ckrs.git::master",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/mko.git::master",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/get_edge.git::master",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/manyff.git::master",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/mcpkg.git::master",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/gbt-fpga.git::master"
                ],

        "local": ["hdl/src/"],

        # the ultrascale plus components are not in the hdlmake, so
        # it gives warnings, that the graph_solver could not find the
        # dependencies, but vivado is going to find them
        "system": ["vhdl", "xilinx"]
        }

fetchto = "libs"
fetch_post_cmd = "source ../sw/scripts/compile_all_ips.sh"

if action == "simulation":
    modules["local"].append("hdl/tests")

# NOTE hdlmake might print some warnings
# while checking the missing dependencies  
# the tmp folder is created so when the 
# Makefile  is generated, all the tmp 
# content is going to be added
import os
if os.path.exists("tmp"):
    modules['local'].append("tmp") 
