----------------------------------------------------------------------------------
-- Author: Alexy Torres Aurora Dugo
-- 
-- Create Date: 02.03.2019 13:12:54
-- Design Name: REG_BANK
-- Module Name: REG_BANK - REG_BANK_FLOW
-- Project Name: RISCV
-- Target Devices: Digilent NEXYS4
-- Tool Versions: Vivado 2018.2
-- Description: 64 bits registers bank.
--              IN: 1 bit, CLK the system clock.
--              IN: 1 bit, RST asynchronous reset.
--              IN: 1 bit, STALL asynchronous stall signal.
--              IN: 1 bit, WRITE set to 1 for write operation or 0 for read operation.
--              IN: 5 bits, RRID1 the index of the register 1 to access.
--              IN: 5 bits, RRID2 the index of the register 2 to access.
--              IN: 5 bits, WRID the index of the register to write to.
--              IN: 64 bits, RWVAL the value to write to the register, ignored when read operation.
--              OUT: 64 bits, RRVAL1 the value of the accessed register 1.
--              OUT: 64 bits, RRVAL2 the value of the accessed register 2.
--
-- Dependencies: REGISTER_64B.
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity REG_BANK is 
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
           
           
end REG_BANK;

architecture REG_BANK_FLOW of REG_BANK is

-- Components
component REGISTER_64B
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           EN :  in STD_LOGIC;
           D :   in STD_LOGIC_VECTOR (63 downto 0);
           Q :   out STD_LOGIC_VECTOR (63 downto 0));
end component;

-- Signals
signal WRITE_ID: STD_LOGIC_VECTOR(31 downto 0) := X"00000000";

signal READ_01: STD_LOGIC_VECTOR(63 downto 0);
signal READ_02: STD_LOGIC_VECTOR(63 downto 0);
signal READ_03: STD_LOGIC_VECTOR(63 downto 0);
signal READ_04: STD_LOGIC_VECTOR(63 downto 0);
signal READ_05: STD_LOGIC_VECTOR(63 downto 0);
signal READ_06: STD_LOGIC_VECTOR(63 downto 0);
signal READ_07: STD_LOGIC_VECTOR(63 downto 0);
signal READ_08: STD_LOGIC_VECTOR(63 downto 0);
signal READ_09: STD_LOGIC_VECTOR(63 downto 0);
signal READ_10: STD_LOGIC_VECTOR(63 downto 0);
signal READ_11: STD_LOGIC_VECTOR(63 downto 0);
signal READ_12: STD_LOGIC_VECTOR(63 downto 0);
signal READ_13: STD_LOGIC_VECTOR(63 downto 0);
signal READ_14: STD_LOGIC_VECTOR(63 downto 0);
signal READ_15: STD_LOGIC_VECTOR(63 downto 0);
signal READ_16: STD_LOGIC_VECTOR(63 downto 0);
signal READ_17: STD_LOGIC_VECTOR(63 downto 0);
signal READ_18: STD_LOGIC_VECTOR(63 downto 0);
signal READ_19: STD_LOGIC_VECTOR(63 downto 0);
signal READ_20: STD_LOGIC_VECTOR(63 downto 0);
signal READ_21: STD_LOGIC_VECTOR(63 downto 0);
signal READ_22: STD_LOGIC_VECTOR(63 downto 0);
signal READ_23: STD_LOGIC_VECTOR(63 downto 0);
signal READ_24: STD_LOGIC_VECTOR(63 downto 0);
signal READ_25: STD_LOGIC_VECTOR(63 downto 0);
signal READ_26: STD_LOGIC_VECTOR(63 downto 0);
signal READ_27: STD_LOGIC_VECTOR(63 downto 0);
signal READ_28: STD_LOGIC_VECTOR(63 downto 0);
signal READ_29: STD_LOGIC_VECTOR(63 downto 0);
signal READ_30: STD_LOGIC_VECTOR(63 downto 0);
signal READ_31: STD_LOGIC_VECTOR(63 downto 0);

-- Constants

begin
    
    -- Components mapping
    R01: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(1),
        D => RWVAL,
        Q => READ_01
    );
    R02: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(2),
        D => RWVAL,
        Q => READ_02
    );
    R03: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(3),
        D => RWVAL,
        Q => READ_03
    );
    R04: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(4),
        D => RWVAL,
        Q => READ_04
    );
    R05: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(5),
        D => RWVAL,
        Q => READ_05
    );
    R06: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(6),
        D => RWVAL,
        Q => READ_06
    );
    R07: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(7),
        D => RWVAL,
        Q => READ_07
    );
    R08: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(8),
        D => RWVAL,
        Q => READ_08
    );
    R09: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(9),
        D => RWVAL,
        Q => READ_09
    );
    R10: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(10),
        D => RWVAL,
        Q => READ_10
    );
    R11: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(11),
        D => RWVAL,
        Q => READ_11
    );
    R12: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(12),
        D => RWVAL,
        Q => READ_12
    );
    R13: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(13),
        D => RWVAL,
        Q => READ_13
    );
    R14: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(14),
        D => RWVAL,
        Q => READ_14
    );
    R15: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(15),
        D => RWVAL,
        Q => READ_15
    );
    R16: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(16),
        D => RWVAL,
        Q => READ_16
    );
    R17: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(17),
        D => RWVAL,
        Q => READ_17
    );
    R18: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(18),
        D => RWVAL,
        Q => READ_18
    );
    R19: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(19),
        D => RWVAL,
        Q => READ_19
    );
    R20: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(20),
        D => RWVAL,
        Q => READ_20
    );
    R21: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(21),
        D => RWVAL,
        Q => READ_21
    );
    R22: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(22),
        D => RWVAL,
        Q => READ_22
    );
    R23: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(23),
        D => RWVAL,
        Q => READ_23
    );
    R24: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(24),
        D => RWVAL,
        Q => READ_24
    );
    R25: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(25),
        D => RWVAL,
        Q => READ_25
    );
    R26: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(26),
        D => RWVAL,
        Q => READ_26
    );
    R27: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(27),
        D => RWVAL,
        Q => READ_27
    );
    R28: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(28),
        D => RWVAL,
        Q => READ_28
    );
    R29: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(29),
        D => RWVAL,
        Q => READ_29
    );
    R30: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(30),
        D => RWVAL,
        Q => READ_30
    );
    R31: REGISTER_64B Port Map (
        CLK => CLK,
        RST => RST,
        EN => WRITE_ID(31),
        D => RWVAL,
        Q => READ_31
    );
    
    -- Write selector
    WR_SEL: process(RST, WRID)
    begin
        if(RST = '1') then 
            WRITE_ID <= (others => '0');
        else
            WRITE_ID <= (others => '0');
            WRITE_ID(TO_INTEGER(UNSIGNED(WRID))) <= WRITE AND NOT STALL; 
        end if;
    end process WR_SEL;
    
    -- Read selector
    WITH RRID1 SELECT RRVAL1 <=
        READ_01 WHEN "00001",
        READ_02 WHEN "00010",
        READ_03 WHEN "00011",
        READ_04 WHEN "00100",
        READ_05 WHEN "00101",
        READ_06 WHEN "00110",
        READ_07 WHEN "00111",
        READ_08 WHEN "01000",
        READ_09 WHEN "01001",
        READ_10 WHEN "01010",
        READ_11 WHEN "01011",
        READ_12 WHEN "01100",
        READ_13 WHEN "01101",
        READ_14 WHEN "01110",
        READ_15 WHEN "01111",
        READ_16 WHEN "10000",
        READ_17 WHEN "10001",
        READ_18 WHEN "10010",
        READ_19 WHEN "10011",
        READ_20 WHEN "10100",
        READ_21 WHEN "10101",
        READ_22 WHEN "10110",
        READ_23 WHEN "10111",
        READ_24 WHEN "11000",
        READ_25 WHEN "11001",
        READ_26 WHEN "11010",
        READ_27 WHEN "11011",
        READ_28 WHEN "11100",
        READ_29 WHEN "11101",
        READ_30 WHEN "11110",
        READ_31 WHEN "11111",
        X"0000000000000000" WHEN OTHERS;
        
    WITH RRID2 SELECT RRVAL2 <=
        READ_01 WHEN "00001",
        READ_02 WHEN "00010",
        READ_03 WHEN "00011",
        READ_04 WHEN "00100",
        READ_05 WHEN "00101",
        READ_06 WHEN "00110",
        READ_07 WHEN "00111",
        READ_08 WHEN "01000",
        READ_09 WHEN "01001",
        READ_10 WHEN "01010",
        READ_11 WHEN "01011",
        READ_12 WHEN "01100",
        READ_13 WHEN "01101",
        READ_14 WHEN "01110",
        READ_15 WHEN "01111",
        READ_16 WHEN "10000",
        READ_17 WHEN "10001",
        READ_18 WHEN "10010",
        READ_19 WHEN "10011",
        READ_20 WHEN "10100",
        READ_21 WHEN "10101",
        READ_22 WHEN "10110",
        READ_23 WHEN "10111",
        READ_24 WHEN "11000",
        READ_25 WHEN "11001",
        READ_26 WHEN "11010",
        READ_27 WHEN "11011",
        READ_28 WHEN "11100",
        READ_29 WHEN "11101",
        READ_30 WHEN "11110",
        READ_31 WHEN "11111",
        X"0000000000000000" WHEN OTHERS;
end REG_BANK_FLOW;
