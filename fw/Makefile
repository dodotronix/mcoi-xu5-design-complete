# TODO create platform project -> extract the libraries
# TODO create project to compile

CC := arm-none-eabi-gcc
XS := xsct
GCCVERSION := $$(arm-none-eabi-gcc --version | head -n1 | sed -e "s/[^0-9]\+\s\+\(.*\)/\1/")
TARGET := mcoi_app
DEVICE := armv7-a
FPU := vfpv3

OUTPUT := ./bin
BUILD := ./build
SRC := ./src
LIBS := ./libs
LD := lscript.ld
LD_FLAGS := -Wl,--start-group,-lxil,-lgcc,-lc,--end-group
HW := ./../syn/exported_hw.xsa
PLATFORM := mcoi_platform
OBJS =  

# check if you have arm-gcc in 
# the PATHS and the correct version
_check_compatibility:
	@which $(XS) &> /dev/null || { \
		printf '\e[1;31m[ERR]\e[0m $(XS) command is not in PATH'; false; };
	@which $(CC) &> /dev/null || { \
		printf '\e[1;31m[ERR]\e[0m $(CC) is not in PATH'; false; };
	@if [ "$(GCCVERSION)" != "11.2.0" ]; then\
		echo "Version of the $(CC) is not 11.2.0";\
		false; \
	fi;

$(BUILD):
	mkdir $(BUILD)

$(BUILD)/exported_hw: _check_compatibility | $(BUILD) 
	$(XS) -eval 'platform create -name $(PLATFORM) -out $@  -hw $(HW)'





test: $(BUILD)/exported_hw

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
	@rm -rf $(OBJS)

.PHONY: clean

# platform create -name {test} \
# 	-hw {/home/pepacner/projects/mcoi-xu5-design-complete/syn/exported_hw.xsa} \
# 	-proc {psu_cortexa53_0} \
# 	-os {standalone} \
# 	-arch {64-bit} \
# 	-fsbl-target {psu_cortexa53_0}\
# 	-out {/home/pepacner/vitis_workspace};platform write; \
# 	platform read {/home/pepacner/vitis_workspace/test/platform.spr} \
# 	platform active {test}
