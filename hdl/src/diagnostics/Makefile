#Makefile for diagnostics module

# IF YOU WANT CHANGE THE PLL TO DIFFERENT FREQUENCY
# GENERATE THE C FILE AND PLACE IT IN CONFIGS
CONFIG_FILE_NAME := test.h

# WARNING: PLEASE DO NOT EDIT THE PARTS BELOW
# IF YOU DON'T KNOW EXACTLY WHAT YOU ARE DOING

#PROJECT FOLDER PATH
PROJECT_PATH := $(shell pwd)
SCRIPTS_DIR := $(ROOT_DIR)/scripts
REGISTER_MAP_DIR := $(SCRIPTS_DIR)/register_map/
IP_CORE_DIR := ip_cores
BRAM_INIT_FILES := $(IP_CORE_DIR)/bram/init_files

PLL_CONFIG_FILE := $(REGISTER_MAP_DIR)/$(CONFIG_FILE_NAME)

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

# TODO clone git repos to temp directory and run run.py
verify:
	@[ ! -d temp_repos ] && mkdir temp_repos; \ 
	cd tests && python3 run.py && cd ..; \ 
	cd $(SCRIPTS_DIR); ./gen_init_coe $(PLL_CONFIG_FILE) \
		$(BRAM_INIT_FILES)

clean:
	rm -r verify/vunit_out; \
	@printf 'TODO - clean temporary files\n'
