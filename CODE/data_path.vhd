----------------------------------------------------------------------
-- File name   : data_path.vhd
--
-- Project     : 8-bit Microcomputer
--
-- Description : Data Path of Central Processing Unit
--
-- Author(s)   : Emma Stensland
--               Brock J. LaMeres
--               Montana State University
----------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Entity declaration
entity data_path is port (clk         : in  std_logic;
                          reset       : in  std_logic;
                          ir_load     : in  std_logic;
                          mar_load    : in  std_logic;
                          pc_load     : in  std_logic;
                          pc_inc      : in  std_logic;
                          a_load      : in  std_logic;
                          b_load      : in  std_logic;
                          ccr_load    : in  std_logic;
                          bus2_sel    : in  std_logic_vector(1 downto 0);
                          bus1_sel    : in  std_logic_vector(1 downto 0);    
                          alu_sel     : in  std_logic_vector(2 downto 0);
                          from_memory : in std_logic_vector(7 downto 0);
                          ccr_result  : out std_logic_vector(3 downto 0);
                          address     : out std_logic_vector(7 downto 0);
                          to_memory   : out std_logic_vector(7 downto 0);
			  ir          : out std_logic_vector(7 downto 0));
end entity;

architecture data_path_arch of data_path is
    -- Declare components used
    component alu port (in1        : in  std_logic_vector(7 downto 0);
                        in2        : in  std_logic_vector(7 downto 0);
                        sel        : in  std_logic_vector(2 downto 0);
                        nzvc       : out std_logic_vector(3 downto 0);
                        alu_result : out std_logic_vector(7 downto 0));
    end component;

    -- Signals for connecting to subcomponents
    signal bus1        : std_logic_vector(7 downto 0) := "00000000";
    signal bus2        : std_logic_vector(7 downto 0) := "00000000";
    signal alu_result  : std_logic_vector(7 downto 0) := "00000000";
    signal nzvc        : std_logic_vector(3 downto 0) := "0000";
    signal pc_uns      : unsigned(7 downto 0) := "00000000";  -- Unsigned for PC increments
    signal pc          : std_logic_vector(7 downto 0) := "00000000";
    signal a_reg       : std_logic_vector(7 downto 0) := "00000000";
    signal b_reg       : std_logic_vector(7 downto 0) := "00000000";
    signal mar_reg     : std_logic_vector(7 downto 0) := "00000000";
    signal ir_reg      : std_logic_vector(7 downto 0) := "00000000";
    
begin
    -- Instantiate the ALU component
    ALU_COMP : alu port map (in1 => b_reg, in2 => bus1, sel => alu_sel, nzvc => nzvc, alu_result => alu_result);

----------------------------------------------------------------------
-- BUS1: Selects input for Bus1 based on bus1_sel
----------------------------------------------------------------------
    MUX_BUS1 : process (bus1_sel, pc_uns, a_load, b_load)
    begin
        case bus1_sel is
            when "00" => bus1 <= pc;  -- PC
            when "01" => bus1 <= a_reg;  -- A Register
            when "10" => bus1 <= b_reg;  -- B Register
            when others => bus1 <= (others => '0');  -- Default to 0
        end case;
    end process;
----------------------------------------------------------------------

----------------------------------------------------------------------
-- BUS2: Selects input for Bus2 based on bus2_sel
----------------------------------------------------------------------
    MUX_BUS2 : process (bus2_sel, alu_result, bus1, from_memory)
    begin
        case bus2_sel is
            when "00" => bus2 <= alu_result;  -- ALU result
            when "01" => bus2 <= bus1;  -- Bus1 (selected from MUX_BUS1)
            when "10" => bus2 <= from_memory;  -- Data from memory
            when others => bus2 <= (others => '0');  -- Default to 0
        end case;
    end process;

    address <= mar_reg;  -- Address output for memory
    to_memory <= bus1;  -- Data to be written to memory
----------------------------------------------------------------------


----------------------------------------------------------------------
-- IR : Get instruction to decode it in control unit
----------------------------------------------------------------------
    INSTRUCTION_REGISTER : process (clk, reset)
    begin
        if (reset = '0') then
            ir_reg <= (others => '0');
        elsif rising_edge(clk) then
            if (ir_load = '1') then
                ir_reg <= bus2;  -- Load instruction from Bus2
            end if;
        end if;
    end process;

    ir <= ir_reg;
----------------------------------------------------------------------
-- MAR : Hold address for next memory operation
----------------------------------------------------------------------
    MEMORY_ADDRESS_REGISTER : process (clk, reset)
    begin
        if (reset = '0') then
            mar_reg <= (others => '0');
        elsif rising_edge(clk) then
            if (mar_load = '1') then
                mar_reg <= bus2;  -- Load memory address from Bus2
            end if;
        end if;
    end process;
----------------------------------------------------------------------


----------------------------------------------------------------------
-- PC : Increment PC, Reset PC, and load PC from bus2 if needed
-- Holds address of next instruction
----------------------------------------------------------------------
    PROGRAM_COUNTER : process (clk, reset)
    begin
        if (reset = '0') then
            pc_uns <= (others => '0');
        elsif rising_edge(clk) then
            if (pc_load = '1') then
                pc_uns <= unsigned(bus2);  -- Load PC from Bus2
            elsif (pc_inc = '1') then
                pc_uns <= pc_uns + 1;  -- Increment PC
            end if;
        end if;
    end process;

    -- Convert unsigned back to std_logic_vector for PC output
    pc <= std_logic_vector(pc_uns);
----------------------------------------------------------------------

----------------------------------------------------------------------
-- A REGISTER : Stores a value
----------------------------------------------------------------------
    A_REGISTER : process (clk, reset)
    begin
        if (reset = '0') then
            a_reg <= (others => '0');
        elsif rising_edge(clk) then
            if (a_load = '1') then
                a_reg <= bus2;  -- Load A Register from Bus2
            end if;
        end if;
    end process;
----------------------------------------------------------------------


----------------------------------------------------------------------
-- B REGISTER : Stores a value, automatically goes to ALU
----------------------------------------------------------------------
    B_REGISTER : process (clk, reset)
    begin
        if (reset = '0') then
            b_reg <= (others => '0');
        elsif rising_edge(clk) then
            if (b_load = '1') then
                b_reg <= bus2;  -- Load B Register from Bus2
            end if;
        end if;
    end process;


----------------------------------------------------------------------
-- CCR : Store the flags from CCR
----------------------------------------------------------------------
    CONDITION_CODE_REGISTER : process (clk, reset)
    begin
        if (reset = '0') then
            ccr_result <= (others => '0');
        elsif rising_edge(clk) then
            if (ccr_load = '1') then
                ccr_result <= nzvc;  -- Load CCR from NZVC flags
            end if;
        end if;
    end process;
----------------------------------------------------------------------

end architecture;