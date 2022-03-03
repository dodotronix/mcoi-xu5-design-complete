# Makefile for diagnostics module

# IF YOU WANT CHANGE THE PLL TO DIFFERENT FREQUENCY
# GENERATE THE C FILE AND PLACE IT IN CONFIGS
SIM_HEADER_FILE_NAME := config_120mhz.h
SIM_COE_FILE_NAME    := config_120mhz.coe
XSIM_TEMP_PROJECT    := temp_top.prj
XSIM_TEMP_VCD_TCL    := dump_vcd.tcl
BUILD_BRAM_TCL       := build_bram.tcl

# WARNING: PLEASE DO NOT EDIT THE PARTS BELOW
# IF YOU DON'T KNOW EXACTLY WHAT YOU ARE DOING

#PROJECT FOLDER PATH
MAKEFILE_PATH     := $(shell pwd)
SCRIPTS_DIR       := $(MAKEFILE_PATH)/scripts
REGISTER_MAP_DIR  := $(SCRIPTS_DIR)/register_map
IP_CORE_DIR       := $(MAKEFILE)/ip_cores
BRAM_INIT_FILES   := $(IP_CORE_DIR)/bram/init_files
TESTS_FOLDER      := $(MAKEFILE_PATH)/tests
TEMP_XSIM_FOLDER  := $(MAKEFILE_PATH)/temp_xsim
TEMP_REPOSITORIES := $(MAKEFILE_PATH)/temp_repos

PLL_HEADER_FILE := $(REGISTER_MAP_DIR)/$(SIM_HEADER_FILE_NAME)

all:
	@printf 'USAGE: init|update|verify|verify_gui|clean\n'
	@printf '       init        - This checks if the correct software is installed\n'
	@printf '       update      - regenerates coe files and updates bram core\n'
	@printf '       verify      - downloads required repos and run the simulation in modelsim\n'
	@printf '       verify_gui  - runs the verify commad and open GUI\n'
	@printf '       clean       - cleans all temporary created directories and files\n'

_check_availability:
	@printf "TODO - check vivado version, modelsim, python"


init: _check_availability

__check_software_availability:
	@type python3 >/dev/null 2>&1 || { \
		printf 'ERR: "python3"\n' >&2; \
		false; }
	@python3 -m pip >/dev/null || { \
		printf 'ERR: pip3 is either not installed or present in the system PATH\n' >&2; \
		false; }
	@python3 -m pip list | grep vunit-hdl >/dev/null || { \
		printf 'ERR: "vunit-hdl" is either not installed or present in the system PATH\n' >&2; \
		false; }
	@type vivado >/dev/null || { \
		printf 'ERR: "Xilinx Vivado" is not installed or present in the system PATH\n' >&2; \
		false; }
## first check if there is a Modelsim or GHDL installed 
	@if type vsim &> /dev/null; then \
		export VUNIT_SIMULATOR=vsim; \
		vsim -version | grep "vsim 2021.1" >/dev/null || \
		printf 'WARN: Version of Modelsim is not "2021.1"\n'; \
		printf 'INFO: Modelsim simulator set as vuint simulator\n'; \
	elif type ghdl &> /dev/null; then \
		export VUNIT_SIMULATOR=ghdl; \
		printf 'INFO: GHDL simulator set as vuint simulator\n'; \
	else \
		printf 'ERR: neither GHDL or Modelsim are installed or in the system PATH\n' >&2; \
		false; \
	fi;

update:
	@printf 'TODO - regenerates ip_cores\n'

verify:
	@[ -d $(TEMP_REPOSITORIES)] && rm -rf $(TEMP_REPOSITORIES); \
		mkdir $(TEMP_REPOSITORIES) && cd $(TEMP_REPOSITORIES); \
		git clone https://github.com/ParticleBert/FPGA-I2C-Slave.git; \
		git clone ssh://git@gitlab.cern.ch:7999/bi/BI_HDL_Cores.git; \
		cd ..; \
		[ ! -d $(TEMP_XSIM_FOLDER) ] && mkdir $(TEMP_XSIM_FOLDER); \
		python3 $(SCRIPTS_DIR)/gen_init_coe.py $(PLL_HEADER_FILE) \
		$(TEMP_XSIM_FOLDER)/$(SIM_COE_FILE_NAME);

test:
		cd $(TESTS_FOLDER) && python3 run.py && cd ..

temp_vivado_project:
	@touch $(TEMP_XSIM_FOLDER)/$(XSIM_TEMP_PROJECT); \
		printf "" > $(TEMP_XSIM_FOLDER)/$(XSIM_TEMP_PROJECT); \
		for i in $(SCRIPTS_DIR)/*.vhd; do \
		printf "vhdl work \"$(SCRIPTS_DIR)/$i\"\n" \
		>> $(TEMP_XSIM_FOLDER)/$(XSIM_TEMP_PROJECT); done; \
		printf "verilog work $(TEMP_XSIM_FOLDER)/IP/\n" \
		>> $(TEMP_XSIM_FOLDER)/$(XSIM_TEMP_PROJECT); \
		printf "verilog work $(TEMP_XSIM_FOLDER)/IP/\n" \
		>> $(TEMP_XSIM_FOLDER)/$(XSIM_TEMP_PROJECT);

create_vdc_file:
	@touch $(TEMP_XSIM_FOLDER)/$(XSIM_TEMP_VCD_TCL); \
		printf "open_vcd\n" \
		> $(TEMP_XSIM_FOLDER)/$(XSIM_TEMP_VCD_TCL); \
		printf "log_vcd [get_object /I2cReader_tb/*]\n" \
		>> $(TEMP_XSIM_FOLDER)/$(XSIM_TEMP_VCD_TCL); \
		printf "log_vcd [get_object /feeder_i/*]\n" \
		>> $(TEMP_XSIM_FOLDER)/$(XSIM_TEMP_VCD_TCL); \
		printf "log_vcd [get_object /interpreter_i/*]\n" \
		>> $(TEMP_XSIM_FOLDER)/$(XSIM_TEMP_VCD_TCL); \
		printf "run all\nclose_vcd\nexit" \
		>> $(TEMP_XSIM_FOLDER)/$(XSIM_TEMP_VCD_TCL) 

build_bram: 
	@cd $(TEMP_XSIM_FOLDER); \
		cp $(TESTS_FOLDER)/xsim/$(BUILD_BRAM_TCL) .; \
		vivado -mode batch -source $(BUILD_BRAM_TCL) \
		-tclargs $(SIM_COE_FILE_NAME) \
		-nojournal -appjournal -nolog; \
		cd ..

clean:
	@rm -fr temp_repos; \
	rm -fr $(TESTS_FOLDER)/vunit_out; \
	rm -fr $(TEMP_XSIM_FOLDER)

