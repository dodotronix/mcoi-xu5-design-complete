ROOT := $(PWD)

XS := xsct
BIF := mcoi_app.bif
BOOT_IMAGE := BOOT.bin

FSBL := $(ROOT)/build/exported_hw/export/exported_hw/sw/exported_hw/boot/fsbl.elf
PMUFW := $(ROOT)/build/exported_hw/export/exported_hw/sw/exported_hw/boot/pmufw.elf
EXPORTED_HW := $(ROOT)/build/mcoi_app/_ide/bitstream/exported_hw.bit
MCOI_APP := $(ROOT)/build/mcoi_app/Debug/mcoi_app.elf

# this path should be generated from by running the xsct tcl script
XIL_LIB_PATHS := $(ROOT)/build/

# Please note that we expect here, that there is just one target connected at
# a time, in case there are more devices, the command takes the first one
JTAG_TARGET_REMOTE := -url tcp:pcsy169:3121
JTAG_TARGET_LOCAL := -url tcp:localhost:3121
JTAG_FREQ := 12000000

JTAG_TARGET := $(JTAG_TARGET_REMOTE)

all:
	$(XS) mcoi_app.tcl

compile_flags.txt:
	@cd ../ && printf -- "-I$(ROOT)/../src\n" > $@ \
		&& printf -- "-I$(ROOT)/../inc\n" >> $@ \
		&& find $(XIL_LIB_PATHS) -type d -name "*" -printf '-I%h/%f\n' >> $@

$(BIF): $(FSBL) $(PMUFW) $(EXPORTED_HW) $(MCOI_APP)
	@printf 'the_ROM_image:\n' >> $@
	@printf '{\n' >> $@ 
	@printf '[bootloader, destination_cpu = a53-0] $(FSBL)\n' >> $@ 
	@printf '[pmufw_image]$(PMUFW)\n' >> $@ 
	@printf '[destination_device = pl]$(EXPORTED_HW)\n' >> $@ 
	@printf '[destination_cpu = a53-0]$(MCOI_APP)\n' >> $@ 
	@printf '}\n' >> $@ 

$(BOOT_IMAGE): $(BIF)
	@echo "Generating boot image $@";
	@bootgen -image $< -arch zynqmp -o $(BOOT_IMAGE) -w on

flash: $(BOOT_IMAGE) $(FSBL) 
	@program_flash -f $(BOOT_IMAGE) -fsbl $(FSBL) \
		-flash_type qspi-x4-single \
		-frequency $(JTAG_FREQ) \
		-verify $(JTAG_TARGET)

.PHONY: clean all flash_remote

clean:
	rm -rf build 
	rm -rf .Xil
	rm -rf $(BOOT_IMAGE)
	rm -rf $(BIF)
