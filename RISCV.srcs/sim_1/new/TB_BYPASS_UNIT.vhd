----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 31.03.2019 14:45:58
-- Design Name: 
-- Module Name: TB_BYPASS_UNIT - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TB_BYPASS_UNIT is
--  Port ( );
end TB_BYPASS_UNIT;

architecture Behavioral of TB_BYPASS_UNIT is

COMPONENT BYPASS_UNIT IS
    PORT ( RVAL1 :    IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           RVAL2 :    IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           EXRDVAL :  IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           MEMRDVAL : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           WBRDVAL :  IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           RID1 :     IN STD_LOGIC_VECTOR(4 DOWNTO 0);
           RID2 :     IN STD_LOGIC_VECTOR(4 DOWNTO 0);
           EXRDID :   IN STD_LOGIC_VECTOR(4 DOWNTO 0);
           MEMRDID :  IN STD_LOGIC_VECTOR(4 DOWNTO 0);
           WBRDID :   IN STD_LOGIC_VECTOR(4 DOWNTO 0);
           EXRDWR :   IN STD_LOGIC;
           MEMRDWR :  IN STD_LOGIC;
           WBRDWR :   IN STD_LOGIC;
           RVAL1OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);       
           RVAL2OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)       
    );
END COMPONENT;

SIGNAL RVAL1_D :    STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL RVAL2_D :    STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL EXRDVAL_D :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL MEMRDVAL_D : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL WBRDVAL_D :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL RID1_D :     STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL RID2_D :     STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL EXRDID_D :   STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL MEMRDID_D :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL WBRDID_D :   STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL RVAL1OUT_D : STD_LOGIC_VECTOR(31 DOWNTO 0);       
SIGNAL RVAL2OUT_D : STD_LOGIC_VECTOR(31 DOWNTO 0); 
SIGNAL EXRDWR_D :   STD_LOGIC;
SIGNAL MEMRDWR_D :  STD_LOGIC;
SIGNAL WBRDWR_D :   STD_LOGIC;

signal notified : STD_LOGIC_VECTOR(1 downto 0) := "00";

begin

U0 : BYPASS_UNIT PORT MAP(
    RVAL1 => RVAL1_D,
    RVAL2 => RVAL2_D,
    EXRDVAL => EXRDVAL_D,
    MEMRDVAL => MEMRDVAL_D,
    WBRDVAL => WBRDVAL_D,
    RID1 => RID1_D,
    RID2 => RID2_D,
    EXRDID => EXRDID_D,
    MEMRDID => MEMRDID_D,
    WBRDID => WBRDID_D,
    EXRDWR => EXRDWR_D,
    MEMRDWR => MEMRDWR_D,
    WBRDWR => WBRDWR_D,
    RVAL1OUT => RVAL1OUT_D,
    RVAL2OUT => RVAL2OUT_D
);


process
begin
    RVAL1_D <= X"00010000";
    RVAL2_D <= X"00000001";
    EXRDVAL_D <= X"00000010";
    MEMRDVAL_D <= X"00000100";
    WBRDVAL_D <= X"00001000";
    WBRDWR_D <= '1';
    MEMRDWR_D <= '1';
    EXRDWR_D <= '1';
    if(notified = "00") then
        for i in 0 to 31 loop
            EXRDID_D <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, EXRDID_D'length));
            for j in 0 to 31 loop
                MEMRDID_D <= STD_LOGIC_VECTOR(TO_UNSIGNED(j, MEMRDID_D'length));
                for k in 0 to 31 loop
                    WBRDID_D <= STD_LOGIC_VECTOR(TO_UNSIGNED(k, WBRDID_D'length));
                    for l in 0 to 31 loop
                        RID1_D <= STD_LOGIC_VECTOR(TO_UNSIGNED(l, RID1_D'length));
                        RID2_D <= STD_LOGIC_VECTOR(TO_UNSIGNED(l, RID2_D'length));
                        wait for 1ps;
                        if(RID1_D = "00000") then
                            assert(RVAL1OUT_D = RVAL1_D)
                            report "ERROR RID1 != NOP value" severity error;
                        elsif(RID1_D = EXRDID_D) then
                            assert(RVAL1OUT_D = EXRDVAL_D)
                            report "ERROR RID1 != EXRID value" severity error;
                        elsif(RID1_D = MEMRDID_D) then
                            assert(RVAL1OUT_D = MEMRDVAL_D)
                            report "ERROR RID1 != MEMID value" severity error;
                        elsif(RID1_D = WBRDID_D) then
                            assert(RVAL1OUT_D = WBRDVAL_D)
                            report "ERROR RID1 != WBID value" severity error;
                        else
                            assert(RVAL1OUT_D = RVAL1_D)
                            report "ERROR RID1 != NOP value" severity error;
                        end if;
                        
                        if(RID2_D = "00000") then
                            assert(RVAL2OUT_D = RVAL2_D)
                            report "ERROR RID2 != NOP value" severity error;
                        elsif(RID2_D = EXRDID_D) then
                            assert(RVAL2OUT_D = EXRDVAL_D)
                            report "ERROR RID2 != EXRID value" severity error;
                        elsif(RID2_D = MEMRDID_D) then
                            assert(RVAL2OUT_D = MEMRDVAL_D)
                            report "ERROR RID2 != MEMID value" severity error;
                        elsif(RID2_D = WBRDID_D) then
                            assert(RVAL2OUT_D = WBRDVAL_D)
                            report "ERROR RID2 != WBID value" severity error;
                        else
                            assert(RVAL2OUT_D = RVAL2_D)
                            report "ERROR RID2 != NOP value" severity error;
                        end if;
                    end loop;
                end loop;
            end loop;
        end loop;
        
        WBRDWR_D <= '0';
        MEMRDWR_D <= '0';
        EXRDWR_D <= '0';
            
        for i in 0 to 31 loop
            EXRDID_D <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, EXRDID_D'length));
            for j in 0 to 31 loop
                MEMRDID_D <= STD_LOGIC_VECTOR(TO_UNSIGNED(j, MEMRDID_D'length));
                for k in 0 to 31 loop
                    WBRDID_D <= STD_LOGIC_VECTOR(TO_UNSIGNED(k, WBRDID_D'length));
                    for l in 0 to 31 loop
                        RID1_D <= STD_LOGIC_VECTOR(TO_UNSIGNED(l, RID1_D'length));
                        RID2_D <= STD_LOGIC_VECTOR(TO_UNSIGNED(l, RID2_D'length));
                        wait for 1ps;
                        if(RID1_D = "00000") then
                            assert(RVAL1OUT_D = RVAL1_D)
                            report "ERROR RID1 != NOP value" severity error;
                        elsif(RID1_D = EXRDID_D) then
                            assert(RVAL1OUT_D = RVAL1_D)
                            report "ERROR RID1 != EXRID value" severity error;
                        elsif(RID1_D = MEMRDID_D) then
                            assert(RVAL1OUT_D = RVAL1_D)
                            report "ERROR RID1 != MEMID value" severity error;
                        elsif(RID1_D = WBRDID_D) then
                            assert(RVAL1OUT_D = RVAL1_D)
                            report "ERROR RID1 != WBID value" severity error;
                        else
                            assert(RVAL1OUT_D = RVAL1_D)
                            report "ERROR RID1 != NOP value" severity error;
                        end if;
                        
                        if(RID2_D = "00000") then
                            assert(RVAL2OUT_D = RVAL2_D)
                            report "ERROR RID2 != NOP value" severity error;
                        elsif(RID2_D = EXRDID_D) then
                            assert(RVAL2OUT_D = RVAL2_D)
                            report "ERROR RID2 != EXRID value" severity error;
                        elsif(RID2_D = MEMRDID_D) then
                            assert(RVAL2OUT_D = RVAL2_D)
                            report "ERROR RID2 != MEMID value" severity error;
                        elsif(RID2_D = WBRDID_D) then
                            assert(RVAL2OUT_D = RVAL2_D)
                            report "ERROR RID2 != WBID value" severity error;
                        else
                            assert(RVAL2OUT_D = RVAL2_D)
                            report "ERROR RID2 != NOP value" severity error;
                        end if;
                    end loop;
                end loop;
            end loop;
        end loop;
                
        notified <= "01";
    elsif(notified = "01") then
        report "End of tests" severity note;
        notified <= "10";
    end if;
    wait for 10ns;
end process;

end Behavioral;
