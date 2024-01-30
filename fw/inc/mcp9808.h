#ifndef MCP9808_H_
#define MCP9808_H_

/* datasheet: https://ww1.microchip.com/downloads/en/DeviceDoc/25095A.pdf */

int mcp9808_init(u8 DeviceAddr);
int mcp9808_read16(u8 reg);
int mcp9808_write16(u8 reg, u16 val);
int mcp9808_readTempRaw();
int mcp9808_readTempC();
int mcp9808_getResolution();
int mcp9808_setResolution();
void mcp9808_getAll();

#endif /* MCP9808_H_ */
