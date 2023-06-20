--============================================================================================
--##################################   Module Information   ##################################
--============================================================================================
--
-- Company: CERN (BE-BI-BL)
--
-- Language: VHDL 2008
--
-- Description:
--
--
--     The input reset is resynchronized in the input clock domain.
--     It is then resynchronized twice in the output clock domain.
--   
--     Asynchronous       |      Output clock domain
--                        |
--                        |
--                        |
--                        |              ___       ___ 
--                        |             | R | Q   | R |
--    reset IN -------------------------|___|-----|___|---- reset OUT
--                        |               |         |  
--                        |  clock OUT --------------
--                        |    cen OUT                         
--
--
--                ________
--     reset IN           \___________________________
--                   ___     ___     ___     ___
--     clock IN   __|   |___|   |___|   |___|   |____
--                 _________
--     signal Q             \\\\____________________
--                 __________________________
--     reset OUT                             \________
--
--
--     Glitch filter consisting of a set of chained flip-flops followed by a comparator. 
--     The comparator toggles to '1' when all FFs in the chain are '1' and respectively to '0' 
--     when all the FFS in the chain are '0'.
--     A latency of filter_length+1 is added on the output
-- 
--     with a filter_length=2 :
--                   ___     ___     ___     ___     ___     ___     ___     ___     ___     ___     ___     ___
--     clock IN   __|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |___
--                   _______________         _______________________         _______
--     data IN   ___|               |_______|                       |_______|       |________________________________
--
--                    1 Filtered                1  NOT filtered   0 filtered 1 filtered      0  NOT filtered
--                                                                   _______________________________________     
--     data OUT  ___________________________________________________|                                       |_______
--
--============================================================================================
--############################################################################################
--============================================================================================


----------------------------------------------------------------------------------------------------
-- Libraries
----------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

----------------------------------------------------------------------------------------------------
-- Entity
----------------------------------------------------------------------------------------------------
entity vme_reset_sync_and_filter is
  port(
    rst_ir   : in  std_logic;   -- reset input
    clk_ik   : in  std_logic;   -- clock input
    cen_ie   : in  std_logic;   -- clock enable input
    -- Data input
    data_i   : in  std_logic;   -- Data input
    -- Data output
    data_o   : out std_logic    -- Data output 
  );
end entity;





----------------------------------------------------------------------------------------------------
-- Architecture
----------------------------------------------------------------------------------------------------
architecture rtl of vme_reset_sync_and_filter is
  
  --Function definitions
  function and_reduced(vector : std_logic_vector) return std_logic is
    variable o : std_logic;
  begin
    o := '1';
    for k in vector'range loop
      o := o and vector(k);
    end loop;
    return o;
  end function and_reduced;
  
  function or_reduced(vector : std_logic_vector) return std_logic is
    variable o : std_logic;
  begin
    o := '0';
    for k in vector'range loop
      o := o or vector(k);
    end loop;
    return o;
  end function or_reduced;
  
  -- Synthesis Attributes 
  attribute syn_preserve       : boolean; -- Do not remove those signals and registers
  attribute syn_replicate      : boolean; -- Do not replicate those register
  attribute syn_allow_retiming : boolean; -- Do not optimize timing by changing registers

  -- Resynchronization
  constant  c_NB_RESYNC_FF_MSR : natural := 2;   -- Number of resynchronization flip-flops
  signal    reset_msr          : std_logic_vector(c_NB_RESYNC_FF_MSR-1 downto 0) := (others=>'0'); -- Metastability registers
  attribute syn_preserve       of reset_msr : signal is true;
  attribute syn_replicate      of reset_msr : signal is false;
  attribute syn_allow_retiming of reset_msr : signal is false;

  -- Glitch filter
  constant g_FILTER_LENGTH     : positive := 4;
  signal glitch_filter_pipe    : std_logic_vector(g_FILTER_LENGTH downto 0) := (others=>'0'); --default value for simu 
  signal data_int              : std_logic := '0'; --default value for simu 

begin

  --------------------------------------------------------------------------------------------------
  -- 2 stages of resynchronization in the output clock domain
  --------------------------------------------------------------------------------------------------
  
  p_resync_on_out_clock : process(clk_ik)
  begin
    if rising_edge(clk_ik) then
      if ( cen_ie = '1' ) then
        reset_msr <= reset_msr(reset_msr'left-1 downto 0) & data_i; --synchronous deassertion
      end if;
    end if;
  end process;
  
  --------------------------------------------------------------------------------------------------
  -- Glitch filter
  --------------------------------------------------------------------------------------------------
  
  -- Glitch filtering logic
  glitch_filter_pipe(0) <= reset_msr(reset_msr'left);

  -- Generate glitch filter FFs
  p_filter_pipe: process (rst_ir, clk_ik)
  begin
    if (rst_ir = '1') then
      glitch_filter_pipe(g_FILTER_LENGTH downto 1) <= (others=>'0');
      elsif rising_edge(clk_ik) then
        if (cen_ie = '1') then
          glitch_filter_pipe(g_FILTER_LENGTH downto 1) <= glitch_filter_pipe(g_FILTER_LENGTH-1 downto 0); --shift register
        end if;
      -- end if;
    end if;
  end process;

  -- Set the data output based on the state of the glitch filter
  p_output: process(rst_ir, clk_ik)
  begin
    if (rst_ir = '1') then
        data_int <= '0';
    elsif rising_edge(clk_ik) then
      if (cen_ie = '1') then
        if    (and_reduced(glitch_filter_pipe) = '1') then
          data_int <= '1';
        elsif (or_reduced(glitch_filter_pipe) = '0') then
          data_int <= '0';
        else
          data_int <= data_int;
        end if;
      end if;
    end if;
  end process;
  
  --output assignment
  data_o <= data_int;

end architecture;
