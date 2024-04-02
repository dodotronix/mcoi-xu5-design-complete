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

IMAGE_NAME:=petalinux_tools
DOCKER_BUILD_PATH:=/home/petalinux/build
SCRIPT:=compile.sh
PETALINUX_INSTALLER:=$(wildcard ./petalinux-*-installer.run)
PETALINUX_ENV_SETUP_SH:=plnx-env-setup.sh
XSA_FILE:=../../syn/exported_hw.xsa

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

