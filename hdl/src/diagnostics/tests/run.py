#!/usr/bin/env python3
# -*- coding: utf-8 -*-

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
# Author: Petr Pacner
# Email:  petr.pacner@cern.ch
#

from vunit import VUnit

# Create VUnit instance by parsing command line arguments
vu = VUnit.from_argv()

# Create library 'lib'
lib = vu.add_library("lib")

lib.add_source_files("*.vhd")
lib.add_source_files("../src/*.vhd")
lib.add_source_files("../3rd_party/FPGA-I2C-Slave/txt_util.vhd",
                     "../3rd_party/FPGA-I2C-Slave/I2C_slave.vhd")

unisim = ui.add_library("unisim")
unisim_src = [os.path.join(VIVADO, 'data/vhdl/src/unisims/unisim_VCOMP.vhd'),
              os.path.join(VIVADO, 'data/vhdl/src/unisims/unisim_VPKG.vhd'),
              ]
unisim.add_source_files(unisim_src)

# Run vunit function
vu.main()
