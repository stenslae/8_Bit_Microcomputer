----------------------------------------------------------------------
-- File name   : rw_96x8_sync.vhd
--
-- Project     : 8-bit Microcomputer
--
-- Description : Data Memory
--
-- Author(s)   : Emma Stensland
--               Brock J. LaMeres
--               Montana State University
----------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Entity declaration
entity rw_96x8_sync is
    port (clk      : in  std_logic;
	  data_in  : in  std_logic_vector(7 downto 0);
	  write_in : in  std_logic;
	  address  : in  std_logic_vector(7 downto 0);
	  data_out : out std_logic_vector(7 downto 0));
end entity;

architecture rw_96x8_sync_arch of rw_96x8_sync is
     -- RW Memory
     type rw_type is array (128 to 223) of std_logic_vector(7 downto 0);
     -- Signal Declarations
     signal RW : rw_type := (others => (others => '0'));
     signal EN : std_logic := '0';

     begin

----------------------------------------------------------------------
-- ENABLE : makes sure reading/writing within range
----------------------------------------------------------------------
     enable : process (address)
          begin
          if ((to_integer(unsigned(address)) >= 128) and
              (to_integer(unsigned(address)) <= 223)) then
               EN <= '1';
          else
               EN <= '0';
          end if;
      end process;
----------------------------------------------------------------------

----------------------------------------------------------------------
-- MEMORY : if reading, will update data_out on clock, if writing, will update memory on clock
----------------------------------------------------------------------
     memory : process (clk)
          begin
          if (clk'event and clk= '1') then
               if (EN= '1' and write_in= '1') then
                    RW(to_integer(unsigned(address))) <= data_in;
               elsif (EN= '1' and write_in= '0') then
                    data_out <= RW(to_integer(unsigned(address)));
               end if;
          end if;
     end process;
----------------------------------------------------------------------

end architecture;