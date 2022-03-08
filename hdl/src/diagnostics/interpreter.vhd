-- descriptions:
-- bram rom has to be set follows: out data width [18:0], address [8:0]
-- data word structure {flag[2:0], reg[7:0], val/mask[7:0]}
-- wait data word sructure [0x4, wait_cycles_cnt[15:0]]
-- end of memory [0x3, 0xed, 0xXX]
-- flags: 0x0 - copy
--        0x1 - set
--        0x2 - clear
--        0x3 - read
--        0x4 - write
--        0x5 - validate 
--        0x6 - stay (wait)
--        0x7 - combine
-- TODO add fail signal if the pll is not responding

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity interpreter is
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
end interpreter;
architecture behavioral of interpreter is

  -- state constants --
  constant IDLE: std_logic_vector(2 downto 0) := "000";
  constant LOAD: std_logic_vector(2 downto 0) := "001";
  constant DECD: std_logic_vector(2 downto 0) := "010";
  constant READ: std_logic_vector(2 downto 0) := "011";
  constant WRIT: std_logic_vector(2 downto 0) := "100";
  constant VALD: std_logic_vector(2 downto 0) := "101";
  constant STAY: std_logic_vector(2 downto 0) := "110";

  -- flag constants --
  constant COPY: std_logic_vector(2 downto 0) := "000";
  constant SET: std_logic_vector(2 downto 0) := "001";
  constant CLR: std_logic_vector(2 downto 0) := "010";
  constant COMB: std_logic_vector(2 downto 0) := "111";

  signal state: std_logic_vector(2 downto 0);

  signal flag: std_logic_vector(2 downto 0);
  signal actual_reg_id: std_logic_vector(7 downto 0);
  signal actual_reg_val: std_logic_vector(7 downto 0);
  signal last_reg_val: std_logic_vector(7 downto 0);
  signal last_reg_id: std_logic_vector(7 downto 0);
  signal rw: std_logic;
  signal brdy_cc: std_logic;
  signal stay_cnt: std_logic_vector(15 downto 0);

  signal bdata_valid: std_logic;
  signal ready_to_load: std_logic;
  signal data_to_bus_16b: std_logic_vector(15 downto 0);
  signal first_read_byte: std_logic_vector(7 downto 0);
  signal second_read_byte: std_logic_vector(7 downto 0);
  signal end_of_memory: std_logic;
  signal finished: std_logic;
  signal end_of_validation: std_logic;
  signal sloop: std_logic;

  -- data shift registers for port A and B
  signal adata_shift_reg38b: std_logic_vector(37 downto 0);
  signal bdata_shift_reg16b: std_logic_vector(15 downto 0);

begin

-- interpreter fsm --
interpreter_fsm: process(clk, rstp) begin
  if(rstp = '1') then
    bdata_valid <= '0';
    ready_to_load <= '0';
    state <= IDLE;
    finished <= '0';
    sloop <= '0';
    end_of_validation  <= '0';
    rw <= '1'; -- read/write flag
    stay_cnt <= (others => '0');
    data_to_bus_16b <= (others => '0');
    adata_shift_reg38b <= (others => '0');
    bdata_shift_reg16b <= (others => '0');
  else
    if(rising_edge(clk)) then
      brdy_cc <= Brdy_i;
      state <= "UUU";
      finished <= '0';
      case state is
        when IDLE =>
          bdata_valid <= '0';
          ready_to_load <= '1';
          state <= state;
          rw <= '1'; -- read/write flag (default: read)
          if(Aval_i = '1' and Brdy_i = '1' and end_of_memory = '0') then
            ready_to_load <= '0';
            state <= LOAD;
          elsif(end_of_memory = '1') then
            finished <= '1';
          end if;
        when LOAD  => 
          --assert Brdy_i = '0' severity error;
          ready_to_load <= '0';
          state <= DECD;
          adata_shift_reg38b <= adata_shift_reg38b(18 downto 0) 
                                & Adata_i19b; 
          --report "value1: " & integer'IMAGE(to_integer(unsigned(adata_shift_reg38b(37 downto 19))));
          --report "value2: " & integer'IMAGE(to_integer(unsigned(adata_shift_reg38b(18 downto 0))));
        when DECD => 
          state <= flag;
          -- choose the next state based on flag --
          if(end_of_memory = '1') then
            state <= IDLE;
          elsif(flag = COPY or flag = CLR or flag = SET 
            or flag = COMB) then
            state <= WRIT;
            rw <= '0';
          end if;
        when WRIT => 
          state <= state;
          bdata_valid <= '0';
          rw <= '0';
          data_to_bus_16b <= actual_reg_val & actual_reg_id; 

          -- incomming data struct: [first_read_byte, second_read_byte] <-- 
          if(flag = SET ) then
            data_to_bus_16b <= (second_read_byte or 
                                actual_reg_val) & actual_reg_id;  
          elsif(flag = CLR) then
            -- apply bit mask to the read byte --
            data_to_bus_16b <= (second_read_byte and 
                                not(actual_reg_val)) & actual_reg_id;  
          elsif(flag = COPY) then
            data_to_bus_16b <= (second_read_byte or 
                               (first_read_byte and actual_reg_val)) 
                               & actual_reg_id;
          elsif(flag = COMB) then
            data_to_bus_16b <= ((second_read_byte and not(actual_reg_id)) 
                               or actual_reg_val) & last_reg_id;
          end if;

          if(brdy_cc = '0' and Brdy_i = '1') then
            state <= IDLE;
            ready_to_load <= '1'; 
          elsif(Brdy_i = '1') then
            bdata_valid <= '1';
          end if;
        when READ => 
          state <= state;
          bdata_valid <= '0'; 
          data_to_bus_16b <= actual_reg_val & actual_reg_id; 
          if(brdy_cc = '0' and Brdy_i = '1') then
            if(end_of_validation = '0' and sloop = '1') then
              state <= DECD;
              adata_shift_reg38b <= adata_shift_reg38b(18 downto 0) 
                                  & adata_shift_reg38b(37 downto 19); 
            else 
              state <= IDLE;
              ready_to_load <= '1'; 
            end if;
            bdata_shift_reg16b <= bdata_shift_reg16b(7 downto 0) 
                                  & Bdata_i8b; 
          elsif(Brdy_i = '1') then
            bdata_valid <= '1'; 
          end if;
        when VALD => 
          if((second_read_byte and actual_reg_id) = actual_reg_val) then
            end_of_validation <= '1';
            state <= IDLE;
            ready_to_load <= '1'; 
            sloop <= '0';
          else
            sloop <= '1';
            state <= DECD;
            end_of_validation <= '0';
            -- shift back the raw data --
            adata_shift_reg38b <= adata_shift_reg38b(18 downto 0) 
                                  & adata_shift_reg38b(37 downto 19); 
          end if;
        when STAY => 
          stay_cnt <= stay_cnt + 1;
          state <= state;
          if(stay_cnt = (actual_reg_val & actual_reg_id)) then
            stay_cnt <= (others => '0');
            state <= IDLE;
            ready_to_load <= '1'; 
          end if;
        when others => 
          bdata_valid <= '0';
          ready_to_load <= '1'; 
          state <= IDLE;
      end case;
    end if;
  end if;
end process interpreter_fsm;

-- output port assignments --
Ardy_o <= ready_to_load;
Bval_o <= bdata_valid;
Bdata_o16b <= data_to_bus_16b;
Brw_o <= rw;
Finished_o <= finished;

-- decode memory chunk --
flag <= adata_shift_reg38b(18 downto 16); 
actual_reg_val <= adata_shift_reg38b(15 downto 8);
actual_reg_id <= adata_shift_reg38b(7 downto 0);
last_reg_id <= adata_shift_reg38b(26 downto 19);
last_reg_val <= adata_shift_reg38b(34 downto 27);

-- incoming data from connected device to port B
first_read_byte <= bdata_shift_reg16b(15 downto 8);
second_read_byte <= bdata_shift_reg16b(7 downto 0);

end_of_memory <= '1' when ((flag = READ) and 
                           (actual_reg_val = x"ed")) else '0';

end architecture;
