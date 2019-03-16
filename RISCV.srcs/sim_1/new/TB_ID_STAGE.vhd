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
    Port ( INSTRUCTION_DATA : in STD_LOGIC_VECTOR(63 downto 0); 
           PC :               in STD_LOGIC_VECTOR(63 downto 0);
           
           REG_RVAL1 :        in STD_LOGIC_VECTOR(63 downto 0);
           REG_RVAL2 :        in STD_LOGIC_VECTOR(63 downto 0);
           
           OPERAND_0 :        out STD_LOGIC_VECTOR(63 downto 0);    
           OPERAND_1 :        out STD_LOGIC_VECTOR(63 downto 0);
           OPERAND_OFF :      out STD_LOGIC_VECTOR(63 downto 0);
           RD :               out STD_LOGIC_VECTOR(4 downto 0);
           ALU_OP :           out STD_LOGIC_VECTOR(3 downto 0);
           BRANCH_OP :        out STD_LOGIC_VECTOR(3 downto 0);
           OP_TYPE :          out STD_LOGIC_VECTOR(3 downto 0);
           LSU_OP :           out STD_LOGIC_VECTOR(3 downto 0);
           
           REG_RID1 :         out STD_LOGIC_VECTOR(4 downto 0);
           REG_RID2 :         out STD_LOGIC_VECTOR(4 downto 0);
           
           SIG_INVALID :      out STD_LOGIC
    );
end component;

signal OP_DATA : STD_LOGIC_VECTOR(6 downto 0);
signal REG_DATA : STD_LOGIC_VECTOR(4 downto 0);

signal INSTRUCTION_DATA_D : STD_LOGIC_VECTOR(63 downto 0);
signal PC_D : STD_LOGIC_VECTOR(63 downto 0);
signal OPERAND_0_D : STD_LOGIC_VECTOR(63 downto 0);
signal OPERAND_1_D : STD_LOGIC_VECTOR(63 downto 0);
signal OPERAND_OFF_D : STD_LOGIC_VECTOR(63 downto 0);
signal RD_D : STD_LOGIC_VECTOR(4 downto 0);
signal ALU_OP_D : STD_LOGIC_VECTOR(3 downto 0);
signal BRANCH_OP_D : STD_LOGIC_VECTOR(3 downto 0);
signal OP_TYPE_D : STD_LOGIC_VECTOR(3 downto 0);
signal LSU_OP_D: STD_LOGIC_VECTOR(3 downto 0);

signal REG_VAL1_D : STD_LOGIC_VECTOR(63 downto 0);
signal REG_VAL2_D : STD_LOGIC_VECTOR(63 downto 0);


signal REG_RID1_D : STD_LOGIC_VECTOR(4 downto 0);
signal REG_RID2_D : STD_LOGIC_VECTOR(4 downto 0);

signal SIG_INVALID_D : STD_LOGIC;

signal NOTIFY: STD_LOGIC;

signal COUNTER : integer := 0;

constant CLK_PERIOD : time := 10ns;

constant OP_IMM_OPCODE : STD_LOGIC_VECTOR(6 downto 0) := "0010011";
constant OP_OPCODE     : STD_LOGIC_VECTOR(6 downto 0) := "0110011";
constant LUI_OPCODE    : STD_LOGIC_VECTOR(6 downto 0) := "0110111";
constant AUIPC_OPCODE  : STD_LOGIC_VECTOR(6 downto 0) := "0010111"; 
constant JAL_OPCODE    : STD_LOGIC_VECTOR(6 downto 0) := "1101111";
constant JALR_OPCODE   : STD_LOGIC_VECTOR(6 downto 0) := "1100111"; 
constant BRANCH_OPCODE : STD_LOGIC_VECTOR(6 downto 0) := "1100011";
constant LOAD_OPCODE   : STD_LOGIC_VECTOR(6 downto 0) := "0000011";
constant STORE_OPCODE  : STD_LOGIC_VECTOR(6 downto 0) := "0100011";

begin
    
     ID: ID_STAGE Port Map(
        INSTRUCTION_DATA => INSTRUCTION_DATA_D,
        PC => PC_D,
        
        REG_RVAL1 => REG_VAL1_D,
        REG_RVAL2 => REG_VAL2_D,
         
        OPERAND_0 => OPERAND_0_D,
        OPERAND_1 => OPERAND_1_D,
        OPERAND_OFF => OPERAND_OFF_D,
        RD => RD_D,
        ALU_OP => ALU_OP_D,
        BRANCH_OP => BRANCH_OP_D,
        OP_TYPE => OP_TYPE_D,
        LSU_OP => LSU_OP_D,
        
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
            
            PC_D <= X"00000000000EF4A4";
            
            wait for CLK_PERIOD;
        -- Test invalid 
        elsif(COUNTER < 2) then
            OP_DATA <= STD_LOGIC_VECTOR(UNSIGNED(OP_DATA) + 1);
            
            for j in 0 to 128 loop 
                OP_DATA <= STD_LOGIC_VECTOR(TO_UNSIGNED(j, OP_DATA'length));
                
                wait for CLK_PERIOD / 256;
                
                INSTRUCTION_DATA_D <= (others => '0');
                INSTRUCTION_DATA_D(6 downto 0) <= OP_DATA;
                
                wait for CLK_PERIOD / 256;
                
                if(OP_DATA(1 downto 0) /= "11") then
                    assert(SIG_INVALID_D = '1')
                    report "ERROR: SIG_INVALID not detected.";
                    
                elsif(OP_DATA(6 downto 0) = OP_IMM_OPCODE OR
                      OP_DATA(6 downto 0) = OP_OPCODE OR
                      OP_DATA(6 downto 0) = LUI_OPCODE OR
                      OP_DATA(6 downto 0) = AUIPC_OPCODE OR
                      OP_DATA(6 downto 0) = JAL_OPCODE OR
                      OP_DATA(6 downto 0) = JALR_OPCODE OR                      
                      OP_DATA(6 downto 0) = BRANCH_OPCODE OR                      
                      OP_DATA(6 downto 0) = LOAD_OPCODE OR                      
                      OP_DATA(6 downto 0) = STORE_OPCODE  ) then
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
            
            assert(ALU_OP_D = "0000")
            report "ERROR: OP-IMM -> Wrong ALU_OP Value.";
            
            assert(OP_TYPE_D = "0000")
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
            
            assert(ALU_OP_D = "0010")
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
            
            assert(ALU_OP_D = "0011")
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
            
            assert(ALU_OP_D = "0111")
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
            
            assert(ALU_OP_D = "0110")
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
            
            assert(ALU_OP_D = "0100")
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
            
            assert(ALU_OP_D = "0001")
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
            
            assert(ALU_OP_D = "0101")
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
            
            assert(ALU_OP_D = "1000")
            report "ERROR: OP-IMM -> Wrong ALU_OP Value.";
            
         -- Test LUI Decode
         elsif(COUNTER < 5) then
             INSTRUCTION_DATA_D <= X"0000000000001" & "10111" & "0110111"; 
            
           wait for CLK_PERIOD;
           assert(RD_D = "10111")
           report "ERROR: LUI -> Wrong RD Value.";
           
           assert(OPERAND_0_D = X"0000000000001000")
           report "ERROR: LUI -> Wrong OP0 Value.";
           
           assert(OP_TYPE_D = "0001")
           report "ERROR: LUI -> Wrong OP_TYPE Value.";
           
        -- Test AUIPC Decode
        elsif(COUNTER < 6) then
            INSTRUCTION_DATA_D <= X"0000000000101" & "10101" & "0010111"; 
           
          wait for CLK_PERIOD;
          assert(RD_D = "10101")
          report "ERROR: AUIPCI -> Wrong RD Value.";
                    
          assert(OPERAND_0_D = X"0000000000101000")
          report "ERROR: AUIPC -> Wrong OP0 Value.";
          
          assert(OP_TYPE_D = "0010")
          report "ERROR: AUIPC -> Wrong OP_TYPE Value.";
          
          assert(BRANCH_OP_D = "1000")
          report "ERROR: AUIPC -> Wring BRANCH_OP Value.";          
          
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
              
              assert(ALU_OP_D = "0000")
              report "ERROR: OP -> Wrong ALU_OP Value.";
              
              assert(OP_TYPE_D = "0000")
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
            
              assert(ALU_OP_D = "1001")
              report "ERROR: OP -> Wrong ALU_OP Value.";
            
              assert(OP_TYPE_D = "0000")
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
             
              assert(ALU_OP_D = "0010")
              report "ERROR: OP -> Wrong ALU_OP Value.";
             
              assert(OP_TYPE_D = "0000")
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
               
              assert(ALU_OP_D = "0011")
              report "ERROR: OP -> Wrong ALU_OP Value.";
               
              assert(OP_TYPE_D = "0000")
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
               
                assert(ALU_OP_D = "0111")
                report "ERROR: OP -> Wrong ALU_OP Value.";
               
                assert(OP_TYPE_D = "0000")
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
               
                assert(ALU_OP_D = "0110")
                report "ERROR: OP -> Wrong ALU_OP Value.";
               
                assert(OP_TYPE_D = "0000")
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
               
                assert(ALU_OP_D = "0100")
                report "ERROR: OP -> Wrong ALU_OP Value.";
               
                assert(OP_TYPE_D = "0000")
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
               
                assert(ALU_OP_D = "0001")
                report "ERROR: OP -> Wrong ALU_OP Value.";
               
                assert(OP_TYPE_D = "0000")
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
               
                assert(ALU_OP_D = "0101")
                report "ERROR: OP -> Wrong ALU_OP Value.";
               
                assert(OP_TYPE_D = "0000")
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
               
                assert(ALU_OP_D = "1000")
                report "ERROR: OP -> Wrong ALU_OP Value.";
               
                assert(OP_TYPE_D = "0000")
                report "ERROR: OP -> Wrong OP_TYPE Value.";
        
        -- Test JAL Decode
        elsif(COUNTER < 8) then
            INSTRUCTION_DATA_D <= X"0000000010101" & "10101" & "1101111"; 
           
            wait for CLK_PERIOD;
            assert(RD_D = "10101")
            report "ERROR: JAL -> Wrong RD Value.";
                    
            assert(OPERAND_0_D = X"0000000010101000")
            report "ERROR: JAL -> Wrong OP1 Value.";
          
            assert(OP_TYPE_D = "0010")
            report "ERROR: JAL -> Wrong OP_TYPE Value.";
            
            assert(BRANCH_OP_D = "1001")
            report "ERROR: JAL -> Wring BRANCH_OP Value.";  
            
            
        -- Test JARL Decode
        elsif(COUNTER < 9) then
            INSTRUCTION_DATA_D <= X"00000000101" & "00011" & "000" & "10101" & "1100111"; 
           
            wait for CLK_PERIOD;
            assert(RD_D = "10101")
            report "ERROR: JARL -> Wrong RD Value.";
            
            assert(REG_RID1_D = "00011")
            report "ERROR: JARL -> Wrong RS1 Value.";
          
            assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
            report "ERROR: JARL -> Wrong OP0 Value.";
                    
            assert(OPERAND_1_D = X"0000000000000101")
            report "ERROR: JARL -> Wrong OP1 Value.";
          
            assert(OP_TYPE_D = "0010")
            report "ERROR: JARL -> Wrong OP_TYPE Value.";
            
            assert(BRANCH_OP_D = "1010")
            report "ERROR: JARL -> Wring BRANCH_OP Value.";  
        -- Test BRANCHES Decode 
        elsif(COUNTER < 10) then
            REG_VAL1_D <= x"0F0F0F0F0F0F0F0F";
            REG_VAL2_D <= x"0000000000000011";
        
            -- BEQ
            INSTRUCTION_DATA_D <= X"00000000" & "0000000" & "01011" & "00011" & "000" & "11010" & "1100011";
            wait for CLK_PERIOD / 6;
            
            assert(REG_RID1_D = "00011")
            report "ERROR: BEQ -> Wrong RS1 Value.";
            
            assert(REG_RID2_D = "01011")
            report "ERROR: BEQ -> Wrong RS2 Value.";
          
            assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
            report "ERROR: BEQ -> Wrong OP0 Value.";
                    
            assert(OPERAND_1_D = X"0000000000000011")
            report "ERROR: BEQ -> Wrong OP1 Value.";
            
            assert(OPERAND_OFF_D = X"000000000000001A")
            report "ERROR: BEQ -> Wrong OP_OFF Value.";
          
            assert(OP_TYPE_D = "0010")
            report "ERROR: BEQ -> Wrong OP_TYPE Value.";
            
            assert(BRANCH_OP_D = "0000")
            report "ERROR: BEQ -> Wring BRANCH_OP Value.";
            
            -- BNE
            INSTRUCTION_DATA_D <= X"00000000" & "0000000" & "01011" & "00011" & "001" & "11010" & "1100011";
            wait for CLK_PERIOD / 6;
            
            assert(REG_RID1_D = "00011")
            report "ERROR: BNE -> Wrong RS1 Value.";
            
            assert(REG_RID2_D = "01011")
            report "ERROR: BNE -> Wrong RS2 Value.";
          
            assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
            report "ERROR: BNE -> Wrong OP0 Value.";
                    
            assert(OPERAND_1_D = X"0000000000000011")
            report "ERROR: BNE -> Wrong OP1 Value.";
            
            assert(OPERAND_OFF_D = X"000000000000001A")
            report "ERROR: BNE -> Wrong OP_OFF Value.";
          
            assert(OP_TYPE_D = "0010")
            report "ERROR: BNE -> Wrong OP_TYPE Value.";
            
            assert(BRANCH_OP_D = "0001")
            report "ERROR: BNE -> Wring BRANCH_OP Value.";
            
            -- BLT
            INSTRUCTION_DATA_D <= X"00000000" & "0000000" & "01011" & "00011" & "100" & "11010" & "1100011";
            wait for CLK_PERIOD / 6;
            
            assert(REG_RID1_D = "00011")
            report "ERROR: BLT -> Wrong RS1 Value.";
            
            assert(REG_RID2_D = "01011")
            report "ERROR: BLT -> Wrong RS2 Value.";
          
            assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
            report "ERROR: BLT -> Wrong OP0 Value.";
                    
            assert(OPERAND_1_D = X"0000000000000011")
            report "ERROR: BLT -> Wrong OP1 Value.";
            
            assert(OPERAND_OFF_D = X"000000000000001A")
            report "ERROR: BLT -> Wrong OP_OFF Value.";
          
            assert(OP_TYPE_D = "0010")
            report "ERROR: BLT -> Wrong OP_TYPE Value.";
            
            assert(BRANCH_OP_D = "0100")
            report "ERROR: BLT -> Wring BRANCH_OP Value.";
                        
            -- BGE
            INSTRUCTION_DATA_D <= X"00000000" & "0000000" & "01011" & "00011" & "101" & "11010" & "1100011";
            wait for CLK_PERIOD / 6;
            
            assert(REG_RID1_D = "00011")
            report "ERROR: BGE -> Wrong RS1 Value.";
            
            assert(REG_RID2_D = "01011")
            report "ERROR: BGE -> Wrong RS2 Value.";
          
            assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
            report "ERROR: BGE -> Wrong OP0 Value.";
                    
            assert(OPERAND_1_D = X"0000000000000011")
            report "ERROR: BGE -> Wrong OP1 Value.";
            
            assert(OPERAND_OFF_D = X"000000000000001A")
            report "ERROR: BGE -> Wrong OP_OFF Value.";
          
            assert(OP_TYPE_D = "0010")
            report "ERROR: BGE -> Wrong OP_TYPE Value.";
            
            assert(BRANCH_OP_D = "0101")
            report "ERROR: BGE -> Wring BRANCH_OP Value.";
            
            -- BLTU
            INSTRUCTION_DATA_D <= X"00000000" & "0000000" & "01011" & "00011" & "110" & "11010" & "1100011";
            wait for CLK_PERIOD / 6;
            
            assert(REG_RID1_D = "00011")
            report "ERROR: BLTU -> Wrong RS1 Value.";
            
            assert(REG_RID2_D = "01011")
            report "ERROR: BLTU -> Wrong RS2 Value.";
          
            assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
            report "ERROR: BLTU -> Wrong OP0 Value.";
                    
            assert(OPERAND_1_D = X"0000000000000011")
            report "ERROR: BLTU -> Wrong OP1 Value.";
            
            assert(OPERAND_OFF_D = X"000000000000001A")
            report "ERROR: BLTU -> Wrong OP_OFF Value.";
          
            assert(OP_TYPE_D = "0010")
            report "ERROR: BLTU -> Wrong OP_TYPE Value.";
            
            assert(BRANCH_OP_D = "0110")
            report "ERROR: BLTU -> Wring BRANCH_OP Value.";
                        
            -- BGEU
            INSTRUCTION_DATA_D <= X"00000000" & "0000000" & "01011" & "00011" & "111" & "11010" & "1100011";
            wait for CLK_PERIOD / 6;
            
            assert(REG_RID1_D = "00011")
            report "ERROR: BGEU -> Wrong RS1 Value.";
            
            assert(REG_RID2_D = "01011")
            report "ERROR: BGEU -> Wrong RS2 Value.";
          
            assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
            report "ERROR: BGEU -> Wrong OP0 Value.";
                    
            assert(OPERAND_1_D = X"0000000000000011")
            report "ERROR: BGEU -> Wrong OP1 Value.";
            
            assert(OPERAND_OFF_D = X"000000000000001A")
            report "ERROR: BGEU -> Wrong OP_OFF Value.";
          
            assert(OP_TYPE_D = "0010")
            report "ERROR: BGEU -> Wrong OP_TYPE Value.";
            
            assert(BRANCH_OP_D = "0111")
            report "ERROR: BGEU -> Wring BRANCH_OP Value.";
            
        -- Test LOAD Decode 
        elsif(COUNTER < 11) then
        
            for i in 0 to 5 loop
                INSTRUCTION_DATA_D <= X"00000000" & "000001001011" & "01011" & STD_LOGIC_VECTOR(TO_UNSIGNED(i, INSTRUCTION_DATA_D(2 downto 0)'length)) & "11010" & "0000011";
                wait for CLK_PERIOD / 6;
                if(i /= 3) then               
                    
                    assert(RD_D = "11010")
                    report "ERROR: LOAD -> Wrong RD Value.";
                    
                    assert(OP_TYPE_D = "0100")
                    report "ERROR: LOAD -> Wrong OP_TYPE Value.";
                    
                    assert(ALU_OP_D = "0000")
                    report "ERROR: LOAD -> Wrong ALU_OP Value.";
                    
                    assert(REG_RID1_D = "01011")
                    report "ERROR: LOAD -> Wrong RS1 Value.";
                    
                    assert(LSU_OP_D = STD_LOGIC_VECTOR(TO_UNSIGNED(i, INSTRUCTION_DATA_D(3 downto 0)'length)))
                    report "ERROR: LOAD -> Wrong LSU_OP Value.";
                  
                    assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
                    report "ERROR: LOAD -> Wrong OP0 Value.";
                    
                    assert(OPERAND_OFF_D = X"000000000000" & "0000000001001011")
                    report "ERROR: LOAD -> Wrong OP_OFF Value.";
                
                end if;
            end loop;
            
            
        -- Test STORE Decode
        elsif(COUNTER < 12) then
            for i in 0 to 2 loop
                INSTRUCTION_DATA_D <= X"00000000" & "0000010" & "01101" & "01011" &                 
                    STD_LOGIC_VECTOR(TO_UNSIGNED(i, INSTRUCTION_DATA_D(2 downto 0)'length)) & 
                    "11010" & "0100011";
                
                wait for CLK_PERIOD / 3;
                                
                assert(OP_TYPE_D = "0101")
                report "ERROR: STORE -> Wrong OP_TYPE Value.";
                
                assert(ALU_OP_D = "0000")
                report "ERROR: STORE -> Wrong ALU_OP Value.";
                
                assert(REG_RID1_D = "01011")
                report "ERROR: STORE -> Wrong RS1 Value.";
                
                assert(REG_RID2_D = "01101")
                report "ERROR: STORE -> Wrong RS2 Value.";
                
                assert(LSU_OP_D = '1' & STD_LOGIC_VECTOR(TO_UNSIGNED(i, INSTRUCTION_DATA_D(2 downto 0)'length)))
                report "ERROR: STORE -> Wrong LSU_OP Value.";
              
                assert(OPERAND_0_D = X"0F0F0F0F0F0F0F0F")
                report "ERROR: STORE -> Wrong OP0 Value.";
                
                assert(OPERAND_1_D = X"00000000000000"& "01011010")
                report "ERROR: STORE -> Wrong OP1 Value.";
                
                assert(OPERAND_OFF_D = X"0000000000000011")
                report "ERROR: STORE -> Wrong OP_OFF Value.";
            end loop;
        
        -- Test INVLID FUNCT Decode 
        elsif(COUNTER < 13) then        
            -- OP
            INSTRUCTION_DATA_D <= X"00000000" & "0000000" & "10101" & "00011" &  "000" & "00101" & "0110011"; 
            for i in 0 to 127 loop
                INSTRUCTION_DATA_D(31 downto 25) <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, 7));
                wait for CLK_PERIOD / 288;
                if(i = 0) then
                    assert(SIG_INVALID_D = '0')
                    report "ERROR: INVALID0 -> Wring SIG_INVALID Value."; 
                elsif(i = 32) then
                    assert(SIG_INVALID_D = '0')
                    report "ERROR: INVALID1 -> Wring SIG_INVALID Value."; 
                else 
                    assert(SIG_INVALID_D = '1')
                    report "ERROR: INVALID2 -> Wring SIG_INVALID Value."; 
                end if;
            end loop;
            INSTRUCTION_DATA_D <= X"00000000" & "0000000" & "10101" & "00011" &  "101" & "00101" & "0110011"; 
            for i in 0 to 127 loop
                INSTRUCTION_DATA_D(31 downto 25) <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, 7));
                wait for CLK_PERIOD / 288;
                if(i = 0) then
                    assert(SIG_INVALID_D = '0')
                    report "ERROR: INVALID3 -> Wring SIG_INVALID Value."; 
                elsif(i = 32) then
                    assert(SIG_INVALID_D = '0')
                    report "ERROR: INVALID4 -> Wring SIG_INVALID Value."; 
                else 
                    assert(SIG_INVALID_D = '1')
                    report "ERROR: INVALID5 -> Wring SIG_INVALID Value."; 
                end if;
            end loop;
            -- JALR
            INSTRUCTION_DATA_D <= X"00000000" & "0000000" & "10101" & "00011" &  "000" & "00101" & "1100111"; 
            for i in 0 to 7 loop
                INSTRUCTION_DATA_D(14 downto 12) <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, 3));
                wait for CLK_PERIOD / 288;
                if(i = 0) then
                    assert(SIG_INVALID_D = '0')
                    report "ERROR: INVALID6 -> Wring SIG_INVALID Value."; 
                else 
                    assert(SIG_INVALID_D = '1')
                    report "ERROR: INVALID7 -> Wring SIG_INVALID Value."; 
                end if;
            end loop;
            -- BRANCH
            INSTRUCTION_DATA_D <= X"00000000" & "0000000" & "10101" & "00011" &  "000" & "00101" & "1100011"; 
            for i in 0 to 7 loop
                INSTRUCTION_DATA_D(14 downto 12) <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, 3));
                wait for CLK_PERIOD / 288;
                if(i = 2 or i = 3) then
                    assert(SIG_INVALID_D = '1')
                    report "ERROR: INVALID8 -> Wring SIG_INVALID Value."; 
                else 
                    assert(SIG_INVALID_D = '0')
                    report "ERROR: INVALID9 -> Wring SIG_INVALID Value."; 
                end if;
            end loop;
            
            
            -- LOAD
            INSTRUCTION_DATA_D <= X"00000000" & "000001001011" & "01011" & "000" & "11010" & "0000011";
            for i in 0 to 7 loop
                INSTRUCTION_DATA_D(14 downto 12) <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, 3));
                wait for CLK_PERIOD / 288;
                if(i = 3 or i > 5) then
                    assert(SIG_INVALID_D = '1')
                    report "ERROR: INVALID10 -> Wring SIG_INVALID Value."; 
                else 
                    assert(SIG_INVALID_D = '0')
                    report "ERROR: INVALID11 -> Wring SIG_INVALID Value."; 
                end if;
            end loop;
            -- STORE
            INSTRUCTION_DATA_D <= X"00000000" & "000001001011" & "01011" & "000" & "11010" & "0100011";
            for i in 0 to 7 loop
                INSTRUCTION_DATA_D(14 downto 12) <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, 3));
                wait for CLK_PERIOD / 288;
                if(i > 2) then
                    assert(SIG_INVALID_D = '1')
                    report "ERROR: INVALID12 -> Wring SIG_INVALID Value."; 
                else 
                    assert(SIG_INVALID_D = '0')
                    report "ERROR: INVALID13 -> Wring SIG_INVALID Value."; 
                end if;
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
