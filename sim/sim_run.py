#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Copyright (C) 2023 Petr Pacner 
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
# Author: Petr Pacner
# Email: petr.pacner@cern.ch
#

from os.path import abspath
from glob import glob

from random import randint
from datetime import datetime
from hdlmake.main import get_design_files

import logging
import vunit

logging.basicConfig(level=logging.INFO)

try:
    from pyloggingformatter import color_formatter
    logging.getLogger().handlers[0].setFormatter(color_formatter)
except:
    pass

# generate SEED, store the seed into file so we can pick it up next
# time. If a test generates error, temporarily overwrite this to get
# specific seed. The seed is APPENDED to the end. So one can trace it,
# including timing

SEED = randint(1, 32768)
with open(".lastseed", "a+t") as f:
    logging.info(f"USING FOLLOWING SEED: {SEED}")
    f.write(f"{datetime.now()}: {SEED}\n")

ui = vunit.VUnit.from_argv() 
ui.add_verilog_builtins()



hdlmake_file_set = get_design_files()
lib = ui.add_library("lib")
lib.add_source_files(hdlmake_file_set)
lib.add_source_files("glbl.v")

for path in glob(f'./libraries/*/'):
    name = path.rsplit("/", 2)[1]
    ui.add_external_library(name, path)

vlog_options = ["+acc",
                "-assertdebug",
                "-sv12compat",
                f"+incdir+{abspath('../hdl/modules')}",
                "+define+den8192Mb",
                "+define+sg125",
                "+define+x16",
                "+define+MAX_MEM",
                "+define+DEBUG",
                "-64"]

lib.set_compile_option("modelsim.vlog_flags", vlog_options)

vsim_options = ["-sva", 
                "-msgmode both", 
                "-sv_seed",
                str(SEED),
                "lib.glbl"]

lib.set_sim_option("modelsim.vsim_flags", vsim_options)
lib.set_sim_option('disable_ieee_warnings', 1)

ui.main()
