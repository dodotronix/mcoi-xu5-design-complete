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
# 5) copy the file to the same directory with the script
# 6) run the script
# ---------------------------------------------------------------------------- #

import smbus
import re
import time
import logging as log

# USER SETUP ----------------------------------------------------------------- #
bus = smbus.SMBus(1)      # 0 = /dev/i2c-0 (I2C0), 1 = /dev/i2c-1 (I2C1)
DEVICE_ADDRESS = 0x70     # 7 bit address
regs_file = 'register_map/config_400khz' # here you write the name of your generated c file

# DO NOT CHANGE THIS PART ---------------------------------------------------- #
p = re.compile(r'''{\s*(?P<reg>\d*),
                   (0x|\s*)(?P<val>[\d\w]*),
                   (0x|\s*)(?P<mask>[\d\w]*).*''',
                   re.DOTALL | re.VERBOSE | re.MULTILINE)


log.basicConfig(format='%(asctime)s %(levelname)s: %(message)s', 
        datefmt='%m/%d/%Y %I:%M:%S %p',level=log.INFO)

log.info('so should this')
log.warning('And this, too')

def set_bits(reg, val):
    current_reg = bus.read_byte_data(DEVICE_ADDRESS, reg)
    log.debug(bin(current_reg))
    bus.write_byte_data(DEVICE_ADDRESS, reg, current_reg | val)
    log.debug(bin(bus.read_byte_data(DEVICE_ADDRESS, reg)))

def clear_bits(reg, val):
    current_reg = bus.read_byte_data(DEVICE_ADDRESS, reg)
    log.debug(bin(current_reg))
    bus.write_byte_data(DEVICE_ADDRESS, reg, current_reg & ~val)
    log.debug(bin(bus.read_byte_data(DEVICE_ADDRESS, reg)))

def copy_bits(reg0, reg1, mask):
    current_reg0 = bus.read_byte_data(DEVICE_ADDRESS, reg0)
    current_reg1 = bus.read_byte_data(DEVICE_ADDRESS, reg1)
    
    current_reg1_new = current_reg1 | (current_reg0 & mask)
    bus.write_byte_data(DEVICE_ADDRESS, reg1, current_reg1_new)
    log.debug('{0} => {1} = {2}))'.format(current_reg0, 
        current_reg1, current_reg1_new))

def parse_config():
    with open(regs_file, 'r+') as regs:
        return [re.match(p, line).groupdict() for line in regs if line[0] == '{']
    
def write_new_config():
    config = parse_config()
    for c in config:
        imask = int(c['mask'], 16) # register mask
        ireg = int(c['reg'], 10) # register position
        ival = int(c['val'], 16) # register variable
        if(imask == 0xff):
            bus.write_byte_data(DEVICE_ADDRESS, ireg, ival)
            log.info('reg: {0}, _ => {1} | reg value: {2}'.format(ireg, 
            ival, bus.read_byte_data(DEVICE_ADDRESS, ireg)))
        else:
            current_reg = bus.read_byte_data(DEVICE_ADDRESS, ireg)
            clear_cur_val = (current_reg & ~imask)
            clear_new_val = ival & imask
            combined = clear_cur_val | clear_new_val
            bus.write_byte_data(DEVICE_ADDRESS, ireg, combined)
            log.info('reg: {0}, {1} => {2} | reg value: {3}'.format(ireg, 
            current_reg, combined, bus.read_byte_data(DEVICE_ADDRESS, ireg)))

def validate_value(reg, mask, val):
    # while True:
    while(not((bus.read_byte_data(DEVICE_ADDRESS, reg) & mask) == val)):
        pass

if __name__ == '__main__':
    log.info('disabling outputs')
    set_bits(230, 0x10) #disable outputs

    log.info('lol pause')
    set_bits(241, 0x80) #pause lol

    log.info('writing config')
    write_new_config()

    log.info('validating input clock ...')
    validate_value(218, 0x04, 0x00) 
    log.info('ok')

    clear_bits(49, 0x80) #configure pll for locking
    set_bits(246, 0x02) #initiate locking of ppl
    
    time.sleep(0.025) #wait 25ms

    clear_bits(241, 0x80) #restart lol
    set_bits(241, 0x65)
    
    log.info('waiting for locking pll ...')
    validate_value(218, 0x15, 0x00)
    log.info('ok')

    log.info('copying registers')
    copy_bits(237, 47, 0x03)
    copy_bits(236, 46, 0xff)
    copy_bits(235, 45, 0xff)

    set_bits(47, 0x14)
    set_bits(49, 0x80) #set pll to use fcal

    # if using down-spread
    # set_bits(226, 0x02) 
    # time.sleep(0.01)
    # clear_bits(226, 0x02)

    log.info('enabling outputs')
    clear_bits(230, 0x10) #enable outputs
    log.info('done')

