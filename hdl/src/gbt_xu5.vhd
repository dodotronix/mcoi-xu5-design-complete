--------------------------------------------------------------------------------
-- Petr Pacner | CERN | 2020-03-05 Do 10:05
-- GBT [XU5 platform]
--------------------------------------------------------------------------------

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
use work.gbt_exampledesign_package.all;

entity gbt_xu5 is
    generic (
                NGBT_BANK_ID : integer := 0;
                NUM_LINKS : integer := 1;
                TX_OPTIMIZATION	: integer range 0 to 1 := STANDARD;
                RX_OPTIMIZATION : integer range 0 to 1 := STANDARD;
                TX_ENCODING : integer range 0 to 2 := GBT_FRAME;
                RX_ENCODING	: integer range 0 to 2 := GBT_FRAME;

                -- Extended configuration --
                DATA_GENERATOR_ENABLE : integer range 0 to 1 := 1;
                DATA_CHECKER_ENABLE : integer range 0 to 1 := 1;
                CLOCKING_SCHEME : integer range 0 to 1 := BC_CLOCK
            );
    port (
             -- Clocks
             frameclk_40mhz : in std_logic;
             xcvrclk : in  std_logic;
             rx_frameclk_o : out std_logic_vector(1 to NUM_LINKS);
             rx_wordclk_o : out std_logic_vector(1 to NUM_LINKS);
             tx_frameclk_o : out std_logic_vector(1 to NUM_LINKS);
             tx_wordclk_o : out std_logic_vector(1 to NUM_LINKS);

             rx_frameclk_rdy_o : out std_logic_vector(1 to NUM_LINKS);

             -- Reset
             gbtbank_general_reset_i : in  std_logic;
             gbtbank_manual_reset_tx_i : in  std_logic;
             gbtbank_manual_reset_rx_i : in  std_logic;

             -- Serial lanes
             gbtbank_mgt_rx_p : in  std_logic_vector(1 to NUM_LINKS);
             gbtbank_mgt_rx_n : in  std_logic_vector(1 to NUM_LINKS);
             gbtbank_mgt_tx_p : out std_logic_vector(1 to NUM_LINKS);
             gbtbank_mgt_tx_n : out std_logic_vector(1 to NUM_LINKS);

             -- Data
             gbtbank_gbt_data_i : in  std_logic_vector(83 downto 0);
             gbtbank_wb_data_i : in std_logic_vector(115 downto 0);
             tx_data_o : out std_logic_vector(83 downto 0);
             wb_data_o : out std_logic_vector(115 downto 0);
             gbtbank_gbt_data_o : out std_logic_vector(83 downto 0);
             gbtbank_wb_data_o : out std_logic_vector(115 downto 0);

             -- Reconf.
             gbtbank_mgt_drp_rst : in  std_logic;
             gbtbank_mgt_drp_clk : in  std_logic;

             -- TX ctrl
             tx_encoding_sel_i : in  std_logic_vector(1 to NUM_LINKS);    --! Select the Tx encoding in dynamic mode ('1': GBT / '0': WideBus)
             gbtbank_tx_isdata_sel_i : in  std_logic_vector(1 to NUM_LINKS);
             gbtbank_test_pattern_sel_i : in  std_logic_vector(1 downto 0);

             -- RX ctrl
             rx_encoding_sel_i : in  std_logic_vector(1 to NUM_LINKS);    --! Select the Rx encoding in dynamic mode ('1': GBT / '0': WideBus)
             gbtbank_reset_gbtrxready_lost_flag_i : in  std_logic_vector(1 to NUM_LINKS);
             gbtbank_reset_data_errorseen_flag_i : in  std_logic_vector(1 to NUM_LINKS);
             gbtbank_rxframeclk_alignpatter_i : in std_logic_vector(2 downto 0);
             gbtbank_rxbitslit_rstoneven_i : in std_logic_vector(1 to NUM_LINKS);

             -- TX Status
             gbtbank_gbttx_ready_o : out std_logic_vector(1 to NUM_LINKS);
             gbtbank_gbtrx_ready_o : out std_logic_vector(1 to NUM_LINKS);
             gbtbank_link_ready_o : out std_logic_vector(1 to NUM_LINKS);
             gbtbank_tx_aligned_o : out std_logic_vector(1 to NUM_LINKS);
             gbtbank_tx_aligncomputed_o : out std_logic_vector(1 to NUM_LINKS);

             -- RX Status
             gbtbank_gbtrxready_lost_flag_o : out std_logic_vector(1 to NUM_LINKS);
             gbtbank_rxdata_errorseen_flag_o : out std_logic_vector(1 to NUM_LINKS);
             gbtbank_rxextradata_widebus_errorseen_flag_o : out std_logic_vector(1 to NUM_LINKS);
             gbtbank_rx_isdata_sel_o : out std_logic_vector(1 to NUM_LINKS);
             gbtbank_rx_errordetected_o : out std_logic_vector(1 to NUM_LINKS);
             gbtbank_rx_bitmodified_flag_o : out gbt_reg84_A(1 to NUM_LINKS);
             gbtbank_rxbitslip_rst_cnt_o : out gbt_reg8_A(1 to NUM_LINKS);

             -- XCVR ctrl
             gbtbank_loopback_i : in  std_logic_vector(2 downto 0);
             gbtbank_tx_pol : in  std_logic_vector(1 to NUM_LINKS);
             gbtbank_rx_pol : in  std_logic_vector(1 to NUM_LINKS)
         );
end gbt_xu5;
architecture structural of gbt_xu5 is

    signal gbt_txframeclk_s : std_logic_vector(1 to NUM_LINKS);
    signal gbt_txreset_s : std_logic_vector(1 to NUM_LINKS);
    signal gbt_txdata_s : gbt_reg84_A(1 to NUM_LINKS);
    signal wb_txdata_s : gbt_reg32_A(1 to NUM_LINKS);
    signal gbt_txclken_s : std_logic_vector(1 to NUM_LINKS);

    signal mgt_txwordclk_s : std_logic_vector(1 to NUM_LINKS);
    signal mgt_rxwordclk_s : std_logic_vector(1 to NUM_LINKS);
    signal mgt_txreset_s : std_logic_vector(1 to NUM_LINKS);
    signal mgt_rxreset_s : std_logic_vector(1 to NUM_LINKS);
    signal mgt_txready_s : std_logic_vector(1 to NUM_LINKS);
    signal mgt_rxready_s : std_logic_vector(1 to NUM_LINKS);

    signal mgt_headerflag_s : std_logic_vector(1 to NUM_LINKS);
    signal mgt_devspecific_to_s : mgtDeviceSpecific_i_R;
    signal mgt_devspecific_from_s : mgtDeviceSpecific_o_R;
    signal resetOnBitslip_s : std_logic_vector(1 to NUM_LINKS);

    signal gbt_rxframeclk_s : std_logic_vector(1 to NUM_LINKS);
    signal gbt_rxreset_s : std_logic_vector(1 to NUM_LINKS);
    signal gbt_rxready_s : std_logic_vector(1 to NUM_LINKS);
    signal gbt_rxdata_s : gbt_reg84_A(1 to NUM_LINKS);
    signal wb_rxdata_s : gbt_reg32_A(1 to NUM_LINKS);
    signal gbt_rxclken_s : std_logic_vector(1 to NUM_LiNKS);
    signal gbt_rxclkenLogic_s : std_logic_vector(1 to NUM_LiNKS);

    signal gbtBank_txEncodingSel : std_logic_vector(1 downto 0);
    signal gbtBank_rxEncodingSel : std_logic_vector(1 downto 0);
    signal txData_from_gbtBank_pattGen : gbt_reg84_A(1 to NUM_LINKS);
    signal txwBData_from_gbtBank_pattGen : gbt_reg32_A(1 to NUM_LINKS);
begin
    -- Clocks
    gbtBank_Clk_gen: for i in 1 to NUM_LINKS generate

        gbtBank_rxFrmClkPhAlgnr: entity work.gbt_rx_frameclk_phalgnr
        generic map(
                       TX_OPTIMIZATION => TX_OPTIMIZATION,
                       RX_OPTIMIZATION => RX_OPTIMIZATION,
                       DIV_SIZE_CONFIG => 3,
                       METHOD => GATED_CLOCK,
                       CLOCKING_SCHEME => CLOCKING_SCHEME
                   )
        port map (
                     RESET_I => not(mgt_rxready_s(i)),

                     RX_WORDCLK_I => mgt_rxwordclk_s(i),
                     FRAMECLK_I => FRAMECLK_40MHZ,
                     RX_FRAMECLK_O => gbt_rxframeclk_s(i),
                     RX_CLKEn_o => gbt_rxclkenLogic_s(i),

                     SYNC_I => mgt_headerflag_s(i),
                     CLK_ALIGN_CONFIG => GBTBANK_RXFRAMECLK_ALIGNPATTER_I,
                     DEBUG_CLK_ALIGNMENT => open,

                     PLL_LOCKED_O => open,
                     DONE_O => RX_FRAMECLK_RDY_O(i)
                 );

        RX_FRAMECLK_O(i) <= gbt_rxframeclk_s(i);
        TX_FRAMECLK_O(i) <= gbt_txframeclk_s(i);

        TX_WORDCLK_O(i) <= mgt_txwordclk_s(i);
        RX_WORDCLK_O(i) <= mgt_rxwordclk_s(i);

        gbt_rxclken_s(i) <= mgt_headerflag_s(i) when CLOCKING_SCHEME = FULL_MGTFREQ else '1';
    end generate;


    -- Resets --
    gbtBank_rst_gen: for i in 1 to NUM_LINKS generate

        gbtBank_gbtBankRst: entity work.gbt_bank_reset
        generic map (
                        INITIAL_DELAY => 1 * 40e6 -- * 1s
                    )
        port map (
                     GBT_CLK_I => FRAMECLK_40MHZ,
                     TX_FRAMECLK_I => gbt_txframeclk_s(i),
                     TX_CLKEN_I => gbt_txclken_s(i),
                     RX_FRAMECLK_I => gbt_rxframeclk_s(i),
                     RX_CLKEN_I => gbt_rxclkenLogic_s(i),
                     MGTCLK_I => GBTBANK_MGT_DRP_CLK,


                     -- Resets scheme --
                     GENERAL_RESET_I => GBTBANK_GENERAL_RESET_I,
                     TX_RESET_I => GBTBANK_MANUAL_RESET_TX_I,
                     RX_RESET_I => GBTBANK_MANUAL_RESET_RX_I,

                     MGT_TX_RESET_O => mgt_txreset_s(i),
                     MGT_RX_RESET_O => mgt_rxreset_s(i),
                     GBT_TX_RESET_O => gbt_txreset_s(i),
                     GBT_RX_RESET_O => gbt_rxreset_s(i),

                     MGT_TX_RSTDONE_I => mgt_txready_s(i),
                     MGT_RX_RSTDONE_I => mgt_rxready_s(i)
                 );

        GBTBANK_GBTRX_READY_O(i) <= mgt_rxready_s(i) and gbt_rxready_s(i);

        GBTBANK_LINK_READY_O(i) <= mgt_txready_s(i) and mgt_rxready_s(i);

        GBTBANK_GBTTX_READY_O(i) <= not(gbt_txreset_s(i));
    end generate;


    -- Data pattern generator --
    dataGenEn_gen: if DATA_GENERATOR_ENABLE = ENABLED generate


        gbtBank_txEncodingSel <= "01" when TX_ENCODING = WIDE_BUS else
                                 "00" when TX_ENCODING = GBT_FRAME else
                                 '0' & not(TX_ENCODING_SEL_i);

        dataGenEn_output_gen: for i in 1 to NUM_LINKS generate
            gbtBank2_pattGen: entity work.gbt_pattern_generator
            generic map(
                           CLOCKING_SCHEME => CLOCKING_SCHEME
                       )
            port map (
                         GENERAL_RST_I => GBTBANK_GENERAL_RESET_I or GBTBANK_MANUAL_RESET_TX_I,
                         RESET_I => gbt_txreset_s(i),
                         TX_FRAMECLK_I => FRAMECLK_40MHZ,
                         TX_WORDCLK_I => mgt_txwordclk_s(i),

                         TX_FRAMECLK_O => gbt_txframeclk_s(i),
                         TX_CLKEN_o => gbt_txclken_s(i),


                         TX_ENCODING_SEL_I => gbtBank_txEncodingSel,
                         TEST_PATTERN_SEL_I => GBTBANK_TEST_PATTERN_SEL_I,
                         STATIC_PATTERN_SCEC_I => "00",
                         STATIC_PATTERN_DATA_I => x"000BABEAC1DACDCFFFFF",
                         STATIC_PATTERN_EXTRADATA_WIDEBUS_I => x"BEEFCAFE",

                         TX_DATA_O => txData_from_gbtBank_pattGen(i),
                         TX_EXTRA_DATA_WIDEBUS_O => txwBData_from_gbtBank_pattGen(i)
                     );

            --gbt_txdata_s(i) <= GBTBANK_WB_DATA_I(115 downto 32) when GBTBANK_TEST_PATTERN_SEL_I = "11" and (TX_ENCODING = WIDE_BUS or (TX_ENCODING = GBT_DYNAMIC and TX_ENCODING_SEL_i(i) = '0')) else
                               --GBTBANK_GBT_DATA_I when GBTBANK_TEST_PATTERN_SEL_I = "11" and (TX_ENCODING = GBT_FRAME or (TX_ENCODING = GBT_DYNAMIC and TX_ENCODING_SEL_i(i) = '1')) else
                               --txData_from_gbtBank_pattGen(i);

            --wb_txdata_s(i) <= GBTBANK_WB_DATA_I(31 downto 0) when GBTBANK_TEST_PATTERN_SEL_I = "11" else
                              --txwBData_from_gbtBank_pattGen(i);

            gbt_txdata_s(i) <= gbtbank_gbt_data_i;
            TX_DATA_O <= gbt_txdata_s(i);
            WB_DATA_O <= gbt_txdata_s(i) & wb_txdata_s(i);

        end generate;
    end generate;

    dataGenDs_gen: if DATA_GENERATOR_ENABLE = DISABLED generate
        dataGenDs_output_gen: for i in 1 to NUM_LINKS generate
            gbt_txdata_s(i) <= GBTBANK_GBT_DATA_I when (TX_ENCODING = GBT_FRAME or (TX_ENCODING = GBT_DYNAMIC and TX_ENCODING_SEL_i(i) = '1')) else GBTBANK_WB_DATA_I(115 downto 32);
            wb_txdata_s(i) <= GBTBANK_WB_DATA_I(31 downto 0);

            TX_DATA_O <= gbt_txdata_s(i);
            WB_DATA_O <= gbt_txdata_s(i) & wb_txdata_s(i);
        end generate;
    end generate;


    -- Data pattern checker --
    dataCheckEn_gen: if DATA_CHECKER_ENABLE = ENABLED generate
        gbtBank_rxEncodingSel <= "01" when RX_ENCODING = WIDE_BUS else
                                 "00" when RX_ENCODING = GBT_FRAME else
                                 '0' & not(RX_ENCODING_SEL_i);

        gbtBank_patCheck_gen: for i in 1 to NUM_LINKS generate
            gbtBank_pattCheck: entity work.gbt_pattern_checker
            port map (
                         RESET_I => GBTBANK_GENERAL_RESET_I or GBTBANK_MANUAL_RESET_RX_I, --gbt_rxreset_s(i),
                         RX_FRAMECLK_I => gbt_rxframeclk_s(i),
                         RX_CLKEN_I => gbt_rxclkenLogic_s(i),

                         RX_DATA_I => gbt_rxdata_s(i),
                         RX_EXTRA_DATA_WIDEBUS_I => wb_rxdata_s(i),

                         GBT_RX_READY_I => gbt_rxready_s(i),
                         RX_ENCODING_SEL_I => gbtBank_rxEncodingSel,
                         TEST_PATTERN_SEL_I => GBTBANK_TEST_PATTERN_SEL_I,
                         STATIC_PATTERN_SCEC_I => "00",
                         STATIC_PATTERN_DATA_I => x"000BABEAC1DACDCFFFFF",
                         STATIC_PATTERN_EXTRADATA_WIDEBUS_I => x"BEEFCAFE",
                         RESET_GBTRXREADY_LOST_FLAG_I => GBTBANK_RESET_GBTRXREADY_LOST_FLAG_I(i),
                         RESET_DATA_ERRORSEEN_FLAG_I => GBTBANK_RESET_DATA_ERRORSEEN_FLAG_I(i),

                         GBTRXREADY_LOST_FLAG_O => GBTBANK_GBTRXREADY_LOST_FLAG_O(i),
                         RXDATA_ERRORSEEN_FLAG_O => GBTBANK_RXDATA_ERRORSEEN_FLAG_O(i),
                         RXEXTRADATA_WIDEBUS_ERRORSEEN_FLAG_O => GBTBANK_RXEXTRADATA_WIDEBUS_ERRORSEEN_FLAG_O(i)
                     );
        end generate;

    end generate;

    dataCheckDs_gen: if DATA_CHECKER_ENABLE = DISABLED generate
        GBTBANK_GBTRXREADY_LOST_FLAG_O <= (others => '0');
        GBTBANK_RXDATA_ERRORSEEN_FLAG_O <= (others => '0');
        GBTBANK_RXEXTRADATA_WIDEBUS_ERRORSEEN_FLAG_O <= (others => '0');
    end generate;

    gbtBank_rxdatamap_gen: for i in 1 to NUM_LINKS generate
        GBTBANK_GBT_DATA_O <= gbt_rxdata_s(i) when RX_ENCODING = GBT_FRAME else
                                 gbt_rxdata_s(i) when (RX_ENCODING = GBT_DYNAMIC and RX_ENCODING_SEL_i(i) = '1') else
                                 (others => '0');
        GBTBANK_WB_DATA_O <= gbt_rxdata_s(i) & wb_rxdata_s(i) when RX_ENCODING = WIDE_BUS else
                                gbt_rxdata_s(i) & wb_rxdata_s(i) when (RX_ENCODING = GBT_DYNAMIC and RX_ENCODING_SEL_i(i) = '0') else
                                (others => '0');
    end generate;

    -- Transceiver --
    gbtBank_mgt_gen: for i in 1 to NUM_LINKS generate

        mgt_devspecific_to_s.drp_addr(i) <= "0000000000";
        mgt_devspecific_to_s.drp_en(i) <= '0';
        mgt_devspecific_to_s.drp_di(i) <= x"0000";
        mgt_devspecific_to_s.drp_we(i) <= '0';
        mgt_devspecific_to_s.drp_clk(i) <= GBTBANK_MGT_DRP_CLK;

        mgt_devspecific_to_s.prbs_txSel(i) <= "000";
        mgt_devspecific_to_s.prbs_rxSel(i) <= "000";
        mgt_devspecific_to_s.prbs_txForceErr(i) <= '0';
        mgt_devspecific_to_s.prbs_rxCntReset(i) <= '0';

        mgt_devspecific_to_s.conf_diffCtrl(i) <= "10110"; -- Comment: 822 mVppd
        mgt_devspecific_to_s.conf_postCursor(i) <= "00000"; -- Comment: 0.00 dB (default)
        mgt_devspecific_to_s.conf_preCursor(i) <= "00000"; -- Comment: 0.00 dB (default)
        mgt_devspecific_to_s.conf_txPol(i) <= GBTBANK_TX_POL(i); -- Comment: Not inverted
        mgt_devspecific_to_s.conf_rxPol(i) <= GBTBANK_RX_POL(i); -- Comment: Not inverted

        mgt_devspecific_to_s.loopBack(i) <= GBTBANK_LOOPBACK_I;

        mgt_devspecific_to_s.rx_p(i) <= GBTBANK_MGT_RX_P(i);
        mgt_devspecific_to_s.rx_n(i) <= GBTBANK_MGT_RX_N(i);

        mgt_devspecific_to_s.reset_freeRunningClock(i) <= GBTBANK_MGT_DRP_CLK;

        GBTBANK_MGT_TX_P(i) <= mgt_devspecific_from_s.tx_p(i);
        GBTBANK_MGT_TX_N(i) <= mgt_devspecific_from_s.tx_n(i);

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
                MGT_CLK_i => XCVRCLK,
                GBT_TXFRAMECLK_i => gbt_txframeclk_s,
                GBT_TXCLKEn_i => gbt_txclken_s,
                GBT_RXFRAMECLK_i => gbt_rxframeclk_s,
                GBT_RXCLKEn_i => gbt_rxclken_s,
                MGT_TXWORDCLK_o => mgt_txwordclk_s,
                MGT_RXWORDCLK_o => mgt_rxwordclk_s,

                -- GBT TX Control --
                GBT_ISDATAFLAG_i => GBTBANK_TX_ISDATA_SEL_I,
                TX_ENCODING_SEL_i => TX_ENCODING_SEL_i,

                -- GBT TX Status --
                TX_PHALIGNED_o => GBTBANK_TX_ALIGNED_O,
                TX_PHCOMPUTED_o => GBTBANK_TX_ALIGNCOMPUTED_O,

                -- GBT RX Control --
                RX_ENCODING_SEL_i => RX_ENCODING_SEL_i,

                -- GBT RX Status --
                GBT_RXREADY_o => gbt_rxready_s,
                GBT_ISDATAFLAG_o => GBTBANK_RX_ISDATA_SEL_O,
                GBT_ERRORDETECTED_o => GBTBANK_RX_ERRORDETECTED_O,
                GBT_ERRORFLAG_o => GBTBANK_RX_BITMODIFIED_FLAG_O,

                -- MGT Control --
                MGT_DEVSPECIFIC_i => mgt_devspecific_to_s,
                MGT_RSTONBITSLIPEn_i => resetOnBitslip_s,
                MGT_RSTONEVEN_i => GBTBANK_RXBITSLIT_RSTONEVEN_I,

                -- MGT Status --
                MGT_TXREADY_o => mgt_txready_s, --GBTBANK_LINK_TX_READY_O,
                MGT_RXREADY_o => mgt_rxready_s, --GBTBANK_LINK_RX_READY_O,
                MGT_DEVSPECIFIC_o => mgt_devspecific_from_s,
                MGT_HEADERFLAG_o => mgt_headerflag_s,
                MGT_RSTCNT_o => GBTBANK_RXBITSLIP_RST_CNT_O,
                --MGT_HEADERLOCKED_o => open,

                -- Data --
                GBT_TXDATA_i => gbt_txdata_s,
                GBT_RXDATA_o => gbt_rxdata_s,

                WB_TXDATA_i => wb_txdata_s,
                WB_RXDATA_o => wb_rxdata_s);

end structural;
