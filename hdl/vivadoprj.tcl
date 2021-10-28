set script_path [file dirname [info script]]
set modules_path $script_path/../modules

#project setup
set proj_name "mcoi-xu5-design-complete"

# Create project
create_project  ${script_path}/Synthesis/${proj_name} -part xczu4ev-sfvc784-1-i

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

set obj [current_project]
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "enable_vhdl_2008" -value "1" -objects $obj
set_property -name "part" -value "xczu4ev-sfvc784-1-i" -objects $obj
set_property -name "simulator_language" -value "Mixed" -objects $obj

# mcoi xu5 part
add_files -fileset sources_1 [glob $script_path/src/*.sv] 

## general blocks
set bi_hdl_cores $modules_path/BI_HDL_Cores/cores_for_synthesis/
add_files -fileset sources_1 [glob $bi_hdl_cores/ip_open_cores/crc/*.v] 
add_files -fileset sources_1 [glob $bi_hdl_cores/ip_open_cores/*.v] 
add_files -fileset sources_1 [glob $bi_hdl_cores/8b10b/*.v] 
add_files -fileset sources_1 [glob $bi_hdl_cores/GlitchFilter.v] 
add_files -fileset sources_1 [glob $bi_hdl_cores/serdes/SerDes*?.v] 

set mcoi_hdl_library $modules_path/mcoi_hdl_library 

set mcoi_packages $mcoi_hdl_library/packages
add_files -fileset sources_1 [glob $mcoi_packages/CKRSPkg.sv] 
add_files -fileset sources_1 [glob $mcoi_packages/MCPkg.sv] 
add_files -fileset sources_1 [glob $mcoi_packages/t_display.sv] 

set gefe_modules_path $modules_path/mcoi_gefe_frontend/hdl/modules
add_files -fileset sources_1 [glob $gefe_modules_path/extremity_switches_mapper.sv] 
add_files -fileset sources_1 [glob $gefe_modules_path/build_number.sv] 

set mcoi_hdl_library_modules $mcoi_hdl_library/modules
add_files -fileset sources_1 [glob $mcoi_hdl_library_modules/pwm/*.sv] 
add_files -fileset sources_1 [glob $mcoi_hdl_library_modules/mko/*.sv] 
add_files -fileset sources_1 [glob $mcoi_hdl_library_modules/clock_divider/*.sv] 
add_files -fileset sources_1 [glob $mcoi_hdl_library_modules/get_edge/*.sv] 
add_files -fileset sources_1 [glob $mcoi_hdl_library_modules/manyff/*.sv] 
add_files -fileset sources_1 [glob $mcoi_hdl_library_modules/memory_transport/rx_memory.sv] 
add_files -fileset sources_1 [glob $mcoi_hdl_library_modules/serial_register/*.sv] 
add_files -fileset sources_1 [glob $mcoi_hdl_library_modules/tlc5920/*.sv] 

set mcoi_vfc_backend_modules $modules_path/mcoi_vfc_backend_fw/hdl/modules
add_files -fileset sources_1 [glob $mcoi_vfc_backend_modules/led_blinker.sv] 

set mcoi_vfc_backend_simulation $modules_path/mcoi_vfc_backend_fw/hdl/simulation
add_files -fileset sources_1 [glob $mcoi_vfc_backend_simulation/constants.sv] 

