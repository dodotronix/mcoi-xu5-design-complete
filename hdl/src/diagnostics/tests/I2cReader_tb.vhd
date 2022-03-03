---
-- Petr Pacner | BRNO |   
-- description: TODO
---
library ieee;
library unisim;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use unisim.vcomponents.all;
use std.env.finish;

library std;
use std.textio.all;

entity I2cReader_tb is
end I2cReader_tb;

architecture behavioral of I2cReader_tb is
constant PERIOD: time := 142.86 ns;

component I2C_slave
generic (
    SLAVE_ADDR : std_logic_vector(6 downto 0));
port (
    scl              : inout std_logic;
    sda              : inout std_logic;
    clk              : in    std_logic;
    rst              : in    std_logic;
    -- User interface
    read_req         : out   std_logic;
    data_to_master   : in    std_logic_vector(7 downto 0);
    data_valid       : out   std_logic;
    data_from_master : out   std_logic_vector(7 downto 0));
end component;

component mcoi_diagnostics
port( 
        Clk : in std_logic;
        Rstp : in std_logic;
        Finished_o: out std_logic;
        Sda_io : inout std_logic;
        Scl_io : inout std_logic);
end component;

signal clk: std_logic := '0';
signal rst: std_logic;

signal scl_io: std_logic;
signal sda_io: std_logic;

-- slave signals --
signal data_valid: std_logic;
signal data_from_master: std_logic_vector(7 downto 0);
signal data_to_master: std_logic_vector(7 downto 0);
signal read_req: std_logic;
signal finished: std_logic;

begin
  sda_io <= 'H';
  scl_io <= 'H';

  -- simalation
  stimulus: process begin
    rst <= '1';
    wait for PERIOD*10;
    rst  <= '0';
    wait for PERIOD*2;
    wait until rising_edge(finished);

    report "Calling 'finish'";
    finish;
  end process stimulus;

  -- clock source
  clk <= not clk after PERIOD/2;

------------------------------------------------------------------
  diagnostics_i: mcoi_diagnostics
  port map(Clk => clk,
           Rstp => rst,
           Finished_o => finished,
           Sda_io => sda_io,
           Scl_io => scl_io);

  i2c_slave_i: I2C_slave
  generic map(
  SLAVE_ADDR => "1110000")
  port map(scl => scl_io,
           sda => sda_io,
           clk => clk,
           rst => rst,
           read_req => read_req,
           data_to_master(7 downto 0) => data_to_master,
           data_valid => data_valid,
           data_from_master(7 downto 0) => data_from_master);
  
  checker: process(clk, rst) begin
    if(rst = '1') then
      data_to_master <= x"22";
    else
      if rising_edge(clk) then
        if(data_valid  = '1') then
          report integer'image(to_integer(unsigned(data_from_master)));
          if(data_from_master = x"da") then
            data_to_master <= x"00"; 
          else
            data_to_master <= x"0a";
          end if;
        end if; 
      end if;
    end if;
  end process checker;

end architecture;
