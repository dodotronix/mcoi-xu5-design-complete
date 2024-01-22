ROOT := $(PWD)

XS := xsct
BIF := mcoi_app.bif
BOOT_IMAGE := BOOT.bin

FSBL := $(ROOT)/build/exported_hw/export/exported_hw/sw/exported_hw/boot/fsbl.elf
PMUFW := $(ROOT)/build/exported_hw/export/exported_hw/sw/exported_hw/boot/pmufw.elf
EXPORTED_HW := $(ROOT)/build/mcoi_app/_ide/bitstream/exported_hw.bit
MCOI_APP := $(ROOT)/build/mcoi_app/Debug/mcoi_app.elf

all:
	$(XS) mcoi_app.tcl

$(BIF): $(FSBL) $(PMUFW) $(EXPORTED_HW) $(MCOI_APP)
	@printf 'the_ROM_image:\n' >> $@
	@printf '{\n' >> $@ 
	@printf '[bootloader, destination_cpu = a53-0] $(FSBL)\n' >> $@ 
	@printf '[pmufw_image]$(PMUFW)\n' >> $@ 
	@printf '[destination_device = pl]$(EXPORTED_HW)\n' >> $@ 
	@printf '[destination_cpu = a53-0]$(MCOI_APP)\n' >> $@ 
	@printf '}\n' >> $@ 

boot_image: $(BIF)
	@echo "Generating boot image BOOT.bin";
	@bootgen -image mcoi_app.bif -arch zynqmp -o BOOT.bin -w on

.PHONY: clean all

clean:
	rm -rf build 
	rm -rf .Xil
	rm -rf $(BOOT_IMAGE)
	rm -rf $(BIF)
