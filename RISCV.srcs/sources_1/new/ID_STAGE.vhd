----------------------------------------------------------------------------------
-- Author: Alexy Torres Aurora Dugo
-- 
-- Create Date: 02.03.2019 12:48:23
-- Design Name: ID_STAGE
-- Module Name: ID_STAGE - ID_STAGE_FLOW
-- Project Name: RISCV
-- Target Devices: Digilent NEXYS4
-- Tool Versions: Vivado 2018.2
-- Description: Instruction Decode stage of the RISCV processor.
--              This stage decodes the instruction.The instruction is split in different
--              parts that are used in the next stages.
--              IN: 64 bits, INSTRUCTION_DATA the data to decode.
--              OUT: 64 bits, OPCODE the current intruction's opcode.
--              OUT: 5 bits, RD the destination tion register
--              OUT: 5 bits, RS1 the first source register.
--              OUT: 5 bits, RS2 the second source register.
--              OUT: 3 bits, FUNCT3 the funct3 operand.
--              OUT: 7 bits, FUNCT7 the funct7 operand.
--              OUT: 32 bits, IMM_I the I format immediate.
--              OUT: 32 bits, IMM_S the S format immediate.
--              OUT: 32 bits, IMM_B the B format immediate.
--              OUT: 32 bits, IMM_U the U format immediate.
--              OUT: 32 bits, IMM_J the J format immediate.
--              OUT: 1 bit, SIG_INVALID the instruction invalid exception signal.
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

entity ID_STAGE is 
    Port ( INSTRUCTION_DATA : in STD_LOGIC_VECTOR (63 downto 0);
           OPCODE :           out STD_LOGIC_VECTOR(6 downto 0);
           RD :               out STD_LOGIC_VECTOR(4 downto 0);
           RS1 :              out STD_LOGIC_VECTOR(4 downto 0);
           RS2 :              out STD_LOGIC_VECTOR(4 downto 0);
           FUNCT3 :           out STD_LOGIC_VECTOR(2 downto 0);
           FUNCT7 :           out STD_LOGIC_VECTOR(6 downto 0);
           IMM_I :            out STD_LOGIC_VECTOR(31 downto 0);
           IMM_S :            out STD_LOGIC_VECTOR(31 downto 0);
           IMM_B :            out STD_LOGIC_VECTOR(31 downto 0);
           IMM_U :            out STD_LOGIC_VECTOR(31 downto 0);
           IMM_J :            out STD_LOGIC_VECTOR(31 downto 0);
           SIG_INVALID :      out STD_LOGIC
    );
          
end ID_STAGE;

architecture ID_STAGE_FLOW of ID_STAGE is

-- Signals

-- Constants

begin
    -- As defined by RISC-V RV64I, opcode is defined by the 7 first bits
    OPCODE <= INSTRUCTION_DATA(6 downto 0);
    
    -- As defined by RISC-V RV64I, RD is defined by the bits 7 to 11
    RD <= INSTRUCTION_DATA(11 downto 7);
    
    -- As defined by RISC-V RV64I, RS1 is defined by the bits 15 to 19
    RS1 <= INSTRUCTION_DATA(19 downto 15);
    
    -- As defined by RISC-V RV64I, RS2 is defined by the bits 20 to 24
    RS2 <= INSTRUCTION_DATA(24 downto 20);

    -- As defined by RISC-V RV64I, FUNCT3 is defined by the bits 12 to 14
    FUNCT3 <= INSTRUCTION_DATA(14 downto 12);
    
    -- As defined by RISC-V RV64I, FUNCT7 is defined by the bits 25 to 31
    FUNCT7 <= INSTRUCTION_DATA(31 downto 25);
    
    -- I Immediate
    IMM_I(10 downto 0)  <= INSTRUCTION_DATA(30 downto 20);
    IMM_I(31 downto 11) <= (others => INSTRUCTION_DATA(31));
    
    -- S Immediate
    IMM_S(4 downto 0)   <= INSTRUCTION_DATA(11 downto 7);
    IMM_S(10 downto 5)  <= INSTRUCTION_DATA(30 downto 25);
    IMM_S(31 downto 11) <= (others => INSTRUCTION_DATA(31));
    
    -- B Immmediate
    IMM_B(0) <= '0';
    IMM_B(4 downto 1)   <= INSTRUCTION_DATA(11 downto 8);
    IMM_B(10 downto 5)  <= INSTRUCTION_DATA(30 downto 25);
    IMM_B(11)           <= INSTRUCTION_DATA(7);
    IMM_B(31 downto 12) <= (others => INSTRUCTION_DATA(31)); 
    
    -- U Immediate
    IMM_U(11 downto 0)  <= (others => '0'); 
    IMM_U(31 downto 12) <= INSTRUCTION_DATA(31 downto 12);
    
    -- J Immediate
    IMM_J(0)            <= '0';
    IMM_J(10 downto 1)  <= INSTRUCTION_DATA(30 downto 21);
    IMM_J(11)           <= INSTRUCTION_DATA(20);
    IMM_J(19 downto 12) <= INSTRUCTION_DATA(19 downto 12);
    IMM_J(31 downto 20) <= (others => INSTRUCTION_DATA(31));
    
    -- Check OPCODE, no custom nor reserved OPCODE is supported
    WITH INSTRUCTION_DATA(6 downto 0) SELECT SIG_INVALID <=
        '0' WHEN "0000011" | "0100011" | "1000011" | "1100011", -- LOAD STORE MADD BRANCH
        '0' WHEN "0000111" | "0100111" | "1000111" | "1100111", -- LOADFP STOREFP MSUB JALR
        '0' WHEN "1001011",                                     -- NMSUB
        '0' WHEN "0001111" | "0101111" | "1001111" | "1101111", -- MISC-MEM AMO NMADD JAL
        '0' WHEN "0010011" | "0110011" | "1010011" | "1110011", -- OP-IMM OP OP-FP SYSTEM
        '0' WHEN "0010111" | "0110111",                         -- AUIPC LUI
        '0' WHEN "0011011" | "0111011",                         -- OP-IMM-32 OP-32
        '1' WHEN OTHERS;
    
    
end ID_STAGE_FLOW;
