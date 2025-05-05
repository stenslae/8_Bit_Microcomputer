----------------------------------------------------------------------
-- File name   : alu.vhd
--
-- Project     : 8-bit Microcomputer
--
-- Description : Arithmetic Logic Unit in Data Path of Central Processing Unit
--
-- Author(s)   : Emma Stensland
--               Brock J. LaMeres
--               Montana State University
----------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Entity declaration
entity alu is
    port (
        in1        : in  std_logic_vector(7 downto 0);
        in2        : in  std_logic_vector(7 downto 0);
        sel        : in  std_logic_vector(2 downto 0);
        nzvc       : out std_logic_vector(3 downto 0);
        alu_result : out std_logic_vector(7 downto 0)
    );
end entity;

architecture alu_arch of alu is

    begin

----------------------------------------------------------------------
-- ALU_PROCESS  : Based on sel value, conducts different math operations
----------------------------------------------------------------------
    ALU_PROCESS : process (in1, in2, sel)
        -- Declare a variable for unsigned sum (9 bits to account for carry)
        variable Sum_uns : unsigned(8 downto 0) := "000000000";
        variable and_result : std_logic_vector(7 downto 0) := "00000000";
    	variable or_result : std_logic_vector(7 downto 0) := "00000000";

        begin
            -- ADDITION
            if (sel = "000") then
                Sum_uns := unsigned('0' & in2) + unsigned('0' & in1);
                alu_result <= std_logic_vector(Sum_uns(7 downto 0)); -- Result is 8 bits
            
                -- Negative Flag (N)
                nzvc(3) <= std_logic(Sum_uns(7));  -- MSB of the result for negative check
            
                -- Zero Flag (Z)
                if (Sum_uns(7 downto 0) = x"00") then
                    nzvc(2) <= '1';  -- Zero flag is set if result is 0
                else
                    nzvc(2) <= '0';
                end if;
            
                -- Overflow Flag (V)
                if ((in1(7) = '0' and in2(7) = '0' and Sum_uns(7) = '1') or
                    (in1(7) = '1' and in2(7) = '1' and Sum_uns(7) = '0')) then
                    nzvc(1) <= '1';  -- Overflow occurs if carry out of MSB
                else
                    nzvc(1) <= '0';
                end if;
            
                -- Carry Flag (C)
                nzvc(0) <= std_logic(Sum_uns(8));  -- Carry out is stored in the 9th bit

            -- SUBTRACTION
            elsif (sel = "001") then
                Sum_uns := unsigned('0' & in2) - unsigned('0' & in1);
                alu_result <= std_logic_vector(Sum_uns(7 downto 0));

                -- Negative Flag (N)
                nzvc(3) <= std_logic(Sum_uns(7));  -- MSB of the result for negative check
            
                -- Zero Flag (Z)
                if (Sum_uns(7 downto 0) = x"00") then
                    nzvc(2) <= '1';  -- Zero flag is set if result is 0
                else
                    nzvc(2) <= '0';
                end if;

                -- Overflow Flag (V)
    		if ((in1(7) = '0' and in2(7) = '1' and Sum_uns(7) = '1') or
        	    (in1(7) = '1' and in2(7) = '0' and Sum_uns(7) = '0')) then
                    nzvc(1) <= '1';  -- Overflow occurs if the result has incorrect sign
    		else
        	    nzvc(1) <= '0';
    		end if;

		-- Carry Flag (C)
                if (unsigned(in2) >= unsigned(in1)) then
                    nzvc(0) <= '1';  -- No borrow (Carry flag set)
                else
        	    nzvc(0) <= '0';  -- Borrow occurred (Carry flag cleared)
    		end if;

            -- AND
            elsif (sel = "010") then
    		and_result := in1 and in2;
    		alu_result <= and_result;

		-- V and C unaffected
                nzvc(1 downto 0) <= "00";
		-- Zero Flag (Z)
                if (and_result = x"00") then nzvc(2) <= '1'; 
		else nzvc(2) <= '0'; 
		end if;
		-- Negative Flag (N)
		nzvc(3) <= std_logic(and_result(7));

            -- OR
            elsif (sel = "011") then
    		or_result := in1 or in2;
    		alu_result <= or_result;

		-- V and C unaffected
                nzvc(1 downto 0) <= "00";
		-- Zero Flag (Z)
                if (or_result = x"00") then nzvc(2) <= '1'; 
		else nzvc(2) <= '0';
		end if;
		-- Negative Flag (N)
		nzvc(3) <= std_logic(or_result(7));

            -- INCA
            elsif (sel = "100") then
		Sum_uns := unsigned('0' & in2) + 1;
                alu_result <= std_logic_vector(Sum_uns(7 downto 0));
                
		-- Negative Flag (N)
                nzvc(3) <= std_logic(Sum_uns(7));  -- MSB of the result for negative check
            
                -- Zero Flag (Z)
                if (Sum_uns(7 downto 0) = x"00") then
                    nzvc(2) <= '1';  -- Zero flag is set if result is 0
                else
                    nzvc(2) <= '0';
                end if;
            
                -- Overflow Flag (V)
                if (in2 = "01111111") then nzvc(1) <= '1';
		else nzvc(1) <= '0'; 
		end if;

                -- Carry Flag (C)
                nzvc(0) <= std_logic(Sum_uns(8));  -- Carry out is stored in the 9th bit

            -- INCB
            elsif (sel = "101") then
                Sum_uns := unsigned('0' & in1) + 1;
		alu_result <= std_logic_vector(Sum_uns(7 downto 0));

                -- Negative Flag (N)
                nzvc(3) <= std_logic(Sum_uns(7));  -- MSB of the result for negative check
            
                -- Zero Flag (Z)
                if (Sum_uns(7 downto 0) = x"00") then
                    nzvc(2) <= '1';  -- Zero flag is set if result is 0
                else
                    nzvc(2) <= '0';
                end if;
            
                -- Overflow Flag (V)
                if (in1 = "01111111") then nzvc(1) <= '1'; 
		else nzvc(1) <= '0'; 
		end if;

                -- Carry Flag (C)
                nzvc(0) <= Sum_uns(8);  -- Carry out is stored in the 9th bit

            -- DECA
            elsif (sel = "110") then
                Sum_uns := unsigned('0' & in2) - 1;
                alu_result <= std_logic_vector(Sum_uns(7 downto 0));

                -- Negative Flag (N)
                nzvc(3) <= std_logic(Sum_uns(7));  -- MSB of the result for negative check
            
                -- Zero Flag (Z)
                if (Sum_uns(7 downto 0) = x"00") then
                    nzvc(2) <= '1';  -- Zero flag is set if result is 0
                else
                    nzvc(2) <= '0';
                end if;
            
                -- Overflow Flag (V)
                if (in2 = "10000000") then nzvc(1) <= '1';
		else nzvc(1) <= '0'; 
		end if;

		-- Carry Flag (C)
		if (unsigned(in2) > 1) then
    		    nzvc(0) <= '1';  -- Set Carry flag if no borrow.
		else
    		    nzvc(0) <= '0';  -- Clear Carry flag if borrow occurred.
		end if;

            -- DECB
            elsif (sel = "111") then
                Sum_uns := unsigned('0' & in1) - 1;
                alu_result <= std_logic_vector(Sum_uns(7 downto 0));

                -- Negative Flag (N)
                nzvc(3) <= std_logic(Sum_uns(7));  -- MSB of the result for negative check
            
                -- Zero Flag (Z)
                if (Sum_uns(7 downto 0) = x"00") then
                    nzvc(2) <= '1';  -- Zero flag is set if result is 0
                else
                    nzvc(2) <= '0';
                end if;
            
                -- Overflow Flag (V)
                if (in1 = "10000000") then nzvc(1) <= '1';
		else nzvc(1) <= '0'; 
		end if;

		-- Carry Flag (C)
		if (unsigned(in1) > 1) then
    		    nzvc(0) <= '1';  -- Set Carry flag if no borrow.
		else
    		    nzvc(0) <= '0';  -- Clear Carry flag if borrow occurred.
		end if;

            else
                -- Default case if the selection is not recognized
                alu_result <= (others => '0');
                nzvc <= "0000";  -- Clear flags in this case
            end if;
    end process;
----------------------------------------------------------------------

end architecture;