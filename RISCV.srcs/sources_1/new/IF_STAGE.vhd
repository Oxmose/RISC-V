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
--              IN: 32 bits, JUMP_INST_ADDR the jump address.
--              IN: 32 bits, INST_MEM_DATA the data from the instruction memory.
--              OUT: 32 bits, PC the address to fetch the data from.
--              OUT: 32 bits, INSTRUCTION the fetched instruction.
--              OUT   1 bit, SIG_ALIGN alignement exception signal.
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

ENTITY IF_STAGE IS 
    PORT ( CLK :            IN STD_LOGIC;
           RST :            IN STD_LOGIC;
           STALL :          IN STD_LOGIC;
           EF_JUMP:         IN STD_LOGIC;
           JUMP_INST_ADDR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           
           INST_MEM_DATA :      IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           MEM_LINK_VALUE_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           MEM_LINK_ADDR :      OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           MEM_LINK_SIZE :      OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
           MEM_LINK_REQ_TYPE :  OUT STD_LOGIC;
           MEM_LINK_REQ :       OUT STD_LOGIC;
           
           PC :             OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           INSTRUCTION :    OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           SIG_ALIGN :      OUT STD_LOGIC
    );
END IF_STAGE;

ARCHITECTURE IF_STAGE_BEHAVE OF IF_STAGE IS

-- Constants
CONSTANT INSTRUCTION_WIDTH : INTEGER := 4;
CONSTANT INSTRUCTION_ALIGN : STD_LOGIC_VECTOR(31 DOWNTO 0) := X"00000003";

-- Types
-- NONE.

-- Signals
SIGNAL CURR_INST_ADDR : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL MASK_INST_ADDR : STD_LOGIC_VECTOR(31 DOWNTO 0);

-- Components
-- NONE;

BEGIN
    -- PC Incrementer process 
    PC_INCREMENT: PROCESS(RST, CLK, STALL)
    BEGIN 
        IF(RST = '1') THEN
            CURR_INST_ADDR <= (OTHERS => '0');
        ELSIF(rising_edge(CLK) AND STALL = '0') THEN                        
            -- PC Selector            
            IF(EF_JUMP = '1') THEN
                -- Jump instruction address
                CURR_INST_ADDR <= JUMP_INST_ADDR;
            ELSE
                -- Increment instruction pointer
                CURR_INST_ADDR <= STD_LOGIC_VECTOR(UNSIGNED(CURR_INST_ADDR) + INSTRUCTION_WIDTH);
            END IF;
        END IF;
    END PROCESS PC_INCREMENT;
    
    -- We never write the instruction memory
    MEM_LINK_REQ_TYPE  <= '0';
    MEM_LINK_VALUE_OUT <= (OTHERS => '0');
    
    -- We never access other then 32 bits size instructions
    MEM_LINK_SIZE <= "10";
    
    -- We request new data when not stalled
    MEM_LINK_REQ <= NOT STALL AND NOT RST;
    
    -- PC is the next address to access
    PC            <= CURR_INST_ADDR;
    MEM_LINK_ADDR <= CURR_INST_ADDR;
            
    -- Async alignement exception signal      
    MASK_INST_ADDR <= CURR_INST_ADDR AND INSTRUCTION_ALIGN;
    WITH MASK_INST_ADDR SELECT SIG_ALIGN <=
        '0' WHEN X"00000000",
        '1' WHEN OTHERS;        
    
    -- Link instruction with memory output 
    INSTRUCTION <= INST_MEM_DATA;
  
END IF_STAGE_BEHAVE;
