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
// Copyright (c) February 2022 CERN

//-----------------------------------------------------------------------------
// @file MCOIXU5DIAGNOSTICS.SV
// @brief
// @author Petr Pacner  <pepacner@cern.ch>, CERN
// @date 20 February 2022
// @details
//
//
// @platform Altera Quartus
// @standard IEEE 1800-2012
//-----------------------------------------------------------------------------

import CKRSPkg::*;

module McoiXu5Diagnostics #(parameter address=7'h20,
                            parameter i2c_divider=10'h3ff)
   (input ckrs_t ClkRs_ix,
    output done,
    inout  i2c_sda_pl,
    inout  i2c_scl_pl);

   /*AUTOWIRE*/
   /*AUTOREGINPUT*/
   /*AUTOINOUTPARAM(*McoiXu5Diagnostics*)*/

   logic [7:0]  byte_from_i2c;
   logic [7:0]  byte_to_i2c;
   logic [15:0] data_to_reader;
   logic [7:0]  data_from_reader;
   
   // control and data signals
   // for i2c master
   logic        send_startb;
   logic        send_byte;
   logic        get_byte;
   logic        send_stopb;
   logic        send_ack;
   logic        rw;
   logic        rdy;
   logic        valid;
   logic        done_internal;
   logic        ack_recv;

   logic clk,
         rstp;

   always_comb begin
      clk = ClkRs_ix.clk;
      rstp = ClkRs_ix.reset;
   end


   I2cReader i2c_reader_i(.Done_i(done_internal),
                          .AckReceived_i(ack_recv),
                          .SendStartBit_o(send_startb),
                          .SendByte_o(send_byte),
                          .GetByte_o(get_byte),
                          .SendStopBit_o(send_stopb),
                          .AckToSend_o(send_ack),
                          .Byte_ib8(byte_from_i2c),
                          .Byte_ob8(byte_to_i2c),
                          .Data_i16b(data_to_reader),
                          .Data_o8b(data_from_reader),
                          .Rw_i(rw),
                          .Ready_o(rdy),
                          .Valid_i(valid),
                          .Dev_addr_i7b(address),
                          .rstp(rstp),
                          .clk(clk));

   si5338_configurer si5338_configurer_i(.Finished_o            (done),    
                                         .Rw_o                  (rw),          
                                         .Data_o16b             (data_to_reader),
                                         .Val_o                 (valid),         
                                         .Clk                   (clk),           
                                         .Rstp                  (rstp),          
                                         .Data_i8b              (data_from_reader), 
                                         .Rdy_i                 (rdy));        

   I2cMasterGeneric #(.g_CycleLenght(i2c_divider))
   i2c_master_generic_i(.Clk_ik         (clk),
                        .Rst_irq        (rstp),
                        .Scl_ioz        (i2c_scl_pl),
                        .Sda_ioz        (i2c_sda_pl),

                        .Byte_ob8       (byte_from_i2c),         
                        .AckReceived_o  (ack_recv),
                        .Done_o         (done_internal),                
                        .SendStartBit_ip(send_startb),       
                        .SendByte_ip    (send_byte),           
                        .GetByte_ip     (get_byte),            
                        .SendStopBit_ip (send_stopb),        
                        .Byte_ib8       (byte_to_i2c),         
                        .AckToSend_i    (send_ack));          

endmodule // McoiXu5Diagnostics
