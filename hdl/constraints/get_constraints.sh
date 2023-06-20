#!/bin/bash

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
# NOTE the name of the driver is passed as an argument to the script
# so that it can be easily modified in the makefile

FILE_NAME=${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}
DIR=$(dirname $FILE_NAME)
ALL_FILES=$(find $DIR -type f -name "*.xdc")

printf "add_files -fileset constrs_1 {\n%s\n}" "${ALL_FILES}" 
