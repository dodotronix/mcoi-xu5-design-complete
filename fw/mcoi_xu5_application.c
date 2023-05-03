/*
* This licence is copyright (c) CERN 2021, and the text of this licence is
* licensed as a whole under a Creative Commons Attribution-NoDerivatives 4.0
* International Licence, (CC BY-ND 4.0), available at
* https://creativecommons.org/licenses/by-nd/4.0/
* As a special exception to that licence, CERN expressly permits faithful
* translations of the entire licence into any language, and subsequent public
* display and distribution, provided that the resulting translation (which may
* include an attribution to the translator) is released under CC BY-ND 4.0
* attributing CERN as the copyright holder, and providing a link to
* the original licence text at
* https://ohwr.org/cern_ohl_w_v2.txt. This paragraph (translated
* appropriately) must be included when copying or translating the licence. You
* must make it clear (by at least including this paragraph) that the
* translation is unofficial and that the original text of the licence
* in the English language as released by CERN is definitive. You may
* also extract parts of the licence text (both in the original and in
* faithful translation) and copy, publicly display and distribute them
* for the purposes of education, training, providing legal advice,
* reviewing and critiquing the licence provided that you attribute
* CERN as above and also provided that such extracted parts do not form part of
* any document intended to have legal effect.

* created on 01 December 2021
* Author: Petr Pacner/DB
* Email:  petr.pacner@cern.ch
*/

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xgpiops.h"
#include "xparameters.h"
#include "sleep.h"
#include "xiicps.h"

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
#define TEST_BUFFER_SIZE	1

int IicPsMasterPolledTest(u16 DeviceId);

XIicPs Iic;

u8 SendBuffer[TEST_BUFFER_SIZE];    /**< Buffer for Transmitting Data */
u8 RecvBuffer[TEST_BUFFER_SIZE];    /**< Buffer for Receiving Data */


int main(void)
{
	int Status;
    char test[20];

    printf("waiting for an input:");
    scanf("%20s", test);
    printf("\n");
    for(int i=0; i<20; ++i) {
        printf("%c", test[i]);
    }
    printf("\n");

    xil_printf("IIC Master Polled Example Test \r\n");

    Status = IicPsMasterPolledTest(IIC_DEVICE_ID);
    if (Status != XST_SUCCESS) {
        xil_printf("IIC Master Polled Example Test Failed\r\n");
        return XST_FAILURE;
    }

    xil_printf("Successfully ran IIC Master Polled Example Test\r\n");
    return XST_SUCCESS;

}

int IicPsMasterPolledTest(u16 DeviceId)
{
	int Status;
	XIicPs_Config *Config;
	int Index;

	Config = XIicPs_LookupConfig(DeviceId);
	if (NULL == Config) {
		return XST_FAILURE;
	}

	Status = XIicPs_CfgInitialize(&Iic, Config, Config->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	Status = XIicPs_SelfTest(&Iic);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	XIicPs_SetSClk(&Iic, IIC_SCLK_RATE);

	for (Index = 0; Index < TEST_BUFFER_SIZE; Index++) {
		SendBuffer[Index] = (Index % TEST_BUFFER_SIZE);
		RecvBuffer[Index] = 0;
	}

	Status = XIicPs_MasterSendPolled(&Iic, SendBuffer,
			 TEST_BUFFER_SIZE, IIC_SLAVE_ADDR);

    printf("Status after writing data to FIFO: %i", Status);

	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

    show_iic_setup(&Iic);

	while (XIicPs_BusIsBusy(&Iic));

	Status = XIicPs_MasterRecvPolled(&Iic, RecvBuffer,
			  TEST_BUFFER_SIZE, IIC_SLAVE_ADDR);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}
