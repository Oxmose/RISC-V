----------------------------------------------------------------------------------
-- Author: Alexy Torres Aurora Dugo
--
-- Create Date: 31.03.2019 13:58:16
-- Design Name: BYPASS_UNIT
-- Module Name: BYPASS_UNIT - BYPASS_UNIT_BEHAVE
-- Project Name: RISCV
-- Target Devices: Digilent NEXYS4
-- Tool Versions: Vivado 2018.2
-- Description: Bypass unit module, used to forward RD value in the pipeline
--              IN: 32 bits, RVAL1 the value of RS1
--              IN: 32 bits, RVAL2 the value of RS2
--              IN: 32 bits, EXRDVAL the value of RD in EXE stage
--              IN: 32 bits, MEMRDVAL the value of RD in MEM stage
--              IN: 32 bits, WBRDVAL the value of RD in WB stage
--              IN: 5 bits, RVAL1 the id of RS1
--              IN: 5 bits, RID2 the id of RS2
--              IN: 5 bits, EXRDID the id of RD in EXE stage
--              IN: 5 bits, MEMRDID the id of RD in MEM stage
--              IN: 5 bits, WBRDID the id of RD in WB stage
--              OUT: 32 bits, RVAL1OUT the actual value of RS1
--              OUT: 32 bits, RVAL2OUT the actual value of RS2
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

ENTITY BYPASS_UNIT IS
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
END BYPASS_UNIT;

ARCHITECTURE BYPASS_UNIT_BEHAVE OF BYPASS_UNIT IS

BEGIN

    RS1_BYPASS : PROCESS(RVAL1, EXRDVAL, MEMRDVAL, WBRDVAL, 
                         RID1, EXRDID, MEMRDID, WBRDID)
    BEGIN   
        IF(RID1 /= "00000" AND EXRDWR = '1' AND RID1 = EXRDID) THEN -- Priority is gave to EXE
            RVAL1OUT <= EXRDVAL;
        ELSIF(RID1 /= "00000" AND MEMRDWR = '1' AND RID1 = MEMRDID) THEN -- Priority then treat MEM
            RVAL1OUT <= MEMRDVAL;
        ELSIF(RID1 /= "00000" AND WBRDWR = '1' AND  RID1 = WBRDID) THEN -- Priority then treat WB
            RVAL1OUT <= WBRDVAL;
        ELSE
            RVAL1OUT <= RVAL1;
        END IF;
    END PROCESS RS1_BYPASS;

    RS2_BYPASS : PROCESS(RVAL2, EXRDVAL, MEMRDVAL, WBRDVAL, 
                         RID2, EXRDID, MEMRDID, WBRDID)
    BEGIN 
        IF(RID2 /= "00000" AND EXRDWR = '1' AND RID2 = EXRDID) THEN -- Priority is gave to EXE
            RVAL2OUT <= EXRDVAL;
        ELSIF(RID2 /= "00000" AND MEMRDWR = '1' AND RID2 = MEMRDID) THEN -- Priority then treat MEM
            RVAL2OUT <= MEMRDVAL;
        ELSIF(RID2 /= "00000" AND WBRDWR = '1' AND RID2 = WBRDID) THEN -- Priority then treat WB
            RVAL2OUT <= WBRDVAL;
        ELSE
            RVAL2OUT <= RVAL2;
        END IF;        
    END PROCESS RS2_BYPASS;
END BYPASS_UNIT_BEHAVE;
