library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
	port (CLOCK_50 : in std_logic;
			KEY      : in  std_logic_vector (1 downto 0);
			SW       : in  std_logic_vector (9 downto 0);
			LEDR     : out std_logic_vector (9 downto 0);
			HEX0     : out std_logic_vector (6 downto 0);
			HEX1     : out std_logic_vector (6 downto 0);
			HEX2     : out std_logic_vector (6 downto 0);
			HEX3     : out std_logic_vector (6 downto 0);
			HEX4     : out std_logic_vector (6 downto 0);
			HEX5     : out std_logic_vector (6 downto 0);
			GPIO     : out std_logic_vector (15 downto 0));
end entity;

architecture top_arch of top is

    -- Component declarations
    component clock_div_prec is
        port (Clock_In  : in  std_logic;
              Reset     : in  std_logic;
              Sel       : in  std_logic_vector(1 downto 0);
              Clock_Out : out std_logic);
    end component;

    component char_decoder is
        port (BIN_IN  : in std_logic_vector (3 downto 0);
              HEX_OUT : out std_logic_vector (6 downto 0));
    end component;

    component computer is
        port (clk         : in  std_logic;
				  reset       : in  std_logic;
				  port_in_00  : in  std_logic_vector(7 downto 0);
				  port_in_01  : in  std_logic_vector(7 downto 0);
				  port_in_02  : in  std_logic_vector(7 downto 0);
				  port_in_03  : in  std_logic_vector(7 downto 0);
				  port_in_04  : in  std_logic_vector(7 downto 0);
				  port_in_05  : in  std_logic_vector(7 downto 0);
				  port_in_06  : in  std_logic_vector(7 downto 0);
				  port_in_07  : in  std_logic_vector(7 downto 0);
				  port_in_08  : in  std_logic_vector(7 downto 0);
				  port_in_09  : in  std_logic_vector(7 downto 0);
				  port_in_10  : in  std_logic_vector(7 downto 0);
				  port_in_11  : in  std_logic_vector(7 downto 0);
				  port_in_12  : in  std_logic_vector(7 downto 0);
				  port_in_13  : in  std_logic_vector(7 downto 0);
				  port_in_14  : in  std_logic_vector(7 downto 0);
				  port_in_15  : in  std_logic_vector(7 downto 0);
				  port_out_00 : out std_logic_vector(7 downto 0);
				  port_out_01 : out std_logic_vector(7 downto 0);
				  port_out_02 : out std_logic_vector(7 downto 0);
				  port_out_03 : out std_logic_vector(7 downto 0);
				  port_out_04 : out std_logic_vector(7 downto 0);
				  port_out_05 : out std_logic_vector(7 downto 0);
				  port_out_06 : out std_logic_vector(7 downto 0);
				  port_out_07 : out std_logic_vector(7 downto 0);
				  port_out_08 : out std_logic_vector(7 downto 0);
				  port_out_09 : out std_logic_vector(7 downto 0);
				  port_out_10 : out std_logic_vector(7 downto 0);
				  port_out_11 : out std_logic_vector(7 downto 0);
				  port_out_12 : out std_logic_vector(7 downto 0);
				  port_out_13 : out std_logic_vector(7 downto 0);
				  port_out_14 : out std_logic_vector(7 downto 0);
				  port_out_15 : out std_logic_vector(7 downto 0));
    end component;
	 
    -- Internal signals
    signal clk_slow  : std_logic;
    signal out_0     : std_logic_vector(7 downto 0);
    signal out_1     : std_logic_vector(7 downto 0);
    signal out_2     : std_logic_vector(7 downto 0);
    signal out_3     : std_logic_vector(7 downto 0); 
    signal out_4     : std_logic_vector(7 downto 0);
    signal out_5     : std_logic_vector(7 downto 0);
    signal out_6     : std_logic_vector(7 downto 0);
    signal out_7     : std_logic_vector(7 downto 0); 
    signal out_8     : std_logic_vector(7 downto 0);
    signal out_9     : std_logic_vector(7 downto 0);
    signal out_10     : std_logic_vector(7 downto 0);
    signal out_11     : std_logic_vector(7 downto 0);
    signal out_12     : std_logic_vector(7 downto 0);
    signal out_13     : std_logic_vector(7 downto 0); 
    signal out_14     : std_logic_vector(7 downto 0);
    signal out_15     : std_logic_vector(7 downto 0);
	
	begin
		-- Port Maps
		COMP : entity work.computer port map (--Inputs 
													clk         => clk_slow, 
													reset       => KEY(0),
													port_in_00  => SW(7 downto 0),
													port_in_01  => "0000000" & KEY(1),
													-- Unused Input
													port_in_02  => (others => '0'),
            									port_in_03  => (others => '0'),
            									port_in_04  => (others => '0'),
            									port_in_05  => (others => '0'),
            									port_in_06  => (others => '0'),
            									port_in_07  => (others => '0'),
            									port_in_08  => (others => '0'),
            									port_in_09  => (others => '0'),
            									port_in_10  => (others => '0'), 
            									port_in_11  => (others => '0'),
            									port_in_12  => (others => '0'), 
            									port_in_13  => (others => '0'), 
            									port_in_14  => (others => '0'), 
            									port_in_15  => (others => '0'),
													-- Outputs
            									port_out_00 => out_0, 
													port_out_01 => out_1, 
													port_out_02 => out_2, 
													port_out_03 => out_3, 
													port_out_04 => out_4,
													port_out_05 => out_5,
													-- Unused Outputs
            									port_out_06 => out_6,
            									port_out_07 => out_7,
            									port_out_08 => out_8,
            									port_out_09 => out_9,
            									port_out_10 => out_10,
            									port_out_11 => out_11,
            									port_out_12 => out_12,
            									port_out_13 => out_13,
            									port_out_14 => out_14,
            									port_out_15 => out_15);
		
		DIV : entity work.clock_div_prec port map (CLOCK_50, KEY(0), SW(9 downto 8), clk_slow);
		C0  : entity work.char_decoder port map (out_1(3 downto 0), HEX0);
		C1  : entity work.char_decoder port map (out_1(7 downto 4), HEX1);
		C2  : entity work.char_decoder port map (out_2(3 downto 0), HEX2);
		C3  : entity work.char_decoder port map (out_2(7 downto 4), HEX3);
		C4  : entity work.char_decoder port map (out_3(3 downto 0), HEX4);
		C5  : entity work.char_decoder port map (out_3(7 downto 4), HEX5);
		LEDR(7 downto 0)  <= out_0;
		GPIO(15 downto 8) <= out_4;
		GPIO(7 downto 0)  <= out_5;
		
end architecture;