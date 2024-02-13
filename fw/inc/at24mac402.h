#ifndef AT24MAC402_H_
#define AT24MAC402_H_

/* datasheet: https://ww1.microchip.com/downloads/aemDocuments/documents/MPD/ProductDocuments/DataSheets/I2C-Compatible-%28Two-Wire%29-Serial-EEPROM-with-a-Factory-Programmed-EUI-48-or-EUI-64-Address-Plus-a-Unique-Factory-Programmed-128-Bit-Serial-Number-2-Kbit-%28256x8%29-20006430A.pdf */

#include "i2cbus.h"

#define AT24MAC402_ADDR_EEPROM 0x54
#define AT24MAC402_ADDR_SN_UUID 0x5C
#define AT24MAC402_ADDR_PROTECTED 0x34

#define AT24MAC402_SN_START 0x80
#define AT24MAC402_MAC48_START 0x9A
#define AT24MAC402_MAC64_START 0x98

typedef struct {
    u8 mac[6];
    u8 uuid[16];
    u8 data[4];
} eeprom_t;

int at24mac402_init(i2c_t *i2c);

void at24mac402_get_mac();
void at24mac402_get_uuid();

#endif /* AT24MAC402_H_ */
