/*
 *
 * https://docs.xilinx.com/r/en-US/ug1085-zynq-ultrascale-trm/Introduction?tocId=woBbxhIOVledjl_YLyd~cQ
 * https://docs.xilinx.com/r/en-US/oslib_rm/BSP-Configuration-Settings?tocId=wMpjv8~9UySetA6BBWH~9Q
 */

#include <stdio.h>
#include "xgpio.h"
#include "xparameters.h"
#include "sleep.h"
#include "xbram.h"

#include "i2cbus.h"
#include "si5338.h"
#include "mcp9808.h"
#include "at24mac402.h"
#include "ina219.h"

/* #include "FreeRTOS.h"
#include "task.h" */

int main(void)
{
    XGpio io;

    i2c_t bus;
    float temp;
    u16 id;
    u32 a;
    int status;

    XBram xmem;
    XBram_Config *cfgmem;

    cfgmem = XBram_LookupConfig(XPAR_SHARED_MEMORY_CONTROL_DEVICE_ID);
    if(XBram_CfgInitialize(&xmem, cfgmem, cfgmem->MemBaseAddress)){
        printf("Bram initialization failed\n");
    }

    status = XGpio_Initialize(&io, XPAR_GPIO_0_DEVICE_ID);
    printf("status of GPIO init: %x\n", status);

    XGpio_SetDataDirection(&io, 1, 0xffff0000);
    printf("Status: %x\n", XGpio_DiscreteRead(&io, 1));

    usleep(250000);

    i2cbus_init(&bus, I2C_DEV0_CLK, I2C_DEV0_ID);

    //scan i2c bus
    i2cbus_scan(&bus);

    // initialization of devices 
    if(si5338_init(&bus)) {
        printf("si5338 init failed\n");
        return 1; 
    }

    if(mcp9808_init(&bus)) {
        printf("mcp9808 init failed\n");
        return 1; 
    }

    if(ina219_init(&bus)) {
        printf("ina219 init failed\n");
        return 1; 
    }

    if(at24mac402_init(&bus)) {
        printf("at24mac402 init failed\n");
        return 1; 
    }

    // TODO mcoi_init(); 
    si5338_configure();

    // enable mcoi PL
    XGpio_DiscreteWrite(&io, 1, 0x04);
    printf("Status: %x\n", XGpio_DiscreteRead(&io, 1));

    id = mcp9808_getID();
    printf("id: %x\n", id);

    // i2cbus_scan(&bus);
    temp = mcp9808_readTempC();
    printf("temp: %f\n", temp);

    ina219_read_all();
    at24mac402_get_mac();
    at24mac402_get_uuid();

    // write value to bram
    //a = (0xb<<16) | (0xdead);
    //printf("Bram data: %x\n", a);
    //XBram_WriteReg(cfgmem->MemBaseAddress, 1, a);

    // Update values passed to the optical link
    XGpio_DiscreteWrite(&io, 1, 0x06);
    printf("register status: %x\n", XGpio_DiscreteRead(&io, 1));

    //wait for status to be up
    while(!(XGpio_DiscreteRead(&io, 1) & 0x80000000));
    usleep(1000000);
    printf("register status: %x\n", XGpio_DiscreteRead(&io, 1));
    usleep(1000000);
    printf("Status is up, let's reset FSM\n");
    XGpio_DiscreteWrite(&io, 1, 0x4);
    printf("register status: %x\n", XGpio_DiscreteRead(&io, 1));

    // event loop
    while(1);

    return 0;
}

/* void mcoi_init() 
{
    int status;
    status = XGpio_Initialize(&io, XPAR_GPIO_0_DEVICE_ID);
    printf("status of GPIO init: %x\n", status);
    XGpio_SetDataDirection(&io, 1, 0xff00);
    printf("initial value: %x\n", XGpio_DiscreteRead(&io, 1));

     for(int i=0; i<10; ++i) {
        XGpio_DiscreteWrite(&io, 1, a | 0x02);
        usleep(250000);
        XGpio_DiscreteWrite(&io, 1, a | 0x00);
        usleep(250000);

    }
} */
