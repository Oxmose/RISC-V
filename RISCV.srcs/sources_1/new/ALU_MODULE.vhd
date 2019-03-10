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
--              IN: 10 bits, SEL the operation selector.
--              OUT: 64 bits, VOUT the output value.
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
    Port ( OP1 :      in STD_LOGIC_VECTOR(63 downto 0);
           OP2 :      in STD_LOGIC_VECTOR(63 downto 0);
           SEL :      in STD_LOGIC_VECTOR(5 downto 0);
           VOUT :     out STD_LOGIC_VECTOR(63 downto 0)
    );
          
end ALU_MODULE;

architecture ALU_MODULE_FLOW of ALU_MODULE is

-- Signals
signal SLTI_RES :  STD_LOGIC;
signal SLTIU_RES : STD_LOGIC;
signal EQ_RES :    STD_LOGIC;

-- Constants

begin

    -- Compute SLTI
    SLTI_RES  <= '1' WHEN SIGNED(OP1) < SIGNED(OP2) ELSE '0';
    SLTIU_RES <= '1' WHEN UNSIGNED(OP1) < UNSIGNED(OP2) ELSE '0';
    
    -- Compute EQ
    EQ_RES <= '1' WHEN OP1 = OP2 ELSE '0';

    WITH SEL SELECT VOUT <= 
        -- ADD
        STD_LOGIC_VECTOR(UNSIGNED(OP1) + UNSIGNED(OP2)) WHEN "000000",
        -- SUB
        STD_LOGIC_VECTOR(UNSIGNED(OP1) - UNSIGNED(OP2)) WHEN "001001",
        -- SLT
        X"000000000000000" & "000" & SLTI_RES WHEN "000010",
        -- SLTU
        X"000000000000000" & "000" & SLTIU_RES WHEN "000011",
        -- AND
        OP1 AND OP2 WHEN "000111",
        -- OR
        OP1 OR OP2 WHEN "000110",
        -- XOR
        OP1 XOR OP2 WHEN "000100",
        -- SLL
        STD_LOGIC_VECTOR(SHIFT_LEFT(UNSIGNED(OP1), TO_INTEGER(UNSIGNED(OP2(5 downto 0))))) WHEN "000001",
        -- SRL
        STD_LOGIC_VECTOR(SHIFT_RIGHT(UNSIGNED(OP1), TO_INTEGER(UNSIGNED(OP2(5 downto 0))))) WHEN "000101",
        -- SRA
        STD_LOGIC_VECTOR(SHIFT_RIGHT(SIGNED(OP1), TO_INTEGER(UNSIGNED(OP2(5 downto 0))))) WHEN "001000",
        -- EQ
        X"000000000000000" & "000" & EQ_RES WHEN "001010",
        -- UNKNOWN
        (others => '1') WHEN OTHERS;
    
    -- Operation selector
    
end ALU_MODULE_FLOW;
