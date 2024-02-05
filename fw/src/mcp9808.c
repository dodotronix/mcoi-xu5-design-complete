
#include "mcp9808.h"

static i2c_t mcp9808_bus;
static u8 data[2];
static temp_t t;

static u16 mcp9808_get_register(u8 reg) {
    mcp9808_bus.data[0] = reg;
    i2cbus_read_data(&mcp9808_bus);
    return (mcp9808_bus.data[0] << 8) | mcp9808_bus.data[1];
};

int mcp9808_init(i2c_t *i2c){
    i2cbus_create_copy(&mcp9808_bus, i2c);
    mcp9808_bus.data = data;
    mcp9808_bus.addr = MCP9808_ADDR;
    mcp9808_bus.writes = 1;
    mcp9808_bus.reads = 2;
    mcp9808_bus.data[0] = 0;
    return i2cbus_read_data(&mcp9808_bus);
};

u16 mcp9808_readTempRaw(){
    // mcp9808 reads MSB first and then LSB
    u16 raw_t = mcp9808_get_register(TEMP_REG);
    t.decimal = T_DECIMAL(raw_t);
    t.fractal = T_FRACTAL(raw_t);
    t.sign = T_SIGN(raw_t);
    return raw_t;
};

u16 mcp9808_getID() {
    // Device ID/Device Revision  = 0x0400
    return mcp9808_get_register(DEVICE_ID_REG);
};

u16 mcp9808_getManufacturer() {
    // Manufacturer ID = 0x0054
    return mcp9808_get_register(MANUFACTURER_ID_REG);
};

float mcp9808_readTempC(){
    float temp;
    mcp9808_readTempRaw();
    
    temp = t.decimal + (t.fractal * 0.0625);
    if(t.sign) temp = 256 - temp;

    return temp;
};


/* int mcp9808_getResolution(){
    return 0;
}; */

/* int mcp9808_setResolution(){
    return 0;
}; */

/* void mcp9808_getAll(){
    return;
}; */
