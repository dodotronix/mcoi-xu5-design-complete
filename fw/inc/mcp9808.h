#ifndef MCP9808_H_
#define MCP9808_H_

/* datasheet: https://ww1.microchip.com/downloads/en/DeviceDoc/25095A.pdf */

#include "i2cbus.h"

#define MCP9808_ADDR 0x18

#define CONFIG_REG 0x01
#define LOW_LIMIT_REG 0x02
#define HIGH_LIMIT_REG 0x03
#define CRIT_LIMIT_REG 0x04
#define TEMP_REG 0x05 
#define MANUFACTURER_ID_REG 0x06
#define DEVICE_ID_REG 0x07

// DECODING MACROS
#define T_DECIMAL(t) ((t & 0x0ff0) >> 4)
#define T_FRACTAL(l) (l & 0x000f)  
#define T_SIGN(h) ((h & 0x1000) == 0x1000)

typedef struct {
   u8 decimal;
   u8 fractal;
   u8 sign;
} temp_t;

int mcp9808_init(i2c_t *i2c);

u16 mcp9808_getID();
u16 mcp9808_getManufacturer();
u16 mcp9808_readTempRaw();
float mcp9808_readTempC();

/* int mcp9808_getResolution();
int mcp9808_setResolution();
void mcp9808_getAll(); */

#endif /* MCP9808_H_ */
