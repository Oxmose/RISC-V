----------------------------------------------------------------------------------
-- Author: Alexy Torres Aurora Dugo
-- 
-- Create Date: 27.02.2019 21:14:04
-- Design Name: IF_STAGE
-- Module Name: IF_STAGE - IF_STAGE_BEHAVE
-- Project Name: RISCV
-- Target Devices: Digilent NEXYS4
-- Tool Versions: Vivado 2018.2
-- Description: Instruction Fetch stage of the RISCV processor.
--              This stage loads the instruction from the instruction memory. The
--              embedded program counter register keeps track of the next instruction
--              address.
--              IN: 1 bit, CLK the system clock.
--              IN: 1 bit, RST asynchronous reset.
--              IN: 1 bit, STALL asynchronous stall signal.
--              IN: 1 bit, EF_JUMP effective jump when 1
--              IN: 64 bits, JUMP_INST_ADDR the jump address.
--              IN: 64 bits, INST_MEM_DATA the data from the instruction memory.
--              OUT: 64 bits, PC the address to fetch the data from.
--              OUT: 64 bits, INSTRUCTION the fetched instruction.
--              OUT   1 bit, SIG_ALIGN alignement exception signal.
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

entity IF_STAGE is 
    Port ( CLK :            in STD_LOGIC;
           RST :            in STD_LOGIC;
           STALL :          in STD_LOGIC;
           EF_JUMP:         in STD_LOGIC;
           JUMP_INST_ADDR : in STD_LOGIC_VECTOR (63 downto 0);
           INST_MEM_DATA :  in STD_LOGIC_VECTOR (63 downto 0);
           PC :             out STD_LOGIC_VECTOR (63 downto 0);
           INSTRUCTION :    out STD_LOGIC_VECTOR (63 downto 0);
           SIG_ALIGN:       out STD_LOGIC);
end IF_STAGE;

architecture IF_STAGE_BEHAVE of IF_STAGE is

-- Signals
signal CURR_INST_ADDR: STD_LOGIC_VECTOR(63 downto 0);
signal MASK_INST_ADDR: STD_LOGIC_VECTOR(63 downto 0);

-- Constants
constant INSTRUCTION_WIDTH: integer := 4;
constant INSTRUCTION_ALIGN: STD_LOGIC_VECTOR(63 downto 0) := X"0000000000000003";

begin

    -- PC Incrementer process 
    PC_INCREMENT: process(RST, CLK)
    begin 
        if(RST = '1') then
            CURR_INST_ADDR <= (others => '0');
        elsif(rising_edge(CLK) AND STALL = '0') then                        
            -- PC Selector
            if(EF_JUMP = '1') then
                -- Jump instruction address
                CURR_INST_ADDR <= JUMP_INST_ADDR;
            else
                -- Increment instruction pointer
                CURR_INST_ADDR <= STD_LOGIC_VECTOR(UNSIGNED(CURR_INST_ADDR) + INSTRUCTION_WIDTH);
            end if;
        end if;
    end process PC_INCREMENT;
            
    -- Async alignement exception signal      
    MASK_INST_ADDR <= CURR_INST_ADDR AND INSTRUCTION_ALIGN;
    WITH MASK_INST_ADDR SELECT SIG_ALIGN <=
        '0' WHEN X"0000000000000000",
        '1' WHEN OTHERS;
        
    -- Link PC and CURR_INST_ADDR
    PC <= CURR_INST_ADDR;
    
    -- Link instruction with memory output 
    INSTRUCTION <= INST_MEM_DATA;
  
end IF_STAGE_BEHAVE;
