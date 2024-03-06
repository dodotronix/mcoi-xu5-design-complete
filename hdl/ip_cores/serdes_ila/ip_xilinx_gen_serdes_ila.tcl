set ip_name serdes_ila 

# DO NOT CHANGE UNLESS YOU KNOW WHAT YOU ARE DOING
set project_path [lindex $argv 0]
set dev_name  [lindex $argv 1]
set ip_file_name [join [list $ip_name ".xci"] ""]

if {($dev_name eq "") || ($project_path eq "")} {
    exit -1
} 

# Create a Manage IP project
create_project $ip_name $project_path -part $dev_name -ip -force
set_property simulator_language Mixed [current_project]
set_property target_language Verilog [current_project]

# Create an IP customization
create_ip -name ila\
    -vendor xilinx.com\
    -library ip\
    -version 6.2\
    -module_name $ip_name 

set_property -dict [list \
  CONFIG.C_NUM_OF_PROBES {13} \
  CONFIG.C_PROBE10_WIDTH {32} \
  CONFIG.C_PROBE2_WIDTH {32} \
  CONFIG.C_PROBE3_WIDTH {32} \
  CONFIG.Component_Name {$ip_name}\
] [get_ips $ip_name]

# Create a synthesis design run for the IP
create_ip_run [get_ips $ip_name]

if {!([get_property CORE_CONTAINER [get_files $ip_file_name]] == "")} {
    convert_ips [get_files $ip_file_name]}
