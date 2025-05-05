library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_div_prec is
    port (
        Clock_In  : in  std_logic;
        Reset     : in  std_logic;
        Sel       : in  std_logic_vector(1 downto 0);
        Clock_Out : out std_logic
    );
end entity;

architecture clock_div_prec_arch of clock_div_prec is

    signal counter     : integer := 0;
    signal clock_val   : std_logic := '0';
    signal max_value   : integer;

begin

    process(Clock_In, Reset)
    begin
        if Reset = '0' then
            counter    <= 0;
            clock_val  <= '0';
        elsif rising_edge(Clock_In) then

            -- Select max value based on Sel input
            case Sel is
                when "00" => max_value <= 24999999; -- 1 Hz
                when "01" => max_value <= 2499999;  -- 10 Hz
                when "11" => max_value <= 249999;   -- 100 Hz
                when "10" => max_value <= 24999;    -- 1 kHz
                when others => max_value <= 24999;  -- Default
            end case;

            -- Count and toggle clock
            if counter >= max_value then
                counter   <= 0;
                clock_val <= not clock_val;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    Clock_Out <= clock_val;

end architecture;