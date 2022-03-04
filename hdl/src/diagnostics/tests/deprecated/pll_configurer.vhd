library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity pll_configurer is
  port( Clk : in std_logic;
        Rstp : in std_logic;
        Rw_o : out std_logic;
        Data_o16b : out std_logic_vector(15 downto 0);
        Data_i8b : in std_logic_vector(7 downto 0);
        Finished_o : out std_logic;
        Val_o : out std_logic;
        Rdy_i : in std_logic);
end pll_configurer;
architecture behavioral of pll_configurer is

component interpreter
port( 
            rstp : in std_logic; -- positive reset
            clk : in std_logic;
            -- A channel
            Ardy_o : out std_logic; -- data ready
            Aval_i : in std_logic; -- data valid
            Adata_i19b : in std_logic_vector(18 downto 0);
            -- B channel
            Brdy_i : in std_logic;
            Bval_o : out std_logic;
            Finished_o : out std_logic;
            Bdata_i8b : in std_logic_vector(7 downto 0);
            Bdata_o16b : out std_logic_vector(15 downto 0);
            Brw_o : out std_logic 
        );
end component;

component feeder
    port(
            clk : in std_logic;
            rstp : in std_logic;
            raw_data_o19b : out std_logic_vector(18 downto 0);
            valid_o : out std_logic;
            ready_i : in std_logic
        );
end component;

signal valid: std_logic;
signal rdy: std_logic;
signal raw_data_19b: std_logic_vector(18 downto 0);

begin

  feeder_i: feeder
  port map(clk => Clk,
           rstp => Rstp,
           raw_data_o19b(18 downto 0) => raw_data_19b,
           valid_o => valid,
           ready_i => rdy);

  interpreter_i: interpreter
  port map(rstp => Rstp,
           clk => Clk,
           Ardy_o => rdy,
           Aval_i => valid,
           Adata_i19b(18 downto 0) => raw_data_19b,
           Brdy_i => Rdy_i,
           Bval_o => Val_o,
           Finished_o => Finished_o, 
           Bdata_i8b(7 downto 0) => Data_i8b,
           Bdata_o16b(15 downto 0) => Data_o16b,
           Brw_o => Rw_o);

end architecture;
