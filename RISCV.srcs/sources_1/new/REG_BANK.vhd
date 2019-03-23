----------------------------------------------------------------------------------
-- Author: Alexy Torres Aurora Dugo
-- 
-- Create Date: 02.03.2019 13:12:54
-- Design Name: REG_BANK
-- Module Name: REG_BANK - REG_BANK_BEHAVE
-- Project Name: RISCV
-- Target Devices: Digilent NEXYS4
-- Tool Versions: Vivado 2018.2
-- Description: 64 bits registers bank, allows two reads and one write in the same clock cycle.
--              IN: 1 bit, CLK the system clock.
--              IN: 1 bit, RST asynchronous reset.
--              IN: 1 bit, STALL asynchronous stall signal.
--              IN: 1 bit, WRITE set to 1 for write operation or 0 for read operation.
--              IN: 5 bits, RRID1 the index of the register 1 to access.
--              IN: 5 bits, RRID2 the index of the register 2 to access.
--              IN: 5 bits, WRID the index of the register to write to.
--              IN: 64 bits, WRVAL the value to write to the register, ignored on read operation.
--              OUT: 64 bits, RRVAL1 the value of the accessed register 1.
--              OUT: 64 bits, RRVAL2 the value of the accessed register 2.
--
-- Dependencies: NONE.
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY REG_BANK IS 
    PORT ( CLK :    IN STD_LOGIC;
           RST :    IN STD_LOGIC;
           STALL :  IN STD_LOGIC;
           WRITE:   IN STD_LOGIC;
           RRID1 :  IN STD_LOGIC_VECTOR(4 DOWNTO 0);  
           RRID2 :  IN STD_LOGIC_VECTOR(4 DOWNTO 0);  
           WRID :   IN STD_LOGIC_VECTOR(4 DOWNTO 0);  
           WRVAL :  IN STD_LOGIC_VECTOR(63 DOWNTO 0);
           RRVAL1 : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
           RRVAL2 : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
    );          
END REG_BANK;

ARCHITECTURE REG_BANK_BEHAVE OF REG_BANK IS

-- Constants
CONSTANT REG_MAX_ID : INTEGER := 31;
CONSTANT REG_WIDTH :  INTEGER := 64;

-- Types
TYPE INT_BANK IS ARRAY(REG_MAX_ID DOWNTO 0) OF STD_LOGIC_VECTOR(REG_WIDTH - 1 DOWNTO 0);

-- Signals
SIGNAL INTERNAL_BANK : INT_BANK;

-- Components
-- NONE.

BEGIN
    -- Write selector
    WR_SEL: PROCESS(CLK, RST)
    BEGIN
        IF(RST = '1') THEN
            FOR i IN 0 TO 31 LOOP
                INTERNAL_BANK(i) <= (OTHERS => '0');
            END LOOP;
        ELSIF(RISING_EDGE(CLK) AND STALL = '0' AND WRITE = '1') THEN
            INTERNAL_BANK(TO_INTEGER(UNSIGNED(WRID))) <= WRVAL;
        END IF;
    END PROCESS WR_SEL;
    
    -- Read selector
    RRVAL1 <= INTERNAL_BANK(TO_INTEGER(UNSIGNED(RRID1)));
    RRVAL2 <= INTERNAL_BANK(TO_INTEGER(UNSIGNED(RRID2)));
    
END REG_BANK_BEHAVE;
