# USER CONFIGURATION
DEVICE := "ME-XU5-4CG/4EV/5EV-G1"
DEFAULT_IOSTANDARD := "LVCMOS18"

#PROJECT FOLDER PATH
PROJECT_PATH := $(shell pwd)/..

# MAKEFILE GLOBAL VARIABLES
ENCLUSTRA_XU5_SPECS := $(PROJECT_PATH)/doc/enclustra_xu5_specs
XU5_MCOI_PINOUT := $(PROJECT_PATH)/pcb_configuration/xu5_pcb_pinout
DEVKIT_PINOUT := $(PROJECT_PATH)/pcb_configuration/pe1_devkit_pinout
SCRIPTS := $(PROJECT_PATH)/sw/scripts

PLATFORM_PINOUT := $(DEVKIT_PINOUT)
# PLATFORM_PINOUT := $(XU5_MCOI_PINOUT)

all_derived: platform_constraints all

init: platform_constraints project 

open: 
	@vivado -mode gui -nojournal -nolog $(PROJECT_FILE) &> /dev/null & 

# The constraints have to be created based on the current pinout
# configuration in Altium project, just generate pinout of the module
# connection -> save it to the folder "pcb_configuration" and run make
# update_constraints.
# IMPORTANT: Names of the files generated with Altium have to have same names
# as in makefile and must be called with correct parameter (-ap/-bp)!

platform_constraints:
	@printf "Generating constraints files for device $(DEVICE)\n"
	python3 $(SCRIPTS)/assemble_constraints.py \
		-d $(DEVICE) \
		-ap $(PLATFORM_PINOUT)/Aconn.csv \
		-bp $(PLATFORM_PINOUT)/Bconn.csv \
		-va $(ENCLUSTRA_XU5_SPECS)/Mercury_XU5-R1_FPGA_Pinout_Assembly_Variants.csv \
		-vp $(ENCLUSTRA_XU5_SPECS)/Mercury_XU5-R1_FPGA_Pinout.csv \
		-o $(PROJECT_PATH)/hdl/constraints \
		-c $(PLATFORM_PINOUT)/config.csv \
		-io $(DEFAULT_IOSTANDARD)
