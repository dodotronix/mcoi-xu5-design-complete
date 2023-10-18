//============================================================================================\\
//##################################   Module Information   ##################################\\
//============================================================================================\\
//                                                                                         
// Company: CERN (BE-BI) 
//                                                        
// File Name: GefeSystem.v  
//
// File versions history:
//
//       DATE          VERSION      AUTHOR             DESCRIPTION
//     - 24/11/2016    1.7          M. Barros Marin    - Removed unused Elinks Clocks and moved to Application
//                                                     - Removed TX registers for compensating DDR delay
//     - 09/03/2016    1.6          M. Barros Marin    Added #1 delay for simulation
//     - 03/03/2016    1.5          M. Barros Marin    Replaced DDR_IO by DDR_I & cosmetic modifications         
//     - 23/10/2015    1.0          M. Barros Marin    First .v module definition
//
// Language: Verilog 2005                                                              
//                                                                                                   
// Targeted device:
//
//     - Vendor: Microsemi 
//     - Model:  ProASIC3E(A3PE3000)/ProASIC3L(A3PE3000L) - 896 FBGA
//
// Description:
//
//     Generic HDL "system" module for the GBT-based Expandable Front-End (GEFE),
//     the standard rad-hard digital board for CERN BE-BI applications.                                                                                                   
//
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! IMPORTANT !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// !!                                                                                        !!
// !!  It is recommended to do not modify the HDL code placed within this "system" module.   !!  
// !!                                                                                        !!
// !!      The user's HDL code should be placed within the "user" module (gefe_user.v).      !!
// !!                                                                                        !!
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  
//                                                                                                   
//============================================================================================\\
//############################################################################################\\
//============================================================================================\\

`timescale 1ns/100ps

module GefeSystem
//========================================  I/O ports  =======================================\\    
(
    //==== Resets Scheme ====\\
    
    // General reset:
    // Comment: See Microsemi application note AC380.
    inout          FpgaReset_ira,
    
    //==== GBTx ====\\
    
    // Elinks:
    // Clocks:
    input          GbtxElinksDclkCg_ikp, 
    input          GbtxElinksDclkCg_ikn, 
    
    // Comment: In GEFE, the GbtxElinksDio pins are only used as INPUTs.
    input  [15: 0] GbtxElinksDio_ib16p,
    input  [15: 0] GbtxElinksDio_ib16n, 
    input  [39:16] GbtxElinksDout_ib24p,
    input  [39:16] GbtxElinksDout_ib24n,
    output [39: 0] GbtxElinksDin_ob40p, 
    output [39: 0] GbtxElinksDin_ob40n, 
    
    // Slow Control (SC) Elink:
    input          GbtxElinksScOut_ip,
    input          GbtxElinksScOut_in,    
    output         GbtxElinksScIn_op,
    output         GbtxElinksScIn_on,
        
    //==== Miscellaneous ====\\
    
    // Crystal oscillator (25MHz):
    // Comment: Osc25Mhz is connected to the "Chip global" (Cg) clock network.
    input          Osc25Mhz_ik,        
    
    //==== Application Module Interface ====\\
    
    // Resets scheme:
    // Comment: See Microsemi application note AC380.
    output         GeneralReset_oran,
    
    // Miscellaneous:
    // Comment: - Osc25MhzCg is connected to the "Chip global" (Cg) clock network.
    //          - ClkFeedbackICg is connected to the "Chip global" (Cg) clock network.
    output         Osc25MhzCg_ok,  
    
    // GBTx:
    output         GbtxElinksDclkCg_ok,
    //--
    output [79: 0] DataFromGbtx_ob80,  
    input  [79: 0] DataToGbtx_ib80,       
    output [ 1: 0] DataFromGbtxSc_ob2,
    input  [ 1: 0] DataToGbtxSc_ib2    
);

//======================================  Declarations  ======================================\\    

//==== Variables ====\\

genvar         i;

//==== Wires & Regs ====\\

// Resets scheme:
wire           PorPpr_ra;
wire   [ 0: 1] PorPpr_rand2;           

// GBTx:
wire   [15: 0] GbtxElinksDio_b16;
wire   [39:16] GbtxElinksDout_b24;
wire   [39: 0] GbtxElinksDin_b40; 
wire           GbtxElinksScOut; 
wire           GbtxElinksScIn;

//=======================================  User Logic  =======================================\\     

//==== Resets Scheme ====\\

// General reset:
// Comment: See Microsemi application note AC380.
BIBUF_LVCMOS25 i_PorPpr_buf (
    .PAD (FpgaReset_ira),
    .D   (1'b0),
    .E   (1'b1),
    .Y   (PorPpr_ra));
    
DFN1C1 i_PorPpr_d1 (
    .D   (1'b1),
    .CLK (Osc25MhzCg_ok),
    .CLR (PorPpr_ra),
    .Q   (PorPpr_rand2[0]));
    
DFN1C1 i_PorPpr_d2 (
    .D   (PorPpr_rand2[0]),
    .CLK (Osc25MhzCg_ok),
    .CLR (PorPpr_ra),
    .Q   (PorPpr_rand2[1])); 
    
assign GeneralReset_oran = PorPpr_rand2[1];

//==== GBTx ====\\

// GBTx Elinks clock:
CLKBUF_LVDS i_GbtxElinksDclkCg_buf (
    .PADP (GbtxElinksDclkCg_ikp),
    .PADN (GbtxElinksDclkCg_ikn),
    .Y    (GbtxElinksDclkCg_ok));

// GBTx Elinks:

generate for (i=0; i<16; i=i+1) begin: GbtxElinksDio_gen
    INBUF_LVDS i_GbtxElinksDio_buf (
        .PADP (GbtxElinksDio_ib16p[i]),
        .PADN (GbtxElinksDio_ib16n[i]),
        .Y    (GbtxElinksDio_b16  [i]));
    //-- 
    DDR_REG i_GbtxElinksDio_ddr (
        .D   (GbtxElinksDio_b16   [i]),
        .CLK (GbtxElinksDclkCg_ok),
        .CLR (1'b0),
        .QR  (DataFromGbtx_ob80   [(i*2)+1]),
        .QF  (DataFromGbtx_ob80   [ i*2]));
end endgenerate

generate for (i=0; i<24; i=i+1) begin: GbtxElinksDout_gen       
    INBUF_LVDS i_GbtxElinksDout_buf (
        .PADP (GbtxElinksDout_ib24p[16+i]),
        .PADN (GbtxElinksDout_ib24n[16+i]),
        .Y    (GbtxElinksDout_b24  [16+i]));
    //-- 
    DDR_REG i_GbtxElinksDout_ddr (
        .D   (GbtxElinksDout_b24   [16+i]),
        .CLK (GbtxElinksDclkCg_ok),
        .CLR (1'b0),
        .QR  (DataFromGbtx_ob80    [32+((i*2)+1)]),
        .QF  (DataFromGbtx_ob80    [32+ (i*2)]));
end endgenerate

generate for (i=0; i<40; i=i+1) begin: GbtxElinksDin_gen
    DDR_OUT i_GbtxElinksDin_ddr (
        .DR   (DataToGbtx_ib80    [(i*2)+1]),
        .DF   (DataToGbtx_ib80    [ i*2]),
        .CLK  (GbtxElinksDclkCg_ok), 
        .CLR  (1'b0),
        .Q    (GbtxElinksDin_b40  [i]));
    //--
    OUTBUF_LVDS i_GbtxElinksDin_buf (
        .D    (GbtxElinksDin_b40  [i]),
        .PADP (GbtxElinksDin_ob40p[i]),
        .PADN (GbtxElinksDin_ob40n[i]));
end endgenerate      

// GBTx SC Elinks:
INBUF_LVDS i_GbtxElinksScOut_buf (
    .PADP (GbtxElinksScOut_ip),
    .PADN (GbtxElinksScOut_in),
    .Y    (GbtxElinksScOut));
//-- 
DDR_REG i_GbtxElinksScOut_ddr (
    .D   (GbtxElinksScOut),
    .CLK (GbtxElinksDclkCg_ok),
    .CLR (1'b0),
    .QR  (DataFromGbtxSc_ob2[1]),
    .QF  (DataFromGbtxSc_ob2[0]));
    
DDR_OUT i_GbtxElinksScIn_ddr (
    .DR  (DataToGbtxSc_ib2[1]),
    .DF  (DataToGbtxSc_ib2[0]),
    .CLK (GbtxElinksDclkCg_ok), 
    .CLR (1'b0),
    .Q   (GbtxElinksScIn));
//--  
OUTBUF_LVDS i_GbtxElinksScIn_buf (
    .D    (GbtxElinksScIn),
    .PADP (GbtxElinksScIn_op),
    .PADN (GbtxElinksScIn_on));

//==== Miscellaneous ====\\

// Clocking scheme:
CLKBUF_LVCMOS25 i_Osc25Mhz_buf (
    .PAD (Osc25Mhz_ik),
    .Y   (Osc25MhzCg_ok));
   
endmodule