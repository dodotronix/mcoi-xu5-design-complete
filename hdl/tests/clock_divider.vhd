----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.01.2016 10:53:52
-- Design Name: 
-- Module Name: gbt_rx_frameclk_phalgnr - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;

entity gbt_rx_clockdivider is
   Generic (
		CLOCK_DIVIDER_HIGH								: integer;
		CLOCK_DIVIDER_LOW									: integer
   );
   port ( 
      
      --=======--
      -- Reset --
      --=======-- 
      RESET_I                                   : in  std_logic;
      
      --===============--
      -- Clocks scheme --
      --===============--
      RX_WORDCLK                                : in  std_logic;     
      RX_FRAMECLK_O                             : out std_logic;   -- Comment: Phase aligned 40MHz output. 
      
		--===========--
		-- Control   --
		--===========--
		
		SYNC_I	   										: in std_logic;
		
      --=========--
      -- Status  --
      --=========--
      PLL_LOCKED_O                              : out std_logic
      
   );
end gbt_rx_clockdivider;

architecture Behavioral of gbt_rx_clockdivider is

	 signal internalClk_s : std_logic := '1';
	 
	 signal cnter : integer range 0 to (CLOCK_DIVIDER_HIGH+CLOCK_DIVIDER_LOW);
	 signal resetClockGenProc : std_logic;
	 signal SYNC_s0: std_logic;
	 
	 signal clkGenRst : std_logic;
	 signal clkGenRst_sync : std_logic;
	 
begin
      
	--========================--
	-- Reset synchronization  --
	--========================--
	syncCnter_proc: process(RX_WORDCLK, RESET_I)
	begin
	
		if(RESET_I='1') then
			cnter <= 0;
			resetClockGenProc <= '1';
			
		elsif rising_edge(RX_WORDCLK) then
		
			cnter <= cnter + 1;
			SYNC_s0 <= SYNC_I;
			
			if SYNC_I = '1' and SYNC_s0 = '0' then
				cnter <= 0;
				resetClockGenProc <= '0';
			end if;
			
		end if;
	end process;
	

	clockengen_proc: process(RX_WORDCLK, resetClockGenProc)
	begin
	
		if(resetClockGenProc='1') then
			internalClk_s				<='0';
			PLL_LOCKED_O 	<='0';
			
		elsif rising_edge(RX_WORDCLK) then
		
			PLL_LOCKED_O <= '1';
			
			if (cnter = 0) then
				internalClk_s <= '1';
				
			elsif cnter = CLOCK_DIVIDER_HIGH then
				internalClk_s <= '0';
			
			end if;
		end if;
	
	end process;
		
	RX_FRAMECLK_O <= internalClk_s;

end Behavioral;
