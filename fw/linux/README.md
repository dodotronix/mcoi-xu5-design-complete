## INSTALLATION INSTRUCTIONS

### Prerequisites
* docker, 
* linux machine
* plnx-env-setup.sh (must be placed in this directory)
* petalinux-xxxx-installer.run (must be placed in this directory)
* exported hardware design .XSA including bitsream (must be placed in this directory)

### Preparation
* compile the jtag petalinux using the make
```bash
> make build 
```
This command will build everything for you It will create a Ubuntu
container because of compatibility purposes. 

* On your PC run the tftp server (this works for archlinux, might be different
name of service on other distros).
```bash
> sudo systemctl start tftpd
```

## Launching U-BOOT (JTAG mode)
* Open your container.
```bash
> docker run -ti --rm -e 'TERM=xterm-256color' -v .:/home/petalinux/build petalinux_tools:latest
```
* In case you change something in the petalinux config, you can rebuild
  the project using compile.sh but you have to change the directory to be 
  in the script path
```bash
> cd ..
> ./compile.sh
```

* To start the u-boot without flashing change directory (cd) to the project
folder and run following command.
```bash
> petalinux-boot --jtag --prebuilt 2 --hw_server-url pcsy169:3121
```

* Wait for the counter in the serial console and hit any button. This will take
  you to the u-boot shell. 

* Now set environment variables. Find ip of your tftp server and set ip
  serverip variable and aquire the IP address from the dhcp server. The
  Enclustra module reads the MAC address from the onboard eeprom, so
  you will have to register that MAC in the CERN network
  (network.cern.ch). Once you did that, you should receive the IP
  address.
```bash
> setenv serverip xxx.xxx.xxx.xxx
> dhcp
```
* If you want to be sure, that you set the correct address of your
  server run following command in u-boot.
```bash
> ping <your ip address>
```

## Loading flat image in jtag mode
* copy your image.ub from the project/image/linux/ directory to the
  tftpserver directory
* In the u-boot load image via ethernet.
```bash
> tftpboot <path to image>/image.ub
```
* Run the linux image.
```bash
> bootm
```
## Preparing EMMC image
* set your tftp server directory path in the makefile. build mmc.
```bash
> make mmc 
```
* load the image.ub in jtag mode as described above.

## FLASHING EMMC
* move the emmc_load.sh script to your tftp server directory
* login as root to the linux loaded from jtag and verify that your
  mmcblk0 is not mounted
```bash
> df -h
```
* download the emmc_load.sh script from your tftp server.
```bash
> tftp -r <directory>/emmc_load.sh -g <tftp server ip>
```
* run the script
```bash
> ./emmc_load.sh
```
* now flash the u-boot in the qspi.
```bash
> make flash
```
* power cycle and enjoy

## LINKS
- [flash emmc](http://enclustra.github.io/ebe-docs/user-doc-altera/index_altera.html#document-index_altera)
- [uboot setup](https://github.com/enclustra/PetalinuxDocumentation/blob/master/doc/QSPI_boot_mode.md)
- [uboot load instructions](https://wiki.emacinc.com/wiki/Loading_Images_with_U-Boot)

## NOTES
* the MAC address is taken from the onboard eeprom - each module = different MAC address
* the u-boot needs to run dhcp command and then setenv serverip <address of the current computer>
* you need to run the ftp server on your personal computer
* to flash emmc you need to flash linux to qspi and then prepare the emmc partitions and then load using tftp

## TROUBLESHOOTING
* if you cannot run linux in jtag mode, try to erase_only the QSPI memory with program_flash command

