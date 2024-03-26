#!/usr/bin/bash

source /opt/petalinux/settings.sh
echo $PATH "\n"

petalinux-create -t project -s *.bsp 
ls -l

cd ME-XU5-4EV-1I-D11E_PE1_QSPI
petalinux-build
