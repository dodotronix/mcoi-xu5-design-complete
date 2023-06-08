
#PROJECT FOLDER PATH
PROJECT_PATH := $(shell pwd)

# MAKEFILE GLOBAL VARIABLES
ENCLUSTRA_XU5_SPECS := $(PROJECT_PATH)/pcb_configuration/enclustra_xu5_specs
XU5_MCOI_PINOUT := $(PROJECT_PATH)/pcb_configuration/xu5_pcb_pinout
DEVKIT_PINOUT := $(PROJECT_PATH)/pcb_configuration/pe1_devkit_pinout
DEVICE := "ME-XU5-4CG/4EV/5EV-G1"
DEFAULT_IOSTANDARD := "LVCMOS18"

# choose the desired platform to generate correct constraints
PLATFORM_PINOUT := $(DEVKIT_PINOUT)
# PLATFORM_PINOUT := $(XU5_MCOI_PINOUT)

all:
	@printf 'USAGE: init|check_compatibility|vproject_open|vproject_update|update|clean\n'
	@printf '       init                - downloads all submodules\n'
	@printf '       check_compatibility - checks if the appropriate software is installed\n'
	@printf '       vproject_update     - opens current project using the tcl script\n'
	@printf '       vproject_open       - updates the vivado project without opening gui\n'
	@printf '       update              - this regenerates the constraints based on files in pcb_configuration directory\n'
	@printf '       compile             - CLI compilation including copying bitstream into output folder\n'
	@printf '       clean               - cleans all automaticaly generated and created directories and files\n'
	@printf '       bitstream           - copies the generated bitstream into output folder\n'

__check_software_availability:
	@type python3 >/dev/null 2>&1 || { \
		printf 'ERR: pip3 is either not installed or present in the system PATH\n' >&2; \
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

compile:
	@vivado -mode batch -source hdl/compile.tcl

bitstream:
	@cp hdl/Synthesis/mcoi-xu5-design-complete.runs/impl_1/*.bit syn/

init:
	@git submodule update --init --recursive

check_compatibility: __check_software_availability

vproject_update:
	@vivado -mode batch -nojournal -source hdl/vivadoprj.tcl

vproject_open:
	@vivado -mode gui -nojournal -source hdl/vivadoprj.tcl &> /dev/null &

platform_constraints:
	@printf "Generating constraints files for device $(DEVICE)\n"
	python3 sw/scripts/assemble_constraints.py \
		-d $(DEVICE) \
		-ap $(PLATFORM_PINOUT)/Aconn.csv \
		-bp $(PLATFORM_PINOUT)/Bconn.csv \
		-va $(ENCLUSTRA_XU5_SPECS)/Mercury_XU5-R1_FPGA_Pinout_Assembly_Variants.csv \
		-vp $(ENCLUSTRA_XU5_SPECS)/Mercury_XU5-R1_FPGA_Pinout.csv \
		-o $(PROJECT_PATH)/hdl/constraints \
		-c $(PLATFORM_PINOUT)/config.csv \
		-io $(DEFAULT_IOSTANDARD)

update: platform_constraints
	@python3 sw/scripts/gen_init_coe.py \
		-s hdl/src/diagnostics/pll_rom.sv \
		-c hdl/ip_cores/bram/init_files/config_120mhz_50mhz.coe\
		fw/register_map/mcoi_xu5_devkit_ch0_ch2_120mhz_low_jitter.h

# The constraints have to be created based on the current pinout
# configuration in Altium project, just generate pinout of the module
# connection -> save it to the folder "pcb_configuration" and run make
# update_constraints.
# IMPORTANT: Names of the files generated with Altium have to have same names
# as in makefile and must be called with correct parameter (-ap/-bp)!

clean:
	@printf 'INF -> removing vivado project files\n' >&2
	@rm -rf hdl/Synthesis
	@rm -rf hdl/.Xil/
	@rm -rf vivado.*
