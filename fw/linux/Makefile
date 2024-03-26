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

