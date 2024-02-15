import CKRSPkg::*;
import types::*;
import constants::*;
import MCPkg::*;


// this works as a 'record' of clocks transported through the domains
interface t_clocks;
   timeunit 1ns;
   timeprecision 100ps;

   // 100MHz on-module oscillator
   ckrs_t ClkRs100MHz_ix;

   // MGT 120MHz coming from external PLL
   ckrs_t ClkRs120MHz_ix;

   // 40MHz derived from MGT Clock
   ckrs_t ClkRs40MHz_ix;

   // 50MHz as separate output from MGT pll - unrelated to all other
   ckrs_t ClkRsVar_ix;


   modport producer(
       output ClkRs100MHz_ix,
       output ClkRs120MHz_ix,
       output ClkRs40MHz_ix,
       output ClkRsVar_ix);

   modport consumer(
       input ClkRs100MHz_ix,
       input ClkRs120MHz_ix,
       input ClkRs40MHz_ix,
       input ClkRsVar_ix);

endinterface // clocks

interface t_motors;
   logic [1:16] pl_boost;
   logic [1:16] pl_dir;
   logic [1:16] pl_en;
   logic [1:16] pl_clk;
   logic [1:16] pl_pfail;
   logic [1:16] pl_sw_outa;
   logic [1:16] pl_sw_outb;


   modport producer(output pl_boost,
                    output pl_dir,
                    output pl_en,
                    output pl_clk,
                    input  pl_pfail,
                    input  pl_sw_outa,
                    input  pl_sw_outb);

endinterface // motors_x

interface t_rs485;
    logic rs485_pl_di;
    logic rs485_pl_ro;

   modport producer(
       output rs485_pl_di,
       input  rs485_pl_ro);

endinterface // rs485_x

interface t_diag;
    logic [6:0] led;
    logic [2:0] mled;
    logic [5:0] test;
    logic [3:0] pcbrev;
    logic fpga_supply_ok;

   modport producer(output led,
                    output mled,
                    output test,
                    input  pcbrev,
                    input  fpga_supply_ok);

endinterface // diag_x

interface t_buffer(input ckrs_t ClkRs_ix);
  logic en; 
  logic [31:0] dout;
  logic [31:0] din;
  logic [31:0] addr;
  logic [3:0] we;
  logic clk;
  logic rst;

  modport consumer(
      input  dout,
      output din,
      output we,
      output addr,
      output clk,
      output rst
      );

  modport producer(
      output dout,
      input  din,
      input  we,
      input  addr,
      input  clk,
      input  rst
      );

endinterface // buffer

interface t_register();
  logic [31:0] status;
  logic [31:0] control;
  logic [31:0] bidir;

  modport consumer(
      input status,
      output control,
      inout bidir
      );

  modport producer(
      output status,
      input control,
      inout bidir 
      );

endinterface

