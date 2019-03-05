----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.03.2019 13:52:22
-- Design Name: 
-- Module Name: TB_REG_BANK - Behavioral
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

entity TB_REG_BANK is
end TB_REG_BANK;

architecture Behavioral of TB_REG_BANK is

component  REG_BANK 
    Port ( CLK :   in STD_LOGIC;
           RST :   in STD_LOGIC;
           STALL : in STD_LOGIC;
           WRITE:  in STD_LOGIC;
           RRID1 : in STD_LOGIC_VECTOR (4 downto 0);  
           RRID2 : in STD_LOGIC_VECTOR (4 downto 0);  
           WRID :  in STD_LOGIC_VECTOR (4 downto 0);  
           RWVAL : in STD_LOGIC_VECTOR (63 downto 0);
           RRVAL1 : OUT STD_LOGIC_VECTOR (63 downto 0);
           RRVAL2 : OUT STD_LOGIC_VECTOR (63 downto 0));
end component;

signal RST_D:       STD_LOGIC := '1';
signal CLK_D:       STD_LOGIC := '0';
signal STALL_D:     STD_LOGIC := '0';
signal WRITE_D:     std_LOGIC := '0';

signal RRID1_D: STD_LOGIC_VECTOR(4 downto 0) := "00000";
signal RRID2_D: STD_LOGIC_VECTOR(4 downto 0) := "00000";
signal WRID_D: STD_LOGIC_VECTOR(4 downto 0) := "00000";

signal RWVAL_D: STD_LOGIC_VECTOR(63 downto 0) := X"0000000000000000";
signal RRVAL1_D: STD_LOGIC_VECTOR(63 downto 0) := X"0000000000000000";
signal RRVAL2_D: STD_LOGIC_VECTOR(63 downto 0) := X"0000000000000000";

signal COUNTER: INTEGER := 0;
signal INNER_COUNTER: STD_LOGIC_VECTOR(4 downto 0) := "00000";

constant CLK_PERIOD : time := 10ns;

begin
    
    BANK: REG_BANK Port Map (
        CLK => CLK_D,
        RST => RST_D,
        STALL => STALL_D,
        WRITE => WRITE_D,
        RRID1 => RRID1_D, 
        RRID2 => RRID2_D, 
        WRID => WRID_D,   
        RWVAL => RWVAL_D,
        RRVAL1 => RRVAL1_D,
        RRVAL2 => RRVAL2_D
    );
    
    TEST_PROC_CLK: process
    begin
        CLK_D <= '0';
        wait for CLK_PERIOD / 2;
        CLK_D <= '1';
        wait for CLK_PERIOD / 2;
    end process;
    
    TEST_CLK_DRIVE: process(CLK_D)
    begin    
        if(rising_edge(CLK_D)) then  
            -- Test Write 
            if(COUNTER = 0) then
                RST_D <= '1';
                INNER_COUNTER <= (others => '0');
            elsif(COUNTER < 34) then
                RST_D <= '0';
                WRITE_D <= '1';
                
                WRID_D <= INNER_COUNTER;
                RWVAL_D(4 downto 0) <= INNER_COUNTER;
                
                INNER_COUNTER <= STD_LOGIC_VECTOR(UNSIGNED(INNER_COUNTER) + 1);
            -- Test Read
            elsif(COUNTER < 66) then
                RST_D <= '0';
                WRITE_D <= '0';
                
                RRID1_D <= INNER_COUNTER;
                RRID2_D <= STD_LOGIC_VECTOR(UNSIGNED(INNER_COUNTER) + 1);
                
                assert(RRVAL1_D(4 downto 0) = RRID1_D)
                report "ERROR: Wrong register value 0";   
                assert(RRVAL2_D(4 downto 0) = RRID2_D)
                report "ERROR: Wrong register value 1";  
                INNER_COUNTER <= STD_LOGIC_VECTOR(UNSIGNED(INNER_COUNTER) + 1);        
            -- Test Stall
            elsif(COUNTER < 98) then
                RST_D <= '0';
                WRITE_D <= '1';
                STALL_D <= '1';
                
                RWVAL_D <= X"FFFFFFFFFFFFFFFF";                
                
                WRID_D <= INNER_COUNTER;
                INNER_COUNTER <= STD_LOGIC_VECTOR(UNSIGNED(INNER_COUNTER) + 1);  
            elsif(COUNTER < 130) then
                RST_D <= '0';
                WRITE_D <= '0';
                STALL_D <= '0';
                
                RRID1_D <= INNER_COUNTER;
                RRID2_D <= STD_LOGIC_VECTOR(UNSIGNED(INNER_COUNTER) + 1);
                assert(RRVAL1_D(4 downto 0) = RRID1_D)
                report "ERROR: Wrong register value 2";   
                assert(RRVAL2_D(4 downto 0) = RRID2_D)
                report "ERROR: Wrong register value 3";   
                INNER_COUNTER <= STD_LOGIC_VECTOR(UNSIGNED(INNER_COUNTER) + 1);       
            
            -- Test Reset
            elsif(COUNTER < 131) then
                RST_D <= '1';
            elsif(COUNTER < 163) then
                WRITE_D <= '0';
                STALL_D <= '0';
                RST_D <= '0';
                
                RRID1_D <= INNER_COUNTER;
                RRID2_D <= STD_LOGIC_VECTOR(UNSIGNED(INNER_COUNTER) + 1);
                assert(RRVAL1_D = X"0000000000000000")
                report "ERROR: Wrong register value 4";  
                assert(RRVAL2_D = X"0000000000000000")
                report "ERROR: Wrong register value 5";  
                INNER_COUNTER <= STD_LOGIC_VECTOR(UNSIGNED(INNER_COUNTER) + 1); 
            else 
                report "Test finished" severity note;      
            end if;
            COUNTER <= COUNTER + 1;
        end if;
    end process;

end Behavioral;
