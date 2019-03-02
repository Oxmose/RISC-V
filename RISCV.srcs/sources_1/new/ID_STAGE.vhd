----------------------------------------------------------------------------------
-- Author: Alexy Torres Aurora Dugo
-- 
-- Create Date: 02.03.2019 12:48:23
-- Design Name: ID_STAGE
-- Module Name: ID_STAGE - IF_STAGE_BEHAVE
-- Project Name: RISCV
-- Target Devices: Digilent NEXYS4
-- Tool Versions: Vivado 2018.2
-- Description: Instruction Decode stage of the RISCV processor.
--              This stage decodes the instruction.The instruction is split in different
--              parts that are used in the next stages.
--              IN: 1 bit, CLK the system clock.
--              IN: 1 bit, RST asynchronous reset.
--              IN: 1 bit, STALL asynchronous stall signal.
--              IN: 64 bits, INSTRUCTION_DATA the data to decode.
--              IN: 64 bits, PC the current program counter.
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
    Port ( CLK :              in STD_LOGIC;
           RST :              in STD_LOGIC;
           STALL :            in STD_LOGIC;
           INSTRUCTION_DATA : in STD_LOGIC_VECTOR (63 downto 0);
           INST_MEM_DATA :  in STD_LOGIC_VECTOR (63 downto 0);
           PC :             out STD_LOGIC_VECTOR (63 downto 0));
end ID_STAGE;

architecture ID_STAGE_BEHAVE of ID_STAGE is

-- Signals
-- Constants

begin


end ID_STAGE_BEHAVE;
