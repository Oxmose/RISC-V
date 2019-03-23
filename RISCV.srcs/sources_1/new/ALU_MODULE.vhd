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
--              IN: 32 bits, OP1 the first operand.
--              IN: 32 bits, OP2 the second operand.
--              IN: 4 bits, SEL the operation selector.
--              OUT: 32 bits, VOUT the output value.
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


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ALU_MODULE IS 
    PORT ( OP1 :         IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           OP2 :         IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           SEL :         IN STD_LOGIC_VECTOR(3 DOWNTO 0);
           VOUT :        OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           SIG_INVALID : OUT STD_LOGIC
    ); 
END ALU_MODULE;

ARCHITECTURE ALU_MODULE_FLOW OF ALU_MODULE IS

-- Constants
CONSTANT MAX_OP : UNSIGNED(3 downto 0) := "1001";

CONSTANT OP_ADD :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
CONSTANT OP_SUB :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "1001";
CONSTANT OP_SLT :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010";
CONSTANT OP_SLTU : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011";
CONSTANT OP_AND :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "0111";
CONSTANT OP_OR :   STD_LOGIC_VECTOR(3 DOWNTO 0) := "0110";
CONSTANT OP_XOR :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100";
CONSTANT OP_SLL :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
CONSTANT OP_SRL :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101";
CONSTANT OP_SRA :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "1000";

-- Types
-- NONE.

-- Signals
SIGNAL SLTI_RES :  STD_LOGIC;
SIGNAL SLTIU_RES : STD_LOGIC;

-- Components
-- NONE.

BEGIN
    -- Compute SLTI
    SLTI_RES  <= '1' WHEN SIGNED(OP1) < SIGNED(OP2)     ELSE '0';
    SLTIU_RES <= '1' WHEN UNSIGNED(OP1) < UNSIGNED(OP2) ELSE '0';
    
    -- Invalid test
    SIG_INVALID <= '1' WHEN UNSIGNED(SEL) > MAX_OP ELSE '0';
 
    -- Operation selector
    WITH SEL SELECT VOUT <= 
        -- ADD
        STD_LOGIC_VECTOR(UNSIGNED(OP1) + UNSIGNED(OP2)) WHEN OP_ADD,
        -- SUB
        STD_LOGIC_VECTOR(UNSIGNED(OP1) - UNSIGNED(OP2)) WHEN OP_SUB,
        -- SLT
        X"0000000" & "000" & SLTI_RES  WHEN OP_SLT,
        -- SLTU
        X"0000000" & "000" & SLTIU_RES WHEN OP_SLTU,
        -- AND
        OP1 AND OP2 WHEN OP_AND,
        -- OR
        OP1 OR OP2  WHEN OP_OR,
        -- XOR
        OP1 XOR OP2 WHEN OP_XOR,
        -- SLL
        STD_LOGIC_VECTOR(SHIFT_LEFT(UNSIGNED(OP1), TO_INTEGER(UNSIGNED(OP2(4 DOWNTO 0)))))  WHEN OP_SLL,
        -- SRL
        STD_LOGIC_VECTOR(SHIFT_RIGHT(UNSIGNED(OP1), TO_INTEGER(UNSIGNED(OP2(4 DOWNTO 0))))) WHEN OP_SRL,
        -- SRA
        STD_LOGIC_VECTOR(SHIFT_RIGHT(SIGNED(OP1), TO_INTEGER(UNSIGNED(OP2(4 DOWNTO 0)))))   WHEN OP_SRA,
        -- UNKNOWN
        (OTHERS => '1') WHEN OTHERS;
    
END ALU_MODULE_FLOW;
