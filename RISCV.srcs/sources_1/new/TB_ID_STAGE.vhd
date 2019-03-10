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
    Port (INSTRUCTION_DATA : in STD_LOGIC_VECTOR (63 downto 0); 
             
           REG_RVAL1 :        in STD_LOGIC_VECTOR(63 downto 0);
           REG_RVAL2 :        in STD_LOGIC_VECTOR(63 downto 0);
           
           OPERAND_0:         out STD_LOGIC_VECTOR(63 downto 0);    
           OPERAND_1:         out STD_LOGIC_VECTOR(63 downto 0);
           RD :               out STD_LOGIC_VECTOR(4 downto 0);
           ALU_OP :           out STD_LOGIC_VECTOR(5 downto 0);
           OP_TYPE :          out STD_LOGIC_VECTOR(5 downto 0);
           
           REG_RID1 :         out STD_LOGIC_VECTOR(4 downto 0);
           REG_RID2 :         out STD_LOGIC_VECTOR(4 downto 0);
           
           SIG_INVALID :      out STD_LOGIC);
end component;

signal OP_DATA : STD_LOGIC_VECTOR(6 downto 0);
signal REG_DATA : STD_LOGIC_VECTOR(4 downto 0);

signal INSTRUCTION_DATA_D : STD_LOGIC_VECTOR(63 downto 0);
signal OPERAND_0_D : STD_LOGIC_VECTOR(63 downto 0);
signal OPERAND_1_D : STD_LOGIC_VECTOR(63 downto 0);
signal RD_D : STD_LOGIC_VECTOR(4 downto 0);
signal ALU_OP_D : STD_LOGIC_VECTOR(5 downto 0);
signal OP_TYPE_D : STD_LOGIC_VECTOR(5 downto 0);

signal REG_VAL1_D : STD_LOGIC_VECTOR(63 downto 0);
signal REG_VAL2_D : STD_LOGIC_VECTOR(63 downto 0);


signal REG_RID1_D : STD_LOGIC_VECTOR(4 downto 0);
signal REG_RID2_D : STD_LOGIC_VECTOR(4 downto 0);

signal SIG_INVALID_D : STD_LOGIC;

signal NOTIFY: STD_LOGIC;

signal COUNTER : integer := 0;

constant CLK_PERIOD : time := 10ns;

begin
    
     ID: ID_STAGE Port Map(
        INSTRUCTION_DATA => INSTRUCTION_DATA_D,
        REG_RVAL1 => REG_VAL1_D,
        REG_RVAL2 => REG_VAL2_D,
         
        OPERAND_0 => OPERAND_0_D,
        OPERAND_1 => OPERAND_1_D,
        RD => RD_D,
        ALU_OP => ALU_OP_D,
        OP_TYPE => OP_TYPE_D,
        
        REG_RID1 => REG_RID1_D,
        REG_RID2 => REG_RID2_D,
                          
        SIG_INVALID => SIG_INVALID_D
      );
      
    
    TEST_CLK_DRIVE: process
    begin            
        -- Init
        if(COUNTER < 1) then
            INSTRUCTION_DATA_D <= (others => '1');
            REG_DATA <= (others => '1');
            NOTIFY <= '0';
            REG_VAL1_D <= x"0F0F0F0F0F0F0F0F";
            REG_VAL2_D <= x"0000000000000011";
                    
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
        -- Test OP-IMM Decode
        elsif(COUNTER < 4) then
            INSTRUCTION_DATA_D <= X"00000000" & "100000010101" & "00011" &  "000" & "00101" & "0010011"; 
                       
            -- ADDI 
            INSTRUCTION_DATA_D(14 downto 12) <= "000";
            wait for CLK_PERIOD / 9;
            assert(RD_D = "00101")
            report "ERROR: OP-IMM -> Wrong RD Value.";
                
            assert(REG_RID1_D = "00011")
            report "ERROR: OP-IMM -> Wrong RS1 Value.";
            
            assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
            report "ERROR: OP-IMM -> Wrong OP0 Value.";
            
            assert(OPERAND_1_D = X"FFFFFFFFFFFFF" & "100000010101")
            report "ERROR: OP-IMM -> Wrong OP1 Value.";
            
            assert(ALU_OP_D = "000000")
            report "ERROR: OP-IMM -> Wrong ALU_OP Value.";
            
            assert(OP_TYPE_D = "000000")
            report "ERROR: OP-IMM -> Wrong OP_TYPE Value.";
            
            -- SLTI 
            INSTRUCTION_DATA_D(14 downto 12) <= "010";
            wait for CLK_PERIOD / 9;
            assert(RD_D = "00101")
            report "ERROR: OP-IMM -> Wrong RD Value.";
                
            assert(REG_RID1_D = "00011")
            report "ERROR: OP-IMM -> Wrong RS1 Value.";
            
            assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
            report "ERROR: OP-IMM -> Wrong OP0 Value.";
            
            assert(OPERAND_1_D = X"FFFFFFFFFFFFF" & "100000010101")
            report "ERROR: OP-IMM -> Wrong OP1 Value.";
            
            assert(ALU_OP_D = "000010")
            report "ERROR: OP-IMM -> Wrong ALU_OP Value.";
            
            -- SLTUI
            INSTRUCTION_DATA_D(14 downto 12) <= "011";
            wait for CLK_PERIOD / 9;
            assert(RD_D = "00101")
            report "ERROR: OP-IMM -> Wrong RD Value.";
                
            assert(REG_RID1_D = "00011")
            report "ERROR: OP-IMM -> Wrong RS1 Value.";
            
            assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
            report "ERROR: OP-IMM -> Wrong OP0 Value.";
            
            assert(OPERAND_1_D = X"FFFFFFFFFFFFF" & "100000010101")
            report "ERROR: OP-IMM -> Wrong OP1 Value.";
            
            assert(ALU_OP_D = "000011")
            report "ERROR: OP-IMM -> Wrong ALU_OP Value.";
            
            -- ANDI 
            INSTRUCTION_DATA_D(14 downto 12) <= "111";
            wait for CLK_PERIOD / 9;
            assert(RD_D = "00101")
            report "ERROR: OP-IMM -> Wrong RD Value.";
                
            assert(REG_RID1_D = "00011")
            report "ERROR: OP-IMM -> Wrong RS1 Value.";
            
            assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
            report "ERROR: OP-IMM -> Wrong OP0 Value.";
            
            assert(OPERAND_1_D = X"FFFFFFFFFFFFF" & "100000010101")
            report "ERROR: OP-IMM -> Wrong OP1 Value.";
            
            assert(ALU_OP_D = "000111")
            report "ERROR: OP-IMM -> Wrong ALU_OP Value.";
            
            -- ORI 
            INSTRUCTION_DATA_D(14 downto 12) <= "110";
            wait for CLK_PERIOD / 9;
            assert(RD_D = "00101")
            report "ERROR: OP-IMM -> Wrong RD Value.";
                
            assert(REG_RID1_D = "00011")
            report "ERROR: OP-IMM -> Wrong RS1 Value.";
            
            assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
            report "ERROR: OP-IMM -> Wrong OP0 Value.";
            
            assert(OPERAND_1_D = X"FFFFFFFFFFFFF" & "100000010101")
            report "ERROR: OP-IMM -> Wrong OP1 Value.";
            
            assert(ALU_OP_D = "000110")
            report "ERROR: OP-IMM -> Wrong ALU_OP Value.";
            
            -- XORI 
            INSTRUCTION_DATA_D(14 downto 12) <= "100";
            wait for CLK_PERIOD / 9;
            assert(RD_D = "00101")
            report "ERROR: OP-IMM -> Wrong RD Value.";
                
            assert(REG_RID1_D = "00011")
            report "ERROR: OP-IMM -> Wrong RS1 Value.";
            
            assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
            report "ERROR: OP-IMM -> Wrong OP0 Value.";
            
            assert(OPERAND_1_D = X"FFFFFFFFFFFFF" & "100000010101")
            report "ERROR: OP-IMM -> Wrong OP1 Value.";
            
            assert(ALU_OP_D = "000100")
            report "ERROR: OP-IMM -> Wrong ALU_OP Value.";
            
            -- SLLI 
            INSTRUCTION_DATA_D(14 downto 12) <= "001";
            wait for CLK_PERIOD / 9;
            assert(RD_D = "00101")
            report "ERROR: OP-IMM -> Wrong RD Value.";
                
            assert(REG_RID1_D = "00011")
            report "ERROR: OP-IMM -> Wrong RS1 Value.";
            
            assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
            report "ERROR: OP-IMM -> Wrong OP0 Value.";
            
            assert(OPERAND_1_D = X"FFFFFFFFFFFFF" & "100000010101")
            report "ERROR: OP-IMM -> Wrong OP1 Value.";
            
            assert(ALU_OP_D = "000001")
            report "ERROR: OP-IMM -> Wrong ALU_OP Value.";
            
            -- SRLI 
            INSTRUCTION_DATA_D(14 downto 12) <= "101";
            wait for CLK_PERIOD / 9;
            assert(RD_D = "00101")
            report "ERROR: OP-IMM -> Wrong RD Value.";
                
            assert(REG_RID1_D = "00011")
            report "ERROR: OP-IMM -> Wrong RS1 Value.";
            
            assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
            report "ERROR: OP-IMM -> Wrong OP0 Value.";
            
            assert(OPERAND_1_D = X"FFFFFFFFFFFFF" & "100000010101")
            report "ERROR: OP-IMM -> Wrong OP1 Value.";
            
            assert(ALU_OP_D = "000101")
            report "ERROR: OP-IMM -> Wrong ALU_OP Value.";
            
            -- SRAI
            INSTRUCTION_DATA_D(14 downto 12) <= "101";
            INSTRUCTION_DATA_D(30) <= '1';
            wait for CLK_PERIOD / 9;
            assert(RD_D = "00101")
            report "ERROR: OP-IMM -> Wrong RD Value.";
                
            assert(REG_RID1_D = "00011")
            report "ERROR: OP-IMM -> Wrong RS1 Value.";
            
            assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
            report "ERROR: OP-IMM -> Wrong OP0 Value.";
            
            assert(OPERAND_1_D = X"FFFFFFFFFFFFF" & "110000010101")
            report "ERROR: OP-IMM -> Wrong OP1 Value.";
            
            assert(ALU_OP_D = "001000")
            report "ERROR: OP-IMM -> Wrong ALU_OP Value.";
            
         -- Test LUI Decode
         elsif(COUNTER < 5) then
             INSTRUCTION_DATA_D <= X"0000000000001" & "10111" & "0110111"; 
            
           wait for CLK_PERIOD;
           assert(RD_D = "10111")
           report "ERROR: LUI -> Wrong RD Value.";
           
           assert(OPERAND_0_D = X"0000000000001000")
           report "ERROR: LUI -> Wrong OP0 Value.";
           
           assert(OP_TYPE_D = "000001")
           report "ERROR: LUI -> Wrong OP_TYPE Value.";
           
        -- Test AUIPC Decode
        elsif(COUNTER < 6) then
            INSTRUCTION_DATA_D <= X"0000000000101" & "10101" & "0010111"; 
           
          wait for CLK_PERIOD;
          assert(RD_D = "10101")
          report "ERROR: AUIPCI -> Wrong RD Value.";
          
          assert(OPERAND_0_D = X"0000000000101000")
          report "ERROR: AUIPC -> Wrong OP0 Value.";
          
          assert(OP_TYPE_D = "000010")
          report "ERROR: AUIPC -> Wrong OP_TYPE Value.";
          
          
          -- Test OP Decode
          elsif(COUNTER < 7) then
              INSTRUCTION_DATA_D <= X"00000000" & "0000000" & "10101" & "00011" &  "000" & "00101" & "0110011"; 
                         
              -- ADD
              INSTRUCTION_DATA_D(14 downto 12) <= "000";
              wait for CLK_PERIOD / 10;
              assert(RD_D = "00101")
              report "ERROR: OP -> Wrong RD Value.";
                  
              assert(REG_RID1_D = "00011")
              report "ERROR: OP -> Wrong RS1 Value.";
              
              assert(REG_RID2_D = "10101")
              report "ERROR: OP -> Wrong RS2 Value.";
              
              assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
              report "ERROR: OP -> Wrong OP0 Value.";
              
              assert(OPERAND_1_D = X"0000000000000011")
              report "ERROR: OP -> Wrong OP1 Value.";
              
              assert(ALU_OP_D = "000000")
              report "ERROR: OP -> Wrong ALU_OP Value.";
              
              assert(OP_TYPE_D = "000000")
              report "ERROR: OP -> Wrong OP_TYPE Value.";
              
              
              -- SUB
              INSTRUCTION_DATA_D(14 downto 12) <= "000";
              INSTRUCTION_DATA_D(30) <= '1';
              wait for CLK_PERIOD / 10;
              assert(RD_D = "00101")
              report "ERROR: OP -> Wrong RD Value.";
                
              assert(REG_RID1_D = "00011")
              report "ERROR: OP -> Wrong RS1 Value.";
              
              assert(REG_RID2_D = "10101")
              report "ERROR: OP -> Wrong RS2 Value.";
            
              assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
              report "ERROR: OP -> Wrong OP0 Value.";
            
              assert(OPERAND_1_D = X"0000000000000011")
              report "ERROR: OP -> Wrong OP1 Value.";
            
              assert(ALU_OP_D = "001001")
              report "ERROR: OP -> Wrong ALU_OP Value.";
            
              assert(OP_TYPE_D = "000000")
              report "ERROR: OP -> Wrong OP_TYPE Value.";
              
              -- SLT
              INSTRUCTION_DATA_D(14 downto 12) <= "010";
              INSTRUCTION_DATA_D(30) <= '0';
              wait for CLK_PERIOD / 10;
              assert(RD_D = "00101")
              report "ERROR: OP -> Wrong RD Value.";
                  
              assert(REG_RID1_D = "00011")
              report "ERROR: OP -> Wrong RS1 Value.";
              
              assert(REG_RID2_D = "10101")
              report "ERROR: OP -> Wrong RS2 Value.";
             
              assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
              report "ERROR: OP -> Wrong OP0 Value.";
             
              assert(OPERAND_1_D = X"0000000000000011")
              report "ERROR: OP -> Wrong OP1 Value.";
             
              assert(ALU_OP_D = "000010")
              report "ERROR: OP -> Wrong ALU_OP Value.";
             
              assert(OP_TYPE_D = "000000")
              report "ERROR: OP -> Wrong OP_TYPE Value.";
  
              -- SLTU
              INSTRUCTION_DATA_D(14 downto 12) <= "011";
              wait for CLK_PERIOD / 10;
              assert(RD_D = "00101")
              report "ERROR: OP -> Wrong RD Value.";
                  
              assert(REG_RID1_D = "00011")
              report "ERROR: OP -> Wrong RS1 Value.";
                
              assert(REG_RID2_D = "10101")
              report "ERROR: OP -> Wrong RS2 Value.";
               
              assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
              report "ERROR: OP -> Wrong OP0 Value.";
               
              assert(OPERAND_1_D = X"0000000000000011")
              report "ERROR: OP -> Wrong OP1 Value.";
               
              assert(ALU_OP_D = "000011")
              report "ERROR: OP -> Wrong ALU_OP Value.";
               
              assert(OP_TYPE_D = "000000")
              report "ERROR: OP -> Wrong OP_TYPE Value.";
              
              -- AND
              INSTRUCTION_DATA_D(14 downto 12) <= "111";
              wait for CLK_PERIOD / 10;
              assert(RD_D = "00101")
              report "ERROR: OP -> Wrong RD Value.";
                  
              assert(REG_RID1_D = "00011")
                report "ERROR: OP -> Wrong RS1 Value.";
                
                assert(REG_RID2_D = "10101")
                report "ERROR: OP -> Wrong RS2 Value.";
               
                assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
                report "ERROR: OP -> Wrong OP0 Value.";
               
                assert(OPERAND_1_D = X"0000000000000011")
                report "ERROR: OP -> Wrong OP1 Value.";
               
                assert(ALU_OP_D = "000111")
                report "ERROR: OP -> Wrong ALU_OP Value.";
               
                assert(OP_TYPE_D = "000000")
                report "ERROR: OP -> Wrong OP_TYPE Value.";
              
              -- OR
              INSTRUCTION_DATA_D(14 downto 12) <= "110";
              wait for CLK_PERIOD / 10;
              assert(RD_D = "00101")
              report "ERROR: OP -> Wrong RD Value.";
                  
              assert(REG_RID1_D = "00011")
                report "ERROR: OP -> Wrong RS1 Value.";
                
                assert(REG_RID2_D = "10101")
                report "ERROR: OP -> Wrong RS2 Value.";
               
                assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
                report "ERROR: OP -> Wrong OP0 Value.";
               
                assert(OPERAND_1_D = X"0000000000000011")
                report "ERROR: OP -> Wrong OP1 Value.";
               
                assert(ALU_OP_D = "000110")
                report "ERROR: OP -> Wrong ALU_OP Value.";
               
                assert(OP_TYPE_D = "000000")
                report "ERROR: OP -> Wrong OP_TYPE Value.";
              
              -- XOR
              INSTRUCTION_DATA_D(14 downto 12) <= "100";
              wait for CLK_PERIOD / 10;
              assert(RD_D = "00101")
              report "ERROR: OP -> Wrong RD Value.";
                  
              assert(REG_RID1_D = "00011")
                report "ERROR: OP -> Wrong RS1 Value.";
                
                assert(REG_RID2_D = "10101")
                report "ERROR: OP -> Wrong RS2 Value.";
               
                assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
                report "ERROR: OP -> Wrong OP0 Value.";
               
                assert(OPERAND_1_D = X"0000000000000011")
                report "ERROR: OP -> Wrong OP1 Value.";
               
                assert(ALU_OP_D = "000100")
                report "ERROR: OP -> Wrong ALU_OP Value.";
               
                assert(OP_TYPE_D = "000000")
                report "ERROR: OP -> Wrong OP_TYPE Value.";
              
              -- SLLI 
              INSTRUCTION_DATA_D(14 downto 12) <= "001";
              wait for CLK_PERIOD / 10;
              assert(RD_D = "00101")
              report "ERROR: OP -> Wrong RD Value.";
                  
              assert(REG_RID1_D = "00011")
                report "ERROR: OP -> Wrong RS1 Value.";
                
                assert(REG_RID2_D = "10101")
                report "ERROR: OP -> Wrong RS2 Value.";
               
                assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
                report "ERROR: OP -> Wrong OP0 Value.";
               
                assert(OPERAND_1_D = X"0000000000000011")
                report "ERROR: OP -> Wrong OP1 Value.";
               
                assert(ALU_OP_D = "000001")
                report "ERROR: OP -> Wrong ALU_OP Value.";
               
                assert(OP_TYPE_D = "000000")
                report "ERROR: OP -> Wrong OP_TYPE Value.";
              
              -- SRL
              INSTRUCTION_DATA_D(14 downto 12) <= "101";
              wait for CLK_PERIOD / 10;
              assert(RD_D = "00101")
              report "ERROR: OP -> Wrong RD Value.";
                  
              assert(REG_RID1_D = "00011")
                report "ERROR: OP -> Wrong RS1 Value.";
                
                assert(REG_RID2_D = "10101")
                report "ERROR: OP -> Wrong RS2 Value.";
               
                assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
                report "ERROR: OP -> Wrong OP0 Value.";
               
                assert(OPERAND_1_D = X"0000000000000011")
                report "ERROR: OP -> Wrong OP1 Value.";
               
                assert(ALU_OP_D = "000101")
                report "ERROR: OP -> Wrong ALU_OP Value.";
               
                assert(OP_TYPE_D = "000000")
                report "ERROR: OP -> Wrong OP_TYPE Value.";
              
              -- SRAI
              INSTRUCTION_DATA_D(14 downto 12) <= "101";
              INSTRUCTION_DATA_D(30) <= '1';
              wait for CLK_PERIOD / 10;
              assert(RD_D = "00101")
              report "ERROR: OP -> Wrong RD Value.";
                  
              assert(REG_RID1_D = "00011")
                report "ERROR: OP -> Wrong RS1 Value.";
                
                assert(REG_RID2_D = "10101")
                report "ERROR: OP -> Wrong RS2 Value.";
               
                assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
                report "ERROR: OP -> Wrong OP0 Value.";
               
                assert(OPERAND_1_D = X"0000000000000011")
                report "ERROR: OP -> Wrong OP1 Value.";
               
                assert(ALU_OP_D = "001000")
                report "ERROR: OP -> Wrong ALU_OP Value.";
               
                assert(OP_TYPE_D = "000000")
                report "ERROR: OP -> Wrong OP_TYPE Value.";
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
