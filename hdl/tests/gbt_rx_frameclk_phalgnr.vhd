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
    use ieee.numeric_std.all;

-- Xilinx devices library:
--library unisim;
--    use unisim.vcomponents.all;

-- Custom libraries and packages:
    use work.gbt_bank_package.all;
    use work.vendor_specific_gbt_bank_package.all;
    use work.gbt_exampledesign_package.all;


entity gbt_rx_frameclk_phalgnr is
   Generic (
      RX_OPTIMIZATION                           : integer := 1;
      TX_OPTIMIZATION                           : integer := 1;
      
      DIV_SIZE_CONFIG                           : integer := 3;
		METHOD												: integer := GATED_CLOCK;
		CLOCKING_SCHEME                           : integer := BC_CLOCK
   );
   port ( 

      --=======--
      -- Reset --
      --=======-- 
      RESET_I                                   : in  std_logic;

      --===============--
      -- Clocks scheme --
      --===============--

      RX_WORDCLK_I                              : in  std_logic;  
      FRAMECLK_I                                : in  std_logic;            
      RX_FRAMECLK_O                             : out std_logic;   -- Comment: Phase aligned 40MHz output.     
		RX_CLKEn_o                                : out std_logic;
		
      --=========--
      -- Control --
      --=========--
      SYNC_I                                    : in  std_logic;
      CLK_ALIGN_CONFIG                          : in std_logic_vector(DIV_SIZE_CONFIG-1 downto 0);
      --=========--
      -- Status  --
      --=========--
      DEBUG_CLK_ALIGNMENT                       : out std_logic_vector(DIV_SIZE_CONFIG-1 downto 0);
      
      PLL_LOCKED_O                              : out std_logic;
      DONE_O                                    : out std_logic
      
   );
end gbt_rx_frameclk_phalgnr;

architecture Behavioral of gbt_rx_frameclk_phalgnr is

    signal pllLocked				: std_logic;
	 signal rxFrameClk_from_pll	    : std_logic;
	 signal reset_from_PhDet		: std_logic;
	 
    signal greset_pll              : std_logic;
	 
	 component gbt_rx_frameclk_pll is
		port (
			RESET_I                   : in  std_logic;
			RX_WORDCLK_I              : in  std_logic;  
			FRAMECLK_O                : out std_logic;
			PLL_LOCKED_O              : out std_logic
		);
	 end component gbt_rx_frameclk_pll;
	
	 signal alignementDone : std_logic;
	 
	 signal serialToParallel: std_logic_Vector((DIV_SIZE_CONFIG-1) downto 0);
	 signal deserializerReset : std_logic;
	 
	 signal syncShifterReg : std_logic_vector(RX_GEARBOXSYNCSHIFT_COUNT+1 downto 0);
	 
begin
   
	bcclock_gen: if CLOCKING_SCHEME = BC_CLOCK generate
	
		latOpt_pll_phalgnr_gen: if RX_OPTIMIZATION = LATENCY_OPTIMIZED and METHOD = PLL generate

			RX_CLKEn_o <= '1';
			
			pll_inst: gbt_rx_frameclk_pll
				port map(
					PLL_LOCKED_O       => pllLocked,
					FRAMECLK_O         => rxFrameClk_from_pll,
					RX_WORDCLK_I       => RX_WORDCLK_I,
					RESET_I            => greset_pll
				);

			greset_pll <= (RESET_I or reset_from_PhDet);
			  
			--==================================--
			-- Frameclock deserializer          --
			--==================================--
			frameclockDeserializer_proc: process(pllLocked, RX_WORDCLK_I)
			begin
			
				 if pllLocked = '0' then
					  serialToParallel <= (others => '0');
					  alignementDone <= '0';
					  reset_from_PhDet <= '0';
					  
				 elsif rising_edge(RX_WORDCLK_I) then
					  serialToParallel((DIV_SIZE_CONFIG-1) downto 1) <= serialToParallel((DIV_SIZE_CONFIG-2) downto 0);
					  serialToParallel(0) <= rxFrameClk_from_pll;
					  
					  if SYNC_I = '1' and alignementDone = '0' then
					  
						  if serialToParallel /= CLK_ALIGN_CONFIG then
								reset_from_PhDet <= '1';
							else
								alignementDone <= '1';
							end if;
							
					  end if;
					  
				 end if;
				 
			end process;
			
			
			PLL_LOCKED_O 	<= pllLocked;
			DONE_O 			<= alignementDone;
			RX_FRAMECLK_O 	<= rxFrameClk_from_pll;
		end generate;

		latOpt_gatedclk_phalgnr_gen: if RX_OPTIMIZATION = LATENCY_OPTIMIZED and METHOD = GATED_CLOCK generate
			
			RX_CLKEn_o <= '1';
			
			clock240Div_gen: if DIV_SIZE_CONFIG = 6 generate
				gatedclock_gen: entity work.gbt_rx_clockdivider
					Generic map(
						CLOCK_DIVIDER_HIGH								=> 3,
						CLOCK_DIVIDER_LOW									=> 3
					)
					port map( 
						RESET_I                                   => RESET_I,
						RX_WORDCLK                                => RX_WORDCLK_I,
						RX_FRAMECLK_O                             => RX_FRAMECLK_O,
						SYNC_I	   										=> SYNC_I,
						PLL_LOCKED_O                              => pllLocked		
					);
			end generate;
			
			clock120Div_gen: if DIV_SIZE_CONFIG = 3 generate
				gatedclock_gen: entity work.gbt_rx_clockdivider
					Generic map(
						CLOCK_DIVIDER_HIGH								=> 2,
						CLOCK_DIVIDER_LOW									=> 1
					)
					port map( 
						RESET_I                                   => RESET_I,
						RX_WORDCLK                                => RX_WORDCLK_I,
						RX_FRAMECLK_O                             => RX_FRAMECLK_O,
						SYNC_I	   										=> SYNC_I,
						PLL_LOCKED_O                              => pllLocked
					);
			end generate;
			
			DONE_O			<= pllLocked;
			PLL_LOCKED_O	<= pllLocked;
				
		end generate;
		
		std_phalgnr_gen: if RX_OPTIMIZATION = STANDARD generate
			  RX_FRAMECLK_O <= FRAMECLK_I;
			  PLL_LOCKED_O <= not(RESET_I); 
			  DONE_O <= not(RESET_I);
			  RX_CLKEn_o <= '1';
		end generate;
	end generate;
			
	mgtfreq_clockingscheme_gen: if CLOCKING_SCHEME = FULL_MGTFREQ generate

		RX_FRAMECLK_O <= RX_WORDCLK_I;
		PLL_LOCKED_O  <= not(RESET_I); 
		DONE_O        <= not(RESET_I);
		
		syncShifterReg(0)  <= SYNC_I;
		
		-- Timing issue: flip-flop stages (configurable)
	   syncShiftReg_gen: for j in 1 to RX_GEARBOXSYNCSHIFT_COUNT+1 generate
	  
			flipflop_proc: process(RESET_I, RX_WORDCLK_I)
			begin
				 if RESET_I = '1' then
					  syncShifterReg(j) <= '0';
					  
				 elsif rising_edge(RX_WORDCLK_I) then
					  syncShifterReg(j) <= syncShifterReg(j-1);
					  
				 end if;
			end process;
			
	   end generate;
		
		RX_CLKEn_o    <= syncShifterReg(RX_GEARBOXSYNCSHIFT_COUNT+1);
			
	end generate;

end Behavioral;
