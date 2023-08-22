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


entity gbt_rx_frameclk_pll is
   port ( 
      RESET_I                                   : in  std_logic;
      RX_WORDCLK_I                              : in  std_logic;          
      FRAMECLK_O                                : out std_logic;   -- Comment: Phase aligned 40MHz output.     
      PLL_LOCKED_O                              : out std_logic
   );
end gbt_rx_frameclk_pll;

architecture Behavioral of gbt_rx_frameclk_pll is

	 component rx_frmclk_pll
         port
          (-- Clock in ports
           clkfb_in          : in     std_logic;
           -- Clock out ports
           clk_out1          : out    std_logic;
           clkfb_out         : out    std_logic;
           -- Status and control signals
           reset             : in     std_logic;
           locked            : out    std_logic;
           clk_in1           : in     std_logic
          );
     end component; 
	
	 signal clkfb		   : std_logic;
	 
begin

        pll_inst : rx_frmclk_pll
           port map ( 
               clkfb_in => clkfb,
               clkfb_out => clkfb,
               clk_out1 => FRAMECLK_O,        
               reset => RESET_I,
               locked => PLL_LOCKED_O,
               clk_in1 => RX_WORDCLK_I
            );

end Behavioral;
