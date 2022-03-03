library IEEE;
library unisim;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use unisim.vcomponents.all;

entity mcoi_diagnostics is
  port( 
        Clk : in std_logic;
        Rstp : in std_logic;
        Finished_o: out std_logic;
        Sda_io : inout std_logic;
        Scl_io : inout std_logic);
end mcoi_diagnostics;
architecture behavioral of mcoi_diagnostics is

  component pll_configurer
    port( Clk : in std_logic;
          Rstp : in std_logic;
          Rw_o : out std_logic;
          Data_o16b : out std_logic_vector(15 downto 0);
          Data_i8b : in std_logic_vector(7 downto 0);
          Finished_o : out std_logic;
          Val_o : out std_logic;
          Rdy_i : in std_logic);
  end component;

  component I2cMasterGeneric 
    generic(g_CycleLenght : std_logic_vector(9 downto 0));
    port(
          Clk_ik : in std_logic;
          Rst_irq : in std_logic;
          SendStartBit_ip : in std_logic;
          SendByte_ip : in std_logic;
          GetByte_ip : in std_logic;
          SendStopBit_ip : in std_logic;
          Byte_ib8 : in std_logic_vector(7 downto 0);
          AckToSend_i : in std_logic;
          Byte_ob8 : out std_logic_vector(7 downto 0);
          AckReceived_o : out std_logic;
          Done_o : out std_logic;

          Scl_ioz : inout std_logic;
          Sda_ioz : inout std_logic);
  end component;

  component I2cReader
    port(
          clk : in std_logic;
          rstp : in std_logic;

          -- i2c master generic
          Done_i : in std_logic;
          AckReceived_i : in std_logic;
          SendStartBit_o : out std_logic;
          SendByte_o : out std_logic;
          GetByte_o : out std_logic;
          SendStopBit_o : out std_logic;
          AckToSend_o : out std_logic;
          Byte_ib8 : in std_logic_vector(7 downto 0);
          Byte_ob8 : out std_logic_vector(7 downto 0);

          -- data ports
          Data_i16b : in std_logic_vector(15 downto 0);
          Data_o8b : out std_logic_vector(7 downto 0);

          -- Reader IOs
          Rw_i : in std_logic;
          Ready_o : out std_logic;
          Valid_i : in std_logic;
          Dev_addr_i7b : in std_logic_vector(6 downto 0));
  end component;

  constant SLVADDR: std_logic_vector(6 downto 0) := "1110000";

  -- signals --
  signal send_startb: std_logic;
  signal send_byte: std_logic;
  signal get_byte: std_logic;
  signal send_stopb: std_logic;
  signal send_ack: std_logic;
  signal byte_from_i2c: std_logic_vector(7 downto 0);
  signal byte_to_i2c: std_logic_vector(7 downto 0);
  signal data_to_reader: std_logic_vector(15 downto 0);
  signal data_from_reader: std_logic_vector(7 downto 0);
  signal rw: std_logic;
  signal rdy: std_logic;
  signal valid: std_logic;
  signal done: std_logic;
  signal ack_recv: std_logic;
begin

  -- clock enabling

  -- i2c reader --
  i2c_reader_i: I2cReader
  port map(clk => Clk,
           rstp => Rstp,
           Done_i => done,
           AckReceived_i => ack_recv,
           SendStartBit_o => send_startb,
           SendByte_o => send_byte,
           GetByte_o => get_byte,
           SendStopBit_o => send_stopb,
           AckToSend_o => send_ack,
           Byte_ib8 => byte_from_i2c,
           Byte_ob8 => byte_to_i2c,
           Data_i16b(15 downto 0) => data_to_reader,
           Data_o8b(7 downto 0) => data_from_reader,
           Rw_i => rw,
           Ready_o => rdy,
           Valid_i => valid,
           Dev_addr_i7b(6 downto 0) => SLVADDR);

  -- configurer --
  pll_configurer_i: pll_configurer
  port map(Clk => Clk,
           Rstp => Rstp,
           Rw_o => rw,
           Data_o16b(15 downto 0) => data_to_reader,
           Data_i8b(7 downto 0) => data_from_reader,
           Finished_o => Finished_o, 
           Val_o => valid,
           Rdy_i => rdy);

  -- i2c master
  i2c_driver_i: I2cMasterGeneric
  generic map(g_CycleLenght => "00" & x"07") -- divide by 9 for freq 7Mhz
  port map(Clk_ik => Clk,
           Rst_irq => Rstp,
           SendStartBit_ip => send_startb,
           SendByte_ip => send_byte,
           GetByte_ip => get_byte,
           SendStopBit_ip => send_stopb,
           AckToSend_i => send_ack,
           Byte_ib8(7 downto 0) => byte_to_i2c,
           Byte_ob8(7 downto 0) => byte_from_i2c,
           AckReceived_o => ack_recv,
           Done_o => done,
           Scl_ioz => Scl_io,
           Sda_ioz => Sda_io);

end architecture;
