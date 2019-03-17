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


entity MEM_STAGE is
      Port ( DATA_OPERAND_IN :  in STD_LOGIC_VECTOR(63 downto 0);
             MEM_ADDR_IN :      in STD_LOGIC_VECTOR(63 downto 0);
             OP_TYPE :          in STD_LOGIC_VECTOR(3 downto 0);
             LSU_OP :           in STD_LOGIC_VECTOR(3 downto 0);
             
             MEM_LINK_VALUE :    inout STD_LOGIC_VECTOR(63 downto 0);
             MEM_LINK_ADDR :     out STD_LOGIC_VECTOR(63 downto 0);
             MEM_LINK_SIZE :     out STD_LOGIC_VECTOR(1 downto 0);
             MEM_LINK_REQ_TYPE : out STD_LOGIC;
             MEM_LINK_REQ :      out STD_LOGIC;
                  
             
             DATA_OPERAND_OUT : out STD_LOGIC_VECTOR(63 downto 0);
             SIG_INVALID :      out STD_LOGIC    
      );
end MEM_STAGE;

architecture MEM_STAGE_BEHAVE of MEM_STAGE is

-- Signals

-- Constants
constant OP_TYPE_LOAD   : STD_LOGIC_VECTOR(3 downto 0) := "0100";
constant OP_TYPE_STORE  : STD_LOGIC_VECTOR(3 downto 0) := "0101";

constant LSU_TYPE_LB :  STD_LOGIC_VECTOR(3 downto 0) := "0000";
constant LSU_TYPE_LH :  STD_LOGIC_VECTOR(3 downto 0) := "0001";
constant LSU_TYPE_LW :  STD_LOGIC_VECTOR(3 downto 0) := "0010";
constant LSU_TYPE_LBU : STD_LOGIC_VECTOR(3 downto 0) := "0100";
constant LSU_TYPE_LHU : STD_LOGIC_VECTOR(3 downto 0) := "0101";

constant LSU_TYPE_SB :  STD_LOGIC_VECTOR(3 downto 0) := "1000";
constant LSU_TYPE_SH :  STD_LOGIC_VECTOR(3 downto 0) := "1001";
constant LSU_TYPE_SW :  STD_LOGIC_VECTOR(3 downto 0) := "1010";

begin

    -- Load / Store process
    LSU_PROC : process(OP_TYPE, LSU_OP, MEM_ADDR_IN, DATA_OPERAND_IN)
    begin
        if(OP_TYPE = OP_TYPE_LOAD) then
            -- Check validity and send data
            CASE LSU_OP IS
                WHEN LSU_TYPE_LB => 
                    DATA_OPERAND_OUT(7 downto 0)  <= MEM_LINK_VALUE(7 downto 0);
                    DATA_OPERAND_OUT(63 downto 8) <= (others => MEM_LINK_VALUE(7));
                    -- Init request 
                    MEM_LINK_ADDR     <= MEM_ADDR_IN;
                    MEM_LINK_REQ_TYPE <= '0';
                    MEM_LINK_REQ      <= '1';
                WHEN LSU_TYPE_LH => 
                    DATA_OPERAND_OUT(15 downto 0)  <= MEM_LINK_VALUE(15 downto 0);
                    DATA_OPERAND_OUT(63 downto 16) <= (others => MEM_LINK_VALUE(15));
                    -- Init request 
                    MEM_LINK_ADDR     <= MEM_ADDR_IN;
                    MEM_LINK_REQ_TYPE <= '0';
                    MEM_LINK_REQ      <= '1';
                WHEN LSU_TYPE_LW =>                     
                    DATA_OPERAND_OUT(31 downto 0)  <= MEM_LINK_VALUE(31 downto 0);
                    -- TODO Change that when in 64 bits
                    DATA_OPERAND_OUT(63 downto 32) <= (others => '0');
                    --DATA_OPERAND_OUT(63 downto 32) <= (others => MEM_LINK_VALUE(31));
                    -- Init request 
                    MEM_LINK_ADDR     <= MEM_ADDR_IN;
                    MEM_LINK_REQ_TYPE <= '0';
                    MEM_LINK_REQ      <= '1';
                WHEN LSU_TYPE_LBU => 
                    DATA_OPERAND_OUT <= MEM_LINK_VALUE AND X"00000000000000FF";
                    -- Init request 
                    MEM_LINK_ADDR     <= MEM_ADDR_IN;
                    MEM_LINK_REQ_TYPE <= '0';
                    MEM_LINK_REQ      <= '1';  
                WHEN LSU_TYPE_LHU => 
                    DATA_OPERAND_OUT <= MEM_LINK_VALUE AND X"000000000000FFFF";
                    -- Init request 
                    MEM_LINK_ADDR     <= MEM_ADDR_IN;
                    MEM_LINK_REQ_TYPE <= '0';
                    MEM_LINK_REQ      <= '1'; 
                WHEN OTHERS =>
                    -- INVALID operation
                    SIG_INVALID <= '1';
            END CASE;
            
        elsif(OP_TYPE = OP_TYPE_STORE) then
            -- Check validity and send data
            CASE LSU_OP IS
                WHEN LSU_TYPE_SB => 
                    MEM_LINK_VALUE(7 downto 0)  <= DATA_OPERAND_IN(7 downto 0);
                    MEM_LINK_VALUE(63 downto 8) <= (others => '0');
                    -- Init request 
                    MEM_LINK_ADDR     <= MEM_ADDR_IN;
                    MEM_LINK_REQ_TYPE <= '1';
                    MEM_LINK_REQ      <= '1';
                    MEM_LINK_SIZE     <= "00";
                WHEN LSU_TYPE_SH => 
                    MEM_LINK_VALUE(15 downto 0)  <= DATA_OPERAND_IN(15 downto 0);
                    MEM_LINK_VALUE(63 downto 16) <= (others => '0');
                    -- Init request 
                    MEM_LINK_ADDR     <= MEM_ADDR_IN;
                    MEM_LINK_REQ_TYPE <= '1';
                    MEM_LINK_REQ      <= '1';
                    MEM_LINK_SIZE     <= "01";
                WHEN LSU_TYPE_SW =>                     
                    MEM_LINK_VALUE(31 downto 0)  <= DATA_OPERAND_IN(31 downto 0);
                    MEM_LINK_VALUE(63 downto 32) <= (others => '0');
                    -- Init request 
                    MEM_LINK_ADDR     <= MEM_ADDR_IN;
                    MEM_LINK_REQ_TYPE <= '1';
                    MEM_LINK_REQ      <= '1';  
                    MEM_LINK_SIZE     <= "10";           
                WHEN OTHERS =>
                    -- INVALID operation
                    SIG_INVALID <= '1';
            END CASE;
        else
            -- Do not init request 
            MEM_LINK_REQ <= '0';
            -- Just copy the value
            DATA_OPERAND_OUT <= DATA_OPERAND_IN;
        end if;
    end process LSU_PROC;

end MEM_STAGE_BEHAVE;
