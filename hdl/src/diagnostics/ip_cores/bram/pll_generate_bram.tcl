#------------------------------------------------------------------------------#
# Petr Pacner | CERN | 2020-01-10 Fr 15:53  
# 
# generate pll config rom 
#------------------------------------------------------------------------------#
#

# set name of generated ip core
set ip_orig_name pll_config_rom 
set ip_file_name [join [list $ip_orig_name ".xci"] ""]
set script_dest [file dirname [info script]]

set ip_path [lindex argv 0]

# check if the IP already exists
if {[lsearch -exact [get_ips] $ip_orig_name] >= 0} {
	puts "the ip core already exists"

} else {
    # create ip 
    create_ip -name blk_mem_gen\
    -vendor xilinx.com\
    -library ip -version 8.4\
    -module_name $ip_orig_name

    set_property -dict [list CONFIG.Component_Name {$ip_source}\
        CONFIG.Memory_Type {Single_Port_ROM}\
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
}

if {!([get_property CORE_CONTAINER [get_files $ip_file_name]] == "")} {
    convert_ips [get_files $ip_file_name]}
