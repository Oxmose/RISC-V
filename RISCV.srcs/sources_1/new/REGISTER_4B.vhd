----------------------------------------------------------------------------------
-- Author: Alexy Torres Aurora Dugo
-- 
-- Create Date: 27.02.2019 19:26:52
-- Design Name: REGISTER_1B
-- Module Name: REGISTER_1B - REGISTER_32B_BEHAVIOR
-- Project Name: RISCV
-- Target Devices: Digilent NEXYS4
-- Tool Versions: Vivado 2018.2
-- Description: 1 Bit register. Stores the input values until reset is used.
--              IN:  1 bit, D The 1 bit value to store.
--              IN:  1 bit, RST resets the register, stored value will be 0.
--              IN:  1 bit, CLK register clock.
--              IN:  1 bit, WR 1 enables write to the register, 0 disables write to the register.
--              OUT: 1 bit, Q the output value of the register.
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

ENTITY REGISTER_1B IS
    PORT ( CLK : IN STD_LOGIC;
           RST : IN STD_LOGIC;
           WR :  IN STD_LOGIC;
           D :   IN STD_LOGIC;
           Q :   OUT STD_LOGIC
    );
END REGISTER_1B;

ARCHITECTURE REGISTER_1B_BEHAVIOR OF REGISTER_1B IS
BEGIN

    REG_PROC: PROCESS(RST, CLK, WR)
    BEGIN
        -- On RST, set Q to 0
        IF(RST = '1') THEN
            Q <= '0';
        -- On rising eadge, if EN is set to 1, write new output
        ELSIF(RISING_EDGE(CLK) AND WR = '1') THEN
            Q <= D;
        END IF;
    END PROCESS REG_PROC;

END REGISTER_1B_BEHAVIOR;
