library IEEE;
library unisim;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use unisim.vcomponents.all;

entity mcoi_diagnostics_top is
  port( 
        MGT_clk_p : in std_logic;
        MGT_clk_n : in std_logic;
        Clk_out : out std_logic;
        Clk100m_pl_p : in std_logic;
        Clk100m_pl_n : in std_logic;
        Rstn : in std_logic;
        Finished_o : out std_logic;
        Sda_io : inout std_logic;
        Scl_io : inout std_logic);
end mcoi_diagnostics_top;
architecture behavioral of mcoi_diagnostics_top is

  component pll_7mhz
    port( clk1m_out : out std_logic;
          reset : in std_logic;
          clk100m_in : in std_logic);
  end component;

  component mcoi_diagnostics
    port( 
          Clk : in std_logic;
          Rstp : in std_logic;
          Finished_o: out std_logic;
          Sda_io : inout std_logic;
          Scl_io : inout std_logic);
  end component;

signal rst: std_logic;
signal clk100m_from_buffer: std_logic;
signal clk7mhz: std_logic;
signal invertor: std_logic;
signal clk_from_gte4: std_logic;


begin

  rst <= not Rstn;
  Finished_o <= not invertor;

  -- pll 7Mhz
  pll7m_i: pll_7mhz
  port map ( clk1m_out => clk7mhz,
             reset => rst,
             clk100m_in => clk100m_from_buffer);


  ibufds_gte4_inst : IBUFDS_GTE4
  port map ( O => open,  
             ODIV2 => clk_from_gte4,
             CEB => '1',
             I => MGT_clk_p,  
             IB => MGT_clk_n);

  bufg_gt_inst : BUFG_GT
  port map( O => Clk_out,
            CE => '1',
            CEMASK => '0',
            CLR => '0',
            CLRMASK => '0',
            DIV => "000",
            I => clk_from_gte4);

  -- differential clock buffer
  iobufds_inst : IBUFDS
  port map (O => clk100m_from_buffer, 
            I => Clk100m_pl_p, 
            Ib => Clk100m_pl_n);

  -- TODO clock enabling
  
  -- diagnostics module
  diagnostics_i: mcoi_diagnostics
  port map(Clk => clk7mhz,
           Rstp => rst,
           Finished_o => invertor,
           Sda_io => Sda_io,
           Scl_io => Scl_io);



end architecture;
