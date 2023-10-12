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

interface t_motors_structured;
   motorsStatuses_t motorsStatuses;
   motorsControls_t motorsControls;

   modport producer(output motorsStatuses,
       input motorsControls);

   modport consumer(input motorsStatuses,
       output motorsControls);
endinterface // t_motors_structured


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

interface t_diag;
    logic [6:0] led;
    logic [2:0] mled;
    logic [5:0] test;
    logic [3:0] pcbrev;
    logic fpga_supply_ok;

   modport producer(output led,
                    // output mled,
                    output test,
                    input  pcbrev,
                    input  fpga_supply_ok);

   modport consumer (input  led,
                     // input  mled,
                     input  test,
                     output pcbrev,
                     output fpga_supply_ok);
endinterface // diag_x

interface t_i2c;
   wire sda;
   wire scl;

   // tri-state i2c - write register (during compilation this is
   // synthesized away as constant signal)
   logic sda_reg = 'z;
   assign sda = sda_reg;


   // debugging - will be synthesized away
   i2c_state_t state;
   logic [7:0] address_received_b8;
   logic [7:0] register_address_received_b8;


   // in multimaster environment SCL is inout as well
   modport endpoint(inout scl, inout sda);

   // bidir driving: when reading we can directly use read from sda,
   // but when driving the net we have to set value to sda_reg, which
   // resolves to sda being driven by resolver function
   modport debugger(
       inout scl,
       input  sda,
       output sda_reg,
       output state,
       output address_received_b8,
       output register_address_received_b8);

endinterface // t_i2c
