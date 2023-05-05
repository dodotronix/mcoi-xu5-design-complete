/*
 *
 * https://docs.xilinx.com/r/en-US/ug1085-zynq-ultrascale-trm/Introduction?tocId=woBbxhIOVledjl_YLyd~cQ
 * https://docs.xilinx.com/r/en-US/oslib_rm/BSP-Configuration-Settings?tocId=wMpjv8~9UySetA6BBWH~9Q
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xgpiops.h"
#include "xparameters.h"
#include "sleep.h"
#include "xiicps.h"
// #include "config_120mhz.h"
#include "config_400khz.h"

void show_iic_setup(XIicPs *InstancePtr) {
    printf("Device ID: %x\n", InstancePtr->Config.DeviceId);
    printf("Base Address: %x\n", InstancePtr->Config.BaseAddress);
    printf("Input Clock Hz: %li\n", InstancePtr->Config.InputClockHz);

    printf("Is Ready: %lx\n", InstancePtr->IsReady);
    printf("Options: %lx\n", InstancePtr->Options);

    /* printf("Received buffer data: %i\n", *(InstancePtr->RecvBufferPtr));
    printf("Send buffer data: %i\n", *(InstancePtr->SendBufferPtr)); */
    printf("Send Byte Count: %lx\n", InstancePtr->SendByteCount);

    printf("Recv Byte Count: %lx\n", InstancePtr->RecvByteCount);
    printf("Current Byte Count: %lx\n", InstancePtr->CurrByteCount);
    printf("Update Tx size: %lx\n", InstancePtr->UpdateTxSize);
    printf("Is Send: %lx\n", InstancePtr->IsSend);
    printf("Is Repeated Start: %lx\n", InstancePtr->IsRepeatedStart);
    printf("Is 10Bit Addr: %lx\n", InstancePtr->Is10BitAddr);
}

#define IIC_DEVICE_ID		XPAR_XIICPS_0_DEVICE_ID
#define IIC_SLAVE_ADDR		0x70
#define IIC_SCLK_RATE		100000

int initialize_iic(u16 DeviceId, XIicPs *iic_dev);
u8 read_byte_data(XIicPs *iic_dev, u16 addr, u8 reg);
void write_byte_data(XIicPs *iic_dev, u16 addr, u8 reg, u8 val);
void set_bits(XIicPs *iic_dev, u8 reg, u8 val);
void clear_bits(XIicPs *iic_dev, u8 reg, u8 val);
void copy_bits(XIicPs *iic_dev, u8 reg0, u8 reg1, u8 mask);
void validate_value(XIicPs *iic_dev, u8 reg, u8 mask, u8 val);
void write_config_map(XIicPs *iic_dev, __Reg_Data const *map, u32 map_length);
int initialize_clock(u16 DeviceId);

u8 SendBuffer[2];
u8 RecvBuffer[1];

int main(void)
{
    char test[20];
    printf("waiting for an input:");
    scanf("%20s", test);
    printf("\n");
    for(int i=0; i<20; ++i) {
        printf("%c", test[i]);
    }
    printf("\n");

    printf("Initialize External PLL\r\n");
    initialize_clock(IIC_DEVICE_ID);

    return 0;
}

void set_bits(XIicPs *iic_dev, u8 reg, u8 val) {
    u8 tmp, current_reg;
    current_reg = read_byte_data(iic_dev, IIC_SLAVE_ADDR, reg);
    tmp = current_reg | val;
    write_byte_data(iic_dev, IIC_SLAVE_ADDR, reg, tmp);
    current_reg = read_byte_data(iic_dev, IIC_SLAVE_ADDR, reg);
    printf("[DEBUG]: addr %i; written %x ---> read %x\n", reg, tmp, current_reg);
}

void clear_bits(XIicPs *iic_dev, u8 reg, u8 val) {
    u8 tmp, current_reg;
    current_reg = read_byte_data(iic_dev, IIC_SLAVE_ADDR, reg);
    tmp = current_reg & ~val;
    write_byte_data(iic_dev, IIC_SLAVE_ADDR, reg, tmp);
    current_reg = read_byte_data(iic_dev, IIC_SLAVE_ADDR, reg);
    printf("[DEBUG]: addr %i; written %x ---> read %x\n", reg, tmp, current_reg);
}

void copy_bits(XIicPs *iic_dev, u8 reg0, u8 reg1, u8 mask) {
    u8 tmp, current_reg0, current_reg1;
    current_reg0 = read_byte_data(iic_dev, IIC_SLAVE_ADDR, reg0);
    current_reg1 = read_byte_data(iic_dev, IIC_SLAVE_ADDR, reg1);
    
    tmp = current_reg1 | (current_reg0 & mask);
    write_byte_data(iic_dev, IIC_SLAVE_ADDR, reg1, tmp);
    printf("[DEBUG]: combine %x | (%x & %x) ---> written %x\n", current_reg1, current_reg0, mask, tmp);
}

void validate_value(XIicPs *iic_dev, u8 reg, u8 mask, u8 val) {
    printf("[DEBUG]: validating value in register %x (desired value %x)\n", reg, val);
    while(!((read_byte_data(iic_dev, IIC_SLAVE_ADDR, reg) & mask) == val));
    printf("ok\n");
}

void write_config_map(XIicPs *iic_dev, __Reg_Data const *map, u32 map_length) {
    __Reg_Data const *element; 
    u8 current_reg, combined, clear_cur_val, tmp;

    for(u32 i=1; i<map_length; ++i) {
        element = map + i;
        printf("addr: %i, value: %x, mask: %x\n", element->Reg_Addr, element->Reg_Val, element->Reg_Mask);
        if(element->Reg_Mask == 0xff) {
            write_byte_data(iic_dev, IIC_SLAVE_ADDR, element->Reg_Addr, element->Reg_Val);
            tmp = read_byte_data(iic_dev, IIC_SLAVE_ADDR, element->Reg_Addr);
            printf("[DEBUG]: addr %i; written %x ---> read %x\n", element->Reg_Addr, element->Reg_Val, tmp);
        } else {
            current_reg = read_byte_data(iic_dev, IIC_SLAVE_ADDR, element->Reg_Addr);
            clear_cur_val = (current_reg & ~element->Reg_Mask);
            tmp = element->Reg_Val & element->Reg_Mask;
            combined = clear_cur_val | tmp;
            write_byte_data(iic_dev, IIC_SLAVE_ADDR, element->Reg_Addr, combined);
            current_reg = read_byte_data(iic_dev, IIC_SLAVE_ADDR, element->Reg_Addr);
            printf("[DEBUG]: addr %i; written %x ---> read %x\n", element->Reg_Addr, combined, current_reg);
        }
    }
}

void write_byte_data(XIicPs *iic_dev, u16 addr, u8 reg, u8 val) {
    SendBuffer[0] = reg;
    SendBuffer[1] = val;
    int Status;

    // Wait for the line to be IDLE
	while (XIicPs_BusIsBusy(iic_dev));
	Status = XIicPs_MasterSendPolled(iic_dev, SendBuffer, 2, addr);
	if (Status) printf("Failed Reading from the I2C\n");
}

u8 read_byte_data(XIicPs *iic_dev, u16 addr, u8 reg) {

    int Status;
    SendBuffer[0] = reg;
    // wait until data line is idle again 
	while (XIicPs_BusIsBusy(iic_dev));
	Status = XIicPs_MasterSendPolled(iic_dev, SendBuffer, 1, addr);

	while (XIicPs_BusIsBusy(iic_dev));
	Status = XIicPs_MasterRecvPolled(iic_dev, RecvBuffer, 1, addr);
	if (Status) printf("Failed Reading from the I2C\n");

    return RecvBuffer[0];
}

int initialize_iic(u16 DeviceId, XIicPs *Iic) {

	int Status;
	XIicPs_Config *Config;

	Config = XIicPs_LookupConfig(DeviceId);
	if (NULL == Config) return XST_FAILURE;

	Status = XIicPs_CfgInitialize(Iic, Config, Config->BaseAddress);
	if (Status != XST_SUCCESS) return XST_FAILURE;

	Status = XIicPs_SelfTest(Iic);
	if (Status) return XST_FAILURE;

	XIicPs_SetSClk(Iic, IIC_SCLK_RATE);
    return XST_SUCCESS;
}

int initialize_clock(u16 DeviceId) {
    
    XIicPs Iic;

    if(initialize_iic(DeviceId, &Iic)) { 
        printf("I2C INITIALIZATION FAILED\n");
        return XST_FAILURE;
    }

    /* write_byte_data(&Iic, IIC_SLAVE_ADDR, 0x31, 0x10);
    printf("Read vaule: %u",read_byte_data(&Iic, IIC_SLAVE_ADDR,  0x31)); */

    set_bits(&Iic, 230, 0x10); //disable outputs

    printf("lol pause\n");
    set_bits(&Iic, 241, 0x80); //pause lol

    printf("writing config\n");
    write_config_map(&Iic, code_Reg_Store, NUM_REGS_MAX);

    printf("validating input clock ... \n");
    validate_value(&Iic, 218, 0x04, 0x00);

    clear_bits(&Iic, 49, 0x80); //configure pll for locking
    set_bits(&Iic, 246, 0x02); //initiate locking of ppl
    
    usleep(0.025); //wait 25ms

    clear_bits(&Iic, 241, 0x80); //restart lol
    set_bits(&Iic, 241, 0x65);
    
    printf("waiting for locking pll ... \n");
    validate_value(&Iic, 218, 0x15, 0x00);

    printf("copying registers\n");
    copy_bits(&Iic, 237, 47, 0x03);
    copy_bits(&Iic, 236, 46, 0xff);
    copy_bits(&Iic, 235, 45, 0xff);

    set_bits(&Iic, 47, 0x14);
    set_bits(&Iic, 49, 0x80); //set pll to use fcal

    printf("enabling outputs\n");
    clear_bits(&Iic, 230, 0x10); //enable outputs
    printf("done\n");

    return XST_SUCCESS;
}
