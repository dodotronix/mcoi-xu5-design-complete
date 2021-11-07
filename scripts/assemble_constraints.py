#!/usr/bin/python3

import csv
import os
import sys
import re
import logging as log

from io import StringIO
from argparse import ArgumentParser, ArgumentError

#submit file names as script arguments
parser = ArgumentParser(description = 'Generates constraints files for ' 
                                      'MCOI XU5 platform')

parser.add_argument('-d', '--device',
        metavar = 'STRING',
        type = str,
        help = 'Full name of the device taken from Enclustra catalog')
parser.add_argument('-ap', '--apinout',
        metavar = 'FILE',
        type = str,
        help = 'Pinout of connector A as is specified in Enclustra XU5 schematics')
parser.add_argument('-bp', '--bpinout',
        metavar = 'FILE',
        type = str,
        help = 'Pinout of connector B as is specified in Enclustra XU5 schematics')
parser.add_argument('-va','--vendor_assembly',
        metavar = 'FILE',
        type = str,
        help = 'Enclustra csv file defining pinouts for different module versions')
parser.add_argument('-vp', '--vendor_pinout',
        metavar = 'FILE',
        type = str,
        help = 'Enclustra csv file with pinout of the specific module')
parser.add_argument('-o', '--output_directory',
        metavar = 'PATH',
        type = str,
        help = 'Output directory for constraints files')
parser.add_argument('-c', '--config',
        metavar = 'FILE',
        required=False,
        type = str,
        help = 'File with additional configs for module pins')
parser.add_argument('-io', '--iostandard',
        metavar = 'STRING',
        type = str,
        help = 'Default IO standard which will be used if the pins ' 
        'not defined in the config file')

args = vars(parser.parse_args())

# logging configuration
root = log.getLogger()
root.setLevel(log.INFO)

dev = args['device']
non_dep_pinout = args['vendor_pinout']
var_dep_pinout = args['vendor_assembly']
pin_mapping_mcoi_a = args['apinout']
pin_mapping_mcoi_b = args['bpinout']
destination_folder = args['output_directory']
board_config = args['config']
default_iostandard = args["iostandard"]

# if the input files change, you can just modify the regex
# this regex counts on that the the file has Pin Designator column and 168 pins
conns = re.compile(r'''Pin\s+Designator.*168.*\n''',
                   re.MULTILINE | re.VERBOSE | re.DOTALL)

# Enclustra files are already modified. The files are originaly in xlsx
# so first they were exported to csv and the redundant footers were removed 
get_all = re.compile(r'''.*''',
                     re.MULTILINE | re.VERBOSE | re.DOTALL)

def create_dict(file, regex_pattern):
    with open(file, "r", newline='') as f:
        #create raw one piece string
        raw_txt_data = ''.join(f.readlines()) 
        # there should be just one match so there fore group(0)
        try:
            pins_a = regex_pattern.search(raw_txt_data).group(0) 
        except:
            log.error('File: {0} has probably '
                      'different structure than expected\n'.format(file))
        dict_iter = csv.DictReader(StringIO(pins_a),
                                   skipinitialspace=True, 
                                   delimiter=',')
        return [i for i in dict_iter]

# read data and create list of dictionaries
log.info("Loading all sources")
conn_a = create_dict(pin_mapping_mcoi_a, conns)
conn_b = create_dict(pin_mapping_mcoi_b, conns)
variants = create_dict(non_dep_pinout, get_all)
assembly = create_dict(var_dep_pinout, get_all)
config = create_dict(board_config, get_all)

dep_t = [i for i in variants if("J80" in i["Connector"])]
dep_var_t = [i for i in variants if(i["Connector"] == "*")]

#list of signals on module (name from enclustra xlsx) 
signal_on_module = [i["Signal on module"] for i in dep_var_t] 
# create map of indexes for variants dependent connections
pin_inx = [signal_on_module.index(i[dev]) for i in assembly]
# replace the asterisks 
for n,i in enumerate(pin_inx):
    pin_number = dep_var_t[i]["FPGA pin number"]
    # This variable shows the pcb connection on the particular variant
    platform_con = assembly[n]["Module Variant"] 
    # this reads data from assembly file and according to whether it is with
    # prefix A or B it adds the value to the places with * based on the
    # "pin_inx" and add the prefix J800 or J801 
    con_num = platform_con.split("-")[1] 
    dep_var_t[i]["Connector"] = ("J800.{0}".format(con_num) 
                                 if("A" in platform_con) 
                                 else "J801.{0}".format(con_num))
    #remove all unconnected routes with *
    rm_asterisk = [i for i in dep_var_t if i["Connector"] != "*"]
    # full configuration of the chosen module
    full_configuratin = rm_asterisk + dep_t

# split the pin set in two (connector A and B as in the schematics)
connector_a = [i for i in full_configuratin if("J800." in i["Connector"])] 
connector_b = [i for i in full_configuratin if("J801." in i["Connector"])] 

# take names from Altium files and rename the pins on enclustra module
def assign_pin_names(connector, altium_pins, parsed_list):
    for i in connector:
        # read pin number and make it integer
        # substracting one at the end is 
        # because of the list zero index
        inx = int(i["Connector"].split(".")[1])-1
        # first check if the pin is used otherwise 
        # exclude it from pin set
        if(altium_pins[inx]["Net Name"] != ""):
            i["Signal on module"] = altium_pins[inx]["Net Name"]
            parsed_list.append(i)

# assign pcb pin names to module pins and remove unconnected pins
new_connector_a = []; new_connector_b = []
assign_pin_names(connector_a, conn_a, new_connector_a)
assign_pin_names(connector_b, conn_b, new_connector_b)

# working pin set
pins_complete = new_connector_a + new_connector_b

# create dictionary sorting out pin vectors in groups
# dictionary key is name of the pin
groups = {}
for i in pins_complete:
    # if there is a number at the and of the pin name 
    # it means it's an array
    raw_name = i["Signal on module"].rsplit("_", 1)
    name = raw_name[0]
    # not all pins have number or "_" sign at the end of its name
    try:
        num = raw_name[1]
    except IndexError:
        num = "x"
    # setdefault is there because the list in dictionary 
    # doesn't have to exist yet
    groups.setdefault(name.lower() if str.isnumeric(num) 
            else i["Signal on module"].lower(), []).append(i)


# grouping of pins according to content in config file
new_groupping = {}
for i in config:  
    # find all occurences of names in the config file 
    pin_search = [n for g in groups if(i["pin"] in g) for n in groups[g]]
    if not pin_search:
        log.error("Couldn't find pin: \"{0}\" name in"
                  " the data set".format(i["pin"]))
        sys.exit(1) # close because of wrong config file
    # add custom settings from config file to the pin dictionary
    for p in pin_search:
        p.update(i)
    # exclude pins (they have to mentioned in config file)
    # if your pin is not excluded, probably there is some invisible
    # character in the config file (<CR> at the end of a line)
    if("exclude" in i["type"].lower()):
        log.warning("Pin Excluded: {0}".format(i["pin"]))
    else:
        new_groupping.setdefault(i["group"], []).append(pin_search)
    # remove all keys with the occurence of "i["pin"]" in groups
    groups = {k : v for k,v in groups.items() if(i["pin"] not in k)}

def get_set_property_standard(pin, name):
    return ("set_property PACKAGE_PIN {0} "
           "[get_ports {1}]\n".format(pin, name))

def get_set_property_vector(pin, name, num):
    return ("set_property PACKAGE_PIN {0} "
            "[get_ports {{{1}[{2}]}}]\n".format(pin, name, num))

def get_group_comment(group_name, iostandard):
    return ("# MCOI XU5 PINGROUP: {0}; "
            "IOSTANDARD: {1}".format(group_name.upper(), 
                                       iostandard.upper()))

def get_create_clock(name, pin, frequency):
    # multiplying by 1000 is because units are in "ns"
    return ("create_clock -period {0:.3f} -name "
            " {1} [get_ports {2}]\n".format((1000/frequency), name, pin))

def get_iostandard_stamp(iostandard, pin):
    return ("set_property IOSTANDARD {0} [get_ports {{{1}}}]\n\n".format(
           iostandard.upper(), pin)) if(iostandard != "") else ("")

def create_clock_stamp(clk_list):
    # pin key in dictionary is user identificator for pins of group
    stamp = "{0}".format(get_group_comment(clk_list[0]["pin"], 
             clk_list[0]["iostandard"]))

    for i in clk_list:
        name = i["Signal on module"].lower()
        user_name = i["pin"]
        pin = i["FPGA pin number"]
        iostandard = i["iostandard"]
        frequency = int(i["freq[Mhz]"])
        stamp = "{0}\n{1}{2}".format(stamp, 
                 get_set_property_standard(pin, name),
                 get_iostandard_stamp(iostandard, name))
    return "{0}\n{1}\n".format(stamp, get_create_clock(
            user_name, name, frequency))

def create_clock_constr(clk_list):
    stamp = ""
    for i in clk_list:
        stamp = "{0}{1}".format(stamp, create_clock_stamp(i))
    return stamp

def create_gpio_stamp_vector(gpio_list):
    stamp = ""
    # sort array using suffix number 
    gpio_list_sorted = sorted(gpio_list, key=lambda x: 
            int(x["Signal on module"].rsplit("_", 1)[1]))  
    for i in gpio_list_sorted:
        raw_name = i["Signal on module"].rsplit("_", 1)
        num = int(raw_name[1]) 
        user_name = raw_name[0].lower()
        pin = i["FPGA pin number"]
        iostandard = (i["iostandard"] if("iostandard" in i) 
                     else default_iostandard) 
        stamp = "{0}{1}".format(stamp, 
                 get_set_property_vector(pin, user_name, num))
    return "{0}{1}".format(stamp, get_iostandard_stamp(
           iostandard, user_name))

def create_gpio_stamp_standard(gpio_list):
    stamp = ""
    # gpio_list for one pin is one element list
    # therefore there is the zero index
    gpio = gpio_list[0]
    pin = gpio["FPGA pin number"]
    user_name = gpio["Signal on module"].lower()
    iostandard = (gpio["iostandard"] if("iostandard" in gpio) 
                 else default_iostandard) 
    return "{0}{1}".format(get_set_property_standard(pin, user_name),
            get_iostandard_stamp(iostandard, user_name))

#TODO generate gpios and groups
def create_gpios_constr(gpio_list):
        stamp = ""
        for i in gpio_list:
            stamp_type = (create_gpio_stamp_vector(i) if (len(i) > 1) 
                         else create_gpio_stamp_standard(i)) 
            stamp = "{0}{1}".format(stamp, stamp_type)
        return stamp

# create strings which will be written to constraints files
clock_constr = ""
gpios_constr = ""
for i in new_groupping:
    if(i == "clk"):
        clock_constr = "# CLOCK CONFIGURATION CONSTRAINTS"
        clock_constr = "{0}\n\n{1}".format(clock_constr,
                        create_clock_constr(new_groupping[i]))
    else:
        gpios_constr = "{0}\n# PIN GROUPPING: {1}".format(gpios_constr,
                       i.upper())
        gpios_constr = "{0}\n{1}".format(gpios_constr,
                       create_gpios_constr(new_groupping[i]))

for i in groups:
    gpios_constr = "{0}\n# PIN GROUPPING: {1}".format(gpios_constr,
                   i.upper())
    # somehowe the groups[i] has to be encapsulated into list
    # because the creat_gpios_constr takes list as an argument 
    gpios_constr = "{0}\n{1}".format(gpios_constr,
                   create_gpios_constr([groups[i]]))

# generate clock constraint file
file_path = os.path.join(destination_folder, 'constraints_mcoi_clk.xdc') 
with open(file_path, 'w') as f:
    f.write(clock_constr)
    f.close()
log.info("Generated file: constraints_mcoi_clk.xdc")

# generate gpio constraint file
file_path = os.path.join(destination_folder, 'constraints_mcoi_io.xdc') 
with open(file_path, 'w') as f:
    f.write(gpios_constr)
    f.close()
log.info("Generated file: constraints_mcoi_io.xdc")
