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
PROC := psu_cortexa53_0
ARCH := 64-bit
OS := standalone

ROOT := $(PWD)
USER_SOURCES := $(ROOT)/../src
USER_INCLUDES := $(ROOT)/../inc

USER_OBJ_DIR := user_objs
OUTPUT_DIR := bin
DIRS := $(OUTPUT_DIR) $(USER_OBJ_DIR)

HW := $(ROOT)/../../syn/exported_hw.xsa

LD := ./../lscript.ld
LD_FLAGS := -Wl,--start-group,-lxil,-lgcc,-lc,--end-group

USER_C_FILES=$(wildcard $(USER_SOURCES)/*.c)
# compile object to the USER_OBJ_DIR
USER_OBJS=$(addsuffix .o, $(addprefix $(USER_OBJ_DIR)/,\
	 $(notdir $(basename $(USER_C_FILES)))))

XILINX_BSP_DIR := $(PLATFORM)/zynqmp_fsbl/zynqmp_fsbl_bsp
XILINX_COMPILED_LIBS := $(XILINX_BSP_DIR)/psu_cortexa53_0/lib
# XILINX_COMPILED_LIBS := $(BUILD)/mcoi_platform/export/mcoi_platform/sw/mcoi_platform/standalone_domain/bsplib/lib
XILINX_LIB_INCLUDES := $(XILINX_BSP_DIR)/psu_cortexa53_0/include
# XILINX_LIB_INCLUDES := $(BUILD)/mcoi_platform/export/mcoi_platform/sw/mcoi_platform/standalone_domain/bspinclude/include
XILINX_BSP_LIBS := xilinx_bsp_libs

## SEVERITY 
INF := \e[1;34m[INF]\e[0m
ERR := \e[1;31m[ERR]\e[0m
WARN := \e[0;33m[WARN]\e[0m 

# this returns either list of libraries generated by $(XS) if the 
# xilinx_bsp_libs file exists, otherwise it returns just the name
# of the file, because make is gonna create it
GET_BSP_LIBS := $(shell [ ! -f $(XILINX_BSP_LIBS) ] && \
				{ echo $(XILINX_BSP_LIBS); } || { cat $(XILINX_BSP_LIBS); })

INCLUDES := -I $(XILINX_LIB_INCLUDES) \
			-I $(USER_INCLUDES)

all: $(OUTPUT_DIR)/$(TARGET).elf 
	@printf '$(INF) Build Finished $(shell date)\n'   
# all: $(BUILD)/xilinx_libs_compiled 

# check if you have arm-gcc in the PATHS and the 
# correct version and create BUILD directory
$(DIRS): 
	@which $(XS) &> /dev/null || { \
		printf '$(ERR) $(XS) command is not in PATH\n'; false; };
	@which $(CC) &> /dev/null || { \
		printf '$(ERR) $(CC) is not in PATH\n'; false; };
	@if [ "$(GCCVERSION)" != "11.2.0" ]; then \
		printf '$(WARN) Version of the $(CC) is $(GCCVERSION) and not 11.2.0\n'; \
		false; \
	fi;  
	@printf '$(INF) CREATING DIRECTORY $@\n'
	@mkdir -p $@

$(PLATFORM): $(HW) | $(DIRS)
	@printf '$(INF) RUNNING PLATFORM GENERATOR\n'
	@[ -d $@ ] && { rm -rf $@; } || { \
		$(XS) -eval 'platform create -name $(PLATFORM) -out $@/../ -hw $(HW) \
		-proc $(PROC) -arch $(ARCH) -os $(OS)'; }

$(XILINX_BSP_LIBS): $(PLATFORM)
	@printf '$(INF) CREATING LIST OF ALL BSP SOURCE FILES\n'
	@find $(XILINX_BSP_DIR)/psu_cortexa53_0/ \
		-type f \( -iname \*.c -o -iname \*.h -o -iname \*.S \) >> $@

xilinx_libs_compiled: $(GET_BSP_LIBS)
	@printf '$(INF) COMPILING XILINX BSP LIBS\n'
	@cd $(XILINX_BSP_DIR) && $(MAKE)
	@touch $@

$(USER_OBJ_DIR)/%.o: $(USER_SOURCES)/%.c
	@printf 'Building file: $<\n'
	$(CC) -Wall -O0 -g3 -c -fmessage-length=0 -MT"$@" \
		$(INCLUDES) -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@printf 'Finished building: $<\n'

$(OUTPUT_DIR)/$(TARGET).elf: xilinx_libs_compiled $(LD) $(USER_OBJS)
	@printf '$(INF) BUILDING TARGET: $@\n'
	$(CC) -Wl,-T -Wl,$(LD) -L $(XILINX_COMPILED_LIBS) \
		-o $@ $(USER_OBJS) -Wl,--start-group,-lxil,-lgcc,-lc,--end-group
	@printf '$(INF) FINISHED BUILDING TARGET: $@\n'

clean:
	rm -rf $(filter-out Makefile, $(wildcard *))
	rm -rf .Xil

.PHONY: clean all

#TODO add target to create fsbl_a53.elf
