modules = {
        "git": ["ssh://git@gitlab.cern.ch:7999/vfc_components/ckrs.git::master",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/mko.git::master",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/get_edge.git::master",
                "ssh://git@gitlab.cern.ch:7999/vfc_components/manyff.git::master",
                "ssh://git@gitlab.cern.ch:7999/personal-digital-lib/zynq_usplus_gbt_fpga.git" 
                ],

        "local": ["hdl/src/"],

        "system": ["vhdl", "xilinx"]
        }

fetchto = "libs"

if action == "simulation":
    modules["local"].append("hdl/tests")
