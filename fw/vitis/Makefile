ROOT := $(PWD)

XS := xsct
GIT := git
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

#COLORS
ERROR = \e[1;31m[ERR]\e[0m
WARNING = \e[1;33m[WRN]\e[0m
INFO = \e[1;34m[INF]\e[0m

JTAG_TARGET := $(JTAG_TARGET_REMOTE)

XILINX_REPO := embeddedsw
ENCLUSTRA_REPO := GigabitEthernetAppNote

XILINX_REPO_DIR := $(ROOT)/$(XILINX_REPO)
XILINX_REPO_URL := https://github.com/Xilinx/$(XILINX_REPO).git

ENCLUSTRA_REPO_DIR := $(ROOT)/$(ENCLUSTRA_REPO)
ENCLUSTRA_REPO_URL := https://github.com/enclustra/$(ENCLUSTRA_REPO).git

NETIF_MODIFICATIONS := /code/RGMII/LWIPModifications/
NETIF_XILINX := $(XILINX_REPO_DIR)/ThirdParty/sw_services/lwip213/src/contrib/ports/xilinx/netif

all: $(XILINX_REPO_DIR)
	@printf "$(INFO) STARTING XILINX BUILD\n"
	@$(XS) mcoi_app.tcl
	@printf "$(WARNING) manually insert $(XILINX_REPO) as a local repository in Vitis\n"
	@printf "$(INFO) Xilinx -> Software Repositories -> Local Repositories\n"

$(XILINX_REPO_DIR): $(ENCLUSTRA_REPO_DIR)
	@printf "$(INFO) cloning $(ENCLUSTRA_REPO) from $(ENCLUSTRA_REPO_URL)\n"
	@$(GIT) clone $(XILINX_REPO_URL)
	@cd $(ENCLUSTRA_REPO_DIR)/$(NETIF_MODIFICATIONS); mv *.c $(NETIF_XILINX)

$(ENCLUSTRA_REPO_DIR):
	@printf "$(INFO) cloning $(ENCLUSTRA_REPO) from $(ENCLUSTRA_REPO_URL)\n"
	@$(GIT) clone $(ENCLUSTRA_REPO_URL)

compile_flags.txt:
	@cd ../ && printf -- "-I$(ROOT)/../src\n" > $@ \
		&& printf -- "-I$(ROOT)/../inc\n" >> $@ \
		&& find $(XIL_LIB_PATHS) $(XILINX_REPO_DIR) -type d -name "*" -printf '-I%h/%f\n' >> $@

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

.PHONY: clean all flash

clean:
	rm -rf build
	rm -rf .Xil
	rm -rf *.bin
	rm -rf $(BOOT_IMAGE)
	rm -rf $(BIF)
	rm -rf $(ENCLUSTRA_REPO)
	rm -rf $(XILINX_REPO)
