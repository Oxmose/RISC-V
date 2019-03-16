----------------------------------------------------------------------------------
-- Author: Alexy Torres Aurora Dugo
-- 
-- Create Date: 04.03.2019 20:13:04
-- Design Name: EXE_STAGE
-- Module Name: EXE_STAGE - EXE_STAGE_FLOW
-- Project Name: RISCV
-- Target Devices: Digilent NEXYS4
-- Tool Versions: Vivado 2018.2
-- Description: Execution stage.
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

entity EXE_STAGE is 
    Port ( OPERAND_0 :        in STD_LOGIC_VECTOR(63 downto 0);    
           OPERAND_1 :        in STD_LOGIC_VECTOR(63 downto 0);
           OPERAND_OFF :      in STD_LOGIC_VECTOR(63 downto 0);
           
           PC_IN :            in STD_LOGIC_VECTOR(63 downto 0);
           
           ALU_OP :           in STD_LOGIC_VECTOR(3 downto 0);
           BRANCH_OP :        in STD_LOGIC_VECTOR(3 downto 0); 
           OP_TYPE :          in STD_LOGIC_VECTOR(3 downto 0);
           
           PC_OUT :           out STD_LOGIC_VECTOR(63 downto 0);
           RD_OUT :          out STD_LOGIC_VECTOR(63 downto 0);
           
           ADDR_OUT :         out STD_LOGIC_VECTOR(63 downto 0);
           MEM_OP_OUT :       out STD_LOGIC_VECTOR(63 downto 0);
           
           B_TAKEN :          out STD_LOGIC;
           RD_WRITE :         out STD_LOGIC;
           
           SIG_INVALID :      out STD_LOGIC    
    );
          
end EXE_STAGE;

architecture EXE_STAGE_FLOW of EXE_STAGE is

-- Signals
signal SIG_INVALID_ALU_BUFFER : STD_LOGIC;
signal SIG_INVALID_BU_BUFFER  : STD_LOGIC;

signal RD_WRITE_BUFFER : STD_LOGIC;

signal BU_OUTPUT  : STD_LOGIC_VECTOR(63 downto 0);
signal ALU_OUTPUT : STD_LOGIC_VECTOR(63 downto 0);

-- Constants
constant OP_TYPE_ALU    : STD_LOGIC_VECTOR(3 downto 0) := "0000";
constant OP_TYPE_LUI    : STD_LOGIC_VECTOR(3 downto 0) := "0001";
constant OP_TYPE_BRANCH : STD_LOGIC_VECTOR(3 downto 0) := "0010";
constant OP_TYPE_LOAD   : STD_LOGIC_VECTOR(3 downto 0) := "0100";
constant OP_TYPE_STORE  : STD_LOGIC_VECTOR(3 downto 0) := "0101";

-- Components
component ALU_MODULE is
    Port ( OP1 :         in STD_LOGIC_VECTOR(63 downto 0);
           OP2 :         in STD_LOGIC_VECTOR(63 downto 0);
           SEL :         in STD_LOGIC_VECTOR(3 downto 0);
           VOUT :        out STD_LOGIC_VECTOR(63 downto 0);
           SIG_INVALID : out STD_LOGIC
    );
end component;

component BRANCH_UNIT_MODULE is
    Port ( OP1 :         in STD_LOGIC_VECTOR(63 downto 0);
           OP2 :         in STD_LOGIC_VECTOR(63 downto 0);
           OFF :         in STD_LOGIC_VECTOR(63 downto 0);
           PC_IN :       in STD_LOGIC_VECTOR(63 downto 0);
           SEL :         in STD_LOGIC_VECTOR(3 downto 0);
           RD_OUT :      out STD_LOGIC_VECTOR(63 downto 0);
           PC_OUT :      out STD_LOGIC_VECTOR(63 downto 0);
           B_TAKEN :     out STD_LOGIC;
           RD_WRITE :    out STD_LOGIC;
           SIG_INVALID : out STD_LOGIC
    );
end component;

begin

    -- Link the ALU
    ALU_MAP : ALU_MODULE Port Map(
        OP1         => OPERAND_0,
        OP2         => OPERAND_1,
        SEL         => ALU_OP,
        VOUT        => ALU_OUTPUT,
        SIG_INVALID => SIG_INVALID_ALU_BUFFER
    );
    
    -- Link the BU
    BU_MAP : BRANCH_UNIT_MODULE Port Map(
        OP1         => OPERAND_0,
        OP2         => OPERAND_1,
        OFF         => OPERAND_OFF,
        PC_IN       => PC_IN,
        SEL         => BRANCH_OP,
        RD_OUT      => BU_OUTPUT,
        PC_OUT      => PC_OUT,
        B_TAKEN     => B_TAKEN,
        RD_WRITE    => RD_WRITE_BUFFER,
        SIG_INVALID => SIG_INVALID_BU_BUFFER
    );
    
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
        -- On Load, store, etc. the value of RD is decided later
        X"0000000000000000" WHEN OTHERS;
        
    -- Select the memory address to use for the next stages
    ADDR_OUT <= ALU_OUTPUT;
    
    -- Select the memory operand to use for the next stages
    MEM_OP_OUT <= OPERAND_OFF;
    
end EXE_STAGE_FLOW;
