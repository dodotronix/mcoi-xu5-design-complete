#!/usr/bin/python
# ---------------------------------------------------------------------------- #
# PETR PACNER | CERN | 2019-09-17 Di 11:19 
# 
# adjusting script for clock generator si5338b
# 
# Manual:
# 1) use clockbuilder application
# 2) go through all steps of adjustment
# 3) generate c header file
# 4) 
# 5) copy the script to the fw/inc directory 
# 6) set terminal variable (export BLINKA_FT232H=1)
# 6) run the script
# ---------------------------------------------------------------------------- #

"""Si5338 loader"""
# If you run this and it seems to hang, try manually unlocking
# your I2C bus from the REPL with
#  >>> import board
#  >>> board.I2C().unlock()

import time
import board
import re
import logging as log
from busio import I2C
from adafruit_bus_device import i2c_device 


log.basicConfig(format='%(asctime)s %(levelname)s: %(message)s', 
        datefmt='%m/%d/%Y %I:%M:%S %p',level=log.INFO)

class rpi_i2c_api:

    def __init__(self, i2c, address: int) -> None:
        self.i2c = i2c
        self.address = address

    def read_byte_data(self, reg: int) -> int:
        return self.i2c.read_byte_data(self.address, reg)

    def write_byte_data(self, reg: int, val: int):
        self.i2c.write_byte_data(self.address, reg, val)

class ft232h_i2c_api:

    def __init__(self, i2c: I2C, address: int) -> None:
        self._BUFFER = bytearray(2)
        self._device = i2c_device.I2CDevice(i2c, address)
        
    def read_byte_data(self, reg: int) -> int:
        with self._device as i2c:
            self._BUFFER[0] = reg & 0xFF
            i2c.write_then_readinto(self._BUFFER, self._BUFFER, out_end=1, in_end=1)
        return self._BUFFER[0]

    def write_byte_data(self, reg: int, val: int) -> None:
        with self._device as i2c:
            self._BUFFER[0] = reg & 0xFF
            self._BUFFER[1] = val & 0xFF
            i2c.write(self._BUFFER, end=2)

class si5338b_loader:

    def __init__(self, i2c_api, register_map_file):
        self._bus = i2c_api
        self.reg_file = register_map_file
        # check if the device is there
    
    def set_bits(self, reg, val):
        current_reg = self._bus.read_byte_data(reg)
        log.debug(bin(current_reg))
        self._bus.write_byte_data(reg, current_reg | val)
        log.debug(bin(self._bus.read_byte_data(reg)))

    def clear_bits(self, reg, val):
        current_reg = self._bus.read_byte_data(reg)
        log.debug(bin(current_reg))
        self._bus.write_byte_data(reg, current_reg & ~val)
        log.debug(bin(self._bus.read_byte_data(reg)))

    def copy_bits(self, reg0, reg1, mask):
        current_reg0 = self._bus.read_byte_data(reg0)
        current_reg1 = self._bus.read_byte_data(reg1)
        
        current_reg1_new = current_reg1 | (current_reg0 & mask)
        self._bus.write_byte_data(reg1, current_reg1_new)
        log.debug('{0} => {1} = {2}))'.format(current_reg0, 
            current_reg1, current_reg1_new))

    def parse_config(self):
        p = re.compile(r'''{\s*(?P<reg>\d*),
                           (0x|\s*)(?P<val>[\d\w]*),
                           (0x|\s*)(?P<mask>[\d\w]*).*''',
                           re.DOTALL | re.VERBOSE | re.MULTILINE)

        with open(self.reg_file, 'r+') as regs:
            return [re.match(p, line).groupdict() for line in regs if line[0] == '{']

    def write_new_config(self):
        config = self.parse_config()
        for c in config:
            imask = int(c['mask'], 16) # register mask
            ireg = int(c['reg'], 10) # register position
            ival = int(c['val'], 16) # register variable
            if(imask == 0xff):
                self._bus.write_byte_data(ireg, ival)
                log.info('reg: {0}, _ => {1} | reg value: {2}'.format(ireg, 
                ival, self._bus.read_byte_data(ireg)))
            else:
                current_reg = self._bus.read_byte_data(ireg)
                clear_cur_val = (current_reg & ~imask)
                clear_new_val = ival & imask
                combined = clear_cur_val | clear_new_val
                self._bus.write_byte_data(ireg, combined)
                log.info('reg: {0}, {1} => {2} | reg value: {3}'.format(ireg, 
                current_reg, combined, self._bus.read_byte_data(ireg)))

    def validate_value(self, reg, mask, val):
        while(not((self._bus.read_byte_data(reg) & mask) == val)):
            pass

    def program(self):
        log.info('disabling outputs')
        self.set_bits(231, 0x10) #disable outputs

        log.info('lol pause')
        self.set_bits(241, 0x80) #pause lol

        log.info('writing config')
        self.write_new_config()

        log.info('validating input clock ...')
        self.validate_value(218, 0x04, 0x00) 
        log.info('ok')

        self.clear_bits(49, 0x80) #configure pll for locking
        self.set_bits(246, 0x02) #initiate locking of ppl
        
        time.sleep(0.025) #wait 25ms

        self.clear_bits(241, 0x80) #restart lol
        self.set_bits(241, 0x65)
        
        log.info('waiting for locking pll ...')
        self.validate_value(218, 0x15, 0x00)
        log.info('ok')

        log.info('copying registers')
        self.copy_bits(237, 47, 0x03)
        self.copy_bits(236, 46, 0xff)
        self.copy_bits(235, 45, 0xff)

        self.set_bits(47, 0x14)
        self.set_bits(49, 0x80) #set pll to use fcal

        # if using down-spread
        # self.set_bits(226, 0x02) 
        # time.sleep(0.01)
        # self.clear_bits(226, 0x02)

        log.info('enabling outputs')
        self.clear_bits(230, 0x10) #enable outputs
        log.info('done')


if __name__ == '__main__':
    # USER SETUP
    # here you write the path to your generated c file
    reg_file = '../../fw/inc/si5338b_evb_ch0_ch2_24mhz_ch1_100mhz_ch3_120mhz_lvds_low_jitter_source_in1_in2_reference_25mhz.h'

    # 7 bit address
    DEVICE_ADDRESS = 0x70 

    i2c = board.I2C() # uses board.SCL and board.SDA
    bus = ft232h_i2c_api(i2c, DEVICE_ADDRESS)

    # i2c = smbus.SMBus(1) # 0 = /dev/i2c-0 (I2C0), 1 = /dev/i2c-1 (I2C1)
    # bus = rpi_i2c_api(i2c, DEVICE_ADDRESS)

    pll = si5338b_loader(bus, reg_file)

    pll.program()
