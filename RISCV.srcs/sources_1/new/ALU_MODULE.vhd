----------------------------------------------------------------------------------
-- Author: Alexy Torres Aurora Dugo
-- 
-- Create Date: 04.03.2019 20:13:04
-- Design Name: ALU_MODULE
-- Module Name: ALU_MODULE - ALU_MODULE_FLOW
-- Project Name: RISCV
-- Target Devices: Digilent NEXYS4
-- Tool Versions: Vivado 2018.2
-- Description: Arithmetic and Logic Unit
--              IN: 64 bits, OP1 the first operand.
--              IN: 64 bits, OP2 the second operand.
--              IN: 4 bits, SEL the operation selector.
--              OUT: 64 bits, VOUT the output value.
--              OUT: 1 bit, SIG_INVALID is set to 1 when an unknown operation is set in SEL.
--
-- The values of SEL determine the ALU operation:
--     - 0000 Addition
--     - 0001 Shift left logical
--     - 0010 Set less than signed
--     - 0011 Set less than unsigned
--     - 0100 XOR
--     - 0101 Shift right logical
--     - 0110 OR
--     - 0111 AND
--     - 1000 Shift right arithmetic
--     - 1001 Substraction
--
-- Dependencies: None.
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU_MODULE is 
    Port ( OP1 :         in STD_LOGIC_VECTOR(63 downto 0);
           OP2 :         in STD_LOGIC_VECTOR(63 downto 0);
           SEL :         in STD_LOGIC_VECTOR(3 downto 0);
           VOUT :        out STD_LOGIC_VECTOR(63 downto 0);
           SIG_INVALID : out STD_LOGIC
    ); 
end ALU_MODULE;

architecture ALU_MODULE_FLOW of ALU_MODULE is

-- Signals
signal SLTI_RES :  STD_LOGIC;
signal SLTIU_RES : STD_LOGIC;

-- Constants
constant MAX_OP : unsigned(3 downto 0) := "1001";

begin

    -- Compute SLTI
    SLTI_RES  <= '1' WHEN SIGNED(OP1) < SIGNED(OP2) ELSE '0';
    SLTIU_RES <= '1' WHEN UNSIGNED(OP1) < UNSIGNED(OP2) ELSE '0';
    
    -- Invalid test
    SIG_INVALID <= '1' WHEN UNSIGNED(SEL) > MAX_OP ELSE '0';
 
    -- Operation selector
    WITH SEL SELECT VOUT <= 
        -- ADD
        STD_LOGIC_VECTOR(UNSIGNED(OP1) + UNSIGNED(OP2)) WHEN "0000",
        -- SUB
        STD_LOGIC_VECTOR(UNSIGNED(OP1) - UNSIGNED(OP2)) WHEN "1001",
        -- SLT
        X"000000000000000" & "000" & SLTI_RES WHEN "0010",
        -- SLTU
        X"000000000000000" & "000" & SLTIU_RES WHEN "0011",
        -- AND
        OP1 AND OP2 WHEN "0111",
        -- OR
        OP1 OR OP2 WHEN "0110",
        -- XOR
        OP1 XOR OP2 WHEN "0100",
        -- SLL
        STD_LOGIC_VECTOR(SHIFT_LEFT(UNSIGNED(OP1), TO_INTEGER(UNSIGNED(OP2(5 downto 0))))) WHEN "0001",
        -- SRL
        STD_LOGIC_VECTOR(SHIFT_RIGHT(UNSIGNED(OP1), TO_INTEGER(UNSIGNED(OP2(5 downto 0))))) WHEN "0101",
        -- SRA
        STD_LOGIC_VECTOR(SHIFT_RIGHT(SIGNED(OP1), TO_INTEGER(UNSIGNED(OP2(5 downto 0))))) WHEN "1000",
        -- UNKNOWN
        (others => '1') WHEN OTHERS;
    
end ALU_MODULE_FLOW;
