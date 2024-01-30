
#ifndef INA219_H_
#define INA219_H_

/* datasheet: https://www.ti.com/lit/ds/symlink/ina219.pdf */

int ina219_init(u8 DeviceAddr);
int ina219_getBusVoltage_raw();
int ina219_getShuntVoltage_raw();
int ina219_getCurrent_raw();
int ina219_getPower_raw();
int ina219_setCalibration(int voltage, int current);

#endif /* INA219_H_ */
