set bd_name zynq_ultrasp_ps_system

# DO NOT CHANGE UNLESS YOU KNOW WHAT YOU ARE DOING
set project_path [lindex $argv 0]
set dev_name  [lindex $argv 1]
set ip_file_name [join [list $bd_name ".xci"] ""]

if {($dev_name eq "") || ($project_path eq "")} {
    exit -1
} 

# Create a Manage IP project
create_project $bd_name $project_path -part $dev_name -ip -force
set_property simulator_language Mixed [current_project]
set_property target_language Verilog [current_project]

# create new block design
create_bd_design $bd_name

set ps ps_part
set conn smart_connect
set gpios axi_gpio
set reset ps_reset
set sysmanager system_management
set ps_reg shared_reg
set mem shared_memory 
set ctrl shared_memory_control 
set port shared_memory_port 

# Create an IP customization
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.4 $ps 
create_bd_cell -type ip -vlnv xilinx.com:ip:system_management_wiz $sysmanager
create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect $conn 
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 $reset 
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 $gpios
create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 $mem 
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 $ctrl

# connections going to PL
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:bram_rtl:1.0 ${port} 
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 ${ps_reg} 

endgroup

set_property -dict [list CONFIG.PSU_BANK_0_IO_STANDARD {LVCMOS18} \
                         CONFIG.PSU_BANK_1_IO_STANDARD {LVCMOS18} \
                         CONFIG.PSU_BANK_2_IO_STANDARD {LVCMOS18} \
                         CONFIG.PSU_BANK_3_IO_STANDARD {LVCMOS18} \
                         CONFIG.PSU__GPIO0_MIO__PERIPHERAL__ENABLE {1}\
                         CONFIG.PSU__GPIO1_MIO__PERIPHERAL__ENABLE {1}\
                         CONFIG.PSU__GPIO2_MIO__PERIPHERAL__ENABLE {1}\
                         CONFIG.PSU__I2C0__PERIPHERAL__ENABLE {1} \
                         CONFIG.PSU__I2C0__PERIPHERAL__IO {MIO 10 .. 11} \
                         CONFIG.PSU__I2C1__PERIPHERAL__ENABLE {1} \
                         CONFIG.PSU__I2C1__PERIPHERAL__IO {EMIO} \
                         CONFIG.PSU__SD0__PERIPHERAL__ENABLE {1} \
                         CONFIG.PSU__SD0__SLOT_TYPE {eMMC} \
                         CONFIG.PSU__SD0__DATA_TRANSFER_MODE {8Bit} \
                         CONFIG.PSU__SD0__PERIPHERAL__IO {MIO 13 .. 22} \
                         CONFIG.PSU__SD1__PERIPHERAL__ENABLE {1} \
                         CONFIG.PSU__SD1__GRP_CD__ENABLE {1} \
                         CONFIG.PSU__SD1__PERIPHERAL__IO {MIO 46 .. 51} \
                         CONFIG.PSU__SD1__SLOT_TYPE {SD 2.0} \
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
                         CONFIG.PSU__ENET0__GRP_MDIO__ENABLE {1} \
                         CONFIG.PSU__ENET0__PERIPHERAL__ENABLE {1} \
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
                         [get_bd_cells $ps]

set_property -dict [ list \
  CONFIG.SINGLE_PORT_BRAM {1} \
] [get_bd_cells $ctrl]

set_property -dict [ list \
  CONFIG.Memory_Type {True_Dual_Port_RAM} \
] [get_bd_cells $mem]

set_property -dict [ list \
  CONFIG.TEMPERATURE_ALARM_OT_TRIGGER {85} \
  CONFIG.CHANNEL_ENABLE_VP_VN {false} \
] [get_bd_cells $sysmanager]

set_property -dict [ list \
    CONFIG.NUM_MI {3} \
    CONFIG.NUM_CLKS {1} \
    CONFIG.NUM_SI {1} \
] [get_bd_cells $conn]

set_property -dict [ list \
    CONFIG.READ_WRITE_MODE READ_WRITE \
    CONFIG.MASTER_TYPE BRAM_CTRL \
] [get_bd_intf_ports ${port}]


startgroup
# connec the blocks
connect_bd_intf_net [get_bd_intf_pins ${conn}/S00_AXI] [get_bd_intf_pins ${ps}/M_AXI_HPM0_LPD]
connect_bd_intf_net [get_bd_intf_pins ${conn}/M00_AXI] [get_bd_intf_pins ${sysmanager}/S_AXI_LITE]
connect_bd_intf_net [get_bd_intf_pins ${gpios}/S_AXI] [get_bd_intf_pins ${conn}/M01_AXI]
connect_bd_intf_net [get_bd_intf_pins ${ctrl}/BRAM_PORTA] [get_bd_intf_pins ${mem}/BRAM_PORTA]
connect_bd_intf_net [get_bd_intf_ports ${port}] [get_bd_intf_pins ${mem}/BRAM_PORTB]
connect_bd_intf_net [get_bd_intf_pins ${conn}/M02_AXI] [get_bd_intf_pins ${ctrl}/S_AXI]
connect_bd_intf_net [get_bd_intf_ports ${ps_reg}] [get_bd_intf_pins axi_gpio/GPIO]

connect_bd_net [get_bd_pins ${ps}/pl_resetn0] [get_bd_pins ${reset}/ext_reset_in]
connect_bd_net [get_bd_pins ${reset}/peripheral_aresetn] [get_bd_pins ${sysmanager}/s_axi_aresetn]

connect_bd_net [get_bd_pins ${conn}/aclk] [get_bd_pins ${ps}/pl_clk0]
connect_bd_net [get_bd_pins ${conn}/aclk] [get_bd_pins ${reset}/slowest_sync_clk]
connect_bd_net [get_bd_pins ${conn}/aclk] [get_bd_pins ${ps}/maxihpm0_lpd_aclk]
connect_bd_net [get_bd_pins ${conn}/aclk] [get_bd_pins ${sysmanager}/s_axi_aclk]
connect_bd_net [get_bd_pins ${conn}/aresetn] [get_bd_pins ${reset}/interconnect_aresetn]

connect_bd_net [get_bd_pins ${ctrl}/s_axi_aclk] [get_bd_pins ${ps}/pl_clk0]
# connect_bd_net [get_bd_pins ${ctrl}/s_axi_aresetn] [get_bd_pins ${ps}/peripheral_aresetn]
connect_bd_net [get_bd_pins ${ctrl}/s_axi_aresetn] [get_bd_pins ${gpios}/s_axi_aresetn]

connect_bd_net [get_bd_pins ${gpios}/s_axi_aclk] [get_bd_pins ${ps}/pl_clk0]
connect_bd_net [get_bd_pins ${gpios}/s_axi_aresetn] [get_bd_pins ${sysmanager}/s_axi_aresetn]

endgroup

assign_bd_address
save_bd_design
validate_bd_design
