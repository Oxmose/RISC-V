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
--              IN: 64 bits, OPCODE the current intruction's opcode.
--              IN: 5 bits, RD the destination tion register
--              IN: 5 bits, RS1 the first source register.
--              IN: 5 bits, RS2 the second source register.
--              IN: 3 bits, FUNCT3 the funct3 operand.
--              IN: 7 bits, FUNCT7 the funct7 operand.
--              IN: 32 bits, IMM_I the I format immediate.
--              IN: 32 bits, IMM_S the S format immediate.
--              IN: 32 bits, IMM_B the B format immediate.
--              IN: 32 bits, IMM_U the U format immediate.
--              IN: 32 bits, IMM_J the J format immediate.
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
    Port ( OPCODE :           in STD_LOGIC_VECTOR(6 downto 0);
           RD :               in STD_LOGIC_VECTOR(4 downto 0);
           RS1 :              in STD_LOGIC_VECTOR(4 downto 0);
           RS2 :              in STD_LOGIC_VECTOR(4 downto 0);
           FUNCT3 :           in STD_LOGIC_VECTOR(2 downto 0);
           FUNCT7 :           in STD_LOGIC_VECTOR(6 downto 0);
           IMM_I :            in STD_LOGIC_VECTOR(31 downto 0);
           IMM_S :            in STD_LOGIC_VECTOR(31 downto 0);
           IMM_B :            in STD_LOGIC_VECTOR(31 downto 0);
           IMM_U :            in STD_LOGIC_VECTOR(31 downto 0);
           IMM_J :            in STD_LOGIC_VECTOR(31 downto 0)
    );
          
end EXE_STAGE;

architecture EXE_STAGE_FLOW of EXE_STAGE is

-- Signals

-- Constants

begin
    
end EXE_STAGE_FLOW;
