#!/usr/bin/bash
#
# Petalinux commands:
# petalinux-create -t <target> -s <script>
# or
# petalinux-create -t project --template zynqmp --name McoiCore
# petalinux-config -get-hw-description=<path_to_xsa>
#
# petalinux-build
#
# This opens a configuration menu
# petalinux-config
# NOTE: If you want test your build in QEMU use the initramfs filesystem
#
# copies binaries to the pre-built folder
# petalinux-package --prebuilt
#
# Petalinux Qemu simulations:
# petalinux-boot --qemu --prebuilt 3
#
# For SD card we have to create BOOT.BIN file and then wic file
# petalinux-package --boot --format BIN --fsbl images/linux/zynqmp_fsbl.elf \
# --u-boot images/linux/u-boot.elf --pmufw images/linux/pmu_rom_qemu_sha3.elf --force
#
# If you want to simulate sd card you need to define the structure of the
# memory using the wic file
# petalinux-package --wic
#
# Creating an app which is automatically enabled
# petalinux-create -t apps --template install --name McoiCore --enable

source /opt/petalinux/settings.sh

petalinux-create -t project --template zynqMP --name McoiXu5BSP  
cd McoiXu5BSP
petalinux-config --get-hw-description=../exported_hw.xsa

cp -R ../petalinux_spec/ .
petalinux-config --silentconfig

#petalinux-build
