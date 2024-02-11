----------------------------------------------------------------------------------
-- Author: Alexy Torres Aurora Dugo
-- 
-- Create Date: 27.04.2019 14:58:38
-- Design Name: CSR_MODULE
-- Module Name: CSR_MODULE - CSR_MODULE_BEHAVE
-- Project Name: RISCV
-- Target Devices: Digilent NEXYS4
-- Tool Versions: Vivado 2018.2
-- Description: CSR Register module. Handles the CSR value and read/write
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

ENTITY CSR_MODULE IS
    PORT ( CLK :          IN STD_LOGIC;
           RST :          IN STD_LOGIC;
           INST_RET_ADD : IN STD_LOGIC;
           CSRREQ :       IN STD_LOGIC;
           CSRW :         IN STD_LOGIC;
           CSRID :        IN STD_LOGIC_VECTOR (15 downto 0); 
           VALIN :        IN STD_LOGIC_VECTOR (64 downto 0);                     
           VALOUT :       OUT STD_LOGIC_VECTOR (64 downto 0);
           SIG_INVALID :  OUT STD_LOGIC
    );
END CSR_MODULE;

ARCHITECTURE CSR_MODULE_BEHAVE OF CSR_MODULE IS

-- Constants
CONSTANT REG_WIDTH : INTEGER := 64;

CONSTANT CYCLECSRID :   STD_LOGIC_VECTOR(14 DOWNTO 0) := X"0C00";
CONSTANT TIMECSRID :    STD_LOGIC_VECTOR(14 DOWNTO 0) := X"0C01";
CONSTANT INSTRETCSRID : STD_LOGIC_VECTOR(14 DOWNTO 0) := X"0C02";
-- Types
-- NONE.

-- Signals
SIGNAL CYCLE_CSR :   STD_LOGIC_VECTOR(REG_WIDTH - 1 DOWNTO 0) := (others => '0');
SIGNAL TIME_CSR :    STD_LOGIC_VECTOR(REG_WIDTH - 1 DOWNTO 0) := (others => '0');
SIGNAL INSTRET_CSR : STD_LOGIC_VECTOR(REG_WIDTH - 1 DOWNTO 0) := (others => '0');

-- Components
-- NONE.

BEGIN

    REG_UPDATE : PROCESS(RST, CLK, CSRREQ, CSRID, CSRW)
    BEGIN
        IF(RISING_EDGE(CLK)) THEN -- User's Request
            -- On RST, reset CSRs
            IF(RST = '1') THEN
                CYCLE_CSR <= (OTHERS => '0');
            -- On rising edge proceed to execution of request
            ELSIF(CSRREQ = '1') THEN
                IF(CSRID = CYCLECSRID) THEN
                    IF(CSRW /= '0') THEN
                        SIG_INVALID <= '1';
                    END IF;  
                    VALOUT <= CYCLE_CSR;  
                ELSE
                    SIG_INVALID <= '1'; 
                END IF; 
            -- Update in rising edge           
            ELSE 
                CYCLE_CSR <= STD_LOGIC_VECTOR(UNSIGNED(CYCLE_CSR) + 1);
                TIME_CSR  <= CYCLE_CSR;
                IF(INST_RET_ADD = '1') THEN
                    INSTRET_CSR <= STD_LOGIC_VECTOR(UNSIGNED(INSTRET_CSR) + 1);
                END IF;
            END IF;
        END IF;
    END PROCESS REG_UPDATE;

END CSR_MODULE_BEHAVE;
