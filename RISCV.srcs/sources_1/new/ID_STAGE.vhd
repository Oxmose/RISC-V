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
--              IN: 32 bits, INSTRUCTION_DATA the data to decode.
--              IN: 32 bits, REG_RVAL1 the value or the first register requested in the register file.
--              IN: 32 bits, REG_RVAL2 the value or the second register requested in the register file.
--              OUT: 32 bits, OPERAND_0 the value of the first operand of the instruction.
--              OUT: 32 bits, OPERAND_1 the value of the second operand of the instruction.
--              OUT: 32 bits, OPERAND_OFF the value of the offset operand of the instruction.
--              OUT: 5 bits, RD the register id for RD. 
--              OUT: 4 bits, ALU_OP the ALU operation to be executed.
--              OUT: 4 bits, BRANCH_OP the BRANCH operation to be executed.
--              OUT: 4 bits, OP_TYPE the operation type to be executed.
--              OUT: 4 bits, LSU_OP the memory operation to be executed.
--              OUT: 5 bits, REG_RID1 the register id for RS1. 
--              OUT: 5 bits, REG_RID2 the register id for RS2. 
--              OUT: 1 bit, SIG_INVALID the instruction invalid exception signal.
--              OUT: 1 bit, LD_STALL the stall signal for load operations.
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

ENTITY ID_STAGE IS 
    PORT ( INSTRUCTION_DATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
           
           REG_RVAL1 :        IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           REG_RVAL2 :        IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           
           RD_IN_EXE :        IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           RD_IN_MEM :        IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           RD_IN_WB :         IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
           RD_ID_EXE :        IN STD_LOGIC_VECTOR(4 DOWNTO 0); 
           RD_ID_MEM :        IN STD_LOGIC_VECTOR(4 DOWNTO 0); 
           RD_ID_WB :         IN STD_LOGIC_VECTOR(4 DOWNTO 0); 
           RD_WR_EXE :        IN STD_LOGIC;
           RD_WR_MEM :        IN STD_LOGIC;
           RD_WR_WB :         IN STD_LOGIC;
           
           OPERAND_0 :        OUT STD_LOGIC_VECTOR(31 DOWNTO 0);    
           OPERAND_1 :        OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           OPERAND_OFF :      OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           
           RD :               OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
           
           ALU_OP :           OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
           BRANCH_OP :        OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
           LSU_OP :           OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
           OP_TYPE :          OUT STD_LOGIC_VECTOR(3 DOWNTO 0);           
           
           REG_RID1_OUT :     OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
           REG_RID2_OUT :     OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
           
           SIG_INVALID :      OUT STD_LOGIC;
           LD_STALL :         OUT STD_LOGIC
    );          
END ID_STAGE;

ARCHITECTURE ID_STAGE_BEHAVE OF ID_STAGE IS

-- Constants
CONSTANT OP_IMM_OPCODE : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0010011";
CONSTANT OP_OPCODE :     STD_LOGIC_VECTOR(6 DOWNTO 0) := "0110011";
CONSTANT LUI_OPCODE :    STD_LOGIC_VECTOR(6 DOWNTO 0) := "0110111";
CONSTANT AUIPC_OPCODE :  STD_LOGIC_VECTOR(6 DOWNTO 0) := "0010111"; 
CONSTANT JAL_OPCODE :    STD_LOGIC_VECTOR(6 DOWNTO 0) := "1101111";
CONSTANT JALR_OPCODE :   STD_LOGIC_VECTOR(6 DOWNTO 0) := "1100111"; 
CONSTANT BRANCH_OPCODE : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1100011";
CONSTANT LOAD_OPCODE :   STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000011";
CONSTANT STORE_OPCODE :  STD_LOGIC_VECTOR(6 DOWNTO 0) := "0100011";
CONSTANT NOP_OPCODE :    STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000000";

CONSTANT OP_TYPE_ALU :    STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
CONSTANT OP_TYPE_LUI :    STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
CONSTANT OP_TYPE_BRANCH : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010";
CONSTANT OP_TYPE_LOAD :   STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100";
CONSTANT OP_TYPE_STORE :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101";

CONSTANT ALU_OP_ADD :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
CONSTANT ALU_OP_SUB :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "1001";
CONSTANT ALU_OP_SRA :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "1000";

CONSTANT BU_OP_AUIPC : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1000";
CONSTANT BU_OP_JAL :   STD_LOGIC_VECTOR(3 DOWNTO 0) := "1001";
CONSTANT BU_OP_JALR :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "1010";

-- Types
-- NONE.

-- Signals
SIGNAL OPCODE : STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL RS1 :    STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL RS2 :    STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL FUNCT3 : STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL FUNCT7 : STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL IMM_I :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL IMM_S :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL IMM_B :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL IMM_U :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL IMM_J :  STD_LOGIC_VECTOR(31 DOWNTO 0);

SIGNAL REG_RID1 : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL REG_RID2 : STD_LOGIC_VECTOR(4 DOWNTO 0);

SIGNAL OP0_BYPASS : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL OP1_BYPASS : STD_LOGIC_VECTOR(31 DOWNTO 0);

-- Components 
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
END COMPONENT BYPASS_UNIT;

BEGIN    

    -- Maop the bypass unit
    BP_U_MAP : BYPASS_UNIT PORT MAP(
        RVAL1    => OP0_BYPASS,
        RVAL2    => OP1_BYPASS,
        EXRDVAL  => RD_IN_EXE,
        MEMRDVAL => RD_IN_MEM,
        WBRDVAL  => RD_IN_WB,
        RID1     => REG_RID1,
        RID2     => REG_RID2,
        EXRDID   => RD_ID_EXE,
        MEMRDID  => RD_ID_MEM,
        WBRDID   => RD_ID_WB,
        EXRDWR   => RD_WR_EXE,
        MEMRDWR  => RD_WR_MEM,
        WBRDWR   => RD_WR_WB,
        RVAL1OUT => OPERAND_0,
        RVAL2OUT => OPERAND_1    
    );
    REG_RID1_OUT <= REG_RID1;
    REG_RID2_OUT <= REG_RID2;
     
     -- As defined by RISC-V RV64I, opcode is defined by the 7 first bits
     OPCODE <= INSTRUCTION_DATA(6 DOWNTO 0);
   
     -- As defined by RISC-V RV64I, RD is defined by the bits 7 to 11
     RD <= INSTRUCTION_DATA(11 DOWNTO 7);
   
     -- As defined by RISC-V RV64I, RS1 is defined by the bits 15 to 19
     RS1 <= INSTRUCTION_DATA(19 DOWNTO 15);
   
     -- As defined by RISC-V RV64I, RS2 is defined by the bits 20 to 24
     RS2 <= INSTRUCTION_DATA(24 DOWNTO 20);

     -- As defined by RISC-V RV64I, FUNCT3 is defined by the bits 12 to 14
     FUNCT3 <= INSTRUCTION_DATA(14 DOWNTO 12);
   
     -- As defined by RISC-V RV64I, FUNCT7 is defined by the bits 25 to 31
     FUNCT7 <= INSTRUCTION_DATA(31 DOWNTO 25);
   
     -- I Immediate
     IMM_I(10 DOWNTO 0)  <= INSTRUCTION_DATA(30 DOWNTO 20);
     IMM_I(31 DOWNTO 11) <= (OTHERS => INSTRUCTION_DATA(31));
   
     -- S Immediate
     IMM_S(4 DOWNTO 0)   <= INSTRUCTION_DATA(11 DOWNTO 7);
     IMM_S(10 DOWNTO 5)  <= INSTRUCTION_DATA(30 DOWNTO 25);
     IMM_S(31 DOWNTO 11) <= (OTHERS => INSTRUCTION_DATA(31));
   
     -- B Immmediate
     IMM_B(0) <= '0';
     IMM_B(4 DOWNTO 1)   <= INSTRUCTION_DATA(11 DOWNTO 8);
     IMM_B(10 DOWNTO 5)  <= INSTRUCTION_DATA(30 DOWNTO 25);
     IMM_B(11)           <= INSTRUCTION_DATA(7);
     IMM_B(31 DOWNTO 12) <= (OTHERS => INSTRUCTION_DATA(31)); 
   
     -- U Immediate
     IMM_U(11 DOWNTO 0)  <= (OTHERS => '0'); 
     IMM_U(31 DOWNTO 12) <= INSTRUCTION_DATA(31 DOWNTO 12);
   
     -- J Immediate
     IMM_J(0)            <= '0';
     IMM_J(10 DOWNTO 1)  <= INSTRUCTION_DATA(30 DOWNTO 21);
     IMM_J(11)           <= INSTRUCTION_DATA(20);
     IMM_J(19 DOWNTO 12) <= INSTRUCTION_DATA(19 DOWNTO 12);
     IMM_J(31 DOWNTO 20) <= (OTHERS => INSTRUCTION_DATA(31));
               
    -- Manage OPCODE
    DECODE_PROCESS: PROCESS(INSTRUCTION_DATA, OPCODE,
                            RS1, REG_RVAL1, RS2, REG_RVAL2, 
                            FUNCT3, FUNCT7, 
                            IMM_I, IMM_S, IMM_B, IMM_U, IMM_J)
    BEGIN 
        SIG_INVALID <= '0';
        OPERAND_OFF <= (OTHERS => '0');
        ALU_OP      <= (OTHERS => '0');
        BRANCH_OP   <= (OTHERS => '0');
        LSU_OP      <= (OTHERS => '0');
        OP_TYPE     <= (OTHERS => '0');
        REG_RID1    <= (OTHERS => '0');
        REG_RID2    <= (OTHERS => '0');
        LD_STALL    <= '0';
        
        CASE OPCODE IS
            WHEN OP_IMM_OPCODE =>                                -- OP-IMM      
                -- Set OP Type as ALU type 
                OP_TYPE <= OP_TYPE_ALU;
            
                -- Select RS1 value as first operand
                REG_RID1  <= RS1;
                OP0_BYPASS <= REG_RVAL1;
                
                -- Set RS2 to 0
                REG_RID2 <= "00000";
                
                -- Select IMM as second operand
                OP1_BYPASS  <= IMM_I;
                
                -- Select the ALU operation
                ALU_OP <= '0' & FUNCT3;
                        
                -- Check left shift validity 
                IF(FUNCT3 = "001" AND (IMM_I(31 downto 5) /= X"000000" & "000")) THEN
                    SIG_INVALID <= '1';
                END IF;
                
                -- Check the SR A/L operation
                IF(FUNCT3 = "101") THEN                    
                    IF(IMM_I(31 DOWNTO 5) = X"0000" & "00000100000") THEN
                        ALU_OP <= ALU_OP_SRA;
                    ELSIF(IMM_I(31 DOWNTO 5) /= X"0000" & "00000000000") THEN
                        SIG_INVALID <= '1';                        
                    END IF;         
                END IF;
                
            WHEN OP_OPCODE =>                                -- OP
                -- Check FUNCT7
                IF(FUNCT7 /= "0000000") THEN
                    IF(FUNCT7 /= "0100000") THEN
                        SIG_INVALID <= '1';
                    ELSIF(FUNCT3 /= "000" AND FUNCT3 /= "101") THEN
                        SIG_INVALID <= '1';
                    END IF;
                END IF;
            
                -- Set OP Type as ALU type 
                OP_TYPE <= OP_TYPE_ALU;
            
                -- Select RS1 value as first operand
                REG_RID1  <= RS1;
                OP0_BYPASS <= REG_RVAL1;
                
                -- Select RS2 value as second operand
                REG_RID2  <= RS2;
                OP1_BYPASS <= REG_RVAL2;
                
                -- Select the ALU operation
                ALU_OP <= '0' & FUNCT3;
                
                -- Check the SR ADD/SUB operation
                IF(FUNCT3 = "000" AND FUNCT7(5) = '1') THEN
                    ALU_OP <= ALU_OP_SUB;                
                END IF;
                
                -- Check the SR A/L operation
                IF(FUNCT3 = "101" AND IMM_I(10) = '1') THEN
                    ALU_OP <= ALU_OP_SRA;                
                END IF;
            
            WHEN LUI_OPCODE =>                               -- LUI 
                -- Set OP Type as LUI type 
                OP_TYPE <= OP_TYPE_LUI;
                
                -- Select IMM as first operand
                OP0_BYPASS <= IMM_U;
                
                -- Set RS1 and RS2 to 0
                REG_RID1 <= "00000";
                REG_RID2 <= "00000";
            
            WHEN AUIPC_OPCODE =>                               -- AUIPC
                -- Set OP Type as branch type 
                OP_TYPE <= OP_TYPE_BRANCH;
                
                -- Select the BRANCH operation (AUIPC)
                BRANCH_OP <= BU_OP_AUIPC;
                           
                -- Select IMM as second operand
                OPERAND_OFF <= IMM_U;
        
            WHEN JAL_OPCODE =>                               -- JAL
                -- Set OP Type as branch type 
                OP_TYPE <= OP_TYPE_BRANCH;
                
                -- Select the BRANCH operation (JAL)
                BRANCH_OP <= BU_OP_JAL;
                
                -- Select IMM as offset operand
                OPERAND_OFF <= IMM_J;
            
            WHEN JALR_OPCODE =>                               -- JALR
                -- Check FUNCT3
                IF(FUNCT3 /= "000") THEN
                    SIG_INVALID <= '1';
                END IF;
                
                -- Set OP Type as branch type 
                OP_TYPE <= OP_TYPE_BRANCH;
                
                -- Select the BRANCH operation (JALR)
                BRANCH_OP <= BU_OP_JALR;
                
                -- Select RS1 value as first operand
                REG_RID1  <= RS1;
                OP0_BYPASS <= REG_RVAL1;
                
                -- Set RS2 to 0
                REG_RID2 <= "00000";
                
                -- Select IMM as second operand
                OP1_BYPASS <= IMM_I;
        
            WHEN BRANCH_OPCODE =>                               -- BRANCH
                -- Check FUNCT3
                IF(FUNCT3 = "010" OR FUNCT3 = "011") THEN
                    SIG_INVALID <= '1';
                END IF;
                            
                -- Set OP Type as branch type 
                OP_TYPE <= OP_TYPE_BRANCH;
                
                -- Select the BRANCH operation
                BRANCH_OP <= '0' & FUNCT3;
                
                -- Select RS1 value as first operand
                REG_RID1  <= RS1;
                OP0_BYPASS <= REG_RVAL1;
                
                -- Select RS2 value as second operand
                REG_RID2  <= RS2;
                OP1_BYPASS <= REG_RVAL2;
                
                -- Add the offset 
                OPERAND_OFF <= IMM_B;
            
            WHEN LOAD_OPCODE =>                              -- LOAD
                -- Check FUNCT3
                IF(FUNCT3 = "011" OR FUNCT3 > "101") THEN
                    SIG_INVALID <= '1';
                END IF;
                
                -- Set OP Type as load type
                OP_TYPE <= OP_TYPE_LOAD;
                
                -- Select the ALU operation ADD
                ALU_OP <= ALU_OP_ADD; 
                
                -- Set RS1 value as first operand
                REG_RID1  <= RS1;
                OP0_BYPASS <= REG_RVAL1;
                
                -- Set RS2 to 0
                REG_RID2 <= "00000";
                
                -- Set the IMM value as offset
                OPERAND_OFF <= IMM_I;

                -- Select the LSU operation Load
                LSU_OP <= '0' & FUNCT3;
                
                -- Load stall bubble 
                LD_STALL <= '1';
                
             WHEN STORE_OPCODE =>                              -- STORE
               -- Check FUNCT3
               IF(FUNCT3 > "010") THEN
                   SIG_INVALID <= '1';
               END IF;
               
               -- Set OP Type as store type
               OP_TYPE <= OP_TYPE_STORE;
               
               -- Set RS1 value as first operand
               REG_RID1  <= RS1;
               OP0_BYPASS <= REG_RVAL1;
               
               -- Set RS2 value as value to store
               REG_RID2  <= RS2;
               OP1_BYPASS <= REG_RVAL2;
               
               -- Set IMM value as offset
               OPERAND_OFF <= IMM_S;
               
               -- Select the ALU operation ADD
               ALU_OP <= ALU_OP_ADD;                
               
               -- Select the LSU operation store
               LSU_OP <= '1' & FUNCT3;
               
            WHEN NOP_OPCODE =>                           -- IMPLEMENTATION SPECIFIC NO OP
                IF(INSTRUCTION_DATA /= X"00000000") THEN
                   SIG_INVALID <= '1';
                END IF;
                
                -- Set OP Type as ALU type 
                OP_TYPE <= OP_TYPE_ALU;
            
                -- Select RS1 value as first operand
                REG_RID1  <= "00000";
                REG_RID2  <= "00000";
                OP0_BYPASS <= REG_RVAL1;
                OP1_BYPASS <= REG_RVAL2;
                OPERAND_OFF  <= (OTHERS => '0');
                
                -- Select the ALU operation
                ALU_OP <= "0000";                
            WHEN OTHERS =>
                SIG_INVALID <= '1';
        END CASE;
    
    END PROCESS DECODE_PROCESS;

END ID_STAGE_BEHAVE;
