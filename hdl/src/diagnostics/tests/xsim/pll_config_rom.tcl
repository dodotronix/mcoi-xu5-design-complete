#------------------------------------------------------------------------------#
# Petr Pacner | CERN | 2020-01-10 Fr 15:53  
# 
# generate pll config rom 
#------------------------------------------------------------------------------#
#

# set name of generated ip core
create_project -in_memory -part xczu4ev-sfvc784-1-i
file mkdir IP

set ip_orig_name test_rom 
set ip_file_name [join [list $ip_orig_name ".xci"] ""]
set script_dest [file dirname [info script]]

# get absolute path to coe file
#set ip_path [file normalize ./test.coe] 
#set ip_path [file normalize ./test200k.coe] 
set ip_path [file normalize ./test400k.coe] 

# create ip 
create_ip -dir IP\
    -name blk_mem_gen\
    -vendor xilinx.com\
    -library ip -version 8.4\
    -module_name $ip_orig_name

set_property -dict [list CONFIG.Memory_Type {Single_Port_ROM}\
    CONFIG.Write_Width_A {19}\
    CONFIG.Write_Depth_A {1024}\
    CONFIG.Read_Width_A {19}\
    CONFIG.Enable_A {Always_Enabled}\
    CONFIG.Write_Width_B {19}\
    CONFIG.Read_Width_B {19}\
    CONFIG.Load_Init_File {true}\
    CONFIG.Coe_File ${ip_path}\
    CONFIG.Port_A_Write_Rate {0}] [get_ips $ip_orig_name]

# generate ip
generate_target all [get_ips]
