# Commands to run the compilation in interactive mode
# docker run --rm -it -e 'TERM=xterm-256color' -v .:/home/petalinux/build petalinux_tools
#
# Enclustra BSP for our XU5 module are here:
# https://github.com/enclustra/Mercury_XU5_PE1_Reference_Design/releases/tag/2022.1_v1.2.1
#
# IMPORTANT: to build the docker image you need to have petalinux-*-installer.run
# in the current directory
#
# LINKS:
# https://support.xilinx.com/s/article/1141772?language=en_US

# Please note that we expect here, that there is just one target connected at
# a time, in case there are more devices, the command takes the first one
JTAG_TARGET_REMOTE := -url tcp:pcsy169:3121
JTAG_TARGET_LOCAL := -url tcp:localhost:3121
JTAG_FREQ := 12000000
TFTP_SERVER_DIR := /srv/tftp

###############################################################################
# DO NOT CHANGE FOLLOWING LINES UNLESS YOU KNOW WHAT YOU ARE DOING            #
###############################################################################

XS := xsct

#COLORS
ERROR = \e[1;31m[ERR]\e[0m
WARNING = \e[1;33m[WRN]\e[0m
INFO = \e[1;34m[INF]\e[0m

JTAG_TARGET := $(JTAG_TARGET_REMOTE)

IMAGE_NAME:=petalinux_tools
DOCKER_BUILD_PATH:=/home/petalinux/build
SCRIPT:=compile.sh
PETALINUX_INSTALLER:=$(wildcard ./petalinux-*-installer.run)
PETALINUX_ENV_SETUP_SH:=plnx-env-setup.sh
XSA_FILE:=../../syn/exported_hw.xsa

# FIXME generate boot.bin and test it on HW
PETALINUX_BUILD_FOLDER:=McoiXu5BSP_emmc
COMPILED_LINUX:=$(PETALINUX_BUILD_FOLDER)/images/linux
BOOT_IMAGE := $(COMPILED_LINUX)/BOOT.bin 
FSBL := $(COMPILED_LINUX)/zynqmp_fsbl.elf

all: build
	@cp $(XSA_FILE) .
	@docker run --rm -e 'TERM=xterm-256color' \
		-v .:$(DOCKER_BUILD_PATH) \
		petalinux_tools:latest \
		$(SCRIPT)

build: $(PETALINUX_INSTALLER) $(PETALINUX_ENV_SETUP_SH)
	@if [ -z "$(shell docker images -q $(IMAGE_NAME):latest 2> /dev/null)" ]; then \
		echo "Generating $(IMAGE_NAME)"; \
		docker build --tag $(IMAGE_NAME) .; \
		else \
		echo "Image already exists"; \
		fi

emmc: build
	@docker run --rm -e 'TERM=xterm-256color' \
		-v .:$(DOCKER_BUILD_PATH) \
		petalinux_tools:latest \
		$(SCRIPT) $@
	@sudo cp -r $(COMPILED_LINUX)/BOOT.BIN $(TFTP_SERVER_DIR) 
	@sudo cp -r $(COMPILED_LINUX)/system.dtb $(TFTP_SERVER_DIR) 
	@sudo cp -r $(COMPILED_LINUX)/Image $(TFTP_SERVER_DIR) 
	@sudo cp -r $(COMPILED_LINUX)/boot.scr $(TFTP_SERVER_DIR) 
	@sudo cp -r $(COMPILED_LINUX)/rootfs.tar.gz $(TFTP_SERVER_DIR) 

flash:
	@echo "flashing procedure"
	@echo "flash qspi"
	@program_flash -f $(BOOT_IMAGE) -fsbl $(FSBL) \
		-flash_type qspi-x4-single \
		-frequency $(JTAG_FREQ) \
		-verify $(JTAG_TARGET)
	@echo "connect to u-boot"
	@echo "flash emmc"
