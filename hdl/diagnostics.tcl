# SI5338B CONFIG MODULE
#
# create transceiver for xu5

# you can either replace the coe_name variable with the path and name of
# desired coe file or just write the name of the source header.h file
# in make and run make gen_coe; this script will automaticaly look for
# the name you have specified in the makefile
# set fd [open $temp_dir/coe_name "r"]
# set coe_name [read $fd]
set script_path [file dirname [info script]]
set si5338b_modules  $script_path/src

set coe_name config_120mhz.coe
set ip_cores $script_path/ip_cores

add_files -fileset sources_1 [glob $si5338b_modules/*.vhd]
add_files -fileset sources_1 [glob $si5338b_modules/*.sv]

# upload bram to the project
set argv [list $coe_name]
set argc 2
source $ip_cores/bram/pll_generate_bram.tcl
