----------------------------------------------------------------------------------
-- Author: Alexy Torres Aurora Dugo
-- 
-- Create Date: 27.02.2019 19:26:52
-- Design Name: REGISTER_32B
-- Module Name: REGISTER_32B - REGISTER_32B_BEHAVIOR
-- Project Name: RISCV
-- Target Devices: Digilent NEXYS4
-- Tool Versions: Vivado 2018.2
-- Description: 32 Bits register. Stores the input values until reset is used.
--              IN:  32 bits, D The 32 bits value to store.
--              IN:  1 bit, RST resets the register, stored value will be 0.
--              IN:  1 bit, CLK register clock.
--              IN:  1 bit, EN 1 enables write to the register, 0 disables write to the register.
--              OUT: 32 bits, Q the output value of the register.
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

entity REGISTER_32B is
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           EN :  in STD_LOGIC;
           D :   in STD_LOGIC_VECTOR (31 downto 0);
           Q :   out STD_LOGIC_VECTOR (31 downto 0)
    );
end REGISTER_32B;

architecture REGISTER_32B_BEHAVIOR of REGISTER_32B is
begin

    process(RST, CLK)
    begin
        -- On RST, set Q to 0
        if(RST = '1') then
            Q <= (others => '0');
        -- On rising eadge, if EN is set to 1, write new output
        elsif(rising_edge(CLK) AND EN = '1') then
            Q <= D;
        end if;
    end process;

end REGISTER_32B_BEHAVIOR;
