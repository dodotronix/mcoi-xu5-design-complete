#include "ina219.h"

static i2c_t ina219_bus;
static u8 data[3];
static consumption_t c;

int ina219_init(i2c_t *i2c){
    u16 temp = 0;
    i2cbus_create_copy(&ina219_bus, i2c);
    ina219_bus.data = data;
    ina219_bus.addr = INA219_ADDR;
    ina219_bus.writes = 3;
    ina219_bus.reads = 2;

    //write calibration register
    ina219_bus.data[0] = INA219_CONFIG_REG;
    i2cbus_read_data(&ina219_bus);
    temp = INA219_ASSEMBLE_VALUE(data[0], data[1]);
    printf("temp: %x\n", temp);
    ina219_bus.data[1] = INA219_LSB(temp);
    ina219_bus.data[2] = INA219_MSB(temp);

    if(i2cbus_write_data(&ina219_bus)) return 1;

    ina219_bus.data[0] = INA219_CALIBRATION_REG;
    temp = (u16) INA219_CALIBRATION_CONST;
    ina219_bus.data[1] = INA219_LSB(temp);
    ina219_bus.data[2] = INA219_MSB(temp);

    return i2cbus_write_data(&ina219_bus);
}

int read_register(u8 reg){
    ina219_bus.data[0] = reg;
    return i2cbus_read_data(&ina219_bus);
}

void display() {
    float test = INA219_CALCULATE_BUSVOLTAGE(c.Vbus);
    float shunt_test = INA219_CALCULATE_SHUNTVOLTAGE(c.Vshunt, 1);

    float power = INA219_CALCULATE_POWER(c.current, c.Vbus);
    float current = INA219_CALCULATE_CURRENT(c.Vshunt, c.current);

    printf("LSB current: %f\n", INA219_LSB_CURRENT);
    printf("LSB power: %f\n", INA219_LSB_POWER);
    printf("Calibration constant: %f\n", INA219_CALIBRATION_CONST);
    printf("\n");
    printf("Bus voltage register: %04x\n", c.Vbus);
    printf("Current register: %04x\n", c.current);
    printf("Shunt voltage register: %04x\n", c.Vshunt);
    printf("Power register: %04x\n", c.power);
    printf("\n");
    printf("Bus voltage [V]: %f\n", test);
    printf("Shunt voltage [V]: %f\n", shunt_test);
    printf("power [W]: %f\n", power);
    printf("current [A]: %f\n", current);
}

void ina219_read_all() {
    read_register(INA219_SHUNT_VOLTAGE_REG);
    c.Vshunt = INA219_ASSEMBLE_VALUE(data[0], data[1]);

    read_register(INA219_BUS_VOLTAGE_REG);
    c.Vbus = INA219_ASSEMBLE_VALUE(data[0], data[1]);

    read_register(INA219_CURRENT_REG);
    c.current = INA219_ASSEMBLE_VALUE(data[0], data[1]);

    read_register(INA219_POWER_REG);
    c.power = INA219_ASSEMBLE_VALUE(data[0], data[1]);

    display();
}
