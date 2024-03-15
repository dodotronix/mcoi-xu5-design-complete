#include "si5338.h"
#include "mcoi_xu5_devkit_ch1_ch2_120mhz_low_jitter_on_1ch_25mhz_ref_lvds_clk_source1_in5_in6_from_pcb_rev1.h"

static u8 data[2];
static i2c_t si5338_bus;

int si5338_init(i2c_t *i2c) {
    i2cbus_create_copy(&si5338_bus, i2c);
    si5338_bus.data = data;
    si5338_bus.addr = SI5338_DEVICE_ADDR;
    si5338_bus.writes = 2;
    si5338_bus.reads = 1;
    si5338_bus.data[0] = 0;
    // ping the si5338 
    return i2cbus_read_data(&si5338_bus);
}

static void copy_bits(u8 reg0, u8 reg1, u8 mask) {
    si5338_bus.data[0] = reg0;
    i2cbus_read_data(&si5338_bus);
    // copy the value on the second 
    // place in the buffer that we 
    // don't have to create another 
    // storage space
    si5338_bus.data[1] = data[0];

    si5338_bus.data[0] = reg1;
    i2cbus_read_data(&si5338_bus);
    
    si5338_bus.data[1] = COMBINE_BIT(data[0], data[1], mask);
    si5338_bus.data[0] = reg1;
    i2cbus_write_data(&si5338_bus);
}

static void set_bits(u8 reg, u8 mask) {
    si5338_bus.data[0] = reg;
    i2cbus_read_data(&si5338_bus);

    si5338_bus.data[1] = SET_BIT(data[0], mask);
    si5338_bus.data[0] = reg;
    i2cbus_write_data(&si5338_bus);
}

static void clear_bits(u8 reg, u8 mask) {
    u8 tmp;
    si5338_bus.data[0] = reg;
    i2cbus_read_data(&si5338_bus);

    tmp = CLEAR_BIT(si5338_bus.data[0], mask);
    si5338_bus.data[1] = tmp;
    si5338_bus.data[0] = reg;
    i2cbus_write_data(&si5338_bus);
}

static void write_config_map() {
    u8 tmp;

    // printf("addr: %i, value: %x, mask: %x\n", element->Reg_Addr, element->Reg_Val, element->Reg_Mask);
    for(u32 i=0; i<NUM_REGS_MAX; ++i) {
        si5338_bus.data[0] = reg_map[i].Reg_Addr;
        si5338_bus.data[1] = reg_map[i].Reg_Val;

        if(~reg_map[i].Reg_Mask & 0xff) {
            i2cbus_read_data(&si5338_bus);
            tmp = CLEAR_BIT(si5338_bus.data[0], reg_map[i].Reg_Mask);
            si5338_bus.data[1] = COMBINE_BIT(tmp, reg_map[i].Reg_Val, reg_map[i].Reg_Mask);
            si5338_bus.data[0] = reg_map[i].Reg_Addr;
        };

        i2cbus_write_data(&si5338_bus);
    }
}

static u8 si5338_get_alarms() {
    si5338_bus.data[0] = SI5338_STATUS;
    i2cbus_read_data(&si5338_bus);
    return si5338_bus.data[0];
}

void si5338_configure(){
    u8 alarms;

    set_bits(230, 0x10); //disable outputs
    
    printf("\x1b[36mlol pause\x1b[0m\n");
    set_bits(241, 0x80); //pause lol

    printf("\x1b[35mwriting config\x1b[0m\n");
    write_config_map();

    // TODO pll does not get locked
    printf("\x1b[35mvalidating input clock ... \x1b[0m\n");
    alarms = si5338_get_alarms();
    if(alarms & 0x04)
    	printf("\x1b[33m[WARN]\x1b[0m LOS_CLKIN is active.\x1b[0m\n");
    if(alarms & 0x08)
    	printf("\x1b[33m[WARN]\x1b[0m LOS_FDBK is active.\x1b[0m\n");

    clear_bits(49, 0x80); //configure pll for locking
    set_bits(246, 0x02); //initiate locking of ppl
    
    DELAY_MS(25); //wait 25ms

    clear_bits(241, 0x80); //restart lol
    set_bits(241, 0x65);
    
    printf("\x1b[35mwaiting for locking pll ... \x1b[0m\n");
    while((si5338_get_alarms() & 0x10) || (si5338_get_alarms() & 0x11));

    printf("\x1b[35mcopying registers\x1b[0m\n");
    copy_bits(237, 47, 0x03);
    copy_bits(236, 46, 0xff);
    copy_bits(235, 45, 0xff);

    set_bits(47, 0x14);
    set_bits(49, 0x80); //set pll to use fcal

    printf("\x1b[36menabling outputs\x1b[0m\n");
    clear_bits(230, 0x10); //enable outputs
    printf("\x1b[32mdone!\x1b[0m\n");
};
