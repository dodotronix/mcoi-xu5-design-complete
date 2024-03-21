/*
 *
 * https://docs.xilinx.com/r/en-US/ug1085-zynq-ultrascale-trm/Introduction?tocId=woBbxhIOVledjl_YLyd~cQ
 * https://docs.xilinx.com/r/en-US/oslib_rm/BSP-Configuration-Settings?tocId=wMpjv8~9UySetA6BBWH~9Q
 */

#include <stdio.h>
#include "xparameters.h"
#include "ethernet.h"
#include "i2cbus.h"
#include "xgpio.h"
#include "si5338.h"

/* 
#include "sleep.h"
#include "xbram.h"
#include "mcp9808.h"
#include "at24mac402.h"
#include "ina219.h"
#include "xil_io.h" */

void blink_led(void *io)
{
    u32 a = 0;
    const TickType_t blink_delay = 500 / portTICK_PERIOD_MS;
    XGpio *ptr = (XGpio *)io;

    // enable mcoi PL
    a = XGpio_DiscreteRead(ptr, 1);
    XGpio_DiscreteWrite(ptr, 1, a | 0x04);

    a = XGpio_DiscreteRead(ptr, 1);
    printf("Status: %x\n", a);
    XGpio_DiscreteWrite(ptr, 1, a | 0x02);

    while(1) {
        a = XGpio_DiscreteRead(ptr, 1);
        // printf("Status: %x\n", a);
        
        // if(a & 0x80000000){
        XGpio_DiscreteWrite(ptr, 1, (a & ~0x00000001));
        vTaskDelay(blink_delay);

        a = XGpio_DiscreteRead(ptr, 1);
        // printf("Status: %x\n", a);

        XGpio_DiscreteWrite(ptr, 1, a | 0x00000001);
        vTaskDelay(blink_delay);
        // }
    }
}

void mcoi_init_thread()
{
    XGpio io;
    i2c_t bus;

    TaskHandle_t blink_handle = NULL;

    const TickType_t wait_delay = 500 / portTICK_PERIOD_MS;
    int status;

    status = XGpio_Initialize(&io, XPAR_GPIO_0_DEVICE_ID);
    // printf("status of GPIO init: %x\n", status);

    XGpio_SetDataDirection(&io, 1, 0xffff0000);
    // printf("Status: %x\n", XGpio_DiscreteRead(&io, 1));

    // initialization of the i2c
    i2cbus_init(&bus, I2C_DEV0_CLK, I2C_DEV0_ID);

    // TODO wait for 500ms
    vTaskDelay(wait_delay);

    //scan i2c bus
    i2cbus_scan(&bus);

    if(si5338_init(&bus)) printf("si5338 init failed\n");

    si5338_configure();

    xTaskCreate(blink_led, "blink_led", 128, 
                (void*)&io, DEFAULT_THREAD_PRIO, &blink_handle);

    sys_thread_new("main_thrd", (void(*)(void*))main_thread, 0,
                    THREAD_STACKSIZE, DEFAULT_THREAD_PRIO);

    vTaskDelete(NULL);
    return;
}


int main(void)
{
    TaskHandle_t mcoi_handle = NULL;

    /* 
    i2c_t bus;
    float temp;
    u16 id;
    u32 a, b;

    XBram xmem;
    XBram_Config *cfgmem;

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


    id = mcp9808_getID();
    printf("id: %x\n", id);

    // i2cbus_scan(&bus);
    temp = mcp9808_readTempC();
    printf("temp: %f\n", temp);

    ina219_read_all();
    at24mac402_get_mac();
    at24mac402_get_uuid();

    cfgmem = XBram_LookupConfig(XPAR_BRAM_0_DEVICE_ID);
    if(XBram_CfgInitialize(&xmem, cfgmem, cfgmem->MemHighAddress)){
        printf("Bram initialization failed\n");
    }

    if (XBram_SelfTest(&xmem, 0)) {
    	printf("Bram selftest failed\n");
    }

	a = (0x0b<<24) | (0xdead);
    for(u32 addr=cfgmem->MemBaseAddress; addr<cfgmem->MemBaseAddress+40;){
    	printf("address: %x\n", addr);
    	XBram_Out32(addr, a);
    	printf("Bram data written: %x\n", a);

    	b = XBram_In32(addr);
    	printf("Bram data read: %x\n", b);
    	addr = addr + 4;
    }

    // Update values passed to the optical link
    XGpio_DiscreteWrite(&io, 1, 0x06);

    //wait for status to be up
    while(!(XGpio_DiscreteRead(&io, 1) & 0x80000000));
    printf("register status: %x\n", XGpio_DiscreteRead(&io, 1));

    usleep(1000000);
    printf("Status is up, let's reset FSM\n");
    XGpio_DiscreteWrite(&io, 1, 0x4);
    printf("register status: %x\n", XGpio_DiscreteRead(&io, 1)); */

    xTaskCreate(mcoi_init_thread,
                "mcoi_init_thread",
                2048,
                NULL, DEFAULT_THREAD_PRIO,
                &mcoi_handle);

    // event loop
    vTaskStartScheduler();
   
    return 0;
}
