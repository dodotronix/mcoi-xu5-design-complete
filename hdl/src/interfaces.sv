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

   // MGT 120MHz coming from external PLL and 40MHz derived from MGT
   ckrs_t ClkRs120MHzMGMT_ix;
   ckrs_t ClkRs40MHzMGMT_ix;

   // 50MHz as separate output from MGT pll - unrelated to all other
   ckrs_t ClkRsVar_ix;


   modport producer(output ClkRs100MHz_ix,
		    output ClkRs120MHzMGMT_ix,
		    output ClkRs40MHzMGMT_ix,
		    output ClkRsVar_ix);

   modport consumer(input ClkRs100MHz_ix,
		    input ClkRs120MHzMGMT_ix,
		    input ClkRs40MHzMGMT_ix,
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

   motorsStatuses_t motorsStatuses;
   motorsControls_t motorsControls;

   generate //motor diagnostics
      for(genvar i=1; i<17; ++i) begin: motor_i
	 always_comb begin
	    //overheat signal
	    motorsStatuses[i].OH_i = 1'b0;
	    //motor fail signal
	    motorsStatuses[i].StepPFail_i = pl_pfail[i];
	    //motor feedback switches
	    motorsStatuses[i].RawSwitches_b2[0] = pl_sw_outa[i];
	    motorsStatuses[i].RawSwitches_b2[1] = pl_sw_outb[i];
	    pl_boost[i] = motorsControls[i].StepBOOST_o;
	    pl_dir[i] = motorsControls[i].StepDIR_o;
	    pl_en[i] = motorsControls[i].StepDeactivate_o;
	    pl_clk[i] = motorsControls[i].StepOutP_o;
	 end
      end
   endgenerate


   modport producer(output pl_boost,
                    output pl_dir,
                    output pl_en,
                    output pl_clk,
                    input  pl_pfail,
                    input  pl_sw_outa,
                    input  pl_sw_outb);

   modport consumer(input motorsStatuses,
		    output motorsControls);
endinterface // motors_x

interface t_gbt;
   logic sfp1_gbitin_p;
   logic sfp1_gbitin_n;
   logic sfp1_los;
   logic sfp1_gbitout_p;
   logic sfp1_gbitout_n;
   logic sfp1_rateselect;
   logic sfp1_txdisable;

   modport producer(input  sfp1_gbitin_p,
                    input  sfp1_gbitin_n,
                    input  sfp1_los,
                    output sfp1_gbitout_p,
                    output sfp1_gbitout_n,
                    output sfp1_rateselect,
                    output sfp1_txdisable);

   modport consumer(output sfp1_gbitin_p,
                    output sfp1_gbitin_n,
                    output sfp1_los,
                    input sfp1_gbitout_p,
                    input sfp1_gbitout_n,
                    input sfp1_rateselect,
                    input sfp1_txdisable);

   modport status(input sfp1_los,
		  input sfp1_txdisable,
		  input sfp1_rateselect);

endinterface // gbt_x

interface t_diag;
   logic [6:0] 		  led;
   logic [5:0] 		  test;
   logic [3:0] 		  pcbrev;
   logic 		  fpga_supply_ok;

   modport producer(output led,
                    output test,
                    input  pcbrev,
                    input  fpga_supply_ok);

   modport consumer (input  led,
                     input  test,
                     output pcbrev,
                     output fpga_supply_ok);
endinterface // diag_x


interface t_gbt_data (input ckrs_t ClkRs_ix);
   t_sfp_stream data_received;
   t_sfp_stream data_sent;

   // testbench port:
   modport producer (input ClkRs_ix, output data_received, input data_sent);
   // ordinary consumer
   modport consumer (input ClkRs_ix, input data_received, output data_sent);
endinterface // t_gbt_data


interface t_i2c;
   wire 		    sda;
   wire 		    scl;

   // tri-state i2c - write register (during compilation this is
   // synthesized away as constant signal)
   logic 		    sda_reg = 'z;
   assign sda = sda_reg;


   // debugging - will be synthesized away
   i2c_state_t state;
   logic [7:0] 		    address_received_b8;
   logic [7:0] 		    register_address_received_b8;



   // in multimaster environment SCL is inout as well
   modport endpoint(inout scl,
		    inout sda);

   // bidir driving: when reading we can directly use read from sda,
   // but when driving the net we have to set value to sda_reg, which
   // resolves to sda being driven by resolver function
   modport debugger(inout scl,
		    input  sda,
		    output sda_reg,
		    output state,
		    output address_received_b8,
		    output register_address_received_b8);

endinterface // t_i2c
