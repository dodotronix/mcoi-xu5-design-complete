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

CC := arm-none-eabi-gcc
XS := xsct

ROOT := $(PWD)
GCCVERSION := $$(arm-none-eabi-gcc --version | head -n1 | sed -e "s/[^0-9]\+\s\+\(.*\)/\1/")
TARGET := mcoi_app
DEVICE := armv7-a
FPU := vfpv3
PLATFORM := mcoi_platform

USER_SRC := $(ROOT)/src
USER_LIBS := $(ROOT)/libs
BUILD := $(ROOT)/build
OUTPUT := $(ROOT)/bin
HW := $(ROOT)/../syn/exported_hw.xsa

PMU_DIR := $(BUILD)/zynqmp_pmufw
FSBL_DIR := $(BUILD)/zynqmp_fsbl
HW_DIR := $(BUILD)/hw

LD := lscript.ld
LD_FLAGS := -Wl,--start-group,-lxil,-lgcc,-lc,--end-group

ASM_OBJ := $(BUILD)/asm_obj
C_OBJ := $(BUILD)/c_obj

# generated paths by the xsct tool, and 
# we want to place them to our own paths
XS_DIR_NAMES := zynqmp_pmufw zynqmp_fsbl hw
XILINX_PATHS := $(addprefix $(BUILD)/, $(XS_DIR_NAMES)) 

# ASM_SOURCES := $(PMU_DIR)/**/libs
# C_SOURCES := $(wildcard)
INCLUDES := $(wildcard $(PMU_DIR)/**/*.h)

# check if you have arm-gcc in 
# the PATHS and the correct version
# and create BUILD directory
$(BUILD): 
	@which $(XS) &> /dev/null || { \
		printf '\e[1;31m[ERR]\e[0m $(XS) command is not in PATH'; false; };
	@which $(CC) &> /dev/null || { \
		printf '\e[1;31m[ERR]\e[0m $(CC) is not in PATH'; false; };
	@if [ "$(GCCVERSION)" != "11.2.0" ]; then\
		echo "Version of the $(CC) is not 11.2.0";\
		false; \
	fi; \
	mkdir $@

$(BUILD)/$(PLATFORM): $(HW) | $(BUILD)
	@$(XS) -eval 'platform create -name $(PLATFORM) -out $@/../  -hw $(HW)'; \
		rm -rf $@/platform.spr; \
		rm -rf $@/logs;

test: $(BUILD)/$(PLATFORM)
	@echo "THIS IS THE END" 

# $(BUILD)/%.o: $(SRC)/%.c
# 	@echo 'Building file: $<'
# 	arm-none-eabi-gcc -Wall -O0 -g3 -c -fmessage-length=0 -MT"$@" \
# 		-march=$(DEVICE) -mfpu=$(FPU) -mfloat-abi=hard \
# 		-I /home/pepacner/vitis_workspace/mcoi_xu5_platform/export/mcoi_xu5_platform/sw/mcoi_xu5_platform/standalone_domain/bspinclude/include \
# 		-MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
# 	@echo 'Finished building: $<'

# # the pipe is needed to not recreate the 
# # directory when its content is updated
# $(OUTPUT)/$(TARGET).elf: _check_compatibility $(OBJS) $(LD) | $(BUILD)
# 	@echo 'Building target: $@'
# 	$(CC) -march=$(TARGET) \
# 		-mfpu=$(FPU) \
# 		-mfloat-abi=hard \
# 		-Wl, -T -Wl,$(LD) \
# 		-L $(LIBS) \
# 		-o $@ \
# 		$(LD_GROUPS) \
# 		$(OBJS)

clean:
	@rm -rf $(BUILD)
	@rm -rf .Xil

.PHONY: clean
