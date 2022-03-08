
# compile project
xvlog -prj top.prj
xelab -prj top.prj -s snapshot I2cReader_tb \
  -debug typical -L work -L blk_mem_gen_v8_4_4 \
  -L unisims_ver -L unimacro_ver -L secureip -L xpm 

# start simulation
xsim snapshot -tclbatch dump_vcd.tcl
