--=================================================================================================--
--##################################   Package Information   ######################################--
--=================================================================================================--
--                                                                                       
-- Company:               CERN (PH-ESE-BE)                                                        
-- Engineer:              Manoel Barros Marin (manoel.barros.marin@cern.ch) (m.barros.marin@ieee.org)
--                        (Original design by P. Vichoudis (CERN)) 
--
-- Project Name:          GBT-FPGA                                                                
-- Package Name:          GBT Bank reset                                   
--                                                                                                 
-- Language:              VHDL'93                                                           
--                                                                                                 
-- Target Device:         Device agnostic                                                         
-- Tool version:                                                                          
--                                                                                                 
-- Revision:              3.0                                                                     
--
-- Description:            
--
-- Versions history:      DATE         VERSION   AUTHOR            DESCRIPTION
--
--                        17/06/2013   1.0       M. Barros Marin   First .vhd module definition           
--
--                        23/06/2013   3.0       M. Barros Marin   - Cosmetic modifications 
--                                                                 - Added generic to chose whether Tx or Rx is initialized first
--                                                                 - Added independent Tx and Rx resets.                                        
--
-- Additional Comments:                                                                               
--
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! IMPORTANT !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!                                                                                           !!
-- !! * The different parameters of the GBT Bank are set through:                               !!  
-- !!   (Note!! These parameters are vendor specific)                                           !!                    
-- !!                                                                                           !!
-- !!   - The MGT control ports of the GBT Bank module (these ports are listed in the records   !!
-- !!     of the file "<vendor>_<device>_gbt_bank_package.vhd").                                !! 
-- !!     (e.g. xlx_v6_gbt_bank_package.vhd)                                                    !!
-- !!                                                                                           !!  
-- !!   - By modifying the content of the file "<vendor>_<device>_gbt_bank_user_setup.vhd".     !!
-- !!     (e.g. xlx_v6_gbt_bank_user_setup.vhd)                                                 !! 
-- !!                                                                                           !! 
-- !! * The "<vendor>_<device>_gbt_bank_user_setup.vhd" is the only file of the GBT Bank that   !!
-- !!   may be modified by the user. The rest of the files MUST be used as is.                  !!
-- !!                                                                                           !!  
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--

-- IEEE VHDL standard library:
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.gbt_exampledesign_package.all;

--=================================================================================================--
--#######################################   Entity   ##############################################--
--=================================================================================================--

entity gbt_bank_reset is   
   generic ( 
	
      INITIAL_DELAY                                : natural := 1   * 40e6 -- Comment: * 1s    @ 40MHz  

   );    
   port (       

      --=======-- 
      -- Clock -- 
      --=======--
      GBT_CLK_I                          		      : in  std_logic;
		TX_FRAMECLK_I											: in  std_logic;
		RX_FRAMECLK_I											: in  std_logic;
		TX_CLKEN_I											   : in  std_logic;
		RX_CLKEN_I											   : in  std_logic;
		MGTCLK_I													: in std_logic;
		
      --===============--  
      -- Resets scheme --  
      --===============--  

      -- General reset: 
      -----------------
      GENERAL_RESET_I                              : in  std_logic;   
      TX_RESET_I                                   : in  std_logic;
      RX_RESET_I                                   : in  std_logic;
      
      -- Reset outputs: 
      -----------------
      MGT_TX_RESET_O                               : out std_logic;
      MGT_RX_RESET_O                               : out std_logic;
      GBT_TX_RESET_O                               : out std_logic;
      GBT_RX_RESET_O                               : out std_logic;

		--=========--
		-- Status  --
		--=========--
		MGT_TX_RSTDONE_I								: in std_logic;
		MGT_RX_RSTDONE_I								: in std_logic

   );
end gbt_bank_reset;

--=================================================================================================--
--####################################   Architecture   ###########################################-- 
--=================================================================================================--

architecture behavioral of gbt_bank_reset is      

   --================================ Signal Declarations ================================--   
   signal genReset_s					: std_logic;
	signal mgtTxReset_s				: std_logic;
	signal mgtRxReset_s				: std_logic;
	signal gbtTxReset_s				: std_logic;
	signal gbtRxReset_s				: std_logic;
	
	signal mgtRxReady_s				: std_logic;
	signal mgtRxReady_sync_s		: std_logic;
	
	signal mgtTxReady_s				: std_logic;
	signal mgtTxReady_sync_s		: std_logic;
	
	signal genRstMgtClk_s			: std_logic;
	signal genRstMgtClk_sync_s		: std_logic;
	
	signal genTxRstMgtClk_s			: std_logic;
	signal genTxRstMgtClk_sync_s	: std_logic;
	
	signal genRxRstMgtClk_s			: std_logic;
	signal genRxRstMgtClk_sync_s	: std_logic;
	
   --=====================================================================================--
   
--=================================================================================================--
begin                 --========####   Architecture Body   ####========-- 
--=================================================================================================--

   generalRstProcess: process(GBT_CLK_I, GENERAL_RESET_I)
		variable timer: integer range 0 to INITIAL_DELAY;		
	begin
	
		if GENERAL_RESET_I = '1' then
			genReset_s 	<= '1';
			timer			:=  0;
			
		elsif rising_edge(GBT_CLK_I) then
			
			if timer >= INITIAL_DELAY-1 then
				genReset_s 	<= '0';
				
			else
				timer			:= timer + 1;
				
			end if;
			
		end if;		
	end process;
	
	genRstMgtClk_Synch_Proc: process(genReset_s, MGTCLK_I)
	begin
	
		if genReset_s = '1' then
			genRstMgtClk_s <= '1';
			genRstMgtClk_sync_s <= '1';
			
		elsif rising_edge(MGTCLK_I) then
			genRstMgtClk_sync_s <= genRstMgtClk_s;
			genRstMgtClk_s <= '0';
			
		end if;
		
	end process;
	
	txRstMgtClk_Synch_Proc: process(TX_RESET_I, MGTCLK_I)
	begin
	
		if TX_RESET_I = '1' then
			genTxRstMgtClk_s <= '1';
			genTxRstMgtClk_sync_s <= '1';
			
		elsif rising_edge(MGTCLK_I) then
			genTxRstMgtClk_sync_s <= genTxRstMgtClk_s;
			genTxRstMgtClk_s <= '0';
			
		end if;
		
	end process;
	
	rxRstMgtClk_Synch_Proc: process(RX_RESET_I, MGTCLK_I)
	begin
	
		if RX_RESET_I = '1' then
			genRxRstMgtClk_s <= '1';
			genRxRstMgtClk_sync_s <= '1';
			
		elsif rising_edge(MGTCLK_I) then
			genRxRstMgtClk_sync_s <= genRxRstMgtClk_s;
			genRxRstMgtClk_s <= '0';
			
		end if;
		
	end process;
	
	-- Reset the TX side of the transceiver
	resetMGTTxProc: process(genRstMgtClk_sync_s, genTxRstMgtClk_sync_s, MGTCLK_I)
	begin		
		if genRstMgtClk_sync_s = '1' or genTxRstMgtClk_sync_s = '1' then
			mgtTxReset_s <= '1';
			
		elsif rising_edge(MGTCLK_I) then
			mgtTxReset_s <= '0';
			
		end if;	
	end process;
	
	-- Reset the RX side of the transceiver
	resetMGTRxProc: process(genRstMgtClk_sync_s, genRxRstMgtClk_sync_s, MGT_TX_RSTDONE_I, MGTCLK_I)
	begin
		if MGT_TX_RSTDONE_I = '0' or genRstMgtClk_sync_s = '1'  or genRxRstMgtClk_sync_s = '1' then
			mgtRxReset_s	<= '1';
			
		elsif rising_edge(MGTCLK_I) then
			mgtRxReset_s 	<= '0';
			
		end if;	
	end process;
	
	-- Reset the TX Datapath of the GBT-FPGA
	gbtTxRst_Synch_Proc: process(MGT_TX_RSTDONE_I, TX_FRAMECLK_I)
	begin
	
		if MGT_TX_RSTDONE_I = '0' then
			mgtTxReady_s <= '0';
			mgtTxReady_sync_s <= '0';
			
		elsif rising_edge(TX_FRAMECLK_I) then
			mgtTxReady_sync_s <= mgtTxReady_s;
			mgtTxReady_s <= '1';
			
		end if;
		
	end process;
	
	resetTXDataPathProcess: process(genReset_s, mgtTxReady_sync_s, TX_FRAMECLK_I)
	begin
	
		if mgtTxReady_sync_s = '0' or genReset_s = '1' then
			gbtTxReset_s	<= '1';
			
		elsif rising_edge(TX_FRAMECLK_I) then
		   if TX_CLKEN_I = '1' then
				gbtTxReset_s 	<= '0';
			end if;
		end if;
		
	end process;
	
	-- Reset the RX Datapath of the GBT-FPGA
	gbtRxRst_Synch_Proc: process(MGT_RX_RSTDONE_I, RX_FRAMECLK_I)
	begin
	
		if MGT_RX_RSTDONE_I = '0' then
			mgtRxReady_s <= '0';
			mgtRxReady_sync_s <= '0';
			
		elsif rising_edge(RX_FRAMECLK_I) then
			mgtRxReady_sync_s <= mgtRxReady_s;
			mgtRxReady_s <= '1';
		end if;
		
	end process;
	
	resetRXDataPathProcess: process(genReset_s, mgtRxReady_sync_s, RX_FRAMECLK_I)
	begin
		if mgtRxReady_sync_s = '0' or genReset_s = '1' then
			gbtRxReset_s	<= '1';
			
		elsif rising_edge(RX_FRAMECLK_I) then
			if RX_CLKEN_I = '1' then
				gbtRxReset_s 	<= '0';
			end if;
		end if;	
	end process;
   
	
	MGT_TX_RESET_O       <= mgtTxReset_s;
	MGT_RX_RESET_O       <= mgtRxReset_s;
	GBT_TX_RESET_O       <= gbtTxReset_s;
	GBT_RX_RESET_O       <= gbtRxReset_s;
		
   --=====================================================================================--   
end behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--