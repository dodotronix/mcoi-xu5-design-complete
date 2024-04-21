#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/ioctl.h>
#include <linux/types.h>
#include <linux/i2c-dev.h>
#include <linux/i2c.h>
#include <sys/stat.h>
#include <sys/mman.h>

int main(int argc, char **argv)
{
    int i2c;
    int addr_si5338 = 0x70;
    int addr_temp = 0x18;
    static const char *i2c_device = "/dev/i2c-0";
    unsigned char i2c_tx_buf[2];
    unsigned char i2c_rx_buf[2];

    struct i2c_msg msgs[2];
    struct i2c_rdwr_ioctl_data msgset[1];

    printf("Do prdele prace podruhe :DDD!\n");

    i2c = open(i2c_device, O_RDWR);
    if (i2c < 0) {
        printf("can't open I2C device\n\r");
        exit(1);
    }

    if (ioctl(i2c, I2C_SLAVE, addr_si5338) < 0) {
        printf("can't find si5338 pll\n\r");
        exit(1);
    }

    if (ioctl(i2c, I2C_SLAVE, addr_temp) < 0) {
        printf("can't find temp sensor\n\r");
        exit(1);
    }

    return 0;
}   

