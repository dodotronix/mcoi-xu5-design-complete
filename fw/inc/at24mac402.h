#ifndef AT24MAC402_H_
#define AT24MAC402_H_

/* datasheet: https://ww1.microchip.com/downloads/aemDocuments/documents/MPD/ProductDocuments/DataSheets/I2C-Compatible-%28Two-Wire%29-Serial-EEPROM-with-a-Factory-Programmed-EUI-48-or-EUI-64-Address-Plus-a-Unique-Factory-Programmed-128-Bit-Serial-Number-2-Kbit-%28256x8%29-20006430A.pdf */

int at24mac402_init(u8 DeviceAddr);
int at24mac402_write(u8 reg, u8 val);
int at24mac402_read(u8 reg);
int at24mac402_get_EUI64(u8 mac[6]);
int at24mac402_get_UUID(u8 uuid[16]);

#endif /* AT24MAC402_H_ */
