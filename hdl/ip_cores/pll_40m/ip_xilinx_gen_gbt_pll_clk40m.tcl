set project_path [lindex $argv 0]
set dev_name  [lindex $argv 1]
set ip_name gbt_pll40m 
set ip_file_name [join [list $ip_name ".xci"] ""]

if {($dev_name eq "") || ($project_path eq "")} {
    exit -1
} 

# Create a Manage IP project
create_project gbt_pll_clk40m ${project_path} -part ${dev_name} -ip -force
set_property simulator_language Mixed [current_project]
set_property target_language Verilog [current_project]

# Create an IP customization
create_ip -name clk_wiz\
    -vendor xilinx.com\
    -library ip\
    -version 6.0\
    -module_name $ip_name

set_property -dict [list CONFIG.PRIMITIVE {PLL}\
    CONFIG.PRIM_IN_FREQ {120}\
    CONFIG.PRIMARY_PORT {clk120m_i}\
    CONFIG.CLK_OUT1_PORT {clk40m_o}\
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {40}\
    CONFIG.CLKIN1_JITTER_PS {83.33}\
    CONFIG.CLKOUT1_DRIVES {Buffer}\
    CONFIG.CLKOUT2_DRIVES {Buffer}\
    CONFIG.CLKOUT3_DRIVES {Buffer}\
    CONFIG.CLKOUT4_DRIVES {Buffer}\
    CONFIG.CLKOUT5_DRIVES {Buffer}\
    CONFIG.CLKOUT6_DRIVES {Buffer}\
    CONFIG.CLKOUT7_DRIVES {Buffer}\
    CONFIG.MMCM_BANDWIDTH {OPTIMIZED}\
    CONFIG.MMCM_CLKFBOUT_MULT_F {7}\
    CONFIG.MMCM_CLKIN1_PERIOD {8.333}\
    CONFIG.MMCM_CLKIN2_PERIOD {10.0}\
    CONFIG.MMCM_COMPENSATION {AUTO}\
    CONFIG.MMCM_CLKOUT0_DIVIDE_F {21}\
    CONFIG.CLKOUT1_JITTER {161.681}\
    CONFIG.CLKOUT1_PHASE_ERROR {107.150}] [get_ips $ip_name]

# Create a synthesis design run for the IP
create_ip_run [get_ips $ip_name]

# Launch the synthesis run for the IP
launch_run ${ip_name}_synth_1 

if {!([get_property CORE_CONTAINER [get_files $ip_file_name]] == "")} {
    convert_ips [get_files $ip_file_name]}
