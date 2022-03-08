#!/usr/bin/python
#
# description :
# mask - 0x00 disable the &~ operation on the input of the shifting
# register in digital design, so the data will be saved as they came
# in case of mask 0xff the first reading will be ignored because of
# the zero value in shifting register in other words the value from
# shift register have no effect in the final formula with logic OR [line 116]
# when the data are loaded on output



from optparse import OptionParser
import re
import os.path as path
import logging
import sys
from pyloggingformatter.logging_formatter import color_formatter

p = re.compile(r'''{\s*(?P<reg>\d*),
                   (0x|\s*)(?P<val>[\d\w]*),
                   (0x|\s*)(?P<mask>[\d\w]*).*''',
                   re.DOTALL | re.VERBOSE | re.MULTILINE)

def parse_file(regs):
    with open(regs, 'r+') as regs:
            return [re.match(p, line).groupdict()
                    for line in regs if line[0] == '{']

def copy_register_stamp(reg0, reg1, mask):
    out = []
    out.append(read_reg(reg0, 0x00))
    out.append(read_reg(reg1, 0x00))
    out.append(0x0*(2**16) + mask*(2**8) + reg1)
    return out

def set_register_stamp(reg, mask):
    out = []
    out.append(read_reg(reg, 0x00))
    out.append(0x1*(2**16) + mask*(2**8) + reg)
    return out

def combined_register_stamp(reg, mask, val):
    """
    this needs a bit of description:
    the mask 0xff clears last byte in shifting register in pl part
    (PllConfigProcessor.sv [line 124]) -> in the next state [WRIT] is
    therefore deployed just the second argument for the data on the
    line [line 116]so at the end the last value is written to the end
    point device, this is how we can create just writing function
    without defining a new flag in data stream and additional
    digital part
    """
    out = []
    if(mask == 0xff):
        out.append(write_reg(reg, val))
    else:
        out.append(read_reg(reg, 0x00))
        out.append(0x7*(2**16) + (val & mask)*(2**8) + mask)
    return out

def read_reg(reg, mask):
    return 0x3*(2**16) + mask*(2**8) + reg

def write_reg(reg, mask):
    return 0x4*(2**16) + mask*(2**8) + reg

def validate_register_stamp(reg, mask, value):
    out = []
    out.append(read_reg(reg, 0x00))
    out.append(0x5*(2**16) + value*(2**8) + mask)
    return out

def wait_stamp(time, design_freq):
    time_int = round(time*design_freq)
    if(time_int > 2**16):
        log.error("Time value to high,"
                  "Max time allowed Time is {0} s".format((2**16)/design_freq))
    return 0x6*(2**16) + time_int

def clr_register_stamp(reg, mask):
    out = []
    out.append(read_reg(reg, 0x00))
    out.append(0x2*(2**16) + mask*(2**8) + reg)
    return out

def stop_stamp():
    return read_reg(0x00, 0xed)

def create_rom_content(source, depth, design_freq):
    final = []
    config = parse_file(source)

    final.extend(set_register_stamp(230, 0x10))
    final.extend(set_register_stamp(241, 0x80))

    for c in config:
        final.extend(combined_register_stamp(int(c['reg'], 10),
            int(c['mask'], 16), int(c['val'], 16)))

    final.extend(validate_register_stamp(218, 0x04, 0x00))

    final.extend(clr_register_stamp(49, 0x80))
    final.extend(set_register_stamp(246, 0x02))

    # wait for 25 ms
    final.append(wait_stamp(0.008, design_freq))
    final.append(wait_stamp(0.009, design_freq))
    final.append(wait_stamp(0.008, design_freq))

    final.extend(clr_register_stamp(241, 0x80))
    final.extend(set_register_stamp(241, 0x65))

    final.extend(validate_register_stamp(218, 0x15, 0x00))

    final.extend(copy_register_stamp(237, 47, 0x03))
    final.extend(copy_register_stamp(236, 46, 0xff))
    final.extend(copy_register_stamp(235, 45, 0xff))

    final.extend(set_register_stamp(47, 0x14))
    final.extend(set_register_stamp(49, 0x80))

    # if using spreaded spectrum
    # final.append(set_register_stamp(226, 0x02))
    # final.append(wait_stamp(10)) #TODO this value is just for simulation
    # final.append(clr_register_stamp(226, 0x02))

    #TODO this value is just for simulation
    final.extend(clr_register_stamp(230, 0x10))
    final.append(stop_stamp())

    for i in range(0, depth-len(final)-1):
        final.append(0)
    return final

def create_coe_structure(num_list):
    head = ('memory_initialization_radix={0};\n'
            'memory_initialization_vector='.format(16))

    # structure = head
    structure = ''
    for i in num_list:
        structure = ('{0},\n'
                     '{1:x}'.format(structure, i))
    return '{0}{1};'.format(head, structure[1:])

def generate_coe_file(coe_structure, destination):
    with open(destination, 'w+') as file_coe:
        file_coe.write(coe_structure)

def generate_memory_instance(num_list, fname):
    logging.info("Generating PLL ROM instance in %s" % (fname))
    mname = path.split(fname)[-1].split(".")[0]
    logging.info("Module name: %s" % (mname))
    # FORMAT COMES FROM Vivado UG901, page 164
    with open(fname, "wt") as f:

        # prepare case style:
        olist = []
        for addr, data in enumerate(num_list):
            if data != 0:
                tst = "          10'(%d) : data <= 19'h%.5X;" % (addr,data)
                olist.append(tst)
                logging.debug(tst)

        fdata = """
// autogenerated by gen_init_coe.py
module %s

  (input logic clk,
   input logic [9:0]   addr,
   output logic [18:0] dout
   );

   (*rom_style = "block" *) reg [18:0] data;

   always_ff @(posedge clk)
     unique case (addr)
%s
       default:
	 data <= '0;
     endcase // unique case (addr)

   assign dout = data;
endmodule // %s
""" % (mname,
       '\n'.join(olist),
       mname)


        logging.info(fdata)
        f.write(fdata)

def main():
    usage="""Usage: %prog [options] SOURCE

This command generates COE file, which can be used to fill the ROM instance
generated by Vivado. In addition this script generates direct systemverilog
code which can be used as code GENERATING FROM SOURCES vivado ROM.

SOURCE is a header file generated by SiLabs software
    """
    parser = OptionParser(usage=usage)
    parser.add_option("-c", "--coe-name", action="store", type="str", dest="coe_name",
                      default='pll_rom.coe', help="Path+filename to export COE file [default: %default]")
    parser.add_option("-s", "--verilog-name", action="store", type="str", dest="verilog_name",
                      default='pll_rom.sv', help="Path+filename to export SV file [default: %default]")
    parser.add_option("-v", "--verbose-level", action="store", type="string", dest="verbose",
                      default="INFO", help="Set verbosity level (in order\
                      of verbosity: CRITICAL, ERROR, WARNING, INFO, DEBUG) [default: %default]")

    (options, args) = parser.parse_args()

    # define logging verbosity here
    logging.basicConfig(level=getattr(logging, options.verbose.upper()))
    logging.getLogger().handlers[0].setFormatter(color_formatter)

    try:
        design_freq = 7e6
        logging.info("Generating ROM content")
        f = create_rom_content(args[0], 2**10, design_freq)
        coe = create_coe_structure(f)
        logging.info("Generating %s" % options.verilog_name)
        generate_memory_instance(f, options.verilog_name)

        logging.info("Generating %s" % options.coe_name)
        generate_coe_file(coe, options.coe_name)
    except IndexError:
        parser.print_help()
        sys.exit(-1)

# catches sigint and properly terminates thread

if __name__ == '__main__':
    main()
