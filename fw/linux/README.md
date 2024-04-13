## INSTALLATION

## LINKS
- [flash emmc](http://enclustra.github.io/ebe-docs/user-doc-altera/index_altera.html#document-index_altera)

## NOTES
* the MAC address is taken from the onboard eeprom - each module = different MAC address
* the u-boot needs to run dhcp command and then setenv serverip <address of the current computer>
* you need to run the ftp server on your personal computer
* to flash emmc you need to flash linux to qspi and then prepare the emmc partitions and then load using tftp
