#!/usr/bin/python
import pyvisa
from time import sleep

a = "ASRL/dev/ttyACM0::INSTR"
rm = pyvisa.ResourceManager()
print(rm.list_resources())

inst = rm.open_resource(a)
del inst.timeout

def select_channel(num):
    inst.write(f'INST outp{num}')
    inst.write(f'OUTP:SEL{num} ON')
    sleep(0.5)

def set_channel(num, voltage, current):
    inst.write(f'INST outp{num}')
    inst.write(f'VOLT {voltage}')
    inst.write(f'CURR {current}')
    sleep(0.5)

def enable_all_channels():
    inst.write("OUTP:GEN ON")

def disable_all_channels():
    inst.write("OUTP:GEN OFF")

print(inst.query("*IDN?"))

# set_channel(1, 1.8, 0.3)
# set_channel(2, 3.3, 0.3)
set_channel(3, 12, 1) # channel 3, 12V, 1A

select_channel(1)
select_channel(2)
select_channel(3)

print("Power cycling lab setup")
disable_all_channels()
sleep(2)
enable_all_channels()

