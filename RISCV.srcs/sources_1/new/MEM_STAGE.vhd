----------------------------------------------------------------------------------
-- Author: Alexy Torres Aurora Dugo
-- 
-- Create Date: 16.03.2019 18:32:02
-- Design Name: MEM_STAGE
-- Module Name: MEM_STAGE - MEM_STAGE_BEHAVE
-- Project Name: RISCV 
-- Target Devices: Digilent NEXYS4
-- Tool Versions: Vivado 2018.2
-- Description: Memory management stage, used to do LOAD and STORE operations.
--              This modules is bypassed in case of non memory operations.
--              IN: 32 bits, DATA_OPERAND_IN the data operand used as input of the stage.
--              IN: 32 bits, MEM_ADDR_IN the memory address to access.
--              IN: 4 bits, OP_TYPE the operation type.
--              IN: 4 bits, LSU_OP the load or store operation type.
--              IN: 32 bits, MEM_LINK_VALUE_IN the value read from the memory.
--              OUT: 32 bits, MEM_LINK_VALUE_OUT the value to write to the memory.
--              OUT: 32 bits, MEM_LINK_ADDR the address to send to the memory controller.
--              OUT: 2 bits, MEM_LINK_SIZE the access size (00 = byte, 01 = half, 10 = word, 11 = double).
--              OUT: 1 bit, MEM_LINK_REQ_TYPE the request type (0 = read, 1 = write).
--              OUT: 1 bit, MEM_LINK_REQ tells is a request to the memory is done (0 = no memory request, 1 = memory request).
--              OUT: 32 bits, DATA_OPERAND_OUT the data outputed by the stage (can be from the memory or not if not a memory operation).
--              OUT: 1 bit, SIG_INVALID is set to 1 when the operation is invalid, 0 otherwise.
--              
-- The value of OP_TYPE determines the operation:
--     - 0100 LOAD
--     - 0101 STORE
--     - OTHERS Non memory related operation
--
-- For LOAD operations the LSU_OP determines the load type 
--     - 0000 Load Byte
--     - 0001 Load Half
--     - 0010 Load Word
--     - 0011 Load Double
--     - 0100 Load Byte Unsigned
--     - 0101 Load Half Unsigned
--     - 0110 Load Word Unsigned
--     - OTHERS Invalid Load
--
-- For STORE operations the LSU_OP determines the store type 
--     - 1000 Store Byte
--     - 1001 Store Half
--     - 1010 Store Word
--     - 1011 Store Double
--     - OTHERS Invalid Load
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

ENTITY MEM_STAGE IS
      PORT ( DATA_OPERAND_IN :  IN STD_LOGIC_VECTOR(31 DOWNTO 0);
             MEM_ADDR_IN :      IN STD_LOGIC_VECTOR(31 DOWNTO 0);
             OP_TYPE :          IN STD_LOGIC_VECTOR(3 DOWNTO 0);
             LSU_OP :           IN STD_LOGIC_VECTOR(3 DOWNTO 0);
             
             MEM_LINK_VALUE_IN :  IN STD_LOGIC_VECTOR(31 DOWNTO 0);
             MEM_LINK_VALUE_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
             MEM_LINK_ADDR :      OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
             MEM_LINK_SIZE :      OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
             MEM_LINK_REQ_TYPE :  OUT STD_LOGIC;
             MEM_LINK_REQ :       OUT STD_LOGIC;
                  
             
             DATA_OPERAND_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
             SIG_INVALID :      OUT STD_LOGIC    
      );
END MEM_STAGE;

ARCHITECTURE MEM_STAGE_BEHAVE OF MEM_STAGE IS

-- Constants
CONSTANT OP_TYPE_LOAD :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100";
CONSTANT OP_TYPE_STORE : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101";

CONSTANT LSU_TYPE_LB :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
CONSTANT LSU_TYPE_LH :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
CONSTANT LSU_TYPE_LW :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010";
CONSTANT LSU_TYPE_LBU : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100";
CONSTANT LSU_TYPE_LHU : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101";

CONSTANT LSU_TYPE_SB :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "1000";
CONSTANT LSU_TYPE_SH :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "1001";
CONSTANT LSU_TYPE_SW :  STD_LOGIC_VECTOR(3 DOWNTO 0) := "1010";

-- Types
-- NONE.

-- Signals
SIGNAL INVALID_REQ : STD_LOGIC := '0';

-- Components
-- None.

BEGIN
    -- Link internal invalid signal to output 
    SIG_INVALID <= INVALID_REQ;
    
    -- Set link data 
    MEM_LINK_ADDR <= MEM_ADDR_IN;
    MEM_LINK_REQ  <= NOT INVALID_REQ WHEN OP_TYPE = OP_TYPE_LOAD OR 
                                          OP_TYPE = OP_TYPE_STORE ELSE
                     '0';    

    -- Data retreive process
    LOAD_PROC : PROCESS(OP_TYPE, LSU_OP, DATA_OPERAND_IN, MEM_LINK_VALUE_IN)
    BEGIN
        IF(OP_TYPE = OP_TYPE_LOAD) THEN
            CASE LSU_OP IS
                WHEN LSU_TYPE_LB =>
                    DATA_OPERAND_OUT <= (DATA_OPERAND_OUT'length - 1 DOWNTO 8 => MEM_LINK_VALUE_IN(7)) & 
                                        MEM_LINK_VALUE_IN(7 DOWNTO 0);
                WHEN LSU_TYPE_LH => 
                    DATA_OPERAND_OUT <= (DATA_OPERAND_OUT'length - 1 DOWNTO 16 => MEM_LINK_VALUE_IN(15)) & 
                                        MEM_LINK_VALUE_IN(15 DOWNTO 0);
                WHEN LSU_TYPE_LW =>     
                    DATA_OPERAND_OUT <= MEM_LINK_VALUE_IN;
                WHEN LSU_TYPE_LBU =>
                    DATA_OPERAND_OUT <= (DATA_OPERAND_OUT'length  - 1downto 8 => '0') & 
                                        MEM_LINK_VALUE_IN(7 DOWNTO 0);
                WHEN LSU_TYPE_LHU => 
                    DATA_OPERAND_OUT <= (DATA_OPERAND_OUT'length - 1 DOWNTO 16 => '0') & 
                                        MEM_LINK_VALUE_IN(15 DOWNTO 0);                 
                WHEN OTHERS =>
                    -- Just copy the data
                    DATA_OPERAND_OUT <= DATA_OPERAND_IN; 
             END CASE;
        ELSE 
            -- Just copy the data
            DATA_OPERAND_OUT <= DATA_OPERAND_IN;
        END IF;
    END PROCESS LOAD_PROC;
        
    -- Load / Store process
    LSU_PROC : PROCESS(OP_TYPE, LSU_OP, MEM_ADDR_IN, DATA_OPERAND_IN)
    BEGIN
        MEM_LINK_REQ_TYPE  <= '0';
        INVALID_REQ        <= '0';
        MEM_LINK_SIZE      <= "00";
        MEM_LINK_VALUE_OUT <= (OTHERS => '0');
        
        IF(OP_TYPE = OP_TYPE_LOAD) THEN
            -- Check validity and send data
            CASE LSU_OP IS
                WHEN LSU_TYPE_LB =>
                    MEM_LINK_SIZE <= "00";
                WHEN LSU_TYPE_LH => 
                    MEM_LINK_SIZE  <= "01";
                WHEN LSU_TYPE_LW =>                     
                    MEM_LINK_SIZE  <= "10";
                WHEN LSU_TYPE_LBU => 
                    MEM_LINK_SIZE <= "00";
                WHEN LSU_TYPE_LHU => 
                    MEM_LINK_SIZE <= "01";                   
                WHEN OTHERS =>
                    -- INVALID operation
                    INVALID_REQ <= '1';
            END CASE;
            -- Set request type
            MEM_LINK_REQ_TYPE <= '0';
            
        ELSIF(OP_TYPE = OP_TYPE_STORE) THEN            
            -- Check validity and send data            
            CASE LSU_OP IS
                WHEN LSU_TYPE_SB => 
                    MEM_LINK_VALUE_OUT(7 DOWNTO 0)  <= DATA_OPERAND_IN(7 DOWNTO 0);
                    MEM_LINK_VALUE_OUT(31 DOWNTO 8) <= (OTHERS => '0');
                    MEM_LINK_SIZE                   <= "00";
                WHEN LSU_TYPE_SH => 
                    MEM_LINK_VALUE_OUT(15 DOWNTO 0)  <= DATA_OPERAND_IN(15 DOWNTO 0);
                    MEM_LINK_VALUE_OUT(31 DOWNTO 16) <= (OTHERS => '0');
                    MEM_LINK_SIZE                    <= "01";
                WHEN LSU_TYPE_SW =>                     
                    MEM_LINK_VALUE_OUT <= DATA_OPERAND_IN;               
                    MEM_LINK_SIZE      <= "10";           
                WHEN OTHERS =>
                    -- INVALID operation
                    INVALID_REQ <= '1';
            END CASE;
           -- Set request type 
           MEM_LINK_REQ_TYPE <= '1';
        END IF;       
    END PROCESS LSU_PROC;
    
END MEM_STAGE_BEHAVE;
