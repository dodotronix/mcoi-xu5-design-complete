
#include "at24mac402.h"

static i2c_t atmac402_bus;
static eeprom_t mem;

int at24mac402_init(i2c_t *i2c){
    i2cbus_create_copy(&atmac402_bus, i2c);
    atmac402_bus.data = mem.mac;
    atmac402_bus.addr = AT24MAC402_ADDR_SN_UUID;
    atmac402_bus.writes = 1;
    atmac402_bus.reads = 6;
    atmac402_bus.data[0] = AT24MAC402_MAC64_START;
    
    if(i2cbus_read_data(&atmac402_bus)) return 1; 

    atmac402_bus.data = mem.uuid;
    atmac402_bus.writes = 1;
    atmac402_bus.reads = 16;
    atmac402_bus.data[0] = AT24MAC402_SN_START;

    if(i2cbus_read_data(&atmac402_bus)) return 1; 
    atmac402_bus.data = mem.data;
    return 0;
}

static void display(u8 *data, u8 len) {
    for(int i=0; i<len; ++i){
        printf("%02x ", data[i]);
    }
    printf("\n");
};

void at24mac402_get_mac() {
    printf("MAC: ");
    display(mem.mac, 6);
};

void at24mac402_get_uuid() {
    printf("UUID: ");
    display(mem.uuid, 16);
};
