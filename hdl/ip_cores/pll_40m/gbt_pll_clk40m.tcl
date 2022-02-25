#------------------------------------------------------------------------------#
# Petr Pacner | CERN | 2020-01-10 Fr 15:53  
# 
# generate gbt 40mhz pll (120mhz on input) 
#------------------------------------------------------------------------------#

# set name of generated ip core
set ip_orig_name gbt_pll40m 
set ip_file_name [join [list $ip_orig_name ".xci"] ""]

# check if the IP already exists
if {[lsearch -exact [get_ips] $ip_orig_name] >= 0} {
	puts "the ip core already exists"
	#read_ip [get_files [join [list $ip_orig_name ".xci"] ""]]

} else {

    # create ip 
    create_ip -name clk_wiz\
        -vendor xilinx.com\
        -library ip\
        -version 6.0\
        -module_name $ip_orig_name

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
        CONFIG.CLKOUT1_PHASE_ERROR {107.150}] [get_ips $ip_orig_name]

    # generate ip
    generate_target all [get_ips]
}

if {!([get_property CORE_CONTAINER [get_files $ip_file_name]] == "")} {
    convert_ips [get_files $ip_file_name]}
