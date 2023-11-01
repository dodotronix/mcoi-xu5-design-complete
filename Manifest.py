modules = {
        "git": ["ssh://git@gitlab.cern.ch:7999/vfc_components/ckrs.git@@207f9cedbbd40028bafc55283177ac497e5c3db5",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/mko.git@@6d8e08f73f2f16875505ce08fc7f98587c3fbace",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/get_edge.git@@fef48c44f551f92b46cb42f914a5feea0cd7c46f",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/manyff.git@@256e16feaa17edce335b1a0305cd520dd511f96b",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/gbt-fpga.git@@8a048686d53e16268d35d85ce15e412655a3a707",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/serdes.git::master",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/codec_8b10b.git::master",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/generic_dpram.git::master",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/gray_fifo.git::master",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/memory_transport.git::master",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/glitch_filter.git::master",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/cyclic_redundancy_check.git::master",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/heart_beat.git::master",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/pwm::master",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/scrambler::master",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/tlc5920::master",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/clock_divider::master"
                ],

        "local": ["hdl/src/"],

        # the ultrascale plus components are not in the hdlmake, so
        # it gives warnings, that the graph_solver could not find the
        # dependencies, but vivado is going to find them
        "system": ["vhdl", "xilinx"]
        }

fetchto = "libs"
fetch_post_cmd = "sh ../sw/scripts/compile_all_ips.sh"

# NOTE hdlmake might print some warnings
# while checking the missing dependencies  
# the tmp folder is created so when the 
# Makefile  is generated, all the tmp 
# content is going to be added
import os
if os.path.exists("tmp"):
    modules['local'].append("tmp") 

if action == "simulation":
    modules["local"].append("hdl/tests")

