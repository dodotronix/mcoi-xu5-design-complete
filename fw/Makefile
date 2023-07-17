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

GCCVERSION := $$(arm-none-eabi-gcc --version | head -n1 | sed -e "s/[^0-9]\+\s\+\(.*\)/\1/")
TARGET := mcoi_app
DEVICE := armv7-a
FPU := vfpv3
PLATFORM := mcoi_platform

ROOT := $(PWD)
HW := $(ROOT)/../syn/exported_hw.xsa
BUILD := $(ROOT)/build
USER_SOURCE := $(ROOT)/src
USER_INCLUDES := $(ROOT)/include
BSP_INCLUDES := $(BUILD)/bsp_include
BSP_SOURCES := $(BUILD)/bsp_sources
BSP_ASM := $(BUILD)/bsp_asm

BSP_SRCS := $(wildcard $(BSP_SOURCES)/*.c)
BSP_OBJS := $(BSP_SRCS:.c=.o)

LD := lscript.ld
LD_FLAGS := -Wl,--start-group,-lxil,-lgcc,-lc,--end-group

USER_SOURCES=$(wildcard $(USER_SOURCE)/*.c)
OBJS=$(USER_SOURCES:.c=.o) 
INCLUDES = -I $(BSP_INCLUDES) \
		   -I $(USER_INCLUDES)

# generated paths by the xsct tool, and 
# we want to place them to our own paths
XS_DIR_NAMES := zynqmp_pmufw zynqmp_fsbl hw

# check if you have arm-gcc in the PATHS and the 
# correct version and create BUILD directory
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
		rm -rf $@/logs; \
		mkdir $(BSP_INCLUDES) $(BSP_SOURCES) $(BSP_ASM);
	@cp $(BUILD)/$(PLATFORM)/zynqmp_fsbl/zynqmp_fsbl_bsp/psu_cortexa53_0/include/*.h $(BSP_INCLUDES); 
	@cp $(BUILD)/$(PLATFORM)/zynqmp_fsbl/zynqmp_fsbl_bsp/psu_cortexa53_0/libsrc/**/src/*.h $(BSP_INCLUDES);
	@cp $(BUILD)/$(PLATFORM)/zynqmp_fsbl/zynqmp_fsbl_bsp/psu_cortexa53_0/libsrc/**/src/*.c $(BSP_SOURCES);
	@cp $(BUILD)/$(PLATFORM)/zynqmp_fsbl/zynqmp_fsbl_bsp/psu_cortexa53_0/libsrc/**/src/*.S $(BSP_ASM);

$(BSP_SOURCES)/%.o: $(BSP_SOURCES)/%.c
	@echo 'Building file: $<'
	aarch64-none-elf-gcc -I $(BSP_INCLUDES) -c -g -Wall -Wextra \
		-fno-tree-loop-distribute-patterns \
		-Os -flto -ffat-lto-objects -I $(BSP_INCLUDES) -MMD -MP $< -o $@ 
	@echo 'Finished building: $<'

$(USER_SOURCE)/%.o: $(USER_SOURCE)/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM v8 32 Bit gcc compiler'
	arm-none-eabi-gcc -Wall -O0 -g3 -c -fmessage-length=0 -MT"$@" \
		-march=armv7-a -mfpu=vfpv3 -mfloat-abi=hard $(INCLUDES) \
		-MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'

# $(BUILD)/$(PLATFORM) $(LD) $(BSP_OBJS) $(USER_SOURCE)
$(TARGET).elf: $(OBJS) $(BSP_OBJS) $(LD)
	@echo 'Building target: $@'
	@echo 'Invoking: ARM v8 32 Bit gcc linker'
	arm-none-eabi-gcc -march=$(DEVICE) \
		-mfpu=vfpv3 -mfloat-abi=hard -Wl,-T -Wl,$(LD) -L $(BSP_OBJS) -o $@ \
		-Wl,--start-group,-lxil,-lgcc,-lc,--end-group
	@echo 'Finished building target: $@'

test: $(BUILD)/$(PLATFORM) $(BSP_OBJS) $(OBJS)
	@echo $(USER_SOURCES)
	@echo $(OBJS)
	@echo "THIS IS THE END" 

clean:
	@rm -rf $(BUILD)
	@rm -rf .Xil

.PHONY: clean

#TODO add target to create fsbl_a53.elf
