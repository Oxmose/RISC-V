----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.02.2019 19:47:27
-- Design Name: 
-- Module Name: TB_REGISTER_64B - TB_REGISTER_64B_BEHAVE
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_REGISTER_64B is
end TB_REGISTER_64B;

architecture TB_REGISTER_64B_BEHAVE of TB_REGISTER_64B is

component REGISTER_64B is
    Port ( D :   in STD_LOGIC_VECTOR (63 downto 0);
           RST : in STD_LOGIC;
           CLK : in STD_LOGIC;
           WR :  in STD_LOGIC;
           Q :   out STD_LOGIC_VECTOR (63 downto 0));
end component;

signal RST_D: STD_LOGIC := '0';
signal CLK_D: STD_LOGIC := '0';
signal EN_D:  STD_LOGIC := '0';

signal COUNTER_D : STD_LOGIC_VECTOR(63 downto 0) := X"0000000000000000";
signal OUTPUT :    STD_LOGIC_VECTOR(63 downto 0) := X"0000000000000000";

constant CLK_PERIOD : time := 10ns;

begin

    reg : REGISTER_64B port map (
        D => COUNTER_D,
        RST => RST_D,
        CLK => CLK_D,
        WR => EN_D,
        Q => OUTPUT
    );
        
    
    TEST_PROC_CLK: process
    begin
        CLK_D <= '0';
        wait for CLK_PERIOD / 2;
        CLK_D <= '1';
        wait for CLK_PERIOD / 2;
    end process;
    
    TEST_CLK_DRIVE: process
    begin             
        -- Test RESET
        if(COUNTER_D = X"0000000000000000") then
            RST_D <= '1';
        elsif(COUNTER_D = X"00000000000000F0") then
            RST_D <= '1';
        else 
            RST_D <= '0';
        end if;
        
        if(COUNTER_D = X"0000000000000001") then 
            assert(OUTPUT = X"0000000000000000")
            report "ERROR: Reset register changed value. 0";
        elsif(COUNTER_D = X"00000000000000F1") then
            assert(OUTPUT = X"0000000000000000")
            report "ERROR: Reset register changed value. 1";
        end if;
        
        -- Test EN
        if(COUNTER_D = X"000000000000000D") then
            EN_D <= '0';
        elsif(COUNTER_D = X"000000000000000E") then
            EN_D <= '0';
        else 
            EN_D <= '1'; 
        end if;
        
        if(COUNTER_D = X"000000000000000E") then
           assert(OUTPUT = X"000000000000000D")
           report "ERROR: Disabled register changed value. 0";
        elsif(COUNTER_D = X"000000000000000F") then
           assert(OUTPUT = X"000000000000000D")
           report "ERROR: Disabled register changed value. 0";
        elsif(unsigned(COUNTER_D) /= 0 and unsigned(COUNTER_D) /= 1) then
            assert(OUTPUT = COUNTER_D)
            report "ERROR: Register has the wrong value. 1";
        end if;
        
        COUNTER_D <= std_logic_vector(unsigned(COUNTER_D) + 1);
        
        wait for CLK_PERIOD;
    end process;

end TB_REGISTER_64B_BEHAVE;
