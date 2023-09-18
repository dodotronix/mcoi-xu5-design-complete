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
-- Copyright (c) Aug 2023 CERN

-------------------------------------------------------------------------------
-- @file GBT_EXPANDED_PINOUT.SV
-- @brief
-- @author Petr Pacner  <pepacner@cern.ch>, CERN
-- @date 24 Aug 2023
-- @details
--
--
-- @platform Xilinx Vivado 
-- @standard IEEE 1800-2012
-------------------------------------------------------------------------------

-- IEEE VHDL standard library:
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Xilinx devices library:
library unisim;
use unisim.vcomponents.all;

-- Custom libraries and packages:
use work.gbt_bank_package.all;
use work.vendor_specific_gbt_bank_package.all;

entity gbt_expanded_pinout is
	generic (
		GBT_BANK_ID : integer := 0;  
		NUM_LINKS : integer := 1;
		TX_OPTIMIZATION : integer range 0 to 1 := STANDARD;
		RX_OPTIMIZATION : integer range 0 to 1 := STANDARD;
		TX_ENCODING : integer range 0 to 2 := GBT_FRAME;
		RX_ENCODING : integer range 0 to 2 := GBT_FRAME;
		
		-- Extended configuration --
		CLOCKING_SCHEME : integer range 0 to 1 := 0
	);
   port ( 
		-- Clocks --
		frameclk_40mhz : in  std_logic;
		xcvrclk : in  std_logic;
		rx_frameclk_o : out std_logic_vector(1 to NUM_LINKS);
		rx_wordclk_o : out std_logic_vector(1 to NUM_LINKS);
		tx_frameclk_o : out std_logic_vector(1 to NUM_LINKS);
		tx_wordclk_o : out std_logic_vector(1 to NUM_LINKS);
		rx_frameclk_rdy_o : out std_logic_vector(1 to NUM_LINKS);
		
		
		-- Reset --
		gbtbank_general_reset_i : in  std_logic;
		gbtbank_manual_reset_tx_i : in  std_logic;
		gbtbank_manual_reset_rx_i : in  std_logic;
		
		
		-- Serial lanes --
		gbtbank_mgt_rx_p : in  std_logic_vector(1 to NUM_LINKS);
        gbtbank_mgt_rx_n : in  std_logic_vector(1 to NUM_LINKS);
		gbtbank_mgt_tx_p : out std_logic_vector(1 to NUM_LINKS);
        gbtbank_mgt_tx_n : out std_logic_vector(1 to NUM_LINKS);
		
		-- Data --
        gbtbank_gbt_data_i : in std_logic_vector(83 downto 0); 
        -- GBTBANK_GBT_DATA_I : in  gbt_reg84_A(1 to NUM_LINKS);
        gbtbank_wb_data_i : in  std_logic_vector(115 downto 0);
        -- GBTBANK_WB_DATA_I : in  gbt_reg116_A(1 to NUM_LINKS);

        tx_data_o : out gbt_reg84_A(1 to NUM_LINKS);
        wb_data_o : out gbt_reg116_A(1 to NUM_LINKS);

		gbtbank_gbt_data_o : out std_logic_vector(83 downto 0);
		--gbtbank_gbt_data_o : out gbt_reg84_A(1 to NUM_LINKS);
		gbtbank_wb_data_o : out std_logic_vector(115 downto 0);
		--gbtbank_wb_data_o : out gbt_reg116_A(1 to NUM_LINKS);
		
		-- Reconf. --
		gbtbank_mgt_drp_clk : in  std_logic;
		
		-- TX ctrl --
        tx_encoding_sel_i : in  std_logic_vector(1 to NUM_LINKS);    --! Select the Tx encoding in dynamic mode ('1': GBT / '0': WideBus)
		gbtbank_tx_isdata_sel_i : in  std_logic_vector(1 to NUM_LINKS);
		
		-- RX ctrl --
        rx_encoding_sel_i : in  std_logic_vector(1 to NUM_LINKS);    --! Select the Rx encoding in dynamic mode ('1': GBT / '0': WideBus)
		gbtbank_rxframeclk_alignpatter_i : in std_logic_vector(2 downto 0);	
		gbtbank_rxbitslit_rstoneven_i : in std_logic_vector(1 to NUM_LINKS);
		
		-- TX Status --
		gbtbank_gbttx_ready_o : out std_logic_vector(1 to NUM_LINKS);
		gbtbank_gbtrx_ready_o : out std_logic_vector(1 to NUM_LINKS);
		gbtbank_link_ready_o : out std_logic_vector(1 to NUM_LINKS);
		gbtbank_tx_aligned_o : out std_logic_vector(1 to NUM_LINKS);
		gbtbank_tx_aligncomputed_o : out std_logic_vector(1 to NUM_LINKS);
		
		-- RX Status --
		gbtbank_rx_isdata_sel_o : out std_logic_vector(1 to NUM_LINKS);
        gbtbank_rx_errordetected_o : out std_logic_vector(1 to NUM_LINKS);
        gbtbank_rx_bitmodified_flag_o : out gbt_reg84_A(1 to NUM_LINKS);
		gbtbank_rxbitslip_rst_cnt_o : out gbt_reg8_A(1 to NUM_LINKS);
		
		-- XCVR ctrl --
		gbtbank_loopback_i : in  std_logic_vector(2 downto 0);
		gbtbank_tx_pol : in  std_logic_vector(1 to NUM_LINKS);
		gbtbank_rx_pol : in  std_logic_vector(1 to NUM_LINKS)
   );
end gbt_expanded_pinout;

architecture structural of gbt_expanded_pinout is  
    -- GBT Tx --
	signal gbt_txframeclk_s                : std_logic_vector(1 to NUM_LINKS);
    signal gbt_txreset_s                   : std_logic_vector(1 to NUM_LINKS);
	signal gbt_txdata_s                    : gbt_reg84_A(1 to NUM_LINKS);
	signal wb_txdata_s                     : gbt_reg32_A(1 to NUM_LINKS);
	signal gbt_txclken_s                   : std_logic_vector(1 to NUM_LINKS);
   
    -- NGT --
	signal mgt_txwordclk_s                 : std_logic_vector(1 to NUM_LINKS);
	signal mgt_rxwordclk_s                 : std_logic_vector(1 to NUM_LINKS);
    signal mgt_txreset_s                   : std_logic_vector(1 to NUM_LINKS);
    signal mgt_rxreset_s                   : std_logic_vector(1 to NUM_LINKS);
    signal mgt_txready_s                   : std_logic_vector(1 to NUM_LINKS);
    signal mgt_rxready_s                   : std_logic_vector(1 to NUM_LINKS);
	
	signal mgt_headerflag_s                : std_logic_vector(1 to NUM_LINKS);
	signal mgt_devspecific_to_s            : mgtDeviceSpecific_i_R;
	signal mgt_devspecific_from_s          : mgtDeviceSpecific_o_R;
	signal resetOnBitslip_s                : std_logic_vector(1 to NUM_LINKS);
    
    -- GBT Rx --
	signal gbt_rxframeclk_s                : std_logic_vector(1 to NUM_LINKS);
    signal gbt_rxreset_s                   : std_logic_vector(1 to NUM_LINKS);
	signal gbt_rxready_s                   : std_logic_vector(1 to NUM_LINKS);
    signal gbt_rxdata_s                    : gbt_reg84_A(1 to NUM_LINKS);
	signal wb_rxdata_s                     : gbt_reg32_A(1 to NUM_LINKS);
	signal gbt_rxclken_s                    : std_logic_vector(1 to NUM_LiNKS);
	signal gbt_rxclkenLogic_s               : std_logic_vector(1 to NUM_LiNKS);
	
   -- Data pattern generator/checker --
   signal gbtBank_rxEncodingSel            : std_logic_vector(1 downto 0);
   signal txData_from_gbtBank_pattGen      : gbt_reg84_A(1 to NUM_LINKS);
   signal txwBData_from_gbtBank_pattGen    : gbt_reg32_A(1 to NUM_LINKS);

begin
	-- Clocks --
    gbtBank_Clk_gen: for i in 1 to NUM_LINKS generate
    
        gbtBank_rxFrmClkPhAlgnr: entity work.gbt_rx_frameclk_phalgnr
            generic map(
                TX_OPTIMIZATION                           => TX_OPTIMIZATION,
                RX_OPTIMIZATION                           => RX_OPTIMIZATION,
                DIV_SIZE_CONFIG                           => 3,
                METHOD                                    => 0, -- GATED_CLOCK
                CLOCKING_SCHEME                           => CLOCKING_SCHEME
            )
            port map (            
                RESET_I                                   => not(mgt_rxready_s(i)),
        
                RX_WORDCLK_I                              => mgt_rxwordclk_s(i),
                FRAMECLK_I                                => frameclk_40mhz,         
                RX_FRAMECLK_O                             => gbt_rxframeclk_s(i), 
                RX_CLKEn_o                                => gbt_rxclkenLogic_s(i),
                     
                SYNC_I                                    => mgt_headerflag_s(i),
                CLK_ALIGN_CONFIG                          => gbtbank_rxframeclk_alignpatter_i,
                DEBUG_CLK_ALIGNMENT                       => open,
                
                PLL_LOCKED_O                              => open,
                DONE_O                                    => rx_frameclk_rdy_o(i)
            );                      
        
          RX_FRAMECLK_O(i)    <= gbt_rxframeclk_s(i);
          TX_FRAMECLK_O(i)    <= gbt_txframeclk_s(i);
          
          TX_WORDCLK_O(i)     <= mgt_txwordclk_s(i);
          RX_WORDCLK_O(i)     <= mgt_rxwordclk_s(i);
          -- CLOCKING_SCHEME = FULL_MGTFREQ = 1 
          gbt_rxclken_s(i)    <= mgt_headerflag_s(i) when CLOCKING_SCHEME = 1 else '1';
    end generate;
                                     
     -- Resets --
     gbtBank_rst_gen: for i in 1 to NUM_LINKS generate
     
         gbtBank_gbtBankRst: entity work.gbt_bank_reset    
             generic map (
                 INITIAL_DELAY                          => 1 * 40e2   --          * 1s
             )
             port map (
                 GBT_CLK_I                              => frameclk_40mhz,
                 TX_FRAMECLK_I                          => gbt_txframeclk_s(i),
                 TX_CLKEN_I                             => gbt_txclken_s(i),
                 RX_FRAMECLK_I                          => gbt_rxframeclk_s(i),
                 RX_CLKEN_I                             => gbt_rxclkenLogic_s(i),
                 MGTCLK_I                               => gbtbank_mgt_drp_clk,
                 
                   
                 -- Resets scheme --  
                 GENERAL_RESET_I                        => gbtbank_general_reset_i,
                 TX_RESET_I                             => gbtbank_manual_reset_tx_i,
                 RX_RESET_I                             => gbtbank_manual_reset_rx_i,
                 
                 MGT_TX_RESET_O                         => mgt_txreset_s(i),
                 MGT_RX_RESET_O                         => mgt_rxreset_s(i),
                 GBT_TX_RESET_O                         => gbt_txreset_s(i),
                 GBT_RX_RESET_O                         => gbt_rxreset_s(i),
 
                 MGT_TX_RSTDONE_I                       => mgt_txready_s(i),
                 MGT_RX_RSTDONE_I                       => mgt_rxready_s(i)                                                                    
             ); 
                      
           gbtbank_gbtrx_ready_o(i)   <= mgt_rxready_s(i) and gbt_rxready_s(i);
           gbtbank_link_ready_o(i)    <= mgt_txready_s(i) and mgt_rxready_s(i);
           gbtbank_gbttx_ready_o(i)   <= not(gbt_txreset_s(i));
     end generate;
               
     dataGenDs_output_gen: for i in 1 to NUM_LINKS generate
           -- This design is staticaly set to BC_CLOCK clocking scheme
         gbt_txframeclk_s(i) <= frameclk_40mhz;
         gbt_txclken_s(i) <= '1';
           -- TODO generate txclxen as it's implemented in the pattern generator
         gbt_txdata_s(i)     <= gbtbank_gbt_data_i when (TX_ENCODING = GBT_FRAME or (TX_ENCODING = GBT_DYNAMIC and TX_ENCODING_SEL_i(i) = '1')) else GBTBANK_WB_DATA_I(115 downto 32);
         wb_txdata_s(i)      <= gbtbank_wb_data_i(31 downto 0);

         TX_DATA_O(i)        <= gbt_txdata_s(i);
         WB_DATA_O(i)        <= gbt_txdata_s(i) & wb_txdata_s(i);
     end generate;        
   
     -- TODO this will not work with NUM_LINKS greater than 1
    gbtBank_rxdatamap_gen: for i in 1 to NUM_LINKS generate
        gbtbank_gbt_data_o  <= gbt_rxdata_s(i) when RX_ENCODING = GBT_FRAME else 
                                  gbt_rxdata_s(i) when (RX_ENCODING = GBT_DYNAMIC and RX_ENCODING_SEL_i(i) = '1') else
                                  (others => '0');
       gbtbank_wb_data_o   <= gbt_rxdata_s(i) & wb_rxdata_s(i) when RX_ENCODING = WIDE_BUS else
                                 gbt_rxdata_s(i) & wb_rxdata_s(i) when (RX_ENCODING = GBT_DYNAMIC and RX_ENCODING_SEL_i(i) = '0') else 
                                    (others => '0');
   end generate;
   
   -- Transceiver --
   gbtBank_mgt_gen: for i in 1 to NUM_LINKS generate

       mgt_devspecific_to_s.drp_addr(i)           <= "0000000000";
       mgt_devspecific_to_s.drp_en(i)             <= '0';
       mgt_devspecific_to_s.drp_di(i)             <= x"0000";
       mgt_devspecific_to_s.drp_we(i)             <= '0';
       mgt_devspecific_to_s.drp_clk(i)            <= gbtbank_mgt_drp_clk;

       mgt_devspecific_to_s.prbs_txSel(i)         <= "000";
       mgt_devspecific_to_s.prbs_rxSel(i)         <= "000";
       mgt_devspecific_to_s.prbs_txForceErr(i)    <= '0';
       mgt_devspecific_to_s.prbs_rxCntReset(i)    <= '0';

       mgt_devspecific_to_s.conf_diffCtrl(i)      <= "01000";    -- Comment: 807 mVppd
       mgt_devspecific_to_s.conf_postCursor(i)    <= "00000";   -- Comment: 0.00 dB (default)
       mgt_devspecific_to_s.conf_preCursor(i)     <= "00000";   -- Comment: 0.00 dB (default)
       mgt_devspecific_to_s.conf_txPol(i)         <= gbtbank_tx_pol(i);       -- Comment: Not inverted
       mgt_devspecific_to_s.conf_rxPol(i)         <= gbtbank_rx_pol(i);       -- Comment: Not inverted     

       mgt_devspecific_to_s.loopBack(i)           <= gbtbank_loopback_i;

       mgt_devspecific_to_s.rx_p(i)               <= gbtbank_mgt_rx_p(i);   
       mgt_devspecific_to_s.rx_n(i)               <= gbtbank_mgt_rx_n(i);

       mgt_devspecific_to_s.reset_freeRunningClock(i)  <= gbtbank_mgt_drp_clk;

       GBTBANK_MGT_TX_P(i)                        <= mgt_devspecific_from_s.tx_p(i);  
       GBTBANK_MGT_TX_N(i)                        <= mgt_devspecific_from_s.tx_n(i);

       resetOnBitslip_s(i)                        <= '1' when RX_OPTIMIZATION = LATENCY_OPTIMIZED else '0';
   end generate; 

   -- GBT Bank --
   gbt_inst: entity work.gbt_bank
   generic map(   
                  NUM_LINKS                 => NUM_LINKS,
                  TX_OPTIMIZATION           => TX_OPTIMIZATION,
                  RX_OPTIMIZATION           => RX_OPTIMIZATION,
                  TX_ENCODING               => TX_ENCODING,
                  RX_ENCODING               => RX_ENCODING)
   port map(
               -- Resets --
               MGT_TXRESET_i            => mgt_txreset_s,
               MGT_RXRESET_i            => mgt_rxreset_s,
               GBT_TXRESET_i            => gbt_txreset_s,
               GBT_RXRESET_i            => gbt_rxreset_s,

               -- Clocks --     
               MGT_CLK_i                => xcvrclk,
               GBT_TXFRAMECLK_i         => gbt_txframeclk_s,
               GBT_TXCLKEn_i            => gbt_txclken_s,
               GBT_RXFRAMECLK_i         => gbt_rxframeclk_s,
               GBT_RXCLKEn_i            => gbt_rxclken_s,
               MGT_TXWORDCLK_o          => mgt_txwordclk_s,
               MGT_RXWORDCLK_o          => mgt_rxwordclk_s,


               -- GBT TX Control --
               GBT_ISDATAFLAG_i         => gbtbank_tx_isdata_sel_i,
               TX_ENCODING_SEL_i        => tx_encoding_sel_i,


               -- GBT TX Status --
               TX_PHALIGNED_o          => gbtbank_tx_aligned_o,
               TX_PHCOMPUTED_o         => gbtbank_tx_aligncomputed_o,


               -- GBT RX Control --
               RX_ENCODING_SEL_i        => rx_encoding_sel_i,


               -- GBT RX Status --
               GBT_RXREADY_o            => gbt_rxready_s,
               GBT_ISDATAFLAG_o         => gbtbank_rx_isdata_sel_o,
               GBT_ERRORDETECTED_o      => gbtbank_rx_errordetected_o,
               GBT_ERRORFLAG_o          => gbtbank_rx_bitmodified_flag_o,

               -- MGT Control --
               MGT_DEVSPECIFIC_i        => mgt_devspecific_to_s,
               MGT_RSTONBITSLIPEn_i     => resetOnBitslip_s,
               MGT_RSTONEVEN_i          => gbtbank_rxbitslit_rstoneven_i,

               -- MGT Status --
               MGT_TXREADY_o            => mgt_txready_s, --GBTBANK_LINK_TX_READY_O,
               MGT_RXREADY_o            => mgt_rxready_s, --GBTBANK_LINK_RX_READY_O,
               MGT_DEVSPECIFIC_o        => mgt_devspecific_from_s,
               MGT_HEADERFLAG_o         => mgt_headerflag_s,
               MGT_RSTCNT_o             => gbtbank_rxbitslip_rst_cnt_o,
               --MGT_HEADERLOCKED_o       => open,

               -- Data   --
               GBT_TXDATA_i             => gbt_txdata_s,
               GBT_RXDATA_o             => gbt_rxdata_s,
               WB_TXDATA_i              => wb_txdata_s,
               WB_RXDATA_o              => wb_rxdata_s);
end structural;
