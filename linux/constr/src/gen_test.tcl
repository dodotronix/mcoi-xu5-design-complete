
set script_path [file dirname [info script]]
set bd_name "mcoi_xu5_optics.bd"

remove_files [get_files $bd_name]

#create block design
create_bd_design "mcoi_xu5_optics"

#load ps part 
#source $script_path/../ps_part/ps_part_forlinux_bd.tcl
source $script_path/../ps_part/ps_part_qspi_bd.tcl

save_bd_design


