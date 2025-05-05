----------------------------------------------------------------------
-- File name   : cpu.vhd
--
-- Project     : 8-bit Microcomputer
--
-- Description : Top File of Central Processing Unit
--
-- Author(s)   : Emma Stensland
--               Brock J. LaMeres
--               Montana State University
----------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Entity declaration
entity cpu is
    port (clk         : in  std_logic;
          reset       : in  std_logic;
          from_memory : in std_logic_vector(7 downto 0);
          write_out   : out std_logic;
          to_memory   : out std_logic_vector(7 downto 0);
          address     : out std_logic_vector(7 downto 0));
end entity;

architecture cpu_arch of cpu is

    -- Declare components used
    component control_unit 
        port (clk        : in  std_logic;
              reset      : in  std_logic;
              ccr_result : in  std_logic_vector(3 downto 0);
              ir         : in  std_logic_vector(7 downto 0);
              write_out  : out std_logic;
              ccr_load   : out std_logic;
              b_load     : out std_logic;
              a_load     : out std_logic;
              pc_inc     : out std_logic;
              pc_load    : out std_logic;
              mar_load   : out std_logic;
              ir_load    : out std_logic;
              bus2_sel   : out std_logic_vector(1 downto 0);
              bus1_sel   : out std_logic_vector(1 downto 0);
              alu_sel    : out std_logic_vector(2 downto 0));
    end component;
    
    component data_path 
        port (clk         : in  std_logic;
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
    end component;

    -- Signals for connecting to subcomponents
    signal ir_cu          : std_logic_vector(7 downto 0);
    signal ir_load_cu     : std_logic := '0';
    signal ccr_load_cu    : std_logic := '0';
    signal b_load_cu      : std_logic := '0';
    signal a_load_cu      : std_logic := '0';
    signal pc_load_cu     : std_logic := '0';
    signal pc_inc_cu      : std_logic := '0';
    signal mar_load_cu    : std_logic := '0';
    signal alu_sel_cu     : std_logic_vector(2 downto 0) := "000";
    signal bus2_sel_cu    : std_logic_vector(1 downto 0) := "00";
    signal bus1_sel_cu    : std_logic_vector(1 downto 0) := "00";
    signal ccr_result_cu  : std_logic_vector(3 downto 0) := "0000";
    
    signal ir_dp          : std_logic_vector(7 downto 0);
    signal ir_load_dp     : std_logic := '0';
    signal ccr_load_dp    : std_logic := '0';
    signal b_load_dp      : std_logic := '0';
    signal a_load_dp      : std_logic := '0';
    signal pc_load_dp     : std_logic := '0';
    signal pc_inc_dp      : std_logic := '0';
    signal mar_load_dp    : std_logic := '0';
    signal alu_sel_dp     : std_logic_vector(2 downto 0) := "000";
    signal bus2_sel_dp    : std_logic_vector(1 downto 0) := "00";
    signal bus1_sel_dp    : std_logic_vector(1 downto 0) := "00";
    signal ccr_result_dp  : std_logic_vector(3 downto 0) := "0000";
    signal to_memory_dp   : std_logic_vector(7 downto 0);
    signal address_dp     : std_logic_vector(7 downto 0);

begin

    -- Instantiate the control unit component
    CNTRL_UNIT : control_unit
        port map (
            clk        => clk,
            reset      => reset,
            ccr_result => ccr_result_dp,  -- From datapath
            ir         => ir_dp,          -- From datapath
            write_out  => write_out,
            ccr_load   => ccr_load_cu,
            b_load     => b_load_cu,
            a_load     => a_load_cu,
            pc_inc     => pc_inc_cu,
            pc_load    => pc_load_cu,
            mar_load   => mar_load_cu,
            ir_load    => ir_load_cu,
            bus2_sel   => bus2_sel_cu,
            bus1_sel   => bus1_sel_cu,
            alu_sel    => alu_sel_cu
        );
    
    -- Instantiate the data path component
    DAT_PTH : data_path
        port map (
            clk         => clk,
            reset       => reset,
            -- Connect data_path inputs to control_unit outputs
            ir_load     => ir_load_cu,
            mar_load    => mar_load_cu,
            pc_load     => pc_load_cu,
            pc_inc      => pc_inc_cu,
            a_load      => a_load_cu,
            b_load      => b_load_cu,
            ccr_load    => ccr_load_cu,
            bus2_sel    => bus2_sel_cu,
            bus1_sel    => bus1_sel_cu,
            alu_sel     => alu_sel_cu,
            -- Memory input and data_path outputs
            from_memory => from_memory,
            ccr_result  => ccr_result_dp,
            address     => address_dp,
            to_memory   => to_memory_dp,
            ir          => ir_dp
        );
    
    -- Link data path and control unit i/o
    to_memory   <= to_memory_dp;
    address     <= address_dp;

end architecture;