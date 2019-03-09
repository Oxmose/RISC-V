----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.03.2019 13:44:28
-- Design Name: 
-- Module Name: TB_ID_STAGE - Behavioral
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

entity TB_ID_STAGE is
end TB_ID_STAGE;

architecture TB_ID_STAGE_BEHAVE of TB_ID_STAGE is

component ID_STAGE is
    Port (CLK :   in STD_LOGIC;
          RST :   in STD_LOGIC;
          STALL : in STD_LOGIC;
          INSTRUCTION_DATA : in STD_LOGIC_VECTOR (63 downto 0);   
          OPERAND_0:         out STD_LOGIC_VECTOR(63 downto 0);    
          OPERAND_1:         out STD_LOGIC_VECTOR(63 downto 0);
          RD :               out STD_LOGIC_VECTOR(4 downto 0);
          ALU_OP :           out STD_LOGIC_VECTOR(5 downto 0);
          SIG_INVALID :      out STD_LOGIC );
end component;

signal OP_DATA : STD_LOGIC_VECTOR(6 downto 0);
signal REG_DATA : STD_LOGIC_VECTOR(4 downto 0);

signal INSTRUCTION_DATA_D : STD_LOGIC_VECTOR(63 downto 0);
signal OPERAND_0_D : STD_LOGIC_VECTOR(63 downto 0);
signal OPERAND_1_D : STD_LOGIC_VECTOR(63 downto 0);
signal RD_D : STD_LOGIC_VECTOR(4 downto 0);
signal ALU_OP_D : STD_LOGIC_VECTOR(5 downto 0);
signal CLK_D : STD_LOGIC;
signal RST_D : STD_LOGIC;
signal STALL_D : STD_LOGIC;
signal SIG_INVALID_D : STD_LOGIC;

signal NOTIFY: STD_LOGIC;

signal COUNTER : integer := 0;

constant CLK_PERIOD : time := 10ns;

begin
    
     ID: ID_STAGE Port Map(
        CLK => CLK_D,
        RST => RST_D,
        STALL => STALL_D,
        INSTRUCTION_DATA => INSTRUCTION_DATA_D,
        OPERAND_0 => OPERAND_0_D,
        OPERAND_1 => OPERAND_1_D,
        RD => RD_D,
        ALU_OP => ALU_OP_D,
        SIG_INVALID => SIG_INVALID_D
      );
      
    CLK_PROC: process
    begin
        CLK_D <= '0';
        WAIT FOR CLK_PERIOD;
        CLK_D <= '1';
        WAIT FOR CLK_PERIOD;
    end process;
    
    TEST_CLK_DRIVE: process
    begin            
        -- Init
        if(COUNTER < 1) then
            RST_D <= '1';
            STALL_D <= '0';
            INSTRUCTION_DATA_D <= (others => '1');
            REG_DATA <= (others => '1');
            NOTIFY <= '0';
            wait for CLK_PERIOD;
        -- Test invalid 
        elsif(COUNTER < 2) then
            OP_DATA <= STD_LOGIC_VECTOR(UNSIGNED(OP_DATA) + 1);
            wait for CLK_PERIOD / 256;
            
            for j in 0 to 128 loop 
                OP_DATA <= STD_LOGIC_VECTOR(TO_UNSIGNED(j, OP_DATA'length));
                
                wait for CLK_PERIOD / 256;
                
                INSTRUCTION_DATA_D <= (others => '0');
                INSTRUCTION_DATA_D(6 downto 0) <= OP_DATA;
                
                wait for CLK_PERIOD / 256;
                
                if(OP_DATA(1 downto 0) /= "11") then
                    assert(SIG_INVALID_D = '1')
                    report "ERROR: SIG_INVALID not detected.";
                elsif(OP_DATA(6 downto 2) = "00000" OR
                      OP_DATA(6 downto 2) = "00001" OR
                      OP_DATA(6 downto 2) = "00011" OR
                      OP_DATA(6 downto 2) = "00100" OR
                      OP_DATA(6 downto 2) = "00101" OR
                      OP_DATA(6 downto 2) = "00110" OR
                      
                      OP_DATA(6 downto 2) = "01000" OR
                      OP_DATA(6 downto 2) = "01001" OR
                      OP_DATA(6 downto 2) = "01011" OR
                      OP_DATA(6 downto 2) = "01100" OR
                      OP_DATA(6 downto 2) = "01101" OR
                      OP_DATA(6 downto 2) = "01110" OR
                      
                      OP_DATA(6 downto 2) = "10000" OR
                      OP_DATA(6 downto 2) = "10001" OR
                      OP_DATA(6 downto 2) = "10010" OR
                      OP_DATA(6 downto 2) = "10011" OR
                      OP_DATA(6 downto 2) = "10100" OR
                      
                      OP_DATA(6 downto 2) = "11000" OR
                      OP_DATA(6 downto 2) = "11001" OR
                      OP_DATA(6 downto 2) = "11000" OR
                      OP_DATA(6 downto 2) = "11011" OR
                      OP_DATA(6 downto 2) = "11100") then
                    assert(SIG_INVALID_D = '0')
                    report "ERROR: SIG_INVALID detected.";
                      
                else 
                    assert(SIG_INVALID_D = '1')
                    report "ERROR: SIG_INVALID not detected.";
                end if;              
            end loop; 
        -- Test RD
        elsif(COUNTER < 3) then
            INSTRUCTION_DATA_D <= (others => '1');
            for i in 0 to 31 loop
                REG_DATA <= STD_LOGIC_VECTOR(UNSIGNED(REG_DATA) + 1);
                wait for CLK_PERIOD / 64;
                INSTRUCTION_DATA_D(11 downto 7) <= REG_DATA;                
                wait for CLK_PERIOD / 64;
                
                assert(RD_D = REG_DATA)
                report "ERROR: Wrong RD Value.";                
            end loop;
        else 
            if(NOTIFY = '0') then
                NOTIFY <= '1';
                report "End of test." severity note;
            end if;
            wait for CLK_PERIOD;
        end if;
        COUNTER <= COUNTER + 1;
    end process;

end TB_ID_STAGE_BEHAVE;
