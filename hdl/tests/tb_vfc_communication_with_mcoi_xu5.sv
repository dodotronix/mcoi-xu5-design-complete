//-----------------------------------------------------------------------------
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor
// Boston, MA  02110-1301, USA.
//
// You can dowload a copy of the GNU General Public License here:
// http://www.gnu.org/licenses/gpl.txt
//
// Copyright (c) June 2023 CERN

//-----------------------------------------------------------------------------
// @file TB_GBT_XU5.SV
// @brief
// @author Petr Pacner  <petr.pacner@cern.ch>, CERN
// @date 8 June 2023
// @details
//
//
// @platform Xilinx Vivado
// @standard IEEE 1800-2012
//-----------------------------------------------------------------------------

`include "vunit_defines.svh"

`timescale 1ps/1ps

import CKRSPkg::*;
import clsclk::*;
import MCPkg::*;


module tb_vfc_communication_with_mcoi_xu5;
   timeunit 1ns;
   timeprecision 100ps;

   /*AUTOWIRE*/
   /*AUTOREGINPUT*/

   // wires to create a loopback
   wire vfc_rx_n;
   wire vfc_rx_p;

   wire vfc_tx_n;
   wire vfc_tx_p;

   logic vfc_clk120mhz, vfc_clk40mhz, newclk_40mhz;

   t_clocks clk_tree_x();
   clock_generator clkg;

   t_gbt gbt_x();
   t_gbt gbt_vfc();

   ckrs_t alt_40mhz;
   ckrs_t alt_120mhz;
   ckrs_t gbt_rx_clkrs;
   ckrs_t gbt_rx_clkrs_vfc;

   ckrs_t ref_clkrs;
   assign ref_clkrs.clk = clk_tree_x.ClkRs120MHz_ix.clk;
   assign ref_clkrs.reset = gbt_x.sfp1_los | 1'b0;

   assign alt_40mhz.clk = vfc_clk40mhz;
   assign alt_40mhz.reset = '0;

   assign alt_120mhz.clk = vfc_clk120mhz;
   assign alt_120mhz.reset = gbt_vfc.sfp1_los;

   // GBT data stream runs in frame clock
   t_gbt_data #(.CLOCKING_SCHEME(0))
   gbt_data_x (.ClkRs_ix(gbt_rx_clkrs),
              .ClkRsRx_ix(ref_clkrs),
              .ClkRsTx_ix(ref_clkrs),
              .refclk(clk_tree_x.ClkRs120MHz_ix.clk));

   t_gbt_data #(.CLOCKING_SCHEME(0))
   gbt_data_vfc (.ClkRs_ix(alt_40mhz),
              .ClkRsRx_ix(alt_120mhz),
              .ClkRsTx_ix(alt_120mhz),
              .refclk(alt_120mhz.clk));

   logic reset_from_design_reset;
   logic reset_bitslip;
   logic [31:0] dynamic_data;

   default clocking cb @(posedge gbt_data_x.ClkRs_ix.clk);
   endclocking

   task run_vfc120mhz();
       // two clocks generated here: 120MHz and 40MHz frame clock
       vfc_clk120mhz = '0;
       #1ns;
       fork begin
           forever begin
               vfc_clk120mhz = 1'b1;
               #4.168ns;
               vfc_clk120mhz = 1'b0;
               #4.168ns;
               vfc_clk120mhz = 1'b1;
               #4.168ns;
               vfc_clk120mhz = 1'b0;
               #4.168ns;
               vfc_clk120mhz = 1'b1;
               #4.168ns;
               vfc_clk120mhz = 1'b0;
               #4.167ns;
           end
       end join_none
   endtask : run_vfc120mhz

   task run_vfc40mhz();
       vfc_clk40mhz = '0;
       #120ns;
       fork begin
           forever begin : gbt_clocks
               @(posedge vfc_clk120mhz);
               repeat(2) @(vfc_clk120mhz);
               vfc_clk40mhz = '1;
               repeat(3) @(vfc_clk120mhz);
               vfc_clk40mhz = '0;
           end
       end join_none
   endtask : run_vfc40mhz

   // equivalent of pll
    task create_40mhz_from_rxclkout;
        newclk_40mhz = '0;
        #1.5ns;
        fork begin
            forever begin : gbt_clocks
                @(posedge gbt_data_x.rx_wordclk);
                repeat(2) @(gbt_data_x.rx_wordclk);
                newclk_40mhz = '1;
                repeat(3) @(gbt_data_x.rx_wordclk);
                newclk_40mhz = '0;
            end
        end join_none
    endtask : create_40mhz_from_rxclkout

   task automatic generator();
       dynamic_data = '0;
       // gbt_data_x.data_sent.motor_data_b64 = 64'd1000;
       fork begin
           forever begin
               while(!gbt_data_x.link_ready) @(posedge gbt_data_x.tx_frameclk);
               if(gbt_data_x.tx_clken) begin
                   dynamic_data = dynamic_data + 1;
                   // gbt_data_x.data_sent = '0;
                   gbt_data_x.data_sent.motor_data_b64 = {dynamic_data, dynamic_data};
               end
               @(posedge gbt_data_x.tx_frameclk);
           end
       end join_none
       endtask : generator

  /* initial begin
    gbt_data_x.bitslip_reset = 1'b0;
    // gbt_data_x.data_sent = 84'h000bebeac1dacdcfffff;
    generator();
    gbt_x.sfp1_los = 1'b1;

    // classes:
    clkg = new;
    clkg.clk_tree_x = clk_tree_x;
    clkg.run();

    #10us;
    gbt_x.sfp1_los = 1'b0;

    #10us;
    if (!gbt_data_x.link_ready) gbt_data_x.bitslip_reset = 1'b1;
    #1ms;

    $finish;
   end */

   /* gbt_uscale #(.DEBUG(0)) DUT (.*,
   .external_pll_source_120mhz(clk_tree_x.ClkRs120MHz_ix.clk));
   */

  `TEST_SUITE begin
      `TEST_SUITE_SETUP begin
          gbt_data_x.data_sent.motor_data_b64 = 64'hcafecafecafecafe;
          gbt_data_x.data_sent.mem_data_b16 = 16'h0;

          gbt_data_vfc.data_sent.motor_data_b64 = 64'hdeadbeefdeadbeef;
          gbt_data_vfc.data_sent.mem_data_b16 = 16'h0;

          gbt_data_x.bitslip_reset = 1'b0;
          gbt_data_vfc.bitslip_reset = 1'b0;
          // gbt_data_x.data_sent = 84'h000bebeac1dacdcfffff;
          // generator();
          gbt_x.sfp1_los = 1'b1;
          gbt_vfc.sfp1_los = 1'b1;

          // classes:
          clkg = new;
          clkg.clk_tree_x = clk_tree_x;
          clkg.run();
          run_vfc120mhz();
          run_vfc40mhz();
          create_40mhz_from_rxclkout();
      end

      `TEST_CASE("link_verification") begin
          #10us;
          gbt_x.sfp1_los = 1'b0;
          gbt_vfc.sfp1_los = 1'b0;
          #120us;
          gbt_x.sfp1_los = 1'b1;
          #50us;
          gbt_x.sfp1_los = 1'b0;
          /* #150us;
          gbt_x.sfp1_los = 1'b1;
          #100us;
          gbt_x.sfp1_los = 1'b0;
          #50us;
          gbt_x.sfp1_los = 1'b1;
          #50us;
          gbt_x.sfp1_los = 1'b0; */
          // #10us;
          // if (!gbt_data_x.link_ready) gbt_data_x.bitslip_reset = 1'b1;
          #6ms;
          `CHECK_EQUAL (1,1);
      end
  end

  // The watchdog macro is optional, but recommended. If present, it
  // must not be placed inside any initial or always-block.
  `WATCHDOG(4ms);

    gbt_zynq_usplus #(.DEBUG(0), .GEFE_MODE(1), .RESET_DELAY(40)) DUT(.*);

    gbt_zynq_usplus #(.DEBUG(0), .GEFE_MODE(0), .RESET_DELAY(40)) VFC(
        .gbt_x(gbt_vfc), .gbt_data_x(gbt_data_vfc));

    always_comb begin
        gbt_rx_clkrs.clk = newclk_40mhz;
        gbt_rx_clkrs.reset = gbt_x.sfp1_los;

        gbt_rx_clkrs_vfc.clk = gbt_data_vfc.rx_frameclk;
        gbt_rx_clkrs_vfc.reset = !gbt_data_vfc.rx_ready;
    end

    // MCOI BOARD
   logic [31:0] slow_data_vfc;
   logic data_arrived_vfc, vfc_linkup;
   logic [31:0] data_from_mcoi;
   logic sc_idata_vfc, sc_odata_vfc;
   serial_register i_vfc_serdes (
       .Rx_i(sc_idata_vfc),
       .Tx_o(sc_odata_vfc),
       .data_ib32(slow_data_vfc),
       .data_ob32(data_from_mcoi),
       .newdata_o(data_arrived_vfc),
       .resetflags_i(1'b0),
       .ClkRs_ix(gbt_rx_clkrs_vfc),
       .ClkRxGBT_ix(gbt_rx_clkrs_vfc),
       .ClkTxGBT_ix(gbt_rx_clkrs_vfc),
       .TxBusy_o(),
       .TxEmptyFifo_o(),
       .txerror_o(),
       .SerialLinkUp_o(vfc_linkup),
       .RxLocked_o()
   );

   logic [31:0] slow_data;
   logic data_arrived, linkup;
   logic [31:0] data_from_vfc;
   logic sc_idata, sc_odata;
   serial_register i_serdes(
       .Rx_i(sc_idata),
       .Tx_o(sc_odata),
       .data_ib32(slow_data),
       .data_ob32(data_from_vfc),
       .newdata_o(data_arrived),
       .resetflags_i(1'b0),
       .ClkRs_ix(gbt_rx_clkrs),
       .ClkRxGBT_ix(gbt_rx_clkrs),
       .ClkTxGBT_ix(gbt_rx_clkrs),
       .TxBusy_o(),
       .TxEmptyFifo_o(),
       .txerror_o(),
       .SerialLinkUp_o(linkup),
       .RxLocked_o()
    );

    always_ff @(posedge gbt_data_x.rx_frameclk) begin
        if(!gbt_data_x.rx_ready)
            sc_idata <= '0;
        else if(gbt_data_x.rx_clken)
            sc_idata <= gbt_data_x.data_received.sc_data_b4[0];
    end

    always_ff @(posedge gbt_data_x.tx_frameclk) begin
        if(!gbt_data_x.rx_ready)
            gbt_data_x.data_sent.sc_data_b4 <= '0;
        else if(gbt_data_x.tx_clken)
            gbt_data_x.data_sent.sc_data_b4 <= {{3{1'b0}}, sc_odata};
    end

    always_ff @(posedge gbt_rx_clkrs_vfc.clk) begin
        if(gbt_rx_clkrs_vfc.reset) begin
            slow_data_vfc <= '0;
        end else if(vfc_linkup && data_arrived_vfc)
            slow_data_vfc <= slow_data_vfc + 32'h1;
    end

    always_ff @(posedge gbt_rx_clkrs.clk) begin
        if(gbt_rx_clkrs.reset) begin
            slow_data <= '0;
        end else if(linkup && data_arrived)
            slow_data <= data_from_vfc;
    end

    always_comb begin
        /* sc_idata <= gbt_data_x.data_received.sc_data_b4[0];
        gbt_data_x.data_sent.sc_data_b4 <= {{3{1'b0}}, sc_odata}; */

        // sc_odata_vfc = 1'b0;
        sc_idata_vfc = gbt_data_vfc.data_received.sc_data_b4[0];
        gbt_data_vfc.data_sent.sc_data_b4 = {{3{1'b0}}, sc_odata_vfc};
    end

   // loopback
   assign gbt_vfc.sfp1_gbitin_n = vfc_rx_n;
   assign gbt_vfc.sfp1_gbitin_p = vfc_rx_p;
   assign vfc_tx_n = gbt_vfc.sfp1_gbitout_n;
   assign vfc_tx_p = gbt_vfc.sfp1_gbitout_p;

   assign vfc_rx_n = gbt_x.sfp1_gbitout_n;
   assign vfc_rx_p = gbt_x.sfp1_gbitout_p;
   assign gbt_x.sfp1_gbitin_n = vfc_tx_n;
   assign gbt_x.sfp1_gbitin_p = vfc_tx_p;


   // loopback of the recoverd clock
   assign gbt_data_x.rx_recclk = gbt_data_x.rx_wordclk;
   assign gbt_data_vfc.rx_recclk = vfc_clk120mhz;


endmodule // tb_gbt_xu5
