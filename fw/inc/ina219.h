
#ifndef INA219_H_
#define INA219_H_

/* datasheet: https://www.ti.com/lit/ds/symlink/ina219.pdf */

#include "i2cbus.h"

#define INA219_ADDR 0x40
#define INA219_MAX_CURRENT 15 // in Amps
#define INA219_SHUNT 0.1 // in Ohms
#define INA219_MEAS_SHUNT_CURRENT 15 // in Amps

#define INA219_CONFIG_REG 0x00 // shunt resistor, resolution
#define INA219_SHUNT_VOLTAGE_REG 0x01
#define INA219_BUS_VOLTAGE_REG 0x02
#define INA219_POWER_REG 0x03
#define INA219_CURRENT_REG 0x04
#define INA219_CALIBRATION_REG 0x05 

#define INA219_FSR 0x2000
#define INA219_RESET 0x8000

#define INA219_PG0 0x1000
#define INA219_PG1 0x0800

#define INA219_BADC0 0x0400
#define INA219_BADC1 0x0200
#define INA219_BADC2 0x0100
#define INA219_BADC3 0x0080

#define INA219_SADC0 0x0040
#define INA219_SADC1 0x0020
#define INA219_SADC2 0x0010
#define INA219_SADC3 0x0008

#define INA219_MODE0 0x0004
#define INA219_MODE1 0x0002
#define INA219_MODE2 0x0001

#define INA219_LSB_CURRENT ( INA219_MAX_CURRENT / ( 1 << 16 ) )
#define INA219_LSB_POWER ( INA219_LSB_CURRENT * 20 )
#define INA219_CALIBRATION_CONST ( 4096 / 100000 * INA219_LSB_CURRENT * INA219_SHUNT)

#define INA219_LSB(x)                  ( x * 0x00ff )
#define INA219_MSB(x)                  ( ( x * 0xff00 ) >> 8 )
#define INA219_CALCULATE_BUSVOLTAGE(x) ( x >> 3 )

#define INA219_ASSEMBLE_VALUE(v0, v1)  ( ( v0 << 8 ) | v1 )

// (shunt voltage reg) * (cal reg) * (current lsb) / 4096
#define INA219_CALCULATE_POWER(c, b)   ( ( c * b * INA219_LSB_POWER )/5000 )
// (current reg) * (bus voltage reg) * (power lsb) / 4096
#define INA219_CALCULATE_CURRENT(s, c) ( ( s * c * INA219_LSB_CURRENT) / 4096 )

int ina219_init(i2c_t *i2c);

typedef struct {
    u16 Vbus;
    u16 Vshunt;
    u16 current;
    u16 power;
} consumption_t;


int ina219_init(i2c_t *i2c);
void ina219_read_all();


/* int ina219_getBusVoltage_raw();
int ina219_getShuntVoltage_raw();
int ina219_getCurrent_raw();
int ina219_getPower_raw();
int ina219_setCalibration(int voltage, int current); */

#endif /* INA219_H_ */
