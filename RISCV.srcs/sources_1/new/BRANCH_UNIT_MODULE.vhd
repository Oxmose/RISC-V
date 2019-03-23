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
--              IN: 64 bits, PC_IN the current value of PC.
--              IN: 4 bits, SEL the branch operation selector.
--              OUT: 64 bits, RD_OUT the output for RD.
--              OUT: 64 bits, PC_OUT the output for PC.
--              OUT: 1 bit, B_TABKEN is set to 1 when the branch is taken, 0 otherwise.
--              OUT: 1 bit, RD_WRITE is set to 1 is RD must be rewriten.
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

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY BRANCH_UNIT_MODULE IS
    PORT ( OP1 :         IN STD_LOGIC_VECTOR(63 DOWNTO 0);
           OP2 :         IN STD_LOGIC_VECTOR(63 DOWNTO 0);
           OFF :         IN STD_LOGIC_VECTOR(63 DOWNTO 0);
           PC_IN :       IN STD_LOGIC_VECTOR(63 DOWNTO 0);
           SEL :         IN STD_LOGIC_VECTOR(3 DOWNTO 0);
           RD_OUT :      OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
           PC_OUT :      OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
           B_TAKEN :     OUT STD_LOGIC;
           RD_WRITE :    OUT STD_LOGIC;
           SIG_INVALID : OUT STD_LOGIC
    );
END BRANCH_UNIT_MODULE;

ARCHITECTURE BRANCH_UNIT_MODULE_FLOW OF BRANCH_UNIT_MODULE IS

-- Constants
CONSTANT INSTRUCTION_WIDTH : INTEGER := 4;

CONSTANT MAX_OP : UNSIGNED(3 DOWNTO 0) := "1010";

CONSTANT OP_AUIPC : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1000";
CONSTANT OP_JAL :   STD_LOGIC_VECTOR(3 DOWNTO 0) := "1001";
CONSTANT OP_JALR :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "1010";
CONSTANT OP_BEQ :   STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
CONSTANT OP_BNE :   STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
CONSTANT OP_BLT :   STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100";
CONSTANT OP_BGE :   STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101";
CONSTANT OP_BLTU :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "0110";
CONSTANT OP_BGEU :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "0111";

-- Types
-- NONE.

-- Signals 
SIGNAL BEQ_RES :  STD_LOGIC_VECTOR(63 DOWNTO 0);
SIGNAL BNE_RES :  STD_LOGIC_VECTOR(63 DOWNTO 0);
SIGNAL BLT_RES :  STD_LOGIC_VECTOR(63 DOWNTO 0);
SIGNAL BLTU_RES : STD_LOGIC_VECTOR(63 DOWNTO 0);
SIGNAL BGE_RES :  STD_LOGIC_VECTOR(63 DOWNTO 0);
SIGNAL BGEU_RES : STD_LOGIC_VECTOR(63 DOWNTO 0);

SIGNAL SHIFT_OFF_NEXT : STD_LOGIC_VECTOR(63 DOWNTO 0);
SIGNAL NEXT_PC :        STD_LOGIC_VECTOR(63 DOWNTO 0);

-- Components
-- NONE.

BEGIN
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
        STD_LOGIC_VECTOR(UNSIGNED(PC_IN) + UNSIGNED(OFF)) WHEN OP_AUIPC,
        -- JAL JALR
        STD_LOGIC_VECTOR(UNSIGNED(PC_IN) + INSTRUCTION_WIDTH) WHEN OP_JAL | OP_JALR,
        -- Others
        X"0000000000000000" WHEN OTHERS;
        
    -- Set RD_WRITE
    WITH SEL SELECT RD_WRITE <=
        -- AUIPC JAL JALR
        '1' WHEN OP_AUIPC | OP_JAL | OP_JALR,
        -- Others
        '0' WHEN OTHERS;

    -- Operation selector
    WITH SEL SELECT NEXT_PC <= 
       -- AUIPC
       STD_LOGIC_VECTOR(UNSIGNED(PC_IN) + UNSIGNED(OFF)) WHEN OP_AUIPC,
       -- JAL
       SHIFT_OFF_NEXT WHEN OP_JAL,
       -- JALR
       STD_LOGIC_VECTOR(UNSIGNED(OP1) + UNSIGNED(OFF)) AND X"FFFFFFFFFFFFFFFE" WHEN OP_JALR,
       -- BEQ
       BEQ_RES WHEN OP_BEQ,
       -- BNE
       BNE_RES WHEN OP_BNE,
       -- BLT
       BLT_RES WHEN OP_BLT,
       -- BGE
       BGE_RES WHEN OP_BGE,
       -- BLTU
       BLTU_RES WHEN OP_BLTU,
       -- BGEU
       BGEU_RES WHEN OP_BGEU,
       -- UNKNOWN
       PC_IN WHEN OTHERS;
       
END BRANCH_UNIT_MODULE_FLOW;
