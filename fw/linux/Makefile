
DOCKER_BUILD_PATH=/home/petalinux/build
SCRIPT=compile.sh

all:
	docker run --rm -e 'TERM=xterm-256color' \
		-v .:$(DOCKER_BUILD_PATH) \
		petalinux_tools:latest \
		$(SCRIPT)

