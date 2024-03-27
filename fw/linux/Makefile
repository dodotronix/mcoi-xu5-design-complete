# Commands to run the compilation in interactive mode
# docker run --rm -it -e 'TERM=xterm-256color' -v .:/home/petalinux/build petalinux_tools
#
# Petalinux commands:
# petalinux-create -t <target> -s <script>
# petalinux-build
#
# This opens a configuration menu
# petalinux-config
# NOTE: If you want test your build in QEMU use the initramfs filesystem
#
# Petalinux Qemu simulations:
# petalinux-boot --qemu --prebuilt 3
#
# For SD card we have to create BOOT.BIN file and then wic file
# petalinux-package --boot --format BIN --fsbl images/linux/zynqmp_fsbl.elf \
  --u-boot images/linux/u-boot.elf --pmufw images/linux/pmu_rom_qemu_sha3.elf --force
#
# petalinux-package --wic
#
# Enclustra BSP for our XU5 module are here:
# https://github.com/enclustra/Mercury_XU5_PE1_Reference_Design/releases/tag/2022.1_v1.2.1
#
# IMPORTANT: to build the docker image you need to have petalinux-*-installer.run
# in the current directory
#

IMAGE_NAME:=petalinux_tools
DOCKER_BUILD_PATH:=/home/petalinux/build
SCRIPT:=compile.sh
PETALINUX_INSTALLER:=$(wildcard ./petalinux-*-installer.run)

build: $(PETALINUX_INSTALLER)
	@if [ -z "$(shell docker images -q $(IMAGE_NAME):latest 2> /dev/null)" ]; then \
		echo "Generating $(IMAGE_NAME)"; \
		docker build --tag $(IMAGE_NAME) .; \
		else \
		echo "Image already exists"; \
		fi

# all: build
# 	docker run --rm -e 'TERM=xterm-256color' \
# 		-v .:$(DOCKER_BUILD_PATH) \
# 		petalinux_tools:latest \
# 		$(SCRIPT)

