----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.03.2019 12:57:00
-- Design Name: 
-- Module Name: TB_EXE_STAGE - Behavioral
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

entity TB_EXE_STAGE is
--  Port ( );
end TB_EXE_STAGE;

architecture Behavioral of TB_EXE_STAGE is

component EXE_STAGE is
    PORT ( OPERAND_0 :        IN STD_LOGIC_VECTOR(31 DOWNTO 0);    
           OPERAND_1 :        IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           OPERAND_OFF :      IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           
           PC_IN :            IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           
           ALU_OP :           IN STD_LOGIC_VECTOR(3 DOWNTO 0);
           BRANCH_OP :        IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
           OP_TYPE :          IN STD_LOGIC_VECTOR(3 DOWNTO 0);
           
           PC_OUT :           OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           RD_OUT :           OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            
           ADDR_OUT :         OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           
           B_TAKEN :          OUT STD_LOGIC;
           RD_WRITE :         OUT STD_LOGIC;
           
           SIG_INVALID :      OUT STD_LOGIC    
    );
end component;

constant CLK_PERIOD : time := 10ns;
signal counter : integer := 0;

CONSTANT OP_TYPE_ALU :    STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
CONSTANT OP_TYPE_LUI :    STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
CONSTANT OP_TYPE_BRANCH : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010";
CONSTANT OP_TYPE_LOAD :   STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100";
CONSTANT OP_TYPE_STORE :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101";


signal OPERAND_0_D :        STD_LOGIC_VECTOR(31 DOWNTO 0);    
signal OPERAND_1_D :        STD_LOGIC_VECTOR(31 DOWNTO 0);
signal OPERAND_OFF_D :      STD_LOGIC_VECTOR(31 DOWNTO 0);
           
signal PC_IN_D :            STD_LOGIC_VECTOR(31 DOWNTO 0);
       
signal ALU_OP_D :           STD_LOGIC_VECTOR(3 DOWNTO 0);
signal BRANCH_OP_D :        STD_LOGIC_VECTOR(3 DOWNTO 0); 
signal OP_TYPE_D :          STD_LOGIC_VECTOR(3 DOWNTO 0);
       
signal PC_OUT_D :           STD_LOGIC_VECTOR(31 DOWNTO 0);
signal RD_OUT_D :           STD_LOGIC_VECTOR(31 DOWNTO 0);
        
signal ADDR_OUT_D :         STD_LOGIC_VECTOR(31 DOWNTO 0);
       
signal B_TAKEN_D :          STD_LOGIC;
signal RD_WRITE_D :         STD_LOGIC;
       
signal SIG_INVALID_D :      STD_LOGIC;   

signal NOTIFY : STD_LOGIC := '0';

begin

    EXE_MAP: EXE_STAGE Port Map(
       OPERAND_0 => OPERAND_0_D,
       OPERAND_1 => OPERAND_1_D,
       OPERAND_OFF => OPERAND_OFF_D,
       
       PC_IN => PC_IN_D,
       
       ALU_OP => ALU_OP_D,
       BRANCH_OP => BRANCH_OP_D,
       OP_TYPE => OP_TYPE_D,
       
       PC_OUT => PC_OUT_D,
       RD_OUT => RD_OUT_D,
        
       ADDR_OUT => ADDR_OUT_D,
       
       B_TAKEN => B_TAKEN_D,
       RD_WRITE => RD_WRITE_D,
       
       SIG_INVALID => SIG_INVALID_D
    );

    process 
    begin
        if(counter < 1) then -- CHECK INVALID SIGNAL         
            for i in 0 to 15 loop
                OP_TYPE_D <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, OP_TYPE_D'length));
                WAIT FOR CLK_PERIOD / 16; 
                if(STD_LOGIC_VECTOR(TO_UNSIGNED(i, OP_TYPE_D'length)) = OP_TYPE_ALU or STD_LOGIC_VECTOR(TO_UNSIGNED(i, OP_TYPE_D'length)) = OP_TYPE_LUI or
                   STD_LOGIC_VECTOR(TO_UNSIGNED(i, OP_TYPE_D'length)) = OP_TYPE_BRANCH or STD_LOGIC_VECTOR(TO_UNSIGNED(i, OP_TYPE_D'length)) = OP_TYPE_LOAD or
                   STD_LOGIC_VECTOR(TO_UNSIGNED(i, OP_TYPE_D'length)) = OP_TYPE_STORE) then
                   assert(SIG_INVALID_D = '0')
                   report "ERROR: INVALID -> Wrong SIG_INVALID_VALUE 0.";
                else
                    assert(SIG_INVALID_D = '1')
                    report "ERROR: INVALID -> Wrong SIG_INVALID_VALUE 1.";
                end if;
            end loop;
        elsif(counter < 2) then -- CHECK RD VALUE      
            for i in 0 to 15 loop
                OP_TYPE_D <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, OP_TYPE_D'length));
                BRANCH_OP_D <= "1000"; 
                OPERAND_0_D <= X"F0F0F0F0";
                PC_IN_D <= X"22222220";
                ALU_OP_D <= "0000";
                OPERAND_1_D <= X"00000001";
                OPERAND_OFF_D <= X"00000004";
                BRANCH_OP_D <= "1000";
                WAIT FOR CLK_PERIOD / 16; 
                if(STD_LOGIC_VECTOR(TO_UNSIGNED(i, OP_TYPE_D'length)) = OP_TYPE_ALU) then
                    assert(RD_OUT_D = X"F0F0F0F1")
                    report "ERROR: RDCHECK -> Wrong RD_OUT_D 0.";
                elsif(STD_LOGIC_VECTOR(TO_UNSIGNED(i, OP_TYPE_D'length)) = OP_TYPE_LUI) then
                    assert(RD_OUT_D = OPERAND_0_D)
                    report "ERROR: RDCHECK -> Wrong RD_OUT_D 1.";
                elsif(STD_LOGIC_VECTOR(TO_UNSIGNED(i, OP_TYPE_D'length)) = OP_TYPE_BRANCH) then
                   assert(RD_OUT_D = X"22222224")
                   report "ERROR: RDCHECK -> Wrong RD_OUT_D 2.";
                elsif(STD_LOGIC_VECTOR(TO_UNSIGNED(i, OP_TYPE_D'length)) = OP_TYPE_STORE) then
                   assert(RD_OUT_D = X"00000001")
                   report "ERROR: RDCHECK -> Wrong RD_OUT_D 3.";
                else
                    assert(RD_OUT_D = X"00000000")
                    report "ERROR: RDCHECK -> Wrong RD_OUT_D 4.";
                end if;
                
            end loop;
        elsif(counter < 3) then -- CHECK RD WRITE      
            for i in 0 to 15 loop
                OP_TYPE_D <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, OP_TYPE_D'length));
                BRANCH_OP_D <= "1000"; 
                WAIT FOR CLK_PERIOD / 16; 
                if(STD_LOGIC_VECTOR(TO_UNSIGNED(i, OP_TYPE_D'length)) = OP_TYPE_ALU or STD_LOGIC_VECTOR(TO_UNSIGNED(i, OP_TYPE_D'length)) = OP_TYPE_LUI or
                   STD_LOGIC_VECTOR(TO_UNSIGNED(i, OP_TYPE_D'length)) = OP_TYPE_BRANCH or STD_LOGIC_VECTOR(TO_UNSIGNED(i, OP_TYPE_D'length)) = OP_TYPE_LOAD) then
                   assert(RD_WRITE_D = '1')
                   report "ERROR: RDCHECK -> Wrong RD_WRITE 0.";
                else
                    assert(RD_WRITE_D = '0')
                    report "ERROR: RDCHECK -> Wrong RD_WRITE 1.";
                end if;
                
            end loop;
        elsif(counter < 4) then -- CHECK Branch taken   
               
                BRANCH_OP_D <= "1001"; 
                OP_TYPE_D <= OP_TYPE_STORE;
                
                WAIT FOR CLK_PERIOD;
                assert(RD_WRITE_D = '0')
                report "ERROR: RDCHECK -> Wrong RD_WRITE 0.";
                
                assert(B_TAKEN_D = '0')
                report "ERROR: RDCHECK -> Wrong B_TAKEN 1.";
        elsif(NOTIFY = '0') then
            NOTIFY <= '1';
            report "INFO: Test finished" severity note;
            WAIT FOR CLK_PERIOD;
        else 
            WAIT FOR CLK_PERIOD;  
        end if;
        counter <= counter + 1;
    end process;

end Behavioral;
