----------------------------------------------------------------------
-- File name   : rom_128x8_sync.vhd
--
-- Project     : 8-bit Microcomputer
--
-- Description : Program Memory
--
-- Author(s)   : Emma Stensland
--               Brock J. LaMeres
--               Montana State University
----------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Entity declaration
entity rom_128x8_sync is
    port (clk      : in  std_logic;
	  address  : in  std_logic_vector(7 downto 0);
	  data_out : out std_logic_vector(7 downto 0));
end entity;

architecture rom_128x8_sync_arch of rom_128x8_sync is
     -- List of opcodes
     constant LDA_IMM : std_logic_vector (7 downto 0) := x"86";
     constant LDA_DIR : std_logic_vector (7 downto 0) := x"87";
     constant LDB_IMM : std_logic_vector (7 downto 0) := x"88";
     constant LDB_DIR : std_logic_vector (7 downto 0) := x"89";
     constant STA_DIR : std_logic_vector (7 downto 0) := x"96";
     constant STB_DIR : std_logic_vector (7 downto 0) := x"97";
     constant ADD_AB  : std_logic_vector (7 downto 0) := x"42";
     constant SUB_AB  : std_logic_vector (7 downto 0) := x"43";
     constant AND_AB  : std_logic_vector (7 downto 0) := x"44";
     constant OR_AB   : std_logic_vector (7 downto 0) := x"45";
     constant INCA    : std_logic_vector (7 downto 0) := x"46";
     constant INCB    : std_logic_vector (7 downto 0) := x"47";
     constant DECA    : std_logic_vector (7 downto 0) := x"48";
     constant DECB    : std_logic_vector (7 downto 0) := x"49";
     constant BRA     : std_logic_vector (7 downto 0) := x"20";
     constant BMI     : std_logic_vector (7 downto 0) := x"21";
     constant BPL     : std_logic_vector (7 downto 0) := x"22";
     constant BEQ     : std_logic_vector (7 downto 0) := x"23";
     constant BNE     : std_logic_vector (7 downto 0) := x"24";
     constant BVS     : std_logic_vector (7 downto 0) := x"25";
     constant BVC     : std_logic_vector (7 downto 0) := x"26";
     constant BCS     : std_logic_vector (7 downto 0) := x"27";
     constant BCC     : std_logic_vector (7 downto 0) := x"28";

     -- ROM memory
     type rom_type is array (0 to 127) of std_logic_vector(7 downto 0);
     constant ROM : rom_type := (-- Load switches into B from port F0
											0  => LDB_DIR, 
											1  => x"F0",
											-- Display B on HEX0/HEX1
											2  => STB_DIR, 
											3  => x"E1",
											-- Load 0x0A into A
											4  => LDA_IMM, 
											5  => x"0A",
											-- Display A on HEX2/HEX3
											6  => STA_DIR, 
											7  => x"E2",
											-- Load 0x03 into B
											8  => LDB_IMM, 
											9  => x"03",
											-- Display B again
											10 => STB_DIR, 
											11 => x"E1",
											-- ADD: A = A + B
											12 => ADD_AB,
											13 => STA_DIR, 
											14 => x"E2",
											-- SUB: A = A - B
											15 => SUB_AB,
											16 => STA_DIR, 
											17 => x"E2",
											-- AND: A = A AND B
											18 => AND_AB,
											19 => STA_DIR, 
											20 => x"E2",
											-- OR: A = A OR B
											21 => OR_AB,
											22 => STA_DIR, 
											23 => x"E2",
											-- INCA
											24 => INCA,
											25 => STA_DIR, 
											26 => x"E2",
											-- INCB
											27 => INCB,
											28 => STB_DIR, 
											29 => x"E1",
											-- DECA
											30 => DECA,
											31 => STA_DIR, 
											32 => x"E2",
											-- DECB
											33 => DECB,
											34 => STB_DIR,
										   35 =>	x"E1",
											-- Loop or NOP
											36 => BRA, 
											37 => x"00",
											others => x"00");
     -- Signal declarations
     signal EN : std_logic := '0';

     begin

----------------------------------------------------------------------
-- ENABLE : only read memory if its within address range
----------------------------------------------------------------------
     enable : process (address)
          begin
          if ((to_integer(unsigned(address)) >= 0) and
              (to_integer(unsigned(address)) <= 127)) then
               EN <= '1';
          else
               EN <= '0';
          end if;
     end process;
----------------------------------------------------------------------


----------------------------------------------------------------------
-- MEMORY : at clock tick, returns data at the address
----------------------------------------------------------------------
     memory : process (clk)
          begin
          if (clk'event and clk= '1') then
               if (EN= '1') then
                    data_out <= ROM(to_integer(unsigned(address)));
                else
		    data_out <= (others => '0');
		end if;
           end if;
     end process;
----------------------------------------------------------------------

end architecture;