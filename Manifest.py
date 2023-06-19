modules = {
        "git": ["ssh://git@gitlab.cern.ch:7999/vfc_components/ckrs.git::master",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/mko.git::master",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/get_edge.git::master",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/manyff.git::master",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/mcpkg.git::master",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/gbt-fpga.git::master"
                ],

        "local": ["hdl/src/"],

        "system": ["vhdl", "xilinx"]
        }

fetchto = "libs"
fetch_post_cmd = "source ../sw/scripts/compile_all_ips.sh"

if action == "simulation":
    modules["local"].append("hdl/tests")
