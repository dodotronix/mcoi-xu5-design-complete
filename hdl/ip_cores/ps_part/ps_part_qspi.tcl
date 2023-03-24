#------------------------------------------------------------------------------#
# Petr Pacner | CERN | 2020-01-13 Mo 10:37   
# 
# GENERATE PROCESSING PART
#------------------------------------------------------------------------------#

## GENERATE IPs

# set name of generated ip core
set ip_root_name zynq_ultrasp_ps 
set ip_orig_name [join [list $ip_root_name "_0"] ""]

startgroup
    create_bd_cell -type ip\
                   -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.4 $ip_orig_name 

set_property -dict [list CONFIG.PSU__ENET0__PERIPHERAL__ENABLE {0}\
                         CONFIG.PSU__GPIO0_MIO__PERIPHERAL__ENABLE {0}\
                         CONFIG.PSU__GPIO1_MIO__PERIPHERAL__ENABLE {0}\
                         CONFIG.PSU__I2C0__PERIPHERAL__ENABLE {0}\
                         CONFIG.PSU__UART0__PERIPHERAL__ENABLE {0}\
                         CONFIG.PSU__USE__M_AXI_GP0 {0}\
                         CONFIG.PSU__USE__M_AXI_GP2 {0}\
                         CONFIG.PSU__USE__FABRIC__RST {0}\
                         CONFIG.PSU__FPGA_PL0_ENABLE {0}\
                         CONFIG.PSU__QSPI__PERIPHERAL__ENABLE {1}\
                         CONFIG.PSU__QSPI__PERIPHERAL__DATA_MODE {x4}]\
                         [get_bd_cells $ip_orig_name]
endgroup

