----------------------------------------------------------------------------------
-- Author: Alexy Torres Aurora Dugo
-- 
-- Create Date: 02.03.2019 12:48:23
-- Design Name: ID_STAGE
-- Module Name: ID_STAGE - ID_STAGE_BEHAVE
-- Project Name: RISCV
-- Target Devices: Digilent NEXYS4
-- Tool Versions: Vivado 2018.2
-- Description: Instruction Decode stage of the RISCV processor.
--              This stage decodes the instruction.The instruction is split in different
--              parts that are used in the next stages.
--              IN: 64 bits, INSTRUCTION_DATA the data to decode.
--              IN: 64 bits, PC the current PC value.
--              IN: 64 bits, REG_RVAL1 the value or the first register requested in the register file.
--              IN: 64 bits, REG_RVAL2 the value or the second register requested in the register file.
--              OUT: 64 bits, OPERAND_0 the value of the first operand of the instruction.
--              OUT: 64 bits, OPERAND_1 the value of the second operand of the instruction.
--              OUT: 64 bits, OPERAND_OFF the value of the offset operand of the instruction.
--              OUT: 5 bits, RD the register id for RD. 
--              OUT: 4 bits, ALU_OP the ALU operation to be executed.
--              OUT: 4 bits, BRANCH_OP the BRANCH operation to be executed.
--              OUT: 4 bits, OP_TYPE the operation type to be executed.
--              OUT: 4 bits, LSU_OP the memory operation to be executed.
--              OUT: 5 bits, REG_RID1 the register id for RS1. 
--              OUT: 5 bits, REG_RID2 the register id for RS2. 
--              OUT: 1 bit, SIG_INVALID the instruction invalid exception signal.
--
-- Dependencies: None.
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ID_STAGE is 
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
           LSU_OP :           out STD_LOGIC_VECTOR(3 downto 0);
           OP_TYPE :          out STD_LOGIC_VECTOR(3 downto 0);           
           
           REG_RID1 :         out STD_LOGIC_VECTOR(4 downto 0);
           REG_RID2 :         out STD_LOGIC_VECTOR(4 downto 0);
           
           SIG_INVALID :      out STD_LOGIC
    );
          
end ID_STAGE;

architecture ID_STAGE_BEHAVE of ID_STAGE is

-- Signals
signal OPCODE :           STD_LOGIC_VECTOR(6 downto 0);
signal RS1 :              STD_LOGIC_VECTOR(4 downto 0);
signal RS2 :              STD_LOGIC_VECTOR(4 downto 0);
signal FUNCT3 :           STD_LOGIC_VECTOR(2 downto 0);
signal FUNCT7 :           STD_LOGIC_VECTOR(6 downto 0);
signal IMM_I :            STD_LOGIC_VECTOR(63 downto 0);
signal IMM_S :            STD_LOGIC_VECTOR(63 downto 0);
signal IMM_B :            STD_LOGIC_VECTOR(63 downto 0);
signal IMM_U :            STD_LOGIC_VECTOR(63 downto 0);
signal IMM_J :            STD_LOGIC_VECTOR(63 downto 0);

-- Constants
constant OP_IMM_OPCODE : STD_LOGIC_VECTOR(6 downto 0) := "0010011";
constant OP_OPCODE     : STD_LOGIC_VECTOR(6 downto 0) := "0110011";
constant LUI_OPCODE    : STD_LOGIC_VECTOR(6 downto 0) := "0110111";
constant AUIPC_OPCODE  : STD_LOGIC_VECTOR(6 downto 0) := "0010111"; 
constant JAL_OPCODE    : STD_LOGIC_VECTOR(6 downto 0) := "1101111";
constant JALR_OPCODE   : STD_LOGIC_VECTOR(6 downto 0) := "1100111"; 
constant BRANCH_OPCODE : STD_LOGIC_VECTOR(6 downto 0) := "1100011";
constant LOAD_OPCODE  : STD_LOGIC_VECTOR(6 downto 0) := "0000011";
constant STORE_OPCODE : STD_LOGIC_VECTOR(6 downto 0) := "0100011";

constant OP_TYPE_ALU    : STD_LOGIC_VECTOR(3 downto 0) := "0000";
constant OP_TYPE_LUI    : STD_LOGIC_VECTOR(3 downto 0) := "0001";
constant OP_TYPE_BRANCH : STD_LOGIC_VECTOR(3 downto 0) := "0010";
constant OP_TYPE_LOAD   : STD_LOGIC_VECTOR(3 downto 0) := "0100";
constant OP_TYPE_STORE  : STD_LOGIC_VECTOR(3 downto 0) := "0101";

-- Components 

begin    
    -- Check OPCODE, no custom nor reserved OPCODE is supported
    --WITH INSTRUCTION_DATA(6 downto 0) SELECT SIG_INVALID <=
    --    '0' WHEN "0000011" | "0100011" | "1000011" | "1100011", -- LOAD STORE MADD BRANCH
    --    '0' WHEN "0000111" | "0100111" | "1000111" | "1100111", -- LOADFP STOREFP MSUB JALR
    --    '0' WHEN "1001011",                                     -- NMSUB
    --    '0' WHEN "0001111" | "0101111" | "1001111" | "1101111", -- MISC-MEM AMO NMADD JAL
    --    '0' WHEN "0010011" | "0110011" | "1010011" | "1110011", -- OP-IMM OP OP-FP SYSTEM
    --    '0' WHEN "0010111" | "0110111",                         -- AUIPC LUI
    --    '0' WHEN "0011011" | "0111011",                         -- OP-IMM-32 OP-32
    --    '1' WHEN OTHERS;
     
     -- As defined by RISC-V RV64I, opcode is defined by the 7 first bits
     OPCODE <= INSTRUCTION_DATA(6 downto 0);
   
     -- As defined by RISC-V RV64I, RD is defined by the bits 7 to 11
     RD <= INSTRUCTION_DATA(11 downto 7);
   
     -- As defined by RISC-V RV64I, RS1 is defined by the bits 15 to 19
     RS1 <= INSTRUCTION_DATA(19 downto 15);
   
     -- As defined by RISC-V RV64I, RS2 is defined by the bits 20 to 24
     RS2 <= INSTRUCTION_DATA(24 downto 20);

     -- As defined by RISC-V RV64I, FUNCT3 is defined by the bits 12 to 14
     FUNCT3 <= INSTRUCTION_DATA(14 downto 12);
   
     -- As defined by RISC-V RV64I, FUNCT7 is defined by the bits 25 to 31
     FUNCT7 <= INSTRUCTION_DATA(31 downto 25);
   
     -- I Immediate
     IMM_I(10 downto 0)  <= INSTRUCTION_DATA(30 downto 20);
     IMM_I(63 downto 11) <= (others => INSTRUCTION_DATA(31));
   
     -- S Immediate
     IMM_S(4 downto 0)   <= INSTRUCTION_DATA(11 downto 7);
     IMM_S(10 downto 5)  <= INSTRUCTION_DATA(30 downto 25);
     IMM_S(63 downto 11) <= (others => INSTRUCTION_DATA(31));
   
     -- B Immmediate
     IMM_B(0) <= '0';
     IMM_B(4 downto 1)   <= INSTRUCTION_DATA(11 downto 8);
     IMM_B(10 downto 5)  <= INSTRUCTION_DATA(30 downto 25);
     IMM_B(11)           <= INSTRUCTION_DATA(7);
     IMM_B(63 downto 12) <= (others => INSTRUCTION_DATA(31)); 
   
     -- U Immediate
     IMM_U(11 downto 0)  <= (others => '0'); 
     IMM_U(31 downto 12) <= INSTRUCTION_DATA(31 downto 12);
     IMM_U(63 downto 32) <= (others => INSTRUCTION_DATA(31));
   
     -- J Immediate
     IMM_J(0)            <= '0';
     IMM_J(10 downto 1)  <= INSTRUCTION_DATA(30 downto 21);
     IMM_J(11)           <= INSTRUCTION_DATA(20);
     IMM_J(19 downto 12) <= INSTRUCTION_DATA(19 downto 12);
     IMM_J(63 downto 20) <= (others => INSTRUCTION_DATA(31));
               
    -- Manage OPCODE
    DECODE_PROCESS: process(INSTRUCTION_DATA, OPCODE, PC,
                            RS1, REG_RVAL1, RS2, REG_RVAL2, 
                            FUNCT3, FUNCT7, 
                            IMM_I, IMM_S, IMM_B, IMM_U, IMM_J)
    begin 
        SIG_INVALID <= '0';
        CASE OPCODE IS
            WHEN OP_IMM_OPCODE =>                                -- OP-IMM      
                -- Set OP Type as ALU type 
                OP_TYPE <= OP_TYPE_ALU;
            
                -- Select RS1 value as first operand
                REG_RID1  <= RS1;
                OPERAND_0 <= REG_RVAL1;
                
                -- Select IMM as second operand
                OPERAND_1  <= IMM_I;
                
                -- Select the ALU operation
                ALU_OP <= '0' & FUNCT3;
                
                -- Check the SR A/L operation
                if(FUNCT3 = "101" AND IMM_I(10) = '1') then
                    ALU_OP <= "1000";                
                end if;
                
            WHEN OP_OPCODE =>                                -- OP
                -- Check FUNCT7
                if(FUNCT7 /= "0000000") then
                    if(FUNCT7 /= "0100000") then
                        SIG_INVALID <= '1';
                    elsif(FUNCT3 /= "000" AND FUNCT3 /= "101") then
                        SIG_INVALID <= '1';
                    end if;
                end if;
            
                -- Set OP Type as ALU type 
                OP_TYPE <= OP_TYPE_ALU;
            
                -- Select RS1 value as first operand
                REG_RID1  <= RS1;
                OPERAND_0 <= REG_RVAL1;
                
                -- Select RS2 value as second operand
                REG_RID2  <= RS2;
                OPERAND_1 <= REG_RVAL2;
                
                -- Select the ALU operation
                ALU_OP <= '0' & FUNCT3;
                
                -- Check the SR ADD/SUB operation
                if(FUNCT3 = "000" AND FUNCT7(5) = '1') then
                    ALU_OP <= "1001";                
                end if;
                
                -- Check the SR A/L operation
                if(FUNCT3 = "101" AND IMM_I(10) = '1') then
                    ALU_OP <= "1000";                
                end if;
            
            WHEN LUI_OPCODE =>                               -- LUI 
                -- Set OP Type as LUI type 
                OP_TYPE <= OP_TYPE_LUI;
                
                -- Select IMM as first operand
                OPERAND_0 <= IMM_U;
            
            WHEN AUIPC_OPCODE =>                               -- AUIPC
                -- Set OP Type as branch type 
                OP_TYPE <= OP_TYPE_BRANCH;
                
                -- Select the BRANCH operation (AUIPC)
                BRANCH_OP <= "1000";
                           
                -- Select IMM as second operand
                OPERAND_0 <= IMM_U;
        
            WHEN JAL_OPCODE =>                               -- JAL
                -- Set OP Type as branch type 
                OP_TYPE <= OP_TYPE_BRANCH;
                
                -- Select the BRANCH operation (JAL)
                BRANCH_OP <= "1001";
                
                -- Select IMM as second operand
                OPERAND_0 <= IMM_U;
            
            WHEN JALR_OPCODE =>                               -- JALR
                -- Check FUNCT3
                if(FUNCT3 /= "000") then
                    SIG_INVALID <= '1';
                end if;
                
                -- Set OP Type as branch type 
                OP_TYPE <= OP_TYPE_BRANCH;
                
                -- Select the BRANCH operation (JALR)
                BRANCH_OP <= "1010";
                
                -- Select RS1 value as first operand
                REG_RID1  <= RS1;
                OPERAND_0 <= REG_RVAL1;
                
                -- Select IMM as second operand
                OPERAND_1 <= IMM_I;
        
            WHEN BRANCH_OPCODE =>                               -- BRANCH
                -- Check FUNCT3
                if(FUNCT3 = "010" OR FUNCT3 = "011") then
                    SIG_INVALID <= '1';
                end if;
                            
                -- Set OP Type as branch type 
                OP_TYPE <= OP_TYPE_BRANCH;
                
                -- Select the BRANCH operation
                BRANCH_OP <= '0' & FUNCT3;
                
                -- Select RS1 value as first operand
                REG_RID1  <= RS1;
                OPERAND_0 <= REG_RVAL1;
                
                -- Select RS2 value as second operand
                REG_RID2  <= RS2;
                OPERAND_1 <= REG_RVAL2;
                
                -- Add the offset 
                OPERAND_OFF <= IMM_B;
            
            WHEN LOAD_OPCODE =>                              -- LOAD
                -- Check FUNCT3
                if(FUNCT3 = "011" OR FUNCT3 > "101") then
                    SIG_INVALID <= '1';
                end if;
                
                -- Set OP Type as load type
                OP_TYPE <= OP_TYPE_LOAD;
                
                -- Select the ALU operation ADD
                ALU_OP <= "0000"; 
                
                -- Set RS1 value as first operand
                REG_RID1  <= RS1;
                OPERAND_0 <= REG_RVAL1;
                
                -- Set the IMM value as offset
                OPERAND_1 <= IMM_I;

                -- Select the LSU operation Load
                LSU_OP <= '0' & FUNCT3;
                
             WHEN STORE_OPCODE =>                              -- STORE
               -- Check FUNCT3
               if(FUNCT3 > "010") then
                   SIG_INVALID <= '1';
               end if;
               
               -- Set OP Type as store type
               OP_TYPE <= OP_TYPE_STORE;
               
               -- Set RS1 value as first operand
               REG_RID1  <= RS1;
               OPERAND_0 <= REG_RVAL1;
               
               -- Set the IMM value second operand
               OPERAND_1 <= IMM_S;
               
               -- Set RS2 value as value to store
               REG_RID2  <= RS2;
               OPERAND_OFF <= REG_RVAL2;
               
               -- Select the ALU operation ADD
               ALU_OP <= "0000";                
               
               -- Select the LSU operation store
               LSU_OP <= '1' & FUNCT3;
                
            WHEN OTHERS =>
                SIG_INVALID <= '1';
        end case;
    
    end process DECODE_PROCESS;

end ID_STAGE_BEHAVE;
