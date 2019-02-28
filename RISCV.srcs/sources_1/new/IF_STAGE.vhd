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
--              IN: 64 bits, INST_MEM_DATA the data from the instruction memory.
--              OUT: 64 bits, INST_MEM_ADDR the address to fetch the data from.
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
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           STALL : in STD_LOGIC;
           INST_MEM_DATA : in STD_LOGIC_VECTOR (63 downto 0);
           INST_MEM_ADDR : out STD_LOGIC_VECTOR (63 downto 0));
end IF_STAGE;

architecture IF_STAGE_BEHAVE of IF_STAGE is

-- Program counter register
component REGISTER_64B
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           EN :  in STD_LOGIC;
           D :   in STD_LOGIC_VECTOR (63 downto 0);
           Q :   out STD_LOGIC_VECTOR (63 downto 0));
end component;

-- Signals
signal PC_WRITE:  STD_LOGIC := '0';
signal NEXT_INST_ADDR: STD_LOGIC_VECTOR(63 downto 0);
signal CURR_INST_ADDR: STD_LOGIC_VECTOR(63 downto 0);

-- Constants
constant INSTRUCTION_WIDTH: integer := 4;

begin

    -- Program counter register mapping 
    U1: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN  => PC_WRITE,
        D   => NEXT_INST_ADDR,
        Q   => CURR_INST_ADDR
    );

    -- PC Incrementer process 
    PC_INCREMENT: process(RST, CLK)
    begin 
        if(RST = '1') then
            PC_WRITE <= '1';
            NEXT_INST_ADDR <= (others => '0');
        elsif(rising_edge(CLK) AND STALL = '0') then
            PC_WRITE <= '1';
            NEXT_INST_ADDR <= STD_LOGIC_VECTOR(UNSIGNED(NEXT_INST_ADDR) + INSTRUCTION_WIDTH);
        else
            PC_WRITE <= '1';
        end if;
    end process PC_INCREMENT;

end IF_STAGE_BEHAVE;
