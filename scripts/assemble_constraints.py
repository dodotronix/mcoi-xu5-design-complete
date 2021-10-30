#!/usr/bin/python

import csv

#user configuration
dev = "ME-XU5-4CG/4EV/5EV-G1"
non_dep_pinout ="../pinout/xu5_module/Mercury_XU5-R1_FPGA_Pinout.csv"
var_dep_pinout ="../pinout/xu5_module/Mercury_XU5-R1_FPGA_Pinout_Assembly_Variants.csv"
pin_mapping_mcoi_a ="../pinout/mcoi/pin_conn_a.csv"
pin_mapping_mcoi_b ="../pinout/mcoi/pin_conn_b.csv"

with open(non_dep_pinout, newline='') as csvfile:
    f = csv.reader(csvfile, delimiter=',')
    dep = []
    var_dep = []
    for i in f: 
        if(len(i) == 4) and ("*") in i[3]:
            var_dep.append(i)
        if(len(i) == 4) and ("J80") in i[3]:
            dep.append(i)

with open(var_dep_pinout, newline='') as csvfile:
    f = csv.reader(csvfile, delimiter=',')
    var_assem_raw = [i for i in f if(len(i) == 5 and i[4])]
    
with open(pin_mapping_mcoi_a, newline='') as csvfile:
    f = csv.reader(csvfile, delimiter=',')
    pinmap_a = [i[0:3] for i in f][3:]

with open(pin_mapping_mcoi_b, newline='') as csvfile:
    f = csv.reader(csvfile, delimiter=',')
    pinmap_b = [i[0:3] for i in f][3:]


# filter just the pins for selected device in configuration
col = var_assem_raw[0].index(dev)
var_assem = [[i[0], i[1], i[col]] for i in var_assem_raw][2:]

for i in var_assem:
    for n in var_dep:
        if(i[2] == n[0]):
            con = i[1].split("-")
            if(con[0] == "A"):
                n[3] = "J800." + con[1] 
            else:
                n[3] = "J801." + con[1]

var_dep = [x for x in var_dep if x[3] != "*"]

def hasNumbers(inputString):
    return any(char.isdigit() for char in inputString)

def pin_stamp_const(pin, name):
    return "set_property PACKAGE_PIN {0} [get_ports {1}]\n".format(pin, name)

def pin_stamp_const_array(pin, name, num):
    return ("set_property PACKAGE_PIN {0} [get_ports {{{1}[{2}]}}]\n".format(pin, name, num))

#join all
final = var_dep + dep 

# replace J800 or J801 with connector pin number
final_a = []
final_b = []
for x in final:
    if "J800." in x[3]:
        x[3] = int(x[3].replace("J800.", ""))
        final_a.append(x)
    elif "J801." in x[3]:
        x[3] = int(x[3].replace("J801.", ""))
        final_b.append(x)

#sort arrays
final_a.sort(key=lambda x : x[3])
final_b.sort(key=lambda x : x[3])

# rename pins on connector A according to altium
for i in final_a:
    i[0] = pinmap_a[i[3]-1][1]

# rename pins on connector B according to altium
for i in final_b:
    i[0] = pinmap_b[i[3]-1][1]

final = final_a + final_b
final.sort(key=lambda x : x[0])

constraints = ""
for i in final:
    if(i[0]):
        raw_name = i[0].rsplit("_", 1)
        num = raw_name[-1]
        name = raw_name[0]
        if(str.isnumeric(num)):
            # TODO probably sort out the groups and sort theme 
            constraints += pin_stamp_const_array(i[1], name.lower(), num)
        else:
            constraints += pin_stamp_const(i[1], i[0].lower())

# generate constraint file
with open('constraints_mcoi_io.xdc', 'w') as f:
    f.write(constraints)
    f.close()

