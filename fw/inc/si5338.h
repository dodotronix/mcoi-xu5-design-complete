#ifndef SI5338_H_
#define SI5338_H_

/* datasheet: https://www.skyworksinc.com/-/media/Skyworks/SL/documents/public/data-sheets/Si5338.pdf */

// USER API
#include "i2cbus.h"
#include "FreeRTOS.h"
#include "task.h"

#define DELAY_MS(x) vTaskDelay( ( x / portTICK_PERIOD_MS ) )

#define SI5338_DEVICE_ADDR 0x70

#define SI5338_STATUS 0xDA // 218
#define SI5338_OEB 0xE6 // 230

# define SET_BIT(x, mask) ((x) | (mask))
# define CLEAR_BIT(x, mask) ((x) & ~(mask))
# define COMBINE_BIT(x, y, mask) ((x) | ((y) & (mask)))


int si5338_init(i2c_t *i2c);
void si5338_configure();

/* void set_bits(XIicPs *iic_dev, u8 reg, u8 val);
void clear_bits(XIicPs *iic_dev, u8 reg, u8 val);
void copy_bits(XIicPs *iic_dev, u8 reg0, u8 reg1, u8 mask);
void validate_value(XIicPs *iic_dev, u8 reg, u8 mask, u8 val);
void write_config_map(XIicPs *iic_dev, t_reg_data const *map, u32 map_length); */

#endif /* SI5338_H_ */
