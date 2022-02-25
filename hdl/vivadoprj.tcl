set script_path [file dirname [info script]]
puts "Script directory: $script_path";

set modules_path $script_path/../libs
puts "Modules directory: $modules_path";

set ip_cores_path $script_path/ip_cores
puts "IP cores directory: $ip_cores_path";

# block design name
set bd_name "mcoi_xu5_ps_part.bd"

#project setup - if you change the names you have to remove the project
#maually before generating a new project with your names!
#You can do that by calling make clean and then make openproject
set proj_path "${script_path}/Synthesis"
set proj_name "mcoi-xu5-design-complete"
set dev_name "xczu4ev-sfvc784-1-i"
puts "Modules directory: $modules_path";

# filesets names - the names are not easy to change
set sources "sources_1"
set constraints "constrs_1"

# Create project
if {![file exists ${proj_path}]} {
  # create project
  create_project  ${proj_path}/${proj_name} -part ${dev_name}
} else {
  #open project
  open_project ${script_path}/Synthesis/${proj_name}
  # IMPORTANT: remove non-existing files - this garanties, that you won't
  # have any duplicates after adding new files and if there were any chaneges
  # in paths the non-existent files will be deleted
  remove_files *
  remove_files ${constraints} *
}

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Project setup
set obj [current_project]
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "enable_vhdl_2008" -value "1" -objects $obj
set_property -name "part" -value "xczu4ev-sfvc784-1-i" -objects $obj
set_property -name "simulator_language" -value "Mixed" -objects $obj

# mcoi xu5 part
add_files [glob $script_path/src/mcoi_xu5_design_complete.sv]
add_files [glob $script_path/src/McoiXu5System.sv]
add_files [glob $script_path/src/McoiXu5Application.sv]
add_files [glob $script_path/src/McoiXu5Diagnostics.sv]
add_files [glob $script_path/src/gbt_xu5.vhd]
add_files [glob $modules_path/BI_HDL_Cores/cores_for_synthesis/vme_reset_sync_and_filter.vhd]
add_files [glob $script_path/src/interfaces.sv]
add_files -fileset ${constraints} [glob $script_path/constraints/*.xdc]

set mcoi_hdl_library $modules_path/mcoi_hdl_library
set mcoi_packages $mcoi_hdl_library/packages
set mcoi_hdl_library_modules $mcoi_hdl_library/modules
add_files -fileset sources_1 [glob $mcoi_packages/CKRSPkg.sv]
add_files -fileset sources_1 [glob $mcoi_packages/MCPkg.sv]
add_files -fileset sources_1 [glob $mcoi_packages/t_display.sv]
add_files -fileset sources_1 [glob $mcoi_hdl_library_modules/tlc5920/*.sv]
add_files -fileset sources_1 [glob $mcoi_hdl_library_modules/clock_divider/*.sv]

# MGMT 40MHz frame PLL
source $ip_cores_path/pll_40m/gbt_pll_clk40m.tcl
source $modules_path/zynq_usplus_gbt_fpga/load2project.tcl
# first clear old block design and create a new
# one just in case that something has changed
remove_files [get_files $bd_name]

# create new block design
create_bd_design $bd_name

# load ps part which is in the current design
# used just to load the logic from the qspi
source $ip_cores_path/ps_part/ps_part_qspi.tcl
save_bd_design

update_compile_order

# Project that are not made by me have different structure,
# so source files have to be added manually

## general blocks
#set bi_hdl_cores $modules_path/BI_HDL_Cores/cores_for_synthesis/
#add_files -fileset sources_1 [glob $bi_hdl_cores/ip_open_cores/crc/*.v]
#add_files -fileset sources_1 [glob $bi_hdl_cores/ip_open_cores/*.v]
#add_files -fileset sources_1 [glob $bi_hdl_cores/8b10b/*.v]
#add_files -fileset sources_1 [glob $bi_hdl_cores/GlitchFilter.v]
#add_files -fileset sources_1 [glob $bi_hdl_cores/serdes/SerDes*?.v]



#set gefe_modules_path $modules_path/mcoi_gefe_frontend/hdl/modules
#add_files -fileset sources_1 [glob $gefe_modules_path/extremity_switches_mapper.sv]
#add_files -fileset sources_1 [glob $gefe_modules_path/build_number.sv]

#add_files -fileset sources_1 [glob $mcoi_hdl_library_modules/pwm/*.sv]
#add_files -fileset sources_1 [glob $mcoi_hdl_library_modules/mko/*.sv]
#add_files -fileset sources_1 [glob $mcoi_hdl_library_modules/get_edge/*.sv]
#add_files -fileset sources_1 [glob $mcoi_hdl_library_modules/manyff/*.sv]
#add_files -fileset sources_1 [glob $mcoi_hdl_library_modules/memory_transport/rx_memory.sv]
#add_files -fileset sources_1 [glob $mcoi_hdl_library_modules/serial_register/*.sv]

#set mcoi_vfc_backend_modules $modules_path/mcoi_vfc_backend_fw/hdl/modules
#add_files -fileset sources_1 [glob $mcoi_vfc_backend_modules/led_blinker.sv]

#set mcoi_vfc_backend_simulation $modules_path/mcoi_vfc_backend_fw/hdl/simulation
#add_files -fileset sources_1 [glob $mcoi_vfc_backend_simulation/constants.sv]
