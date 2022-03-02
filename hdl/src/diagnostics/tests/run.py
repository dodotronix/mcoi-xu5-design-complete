#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from vunit import VUnit

# Create VUnit instance by parsing command line arguments
vu = VUnit.from_argv()

# Create library 'lib'
lib = vu.add_library("lib")

lib.add_source_files("*.vhd")
lib.add_source_files("../src/*.vhd")
lib.add_source_files("../3rd_party/FPGA-I2C-Slave/txt_util.vhd",
                     "../3rd_party/FPGA-I2C-Slave/I2C_slave.vhd")

# Run vunit function
vu.main()
