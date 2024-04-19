#!/bin/bash
# https://github.com/enclustra-bsp/bsp-xilinx/blob/master/documentation/4_Deployment.md#emmc-flash
#
# If you run this script, make sure that you moved your compilation
# products (Image, boot.scr, system.dtb, BOOT.BIN, rootfs.tar.gz) to
# /srv/tftp/

# USER EDIT: add your current ip address
export serverip=128.141.155.156
export mem_name=mmcblk0
export TGTDEV=/dev/${mem_name}

# try to unmount partitions - it will fail if they are not mounted
umount /run/media/${mem_name}p1 2> /dev/null
umount /run/media/${mem_name}p2 2> /dev/null

echo "[INFO] Formatting EMMC"
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${TGTDEV}
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk 
  +500M # 500 MB boot parttion
  n # new partition
  p # primary partition
  2 # partion number 2
    # default, start immediately after preceding partition
    # default, extend partition to end of disk
  t # change type
  1 # typecode for first partition
  b # typecode Windows Fat32 
  w # write the partition table
EOF

#format the partitions
echo "[INFO] Formatting partition P2"
umount /run/media/${mem_name}p2 2> /dev/null
mkfs.ext4 -F -L "rootfs" ${TGTDEV}p2

echo "[INFO] Formatting partition P1"
umount /run/media/${mem_name}p1 2> /dev/null
mkfs.vfat -F32 -n "boot" ${TGTDEV}p1

mkdir -p /mnt/boot
mkdir -p /mnt/rootfs

umount /run/media/${mem_name}p1 2> /dev/null
mount ${TGTDEV}p1 /mnt/boot

umount /run/media/${mem_name}p2  2> /dev/null
mount ${TGTDEV}p2 /mnt/rootfs

cd /mnt/boot
tftp -r BOOT.BIN -g ${serverip}
tftp -r boot.scr -g ${serverip}
tftp -r system.dtb -g ${serverip}
tftp -r Image -g ${serverip}

cd /mnt/
tftp -r rootfs.tar.gz -g ${serverip}
tar -xpv -C /mnt/rootfs/ -f rootfs.tar.gz

echo "[INFO] unmounting partitions"
umount boot
umount rootfs

echo "[INFO] removing temporary folders"
rm -rf /mnt/*
