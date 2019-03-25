----------------------------------------------------------------------------------
-- Author: Alexy Torres Aurora Dugo
-- 
-- Create Date: 04.03.2019 20:13:04
-- Design Name: EXE_STAGE
-- Module Name: EXE_STAGE - EXE_STAGE_FLOW
-- Project Name: RISCV
-- Target Devices: Digilent NEXYS4
-- Tool Versions: Vivado 2018.2
-- Description: Execution stage. Gathers the ALU and the BRANCH unit.
--              IN: 32 bits, OPERAND_0 the first operand for BU or ALU operations
--              IN: 32 bits, OPERAND_1 the second operand for BU or ALU operations
--              IN: 32 bits, OPERAND_OFF the offset operand for BU or ALU operations, also used to keep store memory values
--              IN: 32 bits, PC_IN PC value in
--              IN: 4 bits, ALU_OP ALU operation selector
--              IN: 4 bits, BRANCH_OP BRANCH Unit operation selector
--              IN: 4 bits, OP_TYPE Operation type selector
--              OUT: 32 bits, PC_OUT PC value out
--              OUT: 32 bits, RD_OUT RD value out
--              OUT: 32 bits, ADDR_OUT Memory access address
--              OUT: 32 bits, MEM_OP_OUT Memory access value in case of store
--              OUT: 1 bit, B_TAKEN is set to 1 when a branch is taken
--              OUT: 1 bit, RD_WRITE is set to 1 when RD must be updated
--              OUT: 1 bit, SIG_INVALID is set to 1 when INVALID condition is detected
--
-- Dependencies: ALU_MODULE, BRANCH_UNIT_MODULE.
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY EXE_STAGE IS 
    PORT ( OPERAND_0 :        IN STD_LOGIC_VECTOR(31 DOWNTO 0);    
           OPERAND_1 :        IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           OPERAND_OFF :      IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           
           PC_IN :            IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           
           ALU_OP :           IN STD_LOGIC_VECTOR(3 DOWNTO 0);
           BRANCH_OP :        IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
           OP_TYPE :          IN STD_LOGIC_VECTOR(3 DOWNTO 0);
           
           PC_OUT :           OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           RD_OUT :           OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            
           ADDR_OUT :         OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           
           B_TAKEN :          OUT STD_LOGIC;
           RD_WRITE :         OUT STD_LOGIC;
           
           SIG_INVALID :      OUT STD_LOGIC    
    ); 
END EXE_STAGE;

ARCHITECTURE EXE_STAGE_FLOW OF EXE_STAGE IS

-- Constants
CONSTANT OP_TYPE_ALU :    STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
CONSTANT OP_TYPE_LUI :    STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
CONSTANT OP_TYPE_BRANCH : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010";
CONSTANT OP_TYPE_LOAD :   STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100";
CONSTANT OP_TYPE_STORE :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101";

-- Types
-- NONE.

-- Signals
SIGNAL SIG_INVALID_ALU_BUFFER : STD_LOGIC;
SIGNAL SIG_INVALID_BU_BUFFER :  STD_LOGIC;

SIGNAL B_TAKEN_BUFFER :  STD_LOGIC;
SIGNAL RD_WRITE_BUFFER : STD_LOGIC;

SIGNAL BU_OUTPUT :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL ALU_OUTPUT : STD_LOGIC_VECTOR(31 DOWNTO 0);

-- Components
COMPONENT ALU_MODULE IS
    PORT ( OP1 :         IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           OP2 :         IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           SEL :         IN STD_LOGIC_VECTOR(3 DOWNTO 0);
           VOUT :        OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           SIG_INVALID : OUT STD_LOGIC
    );
END COMPONENT;

COMPONENT BRANCH_UNIT_MODULE IS
    PORT ( OP1 :         IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           OP2 :         IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           OFF :         IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           PC_IN :       IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           SEL :         IN STD_LOGIC_VECTOR(3 DOWNTO 0);
           RD_OUT :      OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           PC_OUT :      OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           B_TAKEN :     OUT STD_LOGIC;
           RD_WRITE :    OUT STD_LOGIC;
           SIG_INVALID : OUT STD_LOGIC
    );
END COMPONENT;

BEGIN

    -- Link the ALU
    ALU_MAP : ALU_MODULE PORT MAP(
        OP1         => OPERAND_0,
        OP2         => OPERAND_1,
        SEL         => ALU_OP,
        VOUT        => ALU_OUTPUT,
        SIG_INVALID => SIG_INVALID_ALU_BUFFER
    );
    
    -- Link the BU
    BU_MAP : BRANCH_UNIT_MODULE PORT MAP(
        OP1         => OPERAND_0,
        OP2         => OPERAND_1,
        OFF         => OPERAND_OFF,
        PC_IN       => PC_IN,
        SEL         => BRANCH_OP,
        RD_OUT      => BU_OUTPUT,
        PC_OUT      => PC_OUT,
        B_TAKEN     => B_TAKEN_BUFFER,
        RD_WRITE    => RD_WRITE_BUFFER,
        SIG_INVALID => SIG_INVALID_BU_BUFFER
    );
    
    -- Check that if branch is taken that indeed we have a branch op
    B_TAKEN <= B_TAKEN_BUFFER WHEN OP_TYPE = OP_TYPE_BRANCH
               ELSE '0';
    
    -- Set the INVALID signal 
    WITH OP_TYPE SELECT SIG_INVALID <=
        -- Check the values of other units
        SIG_INVALID_ALU_BUFFER WHEN OP_TYPE_ALU |  OP_TYPE_LOAD | OP_TYPE_STORE,
        SIG_INVALID_BU_BUFFER  WHEN OP_TYPE_BRANCH,
        -- LUI is detected
        '0' WHEN OP_TYPE_LUI,
        -- Detect error
        '1' WHEN OTHERS;
    
    -- Select the value of RD WRITE
    WITH OP_TYPE SELECT RD_WRITE <=
        -- On branch, let the BU choose
        RD_WRITE_BUFFER WHEN OP_TYPE_BRANCH,
        -- On ALU Operation, LUI Operation and Load operation RD is always written
        '1' WHEN OP_TYPE_ALU | OP_TYPE_LUI | OP_TYPE_LOAD,
        -- Else we don't want to touch RD
        '0' WHEN OTHERS;
        
    -- Select the value that will go to RD depending on the OP type 
    WITH OP_TYPE SELECT RD_OUT <=
        -- On Branch operation ,take BU output
        BU_OUTPUT WHEN OP_TYPE_BRANCH,
        -- On ALU operation take ALU output
        ALU_OUTPUT WHEN OP_TYPE_ALU,
        -- On LUI, take immediate operand 0
        OPERAND_0 WHEN OP_TYPE_LUI,
        -- On STORE, take offset value
        OPERAND_OFF WHEN OP_TYPE_STORE,
        -- On Load, etc. the value of RD is decided later
        X"00000000" WHEN OTHERS;
        
    -- Select the memory address to use for the next stages
    ADDR_OUT <= ALU_OUTPUT;    
END EXE_STAGE_FLOW;
