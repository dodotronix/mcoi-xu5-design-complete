--------------------------------------------------------------------------------
-- Petr Pacner | CERN | 2020-03-05 Do 10:05 
-- GBT [XU5 platform]
--------------------------------------------------------------------------------

-- IEEE VHDL standard library:
library ieee;
use ieee.std_logic_1164.all;

-- Custom libraries and packages:
use work.gbt_bank_package.all;
use work.vendor_specific_gbt_bank_package.all;

entity gbt_xu5 is
    generic (
                NGBT_BANK_ID : integer := 0;  
                FULL_MGTFREQ : integer := 1;
                NUM_LINKS : integer := 1;
                TX_OPTIMIZATION	: integer range 0 to 1 := STANDARD;
                RX_OPTIMIZATION : integer range 0 to 1 := STANDARD;
                TX_ENCODING : integer range 0 to 2 := GBT_FRAME;
                RX_ENCODING	: integer range 0 to 2 := GBT_FRAME;

                -- Extended configuration --
                DATA_GENERATOR_ENABLE : integer range 0 to 1 := 1;
                DATA_CHECKER_ENABLE : integer range 0 to 1 := 1;
                CLOCKING_SCHEME : integer range 0 to 1 := 0 
            );
    port (
             -- Clocks
             frameclk_40mhz : in std_logic;
             xcvrclk : in  std_logic;

             rx_frameclk_i : in std_logic_vector(1 to NUM_LINKS);
             rx_wordclk_o : out std_logic_vector(1 to NUM_LINKS);
             tx_frameclk_o : out std_logic_vector(1 to NUM_LINKS);
             tx_wordclk_o : out std_logic_vector(1 to NUM_LINKS);

             pll_ila : in std_logic;

             -- Serial lanes
             gbtbank_mgt_rx_p : in  std_logic_vector(1 to NUM_LINKS);
             gbtbank_mgt_rx_n : in  std_logic_vector(1 to NUM_LINKS);
             gbtbank_mgt_tx_p : out std_logic_vector(1 to NUM_LINKS);
             gbtbank_mgt_tx_n : out std_logic_vector(1 to NUM_LINKS);

             -- Data
             gbtbank_gbt_data_i : in  std_logic_vector(83 downto 0);
             gbtbank_wb_data_i : in std_logic_vector(115 downto 0);
             gbtbank_gbt_data_o : out std_logic_vector(83 downto 0);
             gbtbank_wb_data_o : out std_logic_vector(115 downto 0);

             gbtbank_mgt_drp_clk : in  std_logic;

             -- TX ctrl
             tx_encoding_sel_i : in  std_logic_vector(1 to NUM_LINKS);
             gbtbank_tx_isdata_sel_i : in  std_logic_vector(1 to NUM_LINKS);

             -- RX ctrl
             rx_encoding_sel_i : in  std_logic_vector(1 to NUM_LINKS);    
             gbtbank_rxbitslit_rstoneven_i : in std_logic_vector(1 to NUM_LINKS);

             -- TX Status
             -- gbtbank_gbttx_ready_o : out std_logic_vector(1 to NUM_LINKS);
             -- gbtbank_gbtrx_ready_o : out std_logic_vector(1 to NUM_LINKS);
             -- gbtbank_link_ready_o : out std_logic_vector(1 to NUM_LINKS);
             gbtbank_tx_aligned_o : out std_logic_vector(1 to NUM_LINKS);
             gbtbank_tx_aligncomputed_o : out std_logic_vector(1 to NUM_LINKS);

             -- RX Status
             gbtbank_rx_isdata_sel_o : out std_logic_vector(1 to NUM_LINKS);
             gbtbank_rx_errordetected_o : out std_logic_vector(1 to NUM_LINKS);
             gbtbank_rx_bitmodified_flag_o : out gbt_reg84_A(1 to NUM_LINKS);
             gbtbank_rxbitslip_rst_cnt_o : out gbt_reg8_A(1 to NUM_LINKS);

             -- XCVR ctrl
             gbtbank_loopback_i : in  std_logic_vector(2 downto 0);
             gbtbank_tx_pol : in  std_logic_vector(1 to NUM_LINKS);
             gbtbank_rx_pol : in  std_logic_vector(1 to NUM_LINKS);

             --exclude reset block from the gbt block 
             mgt_txreset_s : in std_logic_vector(1 to NUM_LINKS);
             mgt_rxreset_s : in std_logic_vector(1 to NUM_LINKS);
             gbt_txreset_s : in std_logic_vector(1 to NUM_LINKS);
             gbt_rxreset_s : in std_logic_vector(1 to NUM_LINKS);
             mgt_txready : out std_logic_vector(1 to NUM_LINKS);
             mgt_rxready : out std_logic_vector(1 to NUM_LINKS);
             gbt_rxclkenLogic : in std_logic_vector(1 to NUM_LINKS);
             mgt_headerflag : out std_logic_vector(1 to NUM_LINKS)
         );
end gbt_xu5;
architecture structural of gbt_xu5 is

    signal gbt_txdata_s : gbt_reg84_A(1 to NUM_LINKS);
    signal wb_txdata_s : gbt_reg32_A(1 to NUM_LINKS);

    signal mgt_devspecific_to_s : mgtDeviceSpecific_i_R;
    signal mgt_devspecific_from_s : mgtDeviceSpecific_o_R;

    signal gbt_rxdata_s : gbt_reg84_A(1 to NUM_LINKS);
    signal wb_rxdata_s : gbt_reg32_A(1 to NUM_LINKS);

    signal txData_from_gbtBank_pattGen : gbt_reg84_A(1 to NUM_LINKS);
    signal txwBData_from_gbtBank_pattGen : gbt_reg32_A(1 to NUM_LINKS);

    signal gbt_txframeclk_s : std_logic_vector(1 to NUM_LINKS);
    signal gbt_txclken_s : std_logic_vector(1 to NUM_LINKS);

    signal mgt_txwordclk_s : std_logic_vector(1 to NUM_LINKS);
    signal mgt_rxwordclk_s : std_logic_vector(1 to NUM_LINKS);

    signal mgt_txready_s : std_logic_vector(1 to NUM_LINKS);
    signal mgt_rxready_s : std_logic_vector(1 to NUM_LINKS);

    signal mgt_headerflag_s : std_logic_vector(1 to NUM_LINKS);
    signal resetOnBitslip_s : std_logic_vector(1 to NUM_LINKS);

    signal gbt_rxframeclk_s : std_logic_vector(1 to NUM_LINKS);

    signal gbt_rxready_s : std_logic_vector(1 to NUM_LINKS);
    signal gbt_rxclken_s : std_logic_vector(1 to NUM_LINKS);
    signal gbt_rxclkenLogic_s : std_logic_vector(1 to NUM_LINKS);
    signal mgt_headerflag_locked_s : std_logic_vector(1 to NUM_LINKS);
begin
    inside_ila : work.illa_gbtcore
    PORT MAP(clk => pll_ila,
             probe0 => gbt_rxdata_s(1)(63 downto 0),
             probe1 => gbt_txdata_s(1)(63 downto 0),
             probe2 => gbt_txframeclk_s(1),
             probe3 => gbt_rxframeclk_s(1),
             probe4 => '0',
             probe5 => '0',
             probe6 => mgt_txready_s(1),
             probe7 => mgt_rxready_s(1) 
            );

    -- Transceiver --
    gbtBank_mgt_gen: for i in 1 to NUM_LINKS generate

        gbt_rxframeclk_s(i) <= rx_frameclk_i(i);
        tx_frameclk_o(i) <= frameclk_40mhz;

        tx_wordclk_o(i) <= mgt_txwordclk_s(i);
        rx_wordclk_o(i) <= mgt_rxwordclk_s(i);

        mgt_headerflag(i) <= mgt_headerflag_s(i);
        gbt_rxclken_s(i) <= mgt_headerflag_s(i) when CLOCKING_SCHEME = FULL_MGTFREQ else '1';
        gbt_rxclkenLogic_s(i) <= gbt_rxclkenLogic(i);

        mgt_txready(i) <= mgt_txready_s(i);
        mgt_rxready(i) <= MGT_RXREADY_S(i);

        -- gbtbank_gbtrx_ready_o(i) <= mgt_rxready_s(i) and gbt_rxready_s(i);
        -- gbtbank_link_ready_o(i) <= mgt_txready_s(i) and mgt_rxready_s(i);
        -- gbtbank_gbttx_ready_o(i) <= not(gbt_txreset_s(i));

        gbt_txclken_s(i) <= '1';
        gbt_txdata_s(i) <= gbtbank_gbt_data_i;
        wb_txdata_s(i) <= gbtbank_wb_data_i(31 downto 0);
        gbt_txframeclk_s(i) <= frameclk_40mhz;

        gbtbank_gbt_data_o <= gbt_rxdata_s(i);
        gbtbank_wb_data_o <= gbt_rxdata_s(i) & wb_rxdata_s(i); 

        mgt_devspecific_to_s.drp_addr(i) <= "0000000000";
        mgt_devspecific_to_s.drp_en(i) <= '0';
        mgt_devspecific_to_s.drp_di(i) <= x"0000";
        mgt_devspecific_to_s.drp_we(i) <= '0';
        mgt_devspecific_to_s.prbs_txSel(i) <= "000";
        mgt_devspecific_to_s.prbs_rxSel(i) <= "000";
        mgt_devspecific_to_s.prbs_txForceErr(i) <= '0';
        mgt_devspecific_to_s.prbs_rxCntReset(i) <= '0';
        mgt_devspecific_to_s.conf_diffCtrl(i) <= "10000"; -- Comment: 807 mVppd
        mgt_devspecific_to_s.conf_postCursor(i) <= "00000"; -- Comment: 0.00 dB (default)
        mgt_devspecific_to_s.conf_preCursor(i) <= "00000"; -- Comment: 0.00 dB (default)
        mgt_devspecific_to_s.conf_txPol(i) <= gbtbank_tx_pol(i); -- Comment: Not inverted
        mgt_devspecific_to_s.conf_rxPol(i) <= gbtbank_rx_pol(i); -- Comment: Not inverted 
        mgt_devspecific_to_s.drp_clk(i) <= gbtbank_mgt_drp_clk;
        mgt_devspecific_to_s.loopBack(i) <= gbtbank_loopback_i;
        mgt_devspecific_to_s.rx_p(i) <= gbtbank_mgt_rx_p(i); 
        mgt_devspecific_to_s.rx_n(i) <= gbtbank_mgt_rx_n(i);
        mgt_devspecific_to_s.reset_freeRunningClock(i) <= gbtbank_mgt_drp_clk;

        gbtbank_mgt_tx_p(i) <= mgt_devspecific_from_s.tx_p(i); 
        gbtbank_mgt_tx_n(i) <= mgt_devspecific_from_s.tx_n(i);
        resetOnBitslip_s(i) <= '1' when RX_OPTIMIZATION = LATENCY_OPTIMIZED else '0';
    end generate; 

    -- GBT Bank --
    gbt_inst: entity work.gbt_bank
    generic map( 
                   NUM_LINKS => NUM_LINKS,
                   TX_OPTIMIZATION => TX_OPTIMIZATION,
                   RX_OPTIMIZATION => RX_OPTIMIZATION,
                   TX_ENCODING => TX_ENCODING,
                   RX_ENCODING => RX_ENCODING
               )
    port map( 
                -- Resets --
                MGT_TXRESET_i => mgt_txreset_s,
                MGT_RXRESET_i => mgt_rxreset_s,
                GBT_TXRESET_i => gbt_txreset_s,
                GBT_RXRESET_i => gbt_rxreset_s,

                -- Clocks -- 
                MGT_CLK_i => xcvrclk,
                GBT_TXFRAMECLK_i => gbt_txframeclk_s,
                GBT_TXCLKEn_i => gbt_txclken_s,
                GBT_RXFRAMECLK_i => gbt_rxframeclk_s,
                GBT_RXCLKEn_i => gbt_rxclken_s,
                MGT_TXWORDCLK_o => mgt_txwordclk_s,
                MGT_RXWORDCLK_o => mgt_rxwordclk_s,

                -- GBT TX Control --
                TX_ENCODING_SEL_i => tx_encoding_sel_i,
                GBT_ISDATAFLAG_i => gbtbank_tx_isdata_sel_i,

                -- GBT TX Status --
                TX_PHCOMPUTED_o => gbtbank_tx_aligncomputed_o,
                TX_PHALIGNED_o => gbtbank_tx_aligned_o,

                -- GBT RX Control --
                RX_ENCODING_SEL_i => rx_encoding_sel_i,

                -- GBT RX Status --
                GBT_RXREADY_o => gbt_rxready_s,
                GBT_ISDATAFLAG_o => gbtbank_rx_isdata_sel_o,
                GBT_ERRORDETECTED_o => gbtbank_rx_errordetected_o,
                GBT_ERRORFLAG_o => gbtbank_rx_bitmodified_flag_o,

                -- MGT Control --
                MGT_DEVSPECIFIC_i => mgt_devspecific_to_s,
                MGT_RSTONBITSLIPEn_i => resetOnBitslip_s,
                MGT_RSTONEVEN_i => gbtbank_rxbitslit_rstoneven_i,

                -- MGT Status --
                MGT_TXREADY_o => mgt_txready_s,
                MGT_RXREADY_o => mgt_rxready_s,
                MGT_DEVSPECIFIC_o => mgt_devspecific_from_s,
                MGT_HEADERFLAG_o => mgt_headerflag_s,
                MGT_HEADERLOCKED_o => mgt_headerflag_locked_s,
                MGT_RSTCNT_o => gbtbank_rxbitslip_rst_cnt_o,

                -- Data --
                GBT_TXDATA_i => gbt_txdata_s,
                GBT_RXDATA_o => gbt_rxdata_s,

                WB_TXDATA_i => wb_txdata_s,
                WB_RXDATA_o => wb_rxdata_s);

end structural;
