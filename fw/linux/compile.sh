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
# petalinux-package --prebuilt --clean
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

SUFFIX=$1 # can be jtag or emmc

shift # shift removes the $1 that the next source does not see the value
source /opt/petalinux/settings.sh

if [ -z $SUFFIX ]; then
    suffix=jtag
fi

PROJ_NAME=McoiXu5BSP_${SUFFIX}

if [ ! -d $PROJ_NAME ]; then
    petalinux-create -t project --template zynqMP --name $PROJ_NAME  
    cd $PROJ_NAME
    petalinux-config --get-hw-description=../exported_hw.xsa --silentconfig

    echo ""
    echo "Copying petalinux_spec folder -> ${PROJ_NAME}"
    echo ""

    cp -R ../petalinux_${SUFFIX}_spec/* project-spec/
    petalinux-config --silentconfig
else
    cd $PROJ_NAME
fi

petalinux-build
petalinux-package --boot \
    --fsbl images/linux/zynqmp_fsbl.elf \
    --u-boot images/linux/u-boot.elf \
    --pmufw images/linux/pmufw.elf \
    --fpga images/linux/system.bit \
    --force
petalinux-package --prebuilt --clean
petalinux-package --prebuilt
