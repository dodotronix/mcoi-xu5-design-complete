
interface display_x;
   // these signals handle communication with led drivers:
   logic 		  latch;
   logic 		  blank;
   logic [2:0]    csel;
   logic 		  sclk;
   logic 		  sin;

   modport producer(output latch,
                    output blank,
                    output csel,
                    output sclk,
                    output sin);

   modport consumer(input latch,
                    input blank,
                    input csel,
                    input sclk,
                    input sin);
endinterface // display_x

interface motors_x;
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

   modport consumer(input pl_boost,
                    input  pl_dir,
                    input  pl_en,
                    input  pl_clk,
                    output pl_pfail,
                    output pl_sw_outa,
                    output pl_sw_outb);
endinterface // motors_x

interface gbt_x;
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

endinterface // gbt_x

interface diag_x;
   logic [6:0] led;
   logic [5:0] test;
   logic [3:0] pcbrev;
   logic       fpga_supply_ok;

   modport producer(output led,
                    output test,
                    input  pcbrev,
                    input  fpga_supply_ok);

   modport consumer (input  led,
                     input  test,
                     output pcbrev,
                     output fpga_supply_ok);

   endinterface // diag_x
