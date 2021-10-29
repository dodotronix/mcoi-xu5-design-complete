#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from vunit import VUnit

# Create VUnit instance by parsing command line arguments
vu = VUnit.from_argv()

# Create library 'lib'
lib = vu.add_library("lib")

lib.add_source_files("/hdl/src/*.sv")
lib.add_source_files("/hdl/src/*.vhd")
lib.add_source_files("/hdl/src/*.v")

#load paths from submodules

# Run vunit function
vu.main()
