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
--              IN: 64 bits, OFF the offset to add to PC.
--              IN: 64 bits, RD_IN the current value of RD.
--              IN: 64 bits, PC_IN the current value of PC.
--              IN: 4 bits, SEL the branch operation selector.
--              OUT: 64 bits, RD_OUT the output for RD.
--              OUT: 64 bits, PC_OUT the output for PC.
--              OUT: 1 bit, B_TABKEN is set to 1 when the branch is taken, 0 otherwise.
--              OUT: 1 bit, SIG_INVALID is set to 1 when the branch operation is invalid, 0 otherwise.
--
-- The values of SEL determine the BRANCH operation:
--     - 0000 BEQ
--     - 0001 BNE
--     - 0010 INVALID
--     - 0011 INVALID
--     - 0100 BLT
--     - 0101 BGE
--     - 0110 BLTU
--     - 0111 BGEU
--     - 1000 AUIPC
--     - 1001 JAL
--     - 1010 JALR
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
    Port ( OP1 :         in STD_LOGIC_VECTOR(63 downto 0);
           OP2 :         in STD_LOGIC_VECTOR(63 downto 0);
           OFF :         in STD_LOGIC_VECTOR(63 downto 0);
           RD_IN :       in STD_LOGIC_VECTOR(63 downto 0);
           PC_IN :       in STD_LOGIC_VECTOR(63 downto 0);
           SEL :         in STD_LOGIC_VECTOR(3 downto 0);
           RD_OUT :      out STD_LOGIC_VECTOR(63 downto 0);
           PC_OUT :      out STD_LOGIC_VECTOR(63 downto 0);
           B_TAKEN :     out STD_LOGIC;
           SIG_INVALID : out STD_LOGIC
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

signal SHIFT_OFF_NEXT : STD_LOGIC_VECTOR(63 downto 0);
signal NEXT_PC :        STD_LOGIC_VECTOR(63 downto 0);

-- Constants
constant INSTRUCTION_WIDTH: integer := 4;
constant MAX_OP :           unsigned(3 downto 0) := "1010";

begin
    -- Get next isntruction 
    SHIFT_OFF_NEXT <= STD_LOGIC_VECTOR(UNSIGNED(PC_IN) + SHIFT_LEFT(UNSIGNED(OFF), 1));

    -- Compute branch conditions 
    BEQ_RES  <= SHIFT_OFF_NEXT WHEN OP1 = OP2                      ELSE PC_IN;
    BNE_RES  <= SHIFT_OFF_NEXT WHEN OP1 /= OP2                     ELSE PC_IN;
    BLT_RES  <= SHIFT_OFF_NEXT WHEN SIGNED(OP1) < SIGNED(OP2)      ELSE PC_IN;
    BLTU_RES <= SHIFT_OFF_NEXT WHEN UNSIGNED(OP1) < UNSIGNED(OP2)  ELSE PC_IN;
    BGE_RES  <= SHIFT_OFF_NEXT WHEN SIGNED(OP1) >= SIGNED(OP2)     ELSE PC_IN;
    BGEU_RES <= SHIFT_OFF_NEXT WHEN UNSIGNED(OP1) >= UNSIGNED(OP2) ELSE PC_IN;
    
    -- Compute branch taken signal
    B_TAKEN <= '0' WHEN PC_IN = NEXT_PC ELSE '1';
    
    -- Compute invalid signal 
    SIG_INVALID <= '1' WHEN SEL = "0010" OR SEL = "0011" OR UNSIGNED(SEL) > MAX_OP ELSE '0';
    
    -- NEXT_PC to PC_OUT
    PC_OUT <= NEXT_PC;
                
    -- Link RD_OUT WITH PC + 4 or AUIPC result
    WITH SEL SELECT RD_OUT <=
        -- AUIPC
        STD_LOGIC_VECTOR(UNSIGNED(PC_IN) + UNSIGNED(OFF)) WHEN "1000",
        -- JAL JALR
        STD_LOGIC_VECTOR(UNSIGNED(PC_IN) + INSTRUCTION_WIDTH) WHEN "1001" | "1010",
        -- Others
        RD_IN WHEN OTHERS;

    -- Operation selector
    WITH SEL SELECT NEXT_PC <= 
       -- AUIPC
       STD_LOGIC_VECTOR(UNSIGNED(PC_IN) + UNSIGNED(OFF)) WHEN "1000",
       -- JAL
       SHIFT_OFF_NEXT WHEN "1001",
       -- JALR
       STD_LOGIC_VECTOR(UNSIGNED(OP1) + UNSIGNED(OFF)) AND X"FFFFFFFFFFFFFFFE" WHEN "1010",
       -- BEQ
       BEQ_RES WHEN "0000",
       -- BNE
       BNE_RES WHEN "0001",
       -- BLT
       BLT_RES WHEN "0100",
       -- BGE
       BGE_RES WHEN "0101",
       -- BLTU
       BLTU_RES WHEN "0110",
       -- BGEU
       BGEU_RES WHEN "0111",
       -- UNKNOWN
       (others => '1') WHEN OTHERS;
       
end BRANCH_UNIT_MODULE_FLOW;
