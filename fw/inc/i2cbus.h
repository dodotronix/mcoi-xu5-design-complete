#ifndef I2CBUS_H_
#define I2CBUS_H_

// USER API
#define I2C_DEV0_ID XPAR_XIICPS_0_DEVICE_ID
#define I2C_DEV0_CLK 100000U

#include <stdio.h>
#include "xil_types.h"
#include "xiicps.h"



typedef struct {
    XIicPs *port;
    u8 *data;
    u8 writes;
    u8 reads;
    u16 addr;
} i2c_t; 

int i2cbus_init(i2c_t *i2c, u32 clk_rate, u16 bus_id);
int i2cbus_scan(i2c_t *i2c);
int i2cbus_write_data(i2c_t *i2c);
int i2cbus_read_data(i2c_t *i2c);

#endif /* I2CBUS_H_ */
