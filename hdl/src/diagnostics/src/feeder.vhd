
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity feeder is
  port(
        clk : in std_logic;
        rstp : in std_logic;
        raw_data_o19b : out std_logic_vector(18 downto 0);
        valid_o : out std_logic;
        ready_i : in std_logic
      );
end feeder;
architecture behavioral of feeder is


  COMPONENT test_rom
    PORT (
           clka : in std_logic;
           addra : in std_logic_vector(9 downto 0);
           douta : out std_logic_vector(18 downto 0)
         );
  END COMPONENT;


  signal addr_cnt: std_logic_vector(9 downto 0);
  signal delay_2cyc: std_logic_vector(1 downto 0);
  signal new_addr: std_logic;
  signal ready_cc: std_logic;
  signal valid: std_logic;

begin
    -- bram memory
  test_rom_i : test_rom
  PORT MAP (
             clka => clk,
             addra => addr_cnt,
             douta => raw_data_o19b
           );

    -- increment address (edge detection) and generate valid signal --
    increment_addr: process(clk, rstp) begin
      if(rstp = '1') then
        ready_cc <= '0';
        valid <= '0';
        delay_2cyc <= "01";
        addr_cnt <=  (others => '0'); -- start at maximum value
      else
        if(rising_edge(clk)) then
          ready_cc <= ready_i; -- for edge detection 
          addr_cnt <= addr_cnt; 
          valid <= valid;

          -- delay the new_addr signal (2 cycles)
          delay_2cyc <= delay_2cyc(0) & '0';
          if(delay_2cyc(1) = '1' and delay_2cyc(0) = '0') then
            valid <= '1';
          end if;

          -- falling edge detection
          if(ready_i = '0' and ready_cc = '1') then
            addr_cnt <= addr_cnt + 1; 
            delay_2cyc <= delay_2cyc(0) & '1';
            valid <= '0';
          end if;
        end if;
      end if;
    end process increment_addr;

    -- signal assignments --
  valid_o <= valid;

end architecture;
