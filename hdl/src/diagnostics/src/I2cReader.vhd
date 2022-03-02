-------------------------------------------------------------------------------
-- Petr Pacner | CERN | 2020-01-13 Mo 10:37   
-- description: 
--              This block serves as controler for CERN I2cMasterGeneric.
--              User signals are:
--              Data_i16b (send byte to device), 
--              Data_08b (receive byte ),
--              Rw_i (user defines direction of transfer),
--              Ready_o (block is ready)
--              Valid_i (user has to set this signal to send data)
--              Dev_addr_i7b (adress of a slave)
--              Other signals are connected according to their names to the 
--              the I2cMasterGeneric entity (for better understanding check the 
--              testbench branch of this digital block)
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity I2cReader is
  port(
        clk  : in std_logic;
        rstp : in std_logic;

        -- i2c master generic
        Done_i         : in std_logic;
        AckReceived_i  : in std_logic;
        SendStartBit_o : out std_logic;
        SendByte_o     : out std_logic;
        GetByte_o      : out std_logic;
        SendStopBit_o  : out std_logic;
        AckToSend_o    : out std_logic;
        Byte_ib8       : in std_logic_vector(7 downto 0);
        Byte_ob8       : out std_logic_vector(7 downto 0);

        -- data ports to reader
        Data_i16b : in std_logic_vector(15 downto 0);
        Data_o8b  : out std_logic_vector(7 downto 0);

        -- Reader IOs
        Rw_i         : in std_logic;
        Ready_o      : out std_logic;
        Valid_i      : in std_logic;
        Dev_addr_i7b : in std_logic_vector(6 downto 0));
end I2cReader;
architecture behavioral of I2cReader is

-- fsm constants --
constant IDLE: std_logic_vector(2 downto 0) := "000";
constant STRT: std_logic_vector(2 downto 0) := "001";
constant ADDR: std_logic_vector(2 downto 0) := "010";
constant WRIT: std_logic_vector(2 downto 0) := "011";
constant READ: std_logic_vector(2 downto 0) := "100";
constant STOP: std_logic_vector(2 downto 0) := "101";

-- fsm state --
signal state: std_logic_vector(2 downto 0);

-- i2c master control signals --
signal startb : std_logic;
signal stopb  : std_logic;
signal sendb  : std_logic;
signal rdy    : std_logic;
signal getb   : std_logic;

-- data in/out buffers --
signal b_to_i2c   : std_logic_vector(7 downto 0);
signal b_from_i2c : std_logic_vector(7 downto 0);

-- reader signals --
signal done_cc   : std_logic;
signal read_flag : std_logic;
signal wrt_fin   : std_logic;

begin
i2c_reader_fsm: process(clk, rstp) begin
  if(rstp = '1') then
    state      <= IDLE;
    rdy        <= '1';
    getb       <= '0';
    stopb      <= '0';
    sendb      <= '0';
    startb     <= '0';
    done_cc    <= '1';
    wrt_fin    <= '0';
    read_flag  <= '0';
    b_from_i2c <= (others => '0');
    b_to_i2c   <= (others => '0');
  else
    if (rising_edge(clk)) then
      state <= "UUU";
      done_cc <= Done_i;
      sendb <= '0';

      case (state) is
        when IDLE => 
          rdy       <= '1';
          state     <= state;
          wrt_fin   <= '0';
          getb      <= '0';
          stopb     <= '0';
          sendb     <= '0';
          startb    <= '0';
          read_flag <= '0';
          if(Valid_i = '1') then
            rdy   <= '0';
            state <= STRT;
          end if;
        when STRT => 
          state  <= state;
          startb <= '0';
          if(Done_i = '1' and done_cc = '0') then
            state  <= ADDR;
          elsif(Done_i = '1') then
            startb <= '1';
          end if;
        when ADDR => 
          state <= state;
          sendb <= '0';
          if(Done_i = '1' and done_cc = '0') then
            state <= WRIT;
            if(AckReceived_i = '1') then
              state <= STOP;
            elsif(read_flag = '1') then
              state <= READ;
            end if;
          elsif(Done_i = '1') then
            sendb <= '1';
            b_to_i2c <= Dev_addr_i7b & '0';  
            if(read_flag = '1') then
              b_to_i2c <= Dev_addr_i7b & '1'; 
            end if;
          end if;
        when WRIT => 
          state <= state;
          sendb <= '0';
          if(Done_i = '1' and done_cc = '0') then
            wrt_fin <= '1';
            state   <= STOP;
            if(AckReceived_i = '0') then
              if(Rw_i = '1') then 
                read_flag <= '1';
                state <= STRT;
              elsif(wrt_fin = '0') then
                state <= state;
              end if;
            end if;
          elsif(Done_i = '1') then
            sendb <= '1';
            b_to_i2c <= Data_i16b(7 downto 0); 
            if(wrt_fin = '1') then
              b_to_i2c <= Data_i16b(15 downto 8); 
            end if;
          end if;
        when READ => 
          state <= state;
          getb <= '0';
          if(Done_i = '1' and done_cc = '0') then
            state <= STOP;
            b_from_i2c <= Byte_ib8;
          elsif(Done_i = '1') then
            getb <= '1';
          end if;
        when STOP => 
          state <= state;
          stopb <= '0';
          if(Done_i = '1' and done_cc = '0') then
            state <= IDLE;
          elsif(Done_i = '1') then
            stopb <= '1';
          end if;
        when others => 
          state <= IDLE;
      end case;
    end if;
  end if;
end process i2c_reader_fsm;

-- outputs --
Byte_ob8       <= b_to_i2c;
Data_o8b       <= b_from_i2c;
SendStartBit_o <= startb;
SendByte_o     <= sendb;
SendStopBit_o  <= stopb;
GetByte_o      <= getb;
AckToSend_o    <= '1';
Ready_o        <= rdy;

end architecture;
