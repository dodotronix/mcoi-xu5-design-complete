onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group gbt_x /tb_gbt_xu5/DUT/gbt_x/sfp1_gbitin_p
add wave -noupdate -group gbt_x /tb_gbt_xu5/DUT/gbt_x/sfp1_gbitin_n
add wave -noupdate -group gbt_x /tb_gbt_xu5/DUT/gbt_x/sfp1_los
add wave -noupdate -group gbt_x /tb_gbt_xu5/DUT/gbt_x/sfp1_gbitout_p
add wave -noupdate -group gbt_x /tb_gbt_xu5/DUT/gbt_x/sfp1_gbitout_n
add wave -noupdate -group gbt_x /tb_gbt_xu5/DUT/gbt_x/sfp1_rateselect
add wave -noupdate -group gbt_x /tb_gbt_xu5/DUT/gbt_x/sfp1_txdisable
add wave -noupdate -group gbt_data_x /tb_gbt_xu5/DUT/gbt_data_x/ClkRs_ix
add wave -noupdate -group gbt_data_x /tb_gbt_xu5/DUT/gbt_data_x/data_received
add wave -noupdate -group gbt_data_x /tb_gbt_xu5/DUT/gbt_data_x/data_sent
add wave -noupdate -group gbt_data_x /tb_gbt_xu5/DUT/gbt_data_x/tx_frameclk
add wave -noupdate -group gbt_data_x /tb_gbt_xu5/DUT/gbt_data_x/rx_frameclk
add wave -noupdate -group gbt_data_x /tb_gbt_xu5/DUT/gbt_data_x/tx_ready
add wave -noupdate -group gbt_data_x /tb_gbt_xu5/DUT/gbt_data_x/rx_ready
add wave -noupdate -group gbt_data_x /tb_gbt_xu5/DUT/gbt_data_x/link_ready
add wave -noupdate -group gbt_data_x /tb_gbt_xu5/DUT/gbt_data_x/bitslip_reset
add wave -noupdate -group gbt_data_x /tb_gbt_xu5/DUT/gbt_data_x/rx_frameclk_ready
add wave -noupdate -group clk_tree_x /tb_gbt_xu5/DUT/clk_tree_x/ClkRs100MHz_ix
add wave -noupdate -group clk_tree_x /tb_gbt_xu5/DUT/clk_tree_x/ClkRs120MHz_ix
add wave -noupdate -group clk_tree_x /tb_gbt_xu5/DUT/clk_tree_x/ClkRs40MHz_ix
add wave -noupdate -group clk_tree_x /tb_gbt_xu5/DUT/clk_tree_x/ClkRsVar_ix
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/MGT_TXRESET_i
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/MGT_RXRESET_i
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/GBT_TXRESET_i
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/GBT_RXRESET_i
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/MGT_CLK_i
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/GBT_TXFRAMECLK_i
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/GBT_TXCLKEn_i
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/GBT_RXFRAMECLK_i
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/GBT_RXCLKEn_i
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/MGT_TXWORDCLK_o
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/MGT_RXWORDCLK_o
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/TX_ENCODING_SEL_i
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/GBT_ISDATAFLAG_i
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/TX_PHCOMPUTED_o
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/TX_PHALIGNED_o
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/RX_ENCODING_SEL_i
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/GBT_RXREADY_o
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/GBT_ISDATAFLAG_o
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/GBT_ERRORDETECTED_o
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/GBT_ERRORFLAG_o
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/MGT_DEVSPECIFIC_i
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/MGT_RSTONBITSLIPEn_i
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/MGT_RSTONEVEN_i
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/MGT_TXREADY_o
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/MGT_RXREADY_o
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/MGT_DEVSPECIFIC_o
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/MGT_HEADERFLAG_o
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/MGT_HEADERLOCKED_o
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/MGT_RSTCNT_o
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/GBT_TXDATA_i
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/GBT_RXDATA_o
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/WB_TXDATA_i
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/WB_RXDATA_o
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_txencdata_s
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_txclkfromDesc_s
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_txwordclk_s
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_rxwordclk_s
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_txword_s
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_rxword_s
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_headerflag_s
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_rxencdata_s
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_rxgearboxready_s
add wave -noupdate -group gbt_inst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_rxclkengearbox_s
add wave -noupdate -group decoder /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_rxdatapath_multilink_gen(1)/gbt_rxdatapath_inst/decoder/RX_RESET_I
add wave -noupdate -group decoder /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_rxdatapath_multilink_gen(1)/gbt_rxdatapath_inst/decoder/RX_FRAMECLK_I
add wave -noupdate -group decoder /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_rxdatapath_multilink_gen(1)/gbt_rxdatapath_inst/decoder/RX_CLKEN_i
add wave -noupdate -group decoder /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_rxdatapath_multilink_gen(1)/gbt_rxdatapath_inst/decoder/RX_ENCODING_SEL_i
add wave -noupdate -group decoder /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_rxdatapath_multilink_gen(1)/gbt_rxdatapath_inst/decoder/READY_O
add wave -noupdate -group decoder /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_rxdatapath_multilink_gen(1)/gbt_rxdatapath_inst/decoder/RX_ISDATA_FLAG_ENABLE_I
add wave -noupdate -group decoder /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_rxdatapath_multilink_gen(1)/gbt_rxdatapath_inst/decoder/RX_ISDATA_FLAG_O
add wave -noupdate -group decoder /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_rxdatapath_multilink_gen(1)/gbt_rxdatapath_inst/decoder/RX_ERROR_DETECTED
add wave -noupdate -group decoder /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_rxdatapath_multilink_gen(1)/gbt_rxdatapath_inst/decoder/RX_BIT_MODIFIED_FLAG
add wave -noupdate -group decoder /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_rxdatapath_multilink_gen(1)/gbt_rxdatapath_inst/decoder/RX_FRAME_I
add wave -noupdate -group decoder /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_rxdatapath_multilink_gen(1)/gbt_rxdatapath_inst/decoder/RX_COMMON_FRAME_O
add wave -noupdate -group decoder /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_rxdatapath_multilink_gen(1)/gbt_rxdatapath_inst/decoder/RX_EXTRA_FRAME_WIDEBUS_O
add wave -noupdate -group decoder /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_rxdatapath_multilink_gen(1)/gbt_rxdatapath_inst/decoder/rxFrame_from_deinterleaver
add wave -noupdate -group decoder /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_rxdatapath_multilink_gen(1)/gbt_rxdatapath_inst/decoder/rxCommonFrame_from_reedSolomonDecoder
add wave -noupdate -group decoder /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_rxdatapath_multilink_gen(1)/gbt_rxdatapath_inst/decoder/error_detected_lsb
add wave -noupdate -group decoder /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_rxdatapath_multilink_gen(1)/gbt_rxdatapath_inst/decoder/error_detected_msb
add wave -noupdate -group decoder /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_rxdatapath_multilink_gen(1)/gbt_rxdatapath_inst/decoder/RX_COMMON_FRAME_gbt_s
add wave -noupdate -group decoder /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_rxdatapath_multilink_gen(1)/gbt_rxdatapath_inst/decoder/RX_EXTRA_FRAME_WIDEBUS_gbt_s
add wave -noupdate -group decoder /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_rxdatapath_multilink_gen(1)/gbt_rxdatapath_inst/decoder/RX_ERROR_DETECTED_gbt_s
add wave -noupdate -group decoder /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_rxdatapath_multilink_gen(1)/gbt_rxdatapath_inst/decoder/RX_BIT_MODIFIED_FLAG_gbt_s
add wave -noupdate -group decoder /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_rxdatapath_multilink_gen(1)/gbt_rxdatapath_inst/decoder/RX_COMMON_FRAME_wb_s
add wave -noupdate -group decoder /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_rxdatapath_multilink_gen(1)/gbt_rxdatapath_inst/decoder/RX_EXTRA_FRAME_WIDEBUS_wb_s
add wave -noupdate -group decoder /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_rxdatapath_multilink_gen(1)/gbt_rxdatapath_inst/decoder/RX_ERROR_DETECTED_wb_s
add wave -noupdate -group decoder /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/gbt_rxdatapath_multilink_gen(1)/gbt_rxdatapath_inst/decoder/RX_BIT_MODIFIED_FLAG_wb_s
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/gbt_clk_i
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/tx_frameclk_i
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/rx_frameclk_i
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/tx_clken_i
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/rx_clken_i
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/mgtclk_i
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/general_reset_i
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/tx_reset_i
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/rx_reset_i
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/mgt_tx_rstdone_i
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/mgt_rx_rstdone_i
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/mgt_tx_reset_o
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/mgt_rx_reset_o
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/gbt_tx_reset_o
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/gbt_rx_reset_o
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/genReset_s
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/mgtTxReset_s
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/mgtRxReset_s
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/gbtTxReset_s
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/gbtRxReset_s
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/mgtRxReady_s
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/mgtRxReady_sync_s
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/mgtTxReady_s
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/mgtTxReady_sync_s
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/genRstMgtClk_s
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/genRstMgtClk_sync_s
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/genTxRstMgtClk_s
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/genTxRstMgtClk_sync_s
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/genRxRstMgtClk_s
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/genRxRstMgtClk_sync_s
add wave -noupdate -group gbtBank_gbtBankRst /tb_gbt_xu5/DUT/gbt_expanded_inst/gbtBank_rst_gen(1)/gbtBank_gbtBankRst/timer
add wave -noupdate -group rxBitSlipControl /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/rxBitSlipControl/RX_RESET_I
add wave -noupdate -group rxBitSlipControl /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/rxBitSlipControl/RX_WORDCLK_I
add wave -noupdate -group rxBitSlipControl /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/rxBitSlipControl/MGT_CLK_I
add wave -noupdate -group rxBitSlipControl /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/rxBitSlipControl/RX_BITSLIPCMD_i
add wave -noupdate -group rxBitSlipControl /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/rxBitSlipControl/RX_BITSLIPCMD_o
add wave -noupdate -group rxBitSlipControl /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/rxBitSlipControl/RX_HEADERLOCKED_i
add wave -noupdate -group rxBitSlipControl /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/rxBitSlipControl/RX_BITSLIPISEVEN_i
add wave -noupdate -group rxBitSlipControl /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/rxBitSlipControl/RX_RSTONBITSLIP_o
add wave -noupdate -group rxBitSlipControl /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/rxBitSlipControl/RX_ENRST_i
add wave -noupdate -group rxBitSlipControl /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/rxBitSlipControl/RX_RSTONEVEN_i
add wave -noupdate -group rxBitSlipControl /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/rxBitSlipControl/DONE_o
add wave -noupdate -group rxBitSlipControl /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/rxBitSlipControl/READY_o
add wave -noupdate -group rxBitSlipControl /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/rxBitSlipControl/bitSlitRst
add wave -noupdate -group rxBitSlipControl /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/rxBitSlipControl/bitSlitRst_sync
add wave -noupdate -group patternSearch /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/patternSearch/RX_WORDCLK_I
add wave -noupdate -group patternSearch /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/patternSearch/RX_RESET_I
add wave -noupdate -group patternSearch /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/patternSearch/RX_BITSLIP_CMD_O
add wave -noupdate -group patternSearch /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/patternSearch/MGT_BITSLIPDONE_i
add wave -noupdate -group patternSearch /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/patternSearch/RX_WORD_I
add wave -noupdate -group patternSearch /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/patternSearch/RX_BITSLIPISEVEN_o
add wave -noupdate -group patternSearch /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/patternSearch/RX_HEADER_LOCKED_O
add wave -noupdate -group patternSearch /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/patternSearch/RX_HEADER_FLAG_O
add wave -noupdate -group patternSearch /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/patternSearch/state
add wave -noupdate -group patternSearch /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/patternSearch/psAddress
add wave -noupdate -group patternSearch /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/patternSearch/shiftPsAddr
add wave -noupdate -group patternSearch /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/patternSearch/bitSlipCmd
add wave -noupdate -group patternSearch /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/patternSearch/headerFlag_s
add wave -noupdate -group patternSearch /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/patternSearch/RX_HEADER_LOCKED_s
add wave -noupdate -group patternSearch /tb_gbt_xu5/DUT/gbt_expanded_inst/gbt_inst/mgt_inst/gtxLatOpt_gen(1)/patternSearch/RX_BITSLIPISEVEN_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 481
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {852 ps}
