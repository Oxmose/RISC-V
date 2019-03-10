----------------------------------------------------------------------------------
-- Author: Alexy Torres Aurora Dugo
-- 
-- Create Date: 10.03.2019 10:50:43
-- Design Name: BRANCH_UNIT_MODULE
-- Module Name: BRANCH_UNIT_MODULE - BRANCH_UNIT_MODULE_FLOW
-- Project Name: RISCV
-- Target Devices: Digilent NEXYS4
-- Tool Versions: Vivado 2018.2
-- Description: Branch unit
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

entity BRANCH_UNIT_MODULE is
    Port ( OP1 :      in STD_LOGIC_VECTOR(63 downto 0);
           OP2 :      in STD_LOGIC_VECTOR(63 downto 0);
           OFF :      in STD_LOGIC_VECTOR(63 downto 0);
           PC_IN :    in STD_LOGIC_VECTOR(63 downto 0);
           SEL :      in STD_LOGIC_VECTOR(3 downto 0);
           RD_OUT :   out STD_LOGIC_VECTOR(63 downto 0);
           PC_OUT :   out STD_LOGIC_VECTOR(63 downto 0)
    );
end BRANCH_UNIT_MODULE;

architecture BRANCH_UNIT_MODULE_FLOW of BRANCH_UNIT_MODULE is

-- Signals 
signal BEQ_RES :  STD_LOGIC_VECTOR(63 downto 0);
signal BNE_RES :  STD_LOGIC_VECTOR(63 downto 0);
signal BLT_RES :  STD_LOGIC_VECTOR(63 downto 0);
signal BLTU_RES : STD_LOGIC_VECTOR(63 downto 0);
signal BGE_RES :  STD_LOGIC_VECTOR(63 downto 0);
signal BGEU_RES : STD_LOGIC_VECTOR(63 downto 0);

signal NEXT_INST : STD_LOGIC_VECTOR(63 downto 0);
signal SHIFT_OFF_NEXT : STD_LOGIC_VECTOR(63 downto 0);

-- Constants
constant INSTRUCTION_WIDTH: integer := 4;

begin
    -- Get next isntruction 
    NEXT_INST      <= STD_LOGIC_VECTOR(UNSIGNED(PC_IN) + INSTRUCTION_WIDTH);
    SHIFT_OFF_NEXT <= STD_LOGIC_VECTOR(UNSIGNED(PC_IN) + SHIFT_LEFT(UNSIGNED(OFF), 1));

    -- Compute branch conditions 
    BEQ_RES  <= SHIFT_OFF_NEXT WHEN OP1 = OP2                      ELSE NEXT_INST;
    BNE_RES  <= SHIFT_OFF_NEXT WHEN OP1 /= OP2                     ELSE NEXT_INST;
    BLT_RES  <= SHIFT_OFF_NEXT WHEN SIGNED(OP1) < SIGNED(OP2)      ELSE NEXT_INST;   
    BLTU_RES <= SHIFT_OFF_NEXT WHEN UNSIGNED(OP1) < UNSIGNED(OP2)  ELSE NEXT_INST;
    BGE_RES  <= SHIFT_OFF_NEXT WHEN SIGNED(OP1) >= SIGNED(OP2)     ELSE NEXT_INST; 
    BGEU_RES <= SHIFT_OFF_NEXT WHEN UNSIGNED(OP1) >= UNSIGNED(OP2) ELSE NEXT_INST; 
                
    -- Link RD_OUT WITH PC + 4 or AUIPC result
    WITH SEL SELECT RD_OUT <=
        -- AUIPC
        STD_LOGIC_VECTOR(UNSIGNED(PC_IN) + UNSIGNED(OFF)) WHEN "1000",
        -- Others
        NEXT_INST WHEN OTHERS;

    -- Operation selector
    WITH SEL SELECT PC_OUT <= 
       -- AUIPC
       STD_LOGIC_VECTOR(UNSIGNED(PC_IN) + UNSIGNED(OFF)) WHEN "1000",
       -- JAL
       SHIFT_OFF_NEXT WHEN "1001",
       -- JARL
       STD_LOGIC_VECTOR(UNSIGNED(OP1) + UNSIGNED(OFF)) AND X"FFFFFFFFFFFFFFFE" WHEN "1010",
       -- BEQ
       BEQ_RES WHEN "0000",
       -- BNEQ
       BNE_RES WHEN "0001",
       -- BLT
       BLT_RES WHEN "0100",
       -- BGE
       BGE_RES WHEN "0101",
       -- BLTU
       BLTU_RES WHEN "0110",
       -- BGEU
       BGE_RES WHEN "0111",
       -- UNKNOWN
       (others => '1') WHEN OTHERS;
end BRANCH_UNIT_MODULE_FLOW;
