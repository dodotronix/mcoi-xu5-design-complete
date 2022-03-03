library IEEE;
use IEEE.std_logic_1164.all;

entity I2cReader_top is
  port(clk : in std_logic;
       rstp : in std_logic;

         -- i2c interface --
       sda_io : inout std_logic;
       scl_io : inout std_logic;

         -- data in/out --
       data_i16b : in std_logic_vector(15 downto 0);
       data_o8b : out std_logic_vector(7 downto 0);

         -- control interface --
       begin_i : in std_logic;
       rw_i : in std_logic;
       ready_o : out std_logic
     );
end I2cReader_top;

architecture behavioral of I2cReader_top is

  component I2cReader
    port(
            -- common signals
          rstp : in std_logic;
          clk : in std_logic;

            -- i2c master generic
          Done_i : in std_logic;
          AckReceived_i : in std_logic;
          Byte_i8b : in std_logic_vector(7 downto 0);
          Byte_o8b : out std_logic_vector(7 downto 0);
          SendStartBit_o : out std_logic;
          SendByte_o : out std_logic;
          GetByte_o : out std_logic;
          SendStopBit_o : out std_logic;
          AckToSend_o : out std_logic;

            -- Reader IOs
          rw_i : in std_logic;
          ready_o : out std_logic;
          begin_i : in std_logic;
          data_o8b : out std_logic_vector(7 downto 0);
          data_i16b : in std_logic_vector(15 downto 0)
        );
  end component;

  component I2cMasterGeneric
    port(Clk_ik: in std_logic;
         Rst_irq: in std_logic;

         SendStartBit_ip: in std_logic;
         SendByte_ip: in std_logic;
         GetByte_ip: in std_logic;
         SendStopBit_ip: in std_logic;
         Byte_ib8: in std_logic_vector(7 downto 0);
         AckToSend_i: in std_logic;
         Byte_ob8: out std_logic_vector(7 downto 0);
         AckReceived_o: out std_logic;
         Done_o: out std_logic;

         Scl_ioz: inout std_logic;
         Sda_ioz: inout std_logic);
  end component;

-- signals --
  signal done: std_logic;
  signal ack_recv: std_logic;
  signal byte_to_bus: std_logic_vector(7 downto 0);
  signal byte_from_bus: std_logic_vector(7 downto 0);
  signal startb: std_logic;
  signal sendb: std_logic;
  signal getb: std_logic;
  signal stopb: std_logic;
  signal ack_snd: std_logic;
  signal sda: std_logic;
  signal scl: std_logic;

begin
  i2c_reader_i: I2cReader
  port map(rstp => rstp,
           clk => clk,
           Done_i => done,
           AckReceived_i => ack_recv,
           Byte_i8b(7 downto 0) => byte_from_bus,
           Byte_o8b(7 downto 0) => byte_to_bus,
           SendStartBit_o => startb,
           SendByte_o => sendb,
           GetByte_o => getb,
           SendStopBit_o => stopb,
           AckToSend_o => ack_snd,
           rw_i => rw_i,
           ready_o => ready_o,
           begin_i => begin_i,
           data_o8b(7 downto 0) => data_o8b,
           data_i16b(15 downto 0) => data_i16b);

  i2c_master_i: I2cMasterGeneric
  port map(Clk_ik => clk,
           Rst_irq => rstp,
           SendStartBit_ip => startb,
           SendByte_ip => sendb,
           GetByte_ip => getb,
           SendStopBit_ip => stopb,
           Byte_ib8(7 downto 0) => byte_to_bus,
           Byte_ob8(7 downto 0) => byte_from_bus,
           AckToSend_i => ack_snd,
           AckReceived_o => ack_recv,
           Done_o => done,
           Scl_ioz => scl,
           Sda_ioz => sda);

    ---- pull-ups --
    --scl <= 'H';
    --sda <= 'H';

  scl_io <= scl;
  sda_io <= sda;


end architecture;
