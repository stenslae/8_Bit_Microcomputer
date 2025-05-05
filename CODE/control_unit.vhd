----------------------------------------------------------------------
-- File name   : control_unit.vhd
--
-- Project     : 8-bit Microcomputer
--
-- Description : Control Unit of Central Processing Unit
--
-- Author(s)   : Emma Stensland
--               Brock J. LaMeres
--               Montana State University
----------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Entity declaration
entity control_unit is port (clk        : in  std_logic;
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
end entity;

architecture control_unit_arch of control_unit is
    -- Define the state type
    type state_type is (
        -- Fetch and decode
        S_FETCH_0, S_FETCH_1, S_FETCH_2, S_DECODE_3,
        -- Load instructions
        S_LDA_IMM_4, S_LDA_IMM_5, S_LDA_IMM_6,
        S_LDA_DIR_4, S_LDA_DIR_5, S_LDA_DIR_6, S_LDA_DIR_7, S_LDA_DIR_8,
        S_LDB_IMM_4, S_LDB_IMM_5, S_LDB_IMM_6,
        S_LDB_DIR_4, S_LDB_DIR_5, S_LDB_DIR_6, S_LDB_DIR_7, S_LDB_DIR_8,
        -- Store instructions
        S_STA_DIR_4, S_STA_DIR_5, S_STA_DIR_6, S_STA_DIR_7,
        S_STB_DIR_4, S_STB_DIR_5, S_STB_DIR_6, S_STB_DIR_7,
        -- Arithmetic and logic
        S_ADD_AB_4,
        S_SUB_AB_4,
        S_AND_AB_4,
        S_OR_AB_4,
        S_INCA_4,
        S_INCB_4,
        S_DECA_4,
        S_DECB_4,
        -- Branch instructions
        S_BRA_4, S_BRA_5, S_BRA_6,
        S_BMI_4, S_BMI_5, S_BMI_6, S_BMI_7,
        S_BEQ_4, S_BEQ_5, S_BEQ_6, S_BEQ_7,
        S_BVS_4, S_BVS_5, S_BVS_6, S_BVS_7,
        S_BCS_4, S_BCS_5, S_BCS_6, S_BCS_7);
    
    -- Signals for current and next state
    signal current_state, next_state : state_type;

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

begin

----------------------------------------------------------------------
-- STATE_MEMORY : Reset state at reset low and FSM progression at clock edge
----------------------------------------------------------------------
    STATE_MEMORY : process (clk, reset)
    begin
        if (reset = '0') then
            current_state <= S_FETCH_0;
        elsif (clk'event and clk = '1') then
            current_state <= next_state;
        end if;
    end process;
----------------------------------------------------------------------

----------------------------------------------------------------------
-- NEXT_STATE_LOGIC : FSM decides next state based on current state
----------------------------------------------------------------------
    NEXT_STATE_LOGIC : process (current_state, ir, ccr_result)
    begin
        case current_state is
	    -- FETCH
            when S_FETCH_0 =>
                next_state <= S_FETCH_1;

            when S_FETCH_1 =>
                next_state <= S_FETCH_2;

            when S_FETCH_2 =>
                next_state <= S_DECODE_3;

	    -- DECODE
            when S_DECODE_3 =>
                -- Select execution path based on IR
                -- DATA
                if    (ir = LDA_IMM) then next_state <= S_LDA_IMM_4;
                elsif (ir = LDA_DIR) then next_state <= S_LDA_DIR_4;
                elsif (ir = LDB_IMM) then next_state <= S_LDB_IMM_4;
                elsif (ir = LDB_DIR) then next_state <= S_LDB_DIR_4;
                elsif (ir = STA_DIR) then next_state <= S_STA_DIR_4;
                elsif (ir = STB_DIR) then next_state <= S_STB_DIR_4;
                -- ARITH
                elsif (ir = ADD_AB) then next_state <= S_ADD_AB_4;
                elsif (ir = SUB_AB) then next_state <= S_SUB_AB_4;
                elsif (ir = AND_AB) then next_state <= S_AND_AB_4;
                elsif (ir = OR_AB) then next_state <= S_OR_AB_4;
                elsif (ir = INCA) then next_state <= S_INCA_4;
                elsif (ir = INCB) then next_state <= S_INCB_4;
                elsif (ir = DECA) then next_state <= S_DECA_4;
                elsif (ir = DECB) then next_state <= S_DECB_4;
                -- BRANCH
                elsif (ir = BRA) then next_state <= S_BRA_4;
                elsif (ir = BMI and ccr_result(3) = '1') then next_state <= S_BMI_4;
                elsif (ir = BMI and ccr_result(3) = '0') then next_state <= S_BMI_7;
                elsif (ir = BEQ and ccr_result(2) = '1') then next_state <= S_BEQ_4;
                elsif (ir = BEQ and ccr_result(2) = '0') then next_state <= S_BEQ_7;
                elsif (ir = BVS and ccr_result(1) = '1') then next_state <= S_BVS_4;
                elsif (ir = BVS and ccr_result(1) = '0') then next_state <= S_BVS_7;
                elsif (ir = BCS and ccr_result(0) = '1') then next_state <= S_BCS_4;
                elsif (ir = BCS and ccr_result(0) = '0') then next_state <= S_BCS_7;
                -- DEFAULT
                else next_state <= S_FETCH_0;
                end if;

            -- LDA Immediate 
            when S_LDA_IMM_4 => next_state <= S_LDA_IMM_5;
            when S_LDA_IMM_5 => next_state <= S_LDA_IMM_6;
            when S_LDA_IMM_6 => next_state <= S_FETCH_0;

            -- LDA Direct
            when S_LDA_DIR_4 => next_state <= S_LDA_DIR_5;
            when S_LDA_DIR_5 => next_state <= S_LDA_DIR_6;
            when S_LDA_DIR_6 => next_state <= S_LDA_DIR_7;
            when S_LDA_DIR_7 => next_state <= S_LDA_DIR_8;
            when S_LDA_DIR_8 => next_state <= S_FETCH_0;

            -- LDB Immediate
            when S_LDB_IMM_4 => next_state <= S_LDB_IMM_5;
            when S_LDB_IMM_5 => next_state <= S_LDB_IMM_6;
            when S_LDB_IMM_6 => next_state <= S_FETCH_0;

            -- LDB Direct
            when S_LDB_DIR_4 => next_state <= S_LDB_DIR_5;
            when S_LDB_DIR_5 => next_state <= S_LDB_DIR_6;
            when S_LDB_DIR_6 => next_state <= S_LDB_DIR_7;
            when S_LDB_DIR_7 => next_state <= S_LDB_DIR_8;
            when S_LDB_DIR_8 => next_state <= S_FETCH_0;

            -- STA Direct
            when S_STA_DIR_4 => next_state <= S_STA_DIR_5;
            when S_STA_DIR_5 => next_state <= S_STA_DIR_6;
            when S_STA_DIR_6 => next_state <= S_STA_DIR_7;
            when S_STA_DIR_7 => next_state <= S_FETCH_0;

            -- STB Direct
            when S_STB_DIR_4 => next_state <= S_STB_DIR_5;
            when S_STB_DIR_5 => next_state <= S_STB_DIR_6;
            when S_STB_DIR_6 => next_state <= S_STB_DIR_7;
            when S_STB_DIR_7 => next_state <= S_FETCH_0;

            -- ARITH
            when S_ADD_AB_4 => next_state <= S_FETCH_0;
            when S_SUB_AB_4 => next_state <= S_FETCH_0;
            when S_AND_AB_4 => next_state <= S_FETCH_0;
            when S_OR_AB_4  => next_state <= S_FETCH_0;
            when S_INCA_4   => next_state <= S_FETCH_0;
            when S_INCB_4   => next_state <= S_FETCH_0;
            when S_DECA_4   => next_state <= S_FETCH_0;
            when S_DECB_4   => next_state <= S_FETCH_0;

            -- BRA
            when S_BRA_4 => next_state <= S_BRA_5;
            when S_BRA_5 => next_state <= S_BRA_6;
            when S_BRA_6 => next_state <= S_FETCH_0;

	    -- BMI
            when S_BMI_4 => next_state <= S_BMI_5;
            when S_BMI_5 => next_state <= S_BMI_6;
            when S_BMI_6 => next_state <= S_FETCH_0;
            when S_BMI_7 => next_state <= S_FETCH_0;

            -- BEQ
            when S_BEQ_4 => next_state <= S_BEQ_5;
            when S_BEQ_5 => next_state <= S_BEQ_6;
            when S_BEQ_6 => next_state <= S_FETCH_0;
            when S_BEQ_7 => next_state <= S_FETCH_0;

	    -- BVS
            when S_BVS_4 => next_state <= S_BVS_5;
            when S_BVS_5 => next_state <= S_BVS_6;
            when S_BVS_6 => next_state <= S_FETCH_0;
            when S_BVS_7 => next_state <= S_FETCH_0;

            -- BCS
            when S_BCS_4 => next_state <= S_BCS_5;
            when S_BCS_5 => next_state <= S_BCS_6;
            when S_BCS_6 => next_state <= S_FETCH_0;
            when S_BCS_7 => next_state <= S_FETCH_0;

	    -- DEFUALT
            when others => next_state <= S_FETCH_0;
        end case;
    end process;
----------------------------------------------------------------------

----------------------------------------------------------------------
-- OUTPUT_LOGIC : FSM updates outputs at each current state
----------------------------------------------------------------------
    OUTPUT_LOGIC : process (current_state)
    begin
        case current_state is
            when S_FETCH_0 =>
                -- Put PC onto MAR to read Opcode
                ir_load <= '0';
                mar_load <= '1';
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  -- "00"=PC
                bus2_sel <= "01";  -- "01"=Bus1
                write_out <= '0';

            when S_FETCH_1 =>
                -- Increment PC
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '1';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  -- "00"=PC
                bus2_sel <= "00";  -- "00"=ALU
                write_out <= '0';
        
           when S_FETCH_2 =>
                ir_load <= '1';    -- IR
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00"; 
                bus2_sel <= "10";  -- "10"=MEMORY
                write_out <= '0';
					 
            when S_DECODE_3 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  
                bus2_sel <= "00";
                write_out <= '0';

	    -- LDA_IMM STEPS
            when S_LDA_IMM_4 =>
                ir_load <= '0';
                mar_load <= '1';  -- MAR
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  -- "00"=PC
                bus2_sel <= "01";  -- "01"=BUS1
                write_out <= '0';
            when S_LDA_IMM_5 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '1';     -- PC INC
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  
                bus2_sel <= "00";  
                write_out <= '0';
            when S_LDA_IMM_6 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '1';    -- LOAD VAL INTO A
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";
                bus2_sel <= "10";  -- "10"=MEMORY
                write_out <= '0';

            -- LDA_DIR STEPS
            when S_LDA_DIR_4 =>
                ir_load <= '0';
                mar_load <= '1';   -- MAR
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  -- "00"=PC
                bus2_sel <= "01";  -- "01"=BUS1
                write_out <= '0';
            when S_LDA_DIR_5 =>    -- Wait 1 Clock Cycle
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '1';    -- PC
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  
                bus2_sel <= "00";  
                write_out <= '0';
            when S_LDA_DIR_6 =>
                ir_load <= '0';
                mar_load <= '1';   -- MAR
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00"; 
                bus2_sel <= "10";  -- "10"=MEMORY
                write_out <= '0';
            when S_LDA_DIR_7 =>    -- Wait 1 Clock Cycle
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';     
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00"; 
                bus2_sel <= "00";  
                write_out <= '0';
            when S_LDA_DIR_8 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '1';     -- A
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  
                bus2_sel <= "10";  -- "10"=MEMORY
                write_out <= '0';

            -- LDB_IMM STEPS
            when S_LDB_IMM_4 =>
                ir_load <= '0';
                mar_load <= '1';   -- MAR
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  -- "00"=PC
                bus2_sel <= "01";  -- "01"=BUS1
                write_out <= '0';
            when S_LDB_IMM_5 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '1';     -- PC INC
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";
                bus2_sel <= "00";
                write_out <= '0';
            when S_LDB_IMM_6 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '1';     -- LOAD VAL INTO B
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";
                bus2_sel <= "10";  -- "10"=MEMORY
                write_out <= '0';

            -- LDB_DIR STEPS
            when S_LDB_DIR_4 =>
                ir_load <= '0';
                mar_load <= '1';   -- MAR
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  -- "00"=PC
                bus2_sel <= "01";  -- "01"=BUS1
                write_out <= '0';
            when S_LDB_DIR_5 =>    -- Wait 1 Clock Cycle
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '1';     -- PC
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  
                bus2_sel <= "00";  
                write_out <= '0';
            when S_LDB_DIR_6 =>
                ir_load <= '0';
                mar_load <= '1';    -- MAR
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";
                bus2_sel <= "10";   -- "10"=MEMORY
                write_out <= '0';
            when S_LDB_DIR_7 =>     -- Wait 1 Clock Cycle
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00"; 
                bus2_sel <= "00";
                write_out <= '0';
            when S_LDB_DIR_8 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';    
                b_load <= '1';      -- B
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";
                bus2_sel <= "10";  -- "10"=MEMORY
                write_out <= '0';

            -- STA_DIR STEPS
            when S_STA_DIR_4 =>
                ir_load <= '0';
                mar_load <= '1';   -- MAR
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  -- "00"=PC
                bus2_sel <= "01";  -- "01"=BUS1
                write_out <= '0';
            when S_STA_DIR_5 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '1';     -- PC
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  
                bus2_sel <= "00"; 
                write_out <= '0';
            when S_STA_DIR_6 =>
                ir_load <= '0';
                mar_load <= '1';    -- MAR
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";
                bus2_sel <= "10";  -- "10"=MEMORY
                write_out <= '0';
            when S_STA_DIR_7 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "01";  -- "01"=A
                bus2_sel <= "00"; 
                write_out <= '1';  -- WRITE

            -- STB_DIR STEPS
            when S_STB_DIR_4 =>
                ir_load <= '0';
                mar_load <= '1';   -- MAR
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  -- "00"=PC
                bus2_sel <= "01";  -- "01"=BUS1
                write_out <= '0';
            when S_STB_DIR_5 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '1';     -- PC
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  
                bus2_sel <= "00"; 
                write_out <= '0';
            when S_STB_DIR_6 =>
                ir_load <= '0';
                mar_load <= '1';    -- MAR
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";
                bus2_sel <= "10";  -- "10"=MEMORY
                write_out <= '0';
            when S_STB_DIR_7 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "10";  -- "10"=B
                bus2_sel <= "00"; 
                write_out <= '1';  -- WRITE

            -- ARITH
            when S_ADD_AB_4 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '1';     -- A on BUS1
                b_load <= '0';
                alu_sel <= "000";  -- ADD
                ccr_load <= '1';   -- CCR
                bus1_sel <= "01";  -- "01"=A
                bus2_sel <= "00";  -- "00"=ALU
                write_out <= '0';
            when S_SUB_AB_4 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '1';     -- A ON BUS1
                b_load <= '0';
                alu_sel <= "001";  -- SUB
                ccr_load <= '1';   -- CCR
                bus1_sel <= "01";  -- "01"=A
                bus2_sel <= "00";  -- "00"=ALU
                write_out <= '0';
            when S_AND_AB_4 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '1';     -- A ON BUS1
                b_load <= '0';
                alu_sel <= "010";  -- AND
                ccr_load <= '1';   -- CCR
                bus1_sel <= "01";  -- "01"=A
                bus2_sel <= "00";  -- "00"=ALU
                write_out <= '0';
            when S_OR_AB_4 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '1';     -- A ON BUS1
                b_load <= '0';
                alu_sel <= "011";  -- OR
                ccr_load <= '1';   -- CCR
                bus1_sel <= "01";  -- "01"=A
                bus2_sel <= "00";  -- "00"=ALU
                write_out <= '0';
            when S_INCA_4 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '1';     -- A ON BUS1
                b_load <= '0';
                alu_sel <= "100";  -- INCA
                ccr_load <= '1';   -- CCR
                bus1_sel <= "01";  -- "01"=A
                bus2_sel <= "00";  -- "00"=ALU
                write_out <= '0';
            when S_INCB_4 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '1';
                alu_sel <= "101";  -- INCB
                ccr_load <= '1';   -- CCR
                bus1_sel <= "10";  -- "10"=B
                bus2_sel <= "00";  -- "00"=ALU
                write_out <= '0';
            when S_DECA_4 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '1';     -- A ON BUS1
                b_load <= '0';
                alu_sel <= "110";  -- DECA
                ccr_load <= '1';   -- CCR
                bus1_sel <= "01";  -- "01"=A
                bus2_sel <= "00";  -- "00"=ALU
                write_out <= '0';
            when S_DECB_4 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '1';
                alu_sel <= "111";  -- DECB
                ccr_load <= '1';   -- CCR
                bus1_sel <= "10";  -- "10"=B
                bus2_sel <= "00";  -- "00"=ALU
                write_out <= '0';

        -- BRA
        when S_BRA_4 =>
                ir_load <= '0';
                mar_load <= '1';   -- MAR
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  -- "00"=PC
                bus2_sel <= "01";  -- "01"=BUS1
                write_out <= '0';
        when S_BRA_5 =>            -- Wait 1 Clock Cycle
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  
                bus2_sel <= "00";  
                write_out <= '0';
        when S_BRA_6 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '1';    -- PC
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  -- "00"=PC
                bus2_sel <= "10";  -- "10"=MEMORY
                write_out <= '0';

        -- BMI
        when S_BMI_4 =>
                ir_load <= '0';
                mar_load <= '1';   -- MAR
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  -- "00"=PC
                bus2_sel <= "01";  -- "01"=BUS1
                write_out <= '0';
        when S_BMI_5 =>            -- Wait 1 Clock Cycle
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  
                bus2_sel <= "00";
                write_out <= '0';
        when S_BMI_6 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '1';   -- PC LOAD
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  
                bus2_sel <= "10";  -- "10"=MEMORY
                write_out <= '0';
        when S_BMI_7 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '1';     -- PC
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  
                bus2_sel <= "00";  
                write_out <= '0';

        -- BEQ
        when S_BEQ_4 =>
                ir_load <= '0';
                mar_load <= '1';   -- MAR
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  -- "00"=PC
                bus2_sel <= "01";  -- "01"=BUS1
                write_out <= '0';
        when S_BEQ_5 =>            -- Wait 1 Clock Cycle
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  
                bus2_sel <= "00";
                write_out <= '0';
        when S_BEQ_6 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '1';   -- PC LOAD
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  
                bus2_sel <= "10";  -- "10"=MEMORY
                write_out <= '0';
        when S_BEQ_7 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '1';     -- PC
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  
                bus2_sel <= "00";  
                write_out <= '0';

        -- BVS
        when S_BVS_4 =>
                ir_load <= '0';
                mar_load <= '1';   -- MAR
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  -- "00"=PC
                bus2_sel <= "01";  -- "01"=BUS1
                write_out <= '0';
        when S_BVS_5 =>            -- Wait 1 Clock Cycle
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  
                bus2_sel <= "00";
                write_out <= '0';
        when S_BVS_6 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '1';   -- PC LOAD
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  
                bus2_sel <= "10";  -- "10"=MEMORY
                write_out <= '0';
        when S_BVS_7 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '1';     -- PC
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  
                bus2_sel <= "00";  
                write_out <= '0';

        -- BCS
        when S_BCS_4 =>
                ir_load <= '0';
                mar_load <= '1';   -- MAR
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  -- "00"=PC
                bus2_sel <= "01";  -- "01"=BUS1
                write_out <= '0';
        when S_BCS_5 =>            -- Wait 1 Clock Cycle
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  
                bus2_sel <= "00";
                write_out <= '0';
        when S_BCS_6 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '1';   -- PC LOAD
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  
                bus2_sel <= "10";  -- "10"=MEMORY
                write_out <= '0';
        when S_BCS_7 =>
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '1';     -- PC
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  
                bus2_sel <= "00";  
                write_out <= '0';

            when others =>
                -- DEFAULT
                ir_load <= '0';
                mar_load <= '0';
                pc_load <= '0';
                pc_inc <= '0';
                a_load <= '0';
                b_load <= '0';
                alu_sel <= "000";
                ccr_load <= '0';
                bus1_sel <= "00";  -- "00"=PC
                bus2_sel <= "00";  -- "00"=ALU
                write_out <= '0';
        end case;
    end process;
----------------------------------------------------------------------

end architecture;