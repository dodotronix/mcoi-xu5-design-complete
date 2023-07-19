##-----------------------------------------------------------------------------
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation; either version 2
## of the License, or (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin Street, Fifth Floor
## Boston, MA  02110-1301, USA.
##
## You can dowload a copy of the GNU General Public License here:
## http://www.gnu.org/licenses/gpl.txt
##
## Copyright (c) July 2023 CERN
##
## @author: Petr Pacner <petr.pacner@cern.ch>, CERN
## @date: 13 July 2023 
##-----------------------------------------------------------------------------

CC := aarch64-none-elf-gcc
XS := xsct

GCCVERSION := $$($(CC) --version | head -n1 | sed -e "s/\([^ ]\+\s\)\{2\}\(.*\)/\2/")
TARGET := mcoi_app
PLATFORM := mcoi_platform

ROOT := $(PWD)
BUILD := $(ROOT)/build
USER_SRC := $(ROOT)/src
USER_INC := $(ROOT)/inc

HW := $(ROOT)/../syn/exported_hw.xsa

LD := lscript.ld
LD_FLAGS := -Wl,--start-group,-lxil,-lgcc,-lc,--end-group

USER_SOURCES=$(wildcard $(USER_SOURCE)/*.c)
OBJS=$(USER_SOURCES:.c=.o) 

INCLUDES = -I $(BSP_INCLUDES) \
		   -I $(USER_INCLUDES)

XILINX_BSP_DIR := $(BUILD)/$(PLATFORM)/zynqmp_fsbl/zynqmp_fsbl_bsp
XILINX_COMPILED_LIBS := $(XILINX_BSP_DIR)/psu_cortexa53_0/lib

GET_BSP_SRCS := 

# all: $(TARGET).elf 
all: $(BUILD)/.xilinx_libs_compiled 
	@echo "Build Finished" $(shell date) 

# check if you have arm-gcc in the PATHS and the 
# correct version and create BUILD directory
$(BUILD): 
	@which $(XS) &> /dev/null || { \
		printf '\e[1;31m[ERR]\e[0m $(XS) command is not in PATH'; false; };
	@which $(CC) &> /dev/null || { \
		printf '\e[1;31m[ERR]\e[0m $(CC) is not in PATH'; false; };
	@if [ "$(GCCVERSION)" != "11.2.0" ]; then \
		echo "Version of the $(CC) is not 11.2.0"; \
		echo $(GCCVERSION); \
		false; \
	fi;  
	@mkdir -p $@

$(BUILD)/test: $(HW) | $(BUILD)
	@[ -d $(BUILD)/$(PLATFORM) ] && { rm -rf $(BUILD)/$(PLATFORM); } || { \
		$(XS) -eval 'platform create -name $(PLATFORM) -out $(BUILD) -hw $(HW)'; }
	@find $(XILINX_BSP_DIR)/psu_cortexa53_0/ \
		-type f \( -iname \*.c -o -iname \*.h -o -iname \*.S \) >> $@

$(BUILD)/.xilinx_libs_compiled:  $(shell cat $(BUILD)/test) 
	@echo "COMPILING XILINX BSP LIBS"
	# @cd $(XILINX_BSP_DIR) && $(MAKE)
	@touch $@

# $(USER_SOURCE)/%.o: $(USER_SOURCE)/%.c
# 	@echo 'Building file: $<'
# 	$(CC) -Wall -O0 -g3 -c -fmessage-length=0 $(INCLUDES) -MMD -MP $<  -o $@
# 	@echo 'Finished building: $<'

# $(TARGET).elf: $(BUILD)/$(PLATFORM) $(OBJS) $(LD)
# 	@echo 'Building target: $@'
# 	$(CC) -Wl,-T -Wl,$(LD) -o $@ $(OBJS)
# 	@echo 'Finished building target: $@'

clean:
	@rm -rf $(BUILD)
	@rm -rf .Xil

.PHONY: clean

#TODO add target to create fsbl_a53.elf
