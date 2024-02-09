#include "i2cbus.h"

int i2cbus_init(i2c_t *i2c, u32 clk_rate, u16 bus_id) 
{
    // allocate memory for i2c bus config 
    static XIicPs iic_dev; 
	XIicPs_Config *cfg;

    i2c->port = &iic_dev;
    i2c->writes = 0;
    i2c->reads = 0;
    i2c->addr = 0;

	cfg = XIicPs_LookupConfig(bus_id);
	if (cfg == NULL) return XST_FAILURE;

	if(XIicPs_CfgInitialize(i2c->port, cfg, cfg->BaseAddress)) 
        return XST_FAILURE;

	XIicPs_SetSClk(i2c->port, clk_rate);
	if (XIicPs_SelfTest(i2c->port)) return XST_FAILURE;
    return XST_SUCCESS;
}


int i2cbus_scan(i2c_t *i2c) {
    char line [64] = "";
    char *line_ptr;
    line_ptr = line;

    printf("     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f");
    for(u8 i=0; i<120; ++i) {
        i2c->writes=1;
        i2c->addr = i;
        i2c->data = (u8*) line_ptr;

        if (!(i%16) || i == 119) {
            printf("%s\n", line);
            sprintf(line, "%02x: ", i); 
            line_ptr = line + 4;
        }

        sprintf(line_ptr, "%02x ", i); 
        if(i2cbus_write_data(i2c)) sprintf(line_ptr, "-- ");
        
        line_ptr = line_ptr + 3;
    }

    return XST_SUCCESS;
}

int i2cbus_write_data(i2c_t *i2c) {
    int s;

	while (XIicPs_BusIsBusy(i2c->port));
	s = XIicPs_MasterSendPolled(i2c->port, i2c->data, i2c->writes, i2c->addr);

	if (s) return XST_FAILURE;
    return XST_SUCCESS;
}

int i2cbus_read_data(i2c_t *i2c) {
    int s;
    u8 wr_num_store = i2c->writes;
    i2c->writes=1;

    if (i2cbus_write_data(i2c)) return XST_FAILURE;
	while (XIicPs_BusIsBusy(i2c->port));
	s = XIicPs_MasterRecvPolled(i2c->port, i2c->data, i2c->reads, i2c->addr);
    i2c->writes = wr_num_store;

	if (s) return XST_FAILURE;
    return XST_SUCCESS;
}

int i2cbus_get_clock(i2c_t *i2c) {
    return i2c->port->Config.InputClockHz;
}

int i2cbus_get_id(i2c_t *i2c) {
    return i2c->port->Config.DeviceId;
}

void i2cbus_create_copy(i2c_t *i2c_new, i2c_t *i2c) {
    i2c_new->port = i2c->port;
}
