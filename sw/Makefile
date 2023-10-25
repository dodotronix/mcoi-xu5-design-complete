# returns user name - the login is the same for all the machines
PROJECT_NAME := mcoi-xu5-design-complete

# Project paths (on fec is no git - so the root is detected by path to the .git/)
ROOT_DIR := $$(which git &> /dev/null && { git rev-parse --show-toplevel; } \
						|| { echo $$PWD | sed "s/\(.*\)\/.*/\1/"; })

BUILD_STAMP_FILE := $(ROOT_DIR)/build_number.txt
SCRIPTS := $(ROOT_DIR)/sw/scripts

all:
	@printf 'NOTE: This is just a makefile to be able to quickly run tests and'
	@printf 'increase version of the project.\n'
	@printf 'USAGE: new_version \n'
	@printf '       new_version  - increases version of the build number'

_increase_version: 
	@$(SCRIPTS)/new_version.sh $(ROOT_DIR)/hdl/src $(BUILD_STAMP_FILE)

new_version: _increase_version

get_version:
	$(eval VERSION=$(shell cat $(BUILD_STAMP_FILE) | head -n 1))
	@printf '\e[1;34m[INF]\e[0m current project version is $(VERSION)\n'
