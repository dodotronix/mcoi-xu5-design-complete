#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Copyright (C) 2006 David Belohrad
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street,
# Fifth Floor, Boston, MA  02110-1301, USA.
#
# You can dowload a copy of the GNU General Public License here:
# http://www.gnu.org/licenses/gpl.txt
#
# Author: David Belohrad
# Email:  david.belohrad@cern.ch
#

"""
VUnit verification
"""

import sys
from os.path import join, dirname, isfile
from vunit.verilog import VUnit
import fnmatch
import os

root = dirname(__file__)

# MODIFY THIS TO YOUR INSTALLATION ENVIRONMENT:
VIVADO = '/opt/Xilinx/Vivado/2021.2/'

BICORES = join(root,
               "libs",
               "mcoi_hdl_library",
               "libs",
               "BI_HDL_Cores",
               "cores_for_synthesis")

MCOILIB = join(root,
               "libs",
               "mcoi_hdl_library",
               "modules")

# find all files in modules and tests, which will be used for the
# simulation. Define which directories to traverse and which extensions
directories_to_parse = ['hdl/src',
                        'hdl/tests',
                        'libs/BI_HDL_Cores/cores_for_synthesis/serdes',
                        # MCOI:
                        'libs/mcoi_hdl_library/tests',
                        'libs/mcoi_hdl_library/modules/clock_divider',
                        'libs/mcoi_hdl_library/modules/get_edge',
                        'libs/mcoi_hdl_library/modules/manyff',
                        'libs/mcoi_hdl_library/modules/memory_transport',
                        'libs/mcoi_hdl_library/modules/mko',
                        'libs/mcoi_hdl_library/modules/pwm',
                        'libs/mcoi_hdl_library/modules/scrambler',
                        'libs/mcoi_hdl_library/modules/serial_register',
                        'libs/mcoi_hdl_library/modules/tlc5920',
                        'libs/mcoi_hdl_library/modules/wb_spi_4wires',
                        'libs/BI_HDL_Cores/cores_for_synthesis/8b10b',
                        'libs/BI_HDL_Cores/cores_for_synthesis/ip_open_cores',
                        'libs/mcoi_hdl_library/packages']

# all sources to be considered:
filters = ['*.sv', '*.v', '*.vhd']

matches = []
for xdir in directories_to_parse:
    for root, dirnames, filenames in os.walk(xdir):
        for filename in fnmatch.filter(filenames, '*'):
            matches.append(os.path.join(root, filename))
# having _all_ the files from those directories we filter away all of
# them not matching the filters extensions
compiled_files = []
for filt in filters:
    compiled_files += fnmatch.filter(matches, filt)

dirs = ['libs/mcoi_vfc_backend_fw/hdl/simulation/constants.sv',
        'libs/BI_HDL_Cores/cores_for_synthesis/GlitchFilter.v',
        'libs/BI_HDL_Cores/cores_for_synthesis/I2cMasterGeneric.v',
        'libs/BI_HDL_Cores/cores_for_simulation/I2CSlave.v',
        'libs/BI_HDL_Cores/cores_for_synthesis/vme_reset_sync_and_filter.vhd',
        # DUMMY placeholder for GBT
        'libs/zynq_usplus_gbt_fpga/modules/gbt-fpga/gbt_bank/core_sources/gbt_bank_package.vhd',
        'libs/zynq_usplus_gbt_fpga/packages/zynq_usplus_gbt_bank_package.vhd',
        'libs/zynq_usplus_gbt_fpga/modules/gbt-fpga/example_designs/core_sources/exampleDsgn_package.vhd',
        'libs/zynq_usplus_gbt_fpga/modules/gbt-fpga/example_designs/core_sources/rxframeclk_phalgnr/gbt_rx_frameclk_phalgnr.vhd',
        'libs/zynq_usplus_gbt_fpga/modules/gbt-fpga/example_designs/core_sources/rxframeclk_phalgnr/phaligner_phase_comparator.vhd',
        'libs/zynq_usplus_gbt_fpga/modules/gbt-fpga/example_designs/core_sources/rxframeclk_phalgnr/phaligner_phase_computing.vhd',
        'libs/zynq_usplus_gbt_fpga/modules/gbt-fpga/example_designs/core_sources/gbt_bank_reset.vhd',
        'libs/zynq_usplus_gbt_fpga/modules/gbt-fpga/example_designs/core_sources/gbt_pattern_checker.vhd',
        'libs/zynq_usplus_gbt_fpga/modules/gbt-fpga/example_designs/core_sources/gbt_pattern_generator.vhd',
        'libs/zynq_usplus_gbt_fpga/modules/gbt-fpga/example_designs/core_sources/clock_divider.vhd',
] +\
compiled_files

ui = VUnit.from_argv()
# put all the test designs into the lib (including the testbenches)
lib = ui.add_library("lib")
for dirx in dirs:
    lib.add_source_files(dirx).\
        set_compile_option("modelsim.vlog_flags",
                           ["+acc",
                            "-sv12compat",
                            "-64"])

unisim = ui.add_library("unisim")
unisim_src = [os.path.join(VIVADO, 'data/vhdl/src/unisims/unisim_VCOMP.vhd'),
              os.path.join(VIVADO, 'data/vhdl/src/unisims/unisim_VPKG.vhd'),
              ]
unisim.add_source_files(unisim_src)

# assure loading of do file into modelsim if that exists
cmdline = list(sys.argv)
currenttest = cmdline[-1]
isspecific = currenttest.startswith("lib.") and\
             currenttest.find("*") == -1

filename = join("hdl", "do_files", currenttest + ".do")
if isspecific and isfile(filename):
    print("Using %s as do-file for modelsim" % (filename))
    ui.set_sim_option("modelsim.init_file.gui", filename)
elif (("-g" in cmdline) or ("--gui" in cmdline)) and isspecific:
    print ("""Running graphics mode, if you want to
    restore your wave environment for the %s test case, save your
    waveform into do_files directory as %s""" % (currenttest,
                                                 filename))
ui.main()
