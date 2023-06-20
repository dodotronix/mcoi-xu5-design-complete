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
# modified by:
# Author: Petr Pacner
# Email: petr.pacner@cern.ch
#

"""
VUnit testbench runner. This script looks through the test benches in
the design, and performs their checking. To understand how it works,
check the documentation of VUnit, which can be found here:

https://vunit.github.io/

The testbench files (systemverilog, .sv), are stored in hdl/tests
directory, whereas all the modules are stored in hdl/modules
directory. This script expects VUnit to be installed on the running
(linux) computer, the VUnit sources can be found as submodule in tools
directory.

"""

from os.path import join, dirname, isfile, abspath
from os import mkdir, scandir
# from vunit.verilog import VUnit
from random import randint
from datetime import datetime
from hdlmake.main import get_design_files

import logging
import vunit
import sys

logging.basicConfig(level=logging.INFO)

try:
    from pyloggingformatter import color_formatter
    logging.getLogger().handlers[0].setFormatter(color_formatter)
except:
    pass

root = dirname(__file__)

# generate SEED, store the seed into file so we can pick it up next
# time. If a test generates error, temporarily overwrite this to get
# specific seed. The seed is APPENDED to the end. So one can trace it,
# including timing

SEED = randint(1, 32768)
with open(".lastseed", "a+t") as f:
    logging.info("USING FOLLOWING SEED: {}".format(SEED))
    f.write("{}: {}\n".format(datetime.now(), SEED))

ui = vunit.VUnit.from_argv() 
ui.add_verilog_builtins()

# for entry in scandir("libraries"):
#     # ignore worklib, but add all others
#     if entry.is_file() or entry.name == "work":
#         continue
#     path = join("libraries", entry.name)
#     logging.info("Adding external library {} from {}".format(entry.name, path))
#     ui.add_external_library(entry.name, path)

# ui.add_external_library("altera_mf", "altera_sim_libs/vhdl_libs/altera_mf")


# ui = VUnit.from_argv()
# # put all the test designs into the lib (including the testbenches)
# lib = ui.add_library("lib")
# for dirx in dirs:
#     lib.add_source_files(dirx).\
#         set_compile_option("modelsim.vlog_flags",
#                            ["+acc",
#                             "-sv12compat",
#                             "-64"])

# unisim = ui.add_library("unisim")
# unisim_src = [os.path.join(VIVADO, 'data/vhdl/src/unisims/unisim_VCOMP.vhd'),
#               os.path.join(VIVADO, 'data/vhdl/src/unisims/unisim_VPKG.vhd'),
#               ]

# unisim.add_source_files(unisim_src)

ui.main()
