-------------------------------------------------------------------------------
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor
-- Boston, MA  02110-1301, USA.
--
-- You can dowload a copy of the GNU General Public License here:
-- http://www.gnu.org/licenses/gpl.txt
--
-- Copyright (c) 2022 CERN

-------------------------------------------------------------------------------
--! @file gbt_bank_dummy.vhd
--! @brief DUMMY PLACEHOLDER FOR GBT_BANK
--! @details
--! We need placeholder not doing anything, because GBT_BANK is not compilable
--! under modelsim (even 2008!). So I have stripped the core and left just
--! declaration as the GBT won't be simulated anyways - we will simulate just the
--! data coming from/to GBT and 'expect' that GBT package will synthesize well
--! and 'just work'
--! @author Dr. David Belohrad <david.belohrad@cern.ch>
--! @date 2010-11-05
--! @version 1.0
--!
--! @details
--! This file is part of . Project description:
--!
--!
--! @b Platform:
--! @b Standard: VHDL'93/02
--! @b Revisions:
--! @verbatim
--! Date        Version  Author         Description
--! 01 Mar 2022   1.0     belohrad        Created
--! @endverbatim
-------------------------------------------------------------------------------


--! Include the IEEE VHDL standard library
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Include the GBT-FPGA specific packages
use work.gbt_bank_package.all;
use work.vendor_specific_gbt_bank_package.all;

--! @brief GBT_BANK - TOP Level
--! @details
--! The gbt_bank module implements the logic required to implement the encoding/decoding
--! required to communicate or emulate a GBTx
entity gbt_bank is
   generic (
        NUM_LINKS                 : integer := 1;                            --! NUM_LINKS: number of links instantiated by the core (Altera: up to 6, Xilinx: up to 4)
        TX_OPTIMIZATION           : integer range 0 to 1 := STANDARD;        --! TX_OPTIMIZATION: Latency mode for the Tx path (STANDARD or LATENCY_OPTIMIZED)
        RX_OPTIMIZATION           : integer range 0 to 1 := STANDARD;        --! RX_OPTIMIZATION: Latency mode for the Rx path (STANDARD or LATENCY_OPTIMIZED)
        TX_ENCODING               : integer range 0 to 2 := GBT_FRAME;       --! TX_ENCODING: Encoding scheme for the Tx datapath (GBT_FRAME or WIDE_BUS)
        RX_ENCODING               : integer range 0 to 2 := GBT_FRAME        --! RX_ENCODING: Encoding scheme for the Rx datapath (GBT_FRAME or WIDE_BUS)
   );
   port (

        --========--
        -- Resets --
        --========--
        MGT_TXRESET_i            : in  std_logic_vector(1 to NUM_LINKS);    --! Reset the TX path of the transceiver (Tx PLL is reset with the first link) [Clock domain: MGT_CLK_i]
        MGT_RXRESET_i            : in  std_logic_vector(1 to NUM_LINKS);    --! Reset the Rx path of the transceiver [Clock domain: MGT_CLK_i]
        GBT_TXRESET_i            : in  std_logic_vector(1 to NUM_LINKS);    --! Reset the Tx Scrambler/Encoder and the Tx Gearbox [Clock domain: GBT_TXFRAMECLK_i]
        GBT_RXRESET_i            : in  std_logic_vector(1 to NUM_LINKS);    --! Reset the Rx Decoder/Descrambler and the Rx gearbox [Clock domain: GBT_RXFRAMECLK_i]

        --========--
        -- Clocks --
        --========--
        MGT_CLK_i                : in  std_logic;                           --! Transceiver reference clock
        GBT_TXFRAMECLK_i         : in  std_logic_vector(1 to NUM_LINKS);    --! Tx datapath's clock (40MHz with GBT_TXCLKEn_i = '1' or MGT_TXWORDCLK_o with GBT_TXCLKEn_i pulsed every 3/6 clock cycles)
        GBT_TXCLKEn_i            : in  std_logic_vector(1 to NUM_LINKS);    --! Rx clock enable signal used when the Rx frameclock is different from 40MHz
		GBT_RXFRAMECLK_i         : in  std_logic_Vector(1 to NUM_LINKS);    --! Rx datapath's clock (40MHz syncrhonous with NGT_RXWORDCLK_o and GBT_RXCLKEn_i = '1' or MGT_RXWORDCLK_o with GBT_RXCLKEn_i connected to the header flag signal)
        GBT_RXCLKEn_i            : in  std_logic_vector(1 to NUM_LINKS);    --! Rx clock enable signal used when the Rx frameclock is different from 40MHz
		MGT_TXWORDCLK_o          : out std_logic_vector(1 to NUM_LINKS);    --! Tx Wordclock from the transceiver (could be used to clock the core with Clocking enable)
        MGT_RXWORDCLK_o          : out std_logic_vector(1 to NUM_LINKS);    --! Rx Wordclock from the transceiver (could be used to clock the core with Clocking enable)

        --================--
        -- GBT TX Control --
        --================--
        TX_ENCODING_SEL_i        : in  std_logic_vector(1 to NUM_LINKS);    --! Select the Tx encoding in dynamic mode ('1': GBT / '0': WideBus)
        GBT_ISDATAFLAG_i         : in  std_logic_vector(1 to NUM_LINKS);    --! Enable dataflag (header) [Clock domain: GBT_TXFRAMECLK_i]

        --=================--
        -- GBT TX Status   --
        --=================--
        TX_PHCOMPUTED_o          : out std_logic_vector(1 to NUM_LINKS);    --! Tx frameclock and Tx wordclock alignement is computed (flag)
		TX_PHALIGNED_o           : out std_logic_vector(1 to NUM_LINKS);    --! Tx frameclock and Tx wordclock are aligned (gearbox is working correctly)

        --================--
        -- GBT RX Control --
        --================--
        RX_ENCODING_SEL_i        : in  std_logic_vector(1 to NUM_LINKS);    --! Select the Rx encoding in dynamic mode ('1': GBT / '0': WideBus)

        --=================--
        -- GBT RX Status   --
        --=================--
        GBT_RXREADY_o            : out std_logic_vector(1 to NUM_LINKS);    --! GBT Encoding/Scrambler is ready[Clock domain: GBT_RXFRAMECLK_i]
        GBT_ISDATAFLAG_o         : out std_logic_vector(1 to NUM_LINKS);    --! Header Is data flag [Clock domain: GBT_RXFRAMECLK_i]
        GBT_ERRORDETECTED_o      : out std_logic_vector(1 to NUM_LINKS);    --! Pulsed when error has been corrected by the decoder [Clock domain: GBT_RXFRAMECLK_i]
        GBT_ERRORFLAG_o          : out gbt_reg84_A(1 to NUM_LINKS);         --! Position of high level bits indicate the position of the bits flipped by the decoder [Clock domain: GBT_RXFRAMECLK_i]

        --================--
        -- MGT Control    --
        --================--
        MGT_DEVSPECIFIC_i        : in  mgtDeviceSpecific_i_R;               --! Device specific record connected to the transceiver, defined into the device specific package
        MGT_RSTONBITSLIPEn_i     : in  std_logic_vector(1 to NUM_LINKS);    --! Enable of the "reset on even or odd bitslip" state machine. It ensures fix latency with a UI precision [Clock domain: MGT_CLK_i]
        MGT_RSTONEVEN_i          : in  std_logic_vector(1 to NUM_LINKS);    --! Configure the "reset on even or odd bitslip": '1' reset when bitslip is even and '0' when is odd [Clock domain: MGT_CLK_i]

        --=================--
        -- MGT Status      --
        --=================--
        MGT_TXREADY_o            : out std_logic_vector(1 to NUM_LINKS);    --! Transceiver tx's path ready signal [Clock domain: MGT_CLK_i]
        MGT_RXREADY_o            : out std_logic_vector(1 to NUM_LINKS);    --! Transceiver rx's path ready signal [Clock domain: MGT_CLK_i]
        MGT_DEVSPECIFIC_o        : out mgtDeviceSpecific_o_R;               --! Device specific record connected to the transceiver, defined into the device specific package
        MGT_HEADERFLAG_o         : out std_logic_vector(1 to NUM_LINKS);    --! Pulsed when the MGT word contains the header [Clock domain: MGT_RXWORDCLK_o]
        MGT_HEADERLOCKED_o       : out std_logic_vector(1 to NUM_LINKS);    --! Asserted when the header is locked
        MGT_RSTCNT_o             : out gbt_reg8_A(1 to NUM_LINKS);          --! Number of resets because of a wrong bitslip parity

        --========--
        -- Data   --
        --========--
        GBT_TXDATA_i             : in  gbt_reg84_A(1 to NUM_LINKS);         --! GBT Data to be encoded and transmit
        GBT_RXDATA_o             : out gbt_reg84_A(1 to NUM_LINKS);         --! GBT Data received and decoded

        WB_TXDATA_i              : in  gbt_reg32_A(1 to NUM_LINKS);         --! (tx) Extra data (32bit) to replace the FEC when the WideBus encoding scheme is selected
        WB_RXDATA_o              : out gbt_reg32_A(1 to NUM_LINKS)          --! (rx) Extra data (32bit) replacing the FEC when the WideBus encoding scheme is selected

   );
end gbt_bank;

--! @brief GBT_BANK architecture - TOP Level
--! @details The GBT_BANK architecture instantiates the Tx datapath, Rx datapath, Gearboxes for the clock domain
--! crossing and the transceiver required to establish GBT links.
architecture structural of gbt_bank is

begin

end structural;
