
all:
	printf 'USAGE: init|openproject\n'
	printf '       init - downloads all submodules'
	printf '       openproject - generates and opens project in vivado'

__check_software_availability:
	@type python3 >/dev/null 2>&1 || { \
		printf 'ERR: "python3"\n' >&2; \
		false; }
	@python3 -m pip >/dev/null || { \
		printf 'ERR: pip3 is either not installed or present in the system PATH\n' >&2; \
		false; }
	@python3 -m pip list | grep vunit-hdl >/dev/null || { \
		printf 'ERR: "vunit-hdl" is either not installed or present in the system PATH\n' >&2; \
		false; }
	@type vivado >/dev/null || { \
		printf 'ERR: "Xilinx Vivado" is not installed or present in the system PATH\n' >&2; \
		false; }
## first check if there is a Modelsim or GHDL installed 
	@if type vsim &> /dev/null; then \
		export VUNIT_SIMULATOR=vsim; \
		vsim -version | grep "vsim 2021.1" >/dev/null || \
		printf 'WARN: Version of Modelsim is not "2021.1"\n'; \
		printf 'INFO: Modelsim simulator set as vuint simulator\n'; \
	elif type ghdl &> /dev/null; then \
		export VUNIT_SIMULATOR=ghdl; \
		printf 'INFO: GHDL simulator set as vuint simulator\n'; \
	else \
		printf 'ERR: neither GHDL or Modelsim are installed or in the system PATH\n' >&2; \
		false; \
	fi;


init:
	@git submodule update --init --recursive

openproject: __check_software_availability
	vivado -source vivadoprj.tcl

#TODO vivadosimul:

#clean:
	#rm - 

