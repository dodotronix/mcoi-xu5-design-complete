set ip_name zynq_ultrasp_ps

# DO NOT CHANGE UNLESS YOU KNOW WHAT YOU ARE DOING
set project_path [lindex $argv 0]
set dev_name  [lindex $argv 1]
set ip_file_name [join [list $ip_name ".xci"] ""]
set bd_name ${ip_name}_system 

if {($dev_name eq "") || ($project_path eq "")} {
    exit -1
} 

# Create a Manage IP project
create_project $ip_name $project_path -part $dev_name -ip -force
set_property simulator_language Mixed [current_project]
set_property target_language Verilog [current_project]

# create new block design
create_bd_design $bd_name

# Create an IP customization
startgroup
    create_bd_cell -type ip\
                   -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.4 $ip_name 

set_property -dict [list CONFIG.PSU__ENET0__PERIPHERAL__ENABLE {0} \
                         CONFIG.PSU_BANK_0_IO_STANDARD {LVCMOS18} \
                         CONFIG.PSU_BANK_1_IO_STANDARD {LVCMOS18} \
                         CONFIG.PSU_BANK_2_IO_STANDARD {LVCMOS18} \
                         CONFIG.PSU_BANK_3_IO_STANDARD {LVCMOS18} \
                         CONFIG.PSU__GPIO0_MIO__PERIPHERAL__ENABLE {1}\
                         CONFIG.PSU__GPIO1_MIO__PERIPHERAL__ENABLE {1}\
                         CONFIG.PSU__GPIO2_MIO__PERIPHERAL__ENABLE {1}\
                         CONFIG.PSU__I2C0__PERIPHERAL__ENABLE {1} \
                         CONFIG.PSU__I2C0__PERIPHERAL__IO {MIO 10 .. 11} \
                         CONFIG.PSU__UART0__PERIPHERAL__ENABLE {1} \
                         CONFIG.PSU__UART0__PERIPHERAL__IO {MIO 38 .. 39} \
                         CONFIG.PSU__TTC0__PERIPHERAL__ENABLE {1} \
                         CONFIG.PSU__USE__M_AXI_GP0 {0} \
                         CONFIG.PSU__USE__M_AXI_GP2 {1} \
                         CONFIG.PSU__USE__FABRIC__RST {1} \
                         CONFIG.PSU__QSPI__PERIPHERAL__ENABLE {1} \
                         CONFIG.PSU__QSPI__PERIPHERAL__DATA_MODE {x4} \
                         CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__FREQMHZ {200} \
                         CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__SRCSEL {RPLL} \
                         CONFIG.PSU__QSPI__GRP_FBCLK__ENABLE {1} \
                         CONFIG.PSU__FPGA_PL0_ENABLE {1} \
                         CONFIG.PSU__FPGA_PL1_ENABLE {0} \
                         CONFIG.PSU__CRF_APB__DDR_CTRL__FREQMHZ {1200} \
                         CONFIG.PSU__DDRC__BG_ADDR_COUNT {1} \
                         CONFIG.PSU__DDRC__CL {17} \
                         CONFIG.PSU__DDRC__CWL {12} \
                         CONFIG.PSU__DDRC__DEVICE_CAPACITY {4096 MBits} \
                         CONFIG.PSU__DDRC__DRAM_WIDTH {16 Bits} \
                         CONFIG.PSU__DDRC__ECC {Enabled} \
                         CONFIG.PSU__DDRC__ROW_ADDR_COUNT {15} \
                         CONFIG.PSU__DDRC__SPEED_BIN {DDR4_2400T} \
                         CONFIG.PSU__DDRC__T_FAW {30} \
                         CONFIG.PSU__DDRC__T_RAS_MIN {32} \
                         CONFIG.PSU__DDRC__T_RC {46.16} \
                         CONFIG.PSU__DDRC__T_RCD {17} \
                         CONFIG.PSU__DDRC__T_RP {17} \
                         CONFIG.PSU_MIO_13_PULLUPDOWN {disable} \
                         CONFIG.PSU_MIO_14_PULLUPDOWN {disable} \
                         CONFIG.PSU_MIO_15_PULLUPDOWN {disable} \
                         CONFIG.PSU_MIO_16_PULLUPDOWN {disable} \
                         CONFIG.PSU_MIO_17_PULLUPDOWN {disable} \
                         CONFIG.PSU_MIO_18_PULLUPDOWN {disable} \
                         CONFIG.PSU_MIO_19_PULLUPDOWN {disable} \
                         CONFIG.PSU_MIO_20_PULLUPDOWN {disable} \
                         CONFIG.PSU_MIO_21_PULLUPDOWN {disable} \
                         CONFIG.PSU_MIO_12_PULLUPDOWN {disable}] \
                         [get_bd_cells $ip_name]

# create_bd_cell -type ip -vlnv xilinx.com:ip:system_management_wiz system_management_wiz
# create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_00
# create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 ps_sys_rst

# set_property -dict [ list \
#   CONFIG.TEMPERATURE_ALARM_OT_TRIGGER {85} \
#   CONFIG.CHANNEL_ENABLE_VP_VN {false} \
# ] [get_bd_cells system_management_wiz]

# set_property -dict [list \
#     CONFIG.NUM_MI {1} \
#     CONFIG.NUM_CLKS {1} \
#     CONFIG.NUM_SI {1}
# ] [get_bd_cells smartconnect_00]

# Create a synthesis design run for the IP
# create_ip_run [get_ips smartconnect_00]
# create_ip_run [get_ips system_management_wiz]

# # connec the blocks
# connect_bd_intf_net [get_bd_intf_pins zynq_ultrasp_ps_0/M_AXI_HPM0_LPD] [get_bd_intf_pins smartconnect_00/S00_AXI]
# connect_bd_net [get_bd_pins smartconnect_00/aclk] [get_bd_pins zynq_ultrasp_ps_0/maxihpm0_lpd_aclk]
# connect_bd_net [get_bd_pins ps_sys_rst/slowest_sync_clk] [get_bd_pins smartconnect_00/aclk]
# connect_bd_net [get_bd_pins system_management_wiz/s_axi_aclk] [get_bd_pins smartconnect_00/aclk]
# connect_bd_intf_net [get_bd_intf_pins smartconnect_00/M00_AXI] [get_bd_intf_pins system_management_wiz/S_AXI_LITE]
# connect_bd_net [get_bd_pins zynq_ultrasp_ps_0/pl_clk0] [get_bd_pins smartconnect_00/aclk]
# connect_bd_net [get_bd_pins smartconnect_00/aresetn] [get_bd_pins ps_sys_rst/interconnect_aresetn]
# connect_bd_net [get_bd_pins zynq_ultrasp_ps_0/pl_resetn0] [get_bd_pins ps_sys_rst/ext_reset_in]
# connect_bd_net [get_bd_pins ps_sys_rst/peripheral_aresetn] [get_bd_pins system_management_wiz/s_axi_aresetn]

endgroup
save_bd_design
