---
-- Petr Pacner | BRNO |   
-- description: TODO
---
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.env.finish;

library std;
use std.textio.all;

entity Interpreter_tb is
end Interpreter_tb;

architecture behavioral of Interpreter_tb is
constant PERIOD: time := 20 ns;

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

--component I2cReader_top
    --port(clk : in std_logic;
         --rstp : in std_logic;

         ---- i2c interface --
         --sda_io : inout std_logic;
         --scl_io : inout std_logic;

         ---- data in/out --
         --data_i16b : in std_logic_vector(15 downto 0);
         --data_o8b : out std_logic_vector(7 downto 0);

         ---- control interface --
         --begin_i : in std_logic;
         --rw_i : in std_logic;
         --ready_o : out std_logic
     --);
--end component;

-- common signals --
signal clk: std_logic := '0';
signal rstp: std_logic;
signal shift_reg38b: std_logic_vector(37 downto 0);
--signal sda_io: std_logic;
--signal scl_io: std_logic;
--signal data_o8b: std_logic_vector(7 downto 0);

-- address counter signals --

signal Brdy_i: std_logic;
signal Bval_o: std_logic;
signal Bdata_i8b: std_logic_vector(7 downto 0);
signal Bdata_o16b: std_logic_vector(15 downto 0);
signal raw_data_o19b: std_logic_vector(18 downto 0);
signal Brw_o: std_logic;
signal rdy: std_logic;
signal valid: std_logic;
signal valid_cc: std_logic;

-- decoder signals
signal flag: std_logic_vector(2 downto 0);
signal low_byte: std_logic_vector(7 downto 0);
signal high_byte: std_logic_vector(7 downto 0);

-- simulation of slave data memory
type MEM is array (0 to 5) of std_logic_vector(7 downto 0);
signal memory_block: MEM := (x"02", x"03", x"00", x"04", x"f0", x"02");
signal sent_data16: std_logic_vector(15 downto 0);

begin

  high_byte <= shift_reg38b(34 downto 27);
  low_byte <= shift_reg38b(26 downto 19);
  flag <= shift_reg38b(37 downto 35);

  stimulus: process
    variable index: integer;
    variable validation_cyc: integer;
    variable expected_result: integer;
    variable last_register: integer;
  begin
    index := 0;
    validation_cyc := 0;
    expected_result := 0;
    last_register := 0;
    rstp <= '1';
    Brdy_i <= '1';
    Bdata_i8b <= (others => '0');
    sent_data16 <= (others => '0');
    wait for 4*PERIOD;

    rstp <= '0';

    report "Start Verification";
    while(not(flag = "011" and high_byte = x"ed")) loop
      while(true) loop
        wait until rising_edge(clk);
        if(Bval_o = '1') then
      --wait until (Bval_o = '1');
      --wait until rising_edge(clk);
          Brdy_i <= '0';
          wait until rising_edge(clk);
      --implement decoder of the flags
      -- TODO use the variables in array and calculate -- output
      -- image and copare it with the output of the digital block
          case to_integer(unsigned(flag)) is 
            when 0 => -- report "Copy flag !!!";
              expected_result := to_integer(unsigned(sent_data16(7 downto 0) or (sent_data16(15 downto 8) and high_byte)));
          --report integer'image(to_integer(unsigned(Bdata_o16b(15 downto 8))));
          --report integer'image(to_integer(unsigned(Bdata_o16b(7 downto 0))));
              assert Bdata_o16b(15 downto 8) = std_logic_vector(to_unsigned(expected_result, 8)) report "Data does not match expected result" severity failure;
              assert Bdata_o16b(7 downto 0) = low_byte report "Destination register does not match with the input value" severity failure;
              assert Brw_o = '0' report "Wrong Read/Write flag on output" severity failure; 
            when 1 => -- report "Set flag !!!";
              expected_result := to_integer(unsigned(sent_data16(7 downto 0) or high_byte)); 
              assert Bdata_o16b(15 downto 8) = std_logic_vector(to_unsigned(expected_result, 8)) report "Data does not match expected result" severity failure;
              assert Bdata_o16b(7 downto 0) = low_byte report "Destination register does not match with the input value" severity failure;
              assert Brw_o = '0' report "Wrong Read/Write flag on output" severity failure; 
            when 2 => -- report "Clear flag !!!";
              expected_result := to_integer(unsigned(sent_data16(7 downto 0) and (not high_byte))); 
              assert Bdata_o16b(15 downto 8) = std_logic_vector(to_unsigned(expected_result, 8)) report "Data does not match expected result" severity failure;
              assert Bdata_o16b(7 downto 0) = low_byte report "Destination register does not match with the input value" severity failure;
              assert Brw_o = '0' report "Wrong Read/Write flag on output" severity failure; 
            when 3 => -- report "Read flag!!!";
              last_register := to_integer(unsigned(low_byte)); 
              index := to_integer(unsigned(Bdata_o16b(7 downto 0))); -- read pointer
              assert rdy = '0' report "signal ready has to be down" severity failure;
          -- check the expected data based on input from feeder
              assert low_byte = Bdata_o16b(7 downto 0) report "wrong low byte on output" severity failure; 
              assert high_byte = Bdata_o16b(15 downto 8) report "wrong high byte on output" severity failure; 
              assert Brw_o = '1' report "wrong Read/Write flag on output" severity failure;
          -- prepare data for reading
              Bdata_i8b <= memory_block(index);
              sent_data16  <= sent_data16(7 downto 0) & memory_block(index);
            when 4 => -- report "Write flag!!!";
              assert Bdata_o16b = (high_byte & low_byte) report "Data does not match expected result" severity failure;
              assert Brw_o = '0' report "wrong Read/Write flag on output" severity failure; 
            when 5 => -- report "Valid flag !!!";
              validation_cyc := validation_cyc + 1;
              report integer'image(validation_cyc);
              if(validation_cyc = 2) then
                Bdata_i8b <= high_byte;
                sent_data16  <= sent_data16(7 downto 0) & high_byte;
          --assert (high_byte and low_byte) = high_byte report "validation failure" severity failure;
              end if;
            when 6 => -- report "Stay flag !!!";
              for i in 0 to to_integer(unsigned((shift_reg38b(34 downto 19)))) - 1 loop
                wait until rising_edge(clk);
                assert Bval_o = '0' and rdy = '0' report "Data valid signal is active" severity failure;
              end loop;
            when 7 => -- report "Combine flag !!!";
              expected_result := to_integer(unsigned((sent_data16(7 downto 0) and low_byte) or high_byte)); 
              assert Bdata_o16b(15 downto 8) = std_logic_vector(to_unsigned(expected_result, 8)) report "Data does not match expected result" severity failure;
              assert Bdata_o16b(7 downto 0) = std_logic_vector(to_unsigned(last_register, 8)) report "Destination register does not match with the input value" severity failure;
              assert Brw_o = '0' report "Wrong Read/Write flag on output" severity failure; 
            when others => 
              assert FALSE report "This must never happen" severity failure;
          end case;

          if(to_integer(unsigned(flag)) /= 5) then
            validation_cyc := 0;
          end if;

      -- in the validation process new data from feeder must not have been read
          if(validation_cyc > 0) then
            assert rdy = '0' report "signal ready has to be down" severity failure;
          end if;

          wait for 150 ns;
          Brdy_i <= '1';
        elsif(high_byte = x"ed") then
          exit;
        end if;
      end loop;
    end loop;
    report "Calling 'finish'";
    finish;
  end process stimulus;

    -- load data to shift register --
  get_raw_input: process(clk, rstp) 
    variable raw_data : integer;
  begin
    if(rstp = '1') then
      shift_reg38b  <= (others => '0');
    else
      if(rising_edge(clk)) then
        valid_cc <= valid;
        if (valid_cc = '0' and valid = '1') then
          shift_reg38b <= shift_reg38b(18 downto 0) & raw_data_o19b;
          --raw_data := to_integer(unsigned(raw_data_o19b));
          --report "raw data value: " & integer'image(raw_data);
        end if;
      end if;
    end if;
  end process get_raw_input;

    -- clock source
  clk <= not clk after PERIOD;

  feeder_i: feeder
  port map(clk => clk,
           rstp => rstp,
           raw_data_o19b(18 downto 0) => raw_data_o19b,
           valid_o => valid,
           ready_i => rdy);

  interpreter_i: interpreter
  port map(rstp => rstp,
           clk => clk,
           Ardy_o => rdy,
           Aval_i => valid,
           Adata_i19b(18 downto 0) => raw_data_o19b,
           Brdy_i => Brdy_i,
           Bval_o => Bval_o,
           Bdata_i8b(7 downto 0) => Bdata_i8b,
           Bdata_o16b(15 downto 0) => Bdata_o16b,
           Brw_o => Brw_o
         );

    -- interpreter --
    -- DUT --
    --i2c_reader_top_i: I2cReader_top
    --port map(clk => clk,
             --rstp => rstp,
             --sda_io => sda_io,
             --scl_io => scl_io,
             --data_i16b(15 downto 0) => data_i16b,
             --data_o8b(7 downto 0) => data_o8b,
             --begin_i => bgn,
             --rw_i => rw,
             --ready_o => rdy);

--sda_io <= 'H';
--scl_io <= 'H';


end architecture;
