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

PROJECT_NAME=mcoi-xu5-design-complete
DEVICE="xczu4ev-sfvc784-1-i"
ROOT_PATH=$(pwd | sed "s/\(.*$PROJECT_NAME\).*/\1/" )
DESTINATION=$ROOT_PATH/tmp
LIST_OF_IPS=""

ALL_IP_GENERATORS=$(find $ROOT_PATH -name "ip_xilinx_gen_*.tcl")

for i in $ALL_IP_GENERATORS; do

    MODULE_NAME=$(echo $i | sed "s/.*\/ip_xilinx_gen_\(.*\).tcl/\1/")

    if [[ ! -d $DESTINATION/$MODULE_NAME ]]; then
        printf '\e[1;36mINFO\e[0m ... GENERATING IP ... %s\n' $MODULE_NAME
        vivado -mode batch -source $i -nojournal -nolog -tclargs $DESTINATION/$MODULE_NAME $DEVICE
    else
        printf '\e[1;36mINFO\e[0m %s ALREADY EXISTS IN THE PROJECT\n' $MODULE_NAME
    fi
    
    FOUND_PATH=$(find $DESTINATION/$MODULES_NAME -type f \( -name "${MODULE_NAME}.xci" -o -name "${MODULE_NAME}.bd" \))
    MANIFEST_PATH=$(echo "$FOUND_PATH" | sed "s/.*\/tmp\/\(.*\)/\1/")

    if [ -z "$MANIFEST_PATH" ]; then
        printf "The path of .xci or .bd file could not be found\n"
        continue
    fi

    if [ ! -z "$LIST_OF_IPS" ]; then
        LIST_OF_IPS=$(printf "%s,\n\"%s\"" "${LIST_OF_IPS}" "${MANIFEST_PATH}")
    else
        LIST_OF_IPS=$(printf "\"%s\"" "${MANIFEST_PATH}")
    fi

done

MANIFEST_FILES=$(printf "files=[\n%s\n]" "$LIST_OF_IPS")
printf "HDLmake Manifest created: %s\n" "$DESTINATION/Manifest.py"
printf "$MANIFEST_FILES" > $DESTINATION/Manifest.py
