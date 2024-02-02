
#include "mcp9808.h"

static i2c_t mcp9808_bus;
static u8 data[2];
static temp_t t;

void mcp9808_init(i2c_t *i2c){
    i2cbus_create_copy(&mcp9808_bus, i2c);
    mcp9808_bus.data = data;
    mcp9808_bus.addr = MCP9808_ADDR;
    mcp9808_bus.writes = 1;
    mcp9808_bus.reads = 2;
};

void mcp9808_readTempRaw(){
    mcp9808_bus.data[0] = TEMP_REG;
    i2cbus_read_data(&mcp9808_bus);
    t.decimal = T_DECIMAL(mcp9808_bus.data[1], mcp9808_bus.data[0]);
    t.fractal = T_FRACTAL(mcp9808_bus.data[0]);
    t.sign = T_SIGN(mcp9808_bus.data[1]);
};

float mcp9808_readTempC(){
    float temp;
    mcp9808_readTempRaw();
    
    temp = t.decimal + t.fractal * 0.0625;
    if(t.sign) temp = -temp;
    
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
