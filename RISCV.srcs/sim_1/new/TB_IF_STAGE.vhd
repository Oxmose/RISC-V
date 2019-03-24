----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.02.2019 20:29:15
-- Design Name: 
-- Module Name: TB_IF_STAGE - Behavioral
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

entity TB_IF_STAGE is
end TB_IF_STAGE;

architecture TB_IF_STAGE_BEHAVE of TB_IF_STAGE is

component IF_STAGE is
    Port ( CLK :            IN STD_LOGIC;
           RST :            IN STD_LOGIC;
           STALL :          IN STD_LOGIC;
           EF_JUMP:         IN STD_LOGIC;
           JUMP_INST_ADDR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
          
           INST_MEM_DATA :      IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           MEM_LINK_VALUE_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           MEM_LINK_ADDR :      OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           MEM_LINK_SIZE :      OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
           MEM_LINK_REQ_TYPE :  OUT STD_LOGIC;
           MEM_LINK_REQ :       OUT STD_LOGIC;
          
           PC :             OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           INSTRUCTION :    OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           SIG_ALIGN :      OUT STD_LOGIC);
end component;

signal RST_D:       STD_LOGIC := '1';
signal CLK_D:       STD_LOGIC := '0';
signal EN_D:        STD_LOGIC := '0';
signal STALL_D:     STD_LOGIC := '0';
signal EF_JUMP_D:   STD_LOGIC := '0';
signal SIG_ALIGN_D: STD_LOGIC := '0';

signal JUMP_INST_ADDR_D: STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
signal INST_MEM_DATA_D:  STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
signal INST_MEM_ADDR_D:  STD_LOGIC_VECTOR(31 downto 0) := X"00000000";

signal MEM_LINK_VALUE_OUT_D : STD_LOGIC_VECTOR(31 downto 0);
signal MEM_LINK_ADDR_D : STD_LOGIC_VECTOR(31 downto 0);
signal MEM_LINK_SIZE_D : STD_LOGIC_VECTOR(1 downto 0);
signal MEM_LINK_REQ_TYPE_D : STD_LOGIC;
signal MEM_LINK_REQ_D: STD_LOGIC;

signal CURRENT_ADDR:  STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
signal PAST_ADDR:  STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
signal COUNTER: STD_LOGIC_VECTOR(31 downto 0) := x"00000000";

constant CLK_PERIOD : time := 10ns;

begin

    stage : IF_STAGE port map (
       CLK => CLK_D,
       RST  => RST_D,
       STALL => STALL_D,
       EF_JUMP => EF_JUMP_D,
       JUMP_INST_ADDR => JUMP_INST_ADDR_D,
       INST_MEM_DATA => INST_MEM_DATA_D,
       MEM_LINK_VALUE_OUT => MEM_LINK_VALUE_OUT_D,
       MEM_LINK_ADDR => MEM_LINK_ADDR_D,
       MEM_LINK_SIZE => MEM_LINK_SIZE_D,
       MEM_LINK_REQ_TYPE => MEM_LINK_REQ_TYPE_D,
       MEM_LINK_REQ => MEM_LINK_REQ_D,
       PC => INST_MEM_ADDR_D,
       SIG_ALIGN => SIG_ALIGN_D
       
    );
        
    
    TEST_PROC_CLK: process
    begin
        CLK_D <= '0';
        wait for CLK_PERIOD / 2;
        CLK_D <= '1';
        wait for CLK_PERIOD / 2;
    end process;
    
    TEST_CLK_DRIVE: process(CLK_D)
    begin          
        assert(MEM_LINK_VALUE_OUT_D = X"00000000")
        report "ERROR: Value out incorrect";
        assert(MEM_LINK_REQ_TYPE_D = '0')
        report "ERROR: REQ TYPE incorrect";
        assert(MEM_LINK_SIZE_D = "10")
        report "ERROR: REQ SIZE incorrect";
        assert(MEM_LINK_ADDR_D = CURRENT_ADDR)
        report "ERROR: MEM_LINK_ADDR incorrect";
        assert(MEM_LINK_REQ_D = (NOT STALL_D AND NOT RST_D))
        report "ERROR: MEM_LINK_REQ incorrect";
        
        if(rising_edge(CLK_D)) then
            
            -- Check RST
            if(COUNTER = X"00000000" OR COUNTER = X"00000040") then
                RST_D <= '1';
            else 
                RST_D <= '0';
            end if;
                        
            -- Check EF_JUMP
            if(COUNTER = X"00000030") then
                EF_JUMP_D <= '1';
                JUMP_INST_ADDR_D <= X"00010000";
            else
                EF_JUMP_D <= '0';
                JUMP_INST_ADDR_D <= X"00000000";
            end if;
            
            -- Check STALL            
            if(COUNTER = X"00000010") then
                STALL_D <= '1';
            end if;
            
            if(COUNTER = X"00000020") then
                STALL_D <= '0';
            end if;
            
            -- Check ADDR for all mentionned above
            assert(INST_MEM_ADDR_D = PAST_ADDR)
            report "ERROR: Wrong PC value";
            
            -- Drive simple address             
            if((INST_MEM_ADDR_D AND X"00000004") = X"00000004") then
                INST_MEM_DATA_D <= X"0000FFFF";
            else 
                INST_MEM_DATA_D <= X"FFFF0000";
            end if;
            
            -- Check ALIGN
            if(COUNTER = X"00000050") then
                EF_JUMP_D <= '1';
                JUMP_INST_ADDR_D <= X"00010001";
            end if;
            
            if(COUNTER >= X"00000052") then
                assert(SIG_ALIGN_D = '1')
                report "ERROR: Align sig not detected";
            else 
                assert(SIG_ALIGN_D = '0')
                report "ERROR: Align sig detected";
            end if;
            
            -- Increment values 
            if(STALL_D /= '1') then
                PAST_ADDR <= CURRENT_ADDR;
            end if;
            COUNTER <= STD_LOGIC_VECTOR(UNSIGNED(COUNTER) + 1);
            if(COUNTER = X"00000031" AND STALL_D = '0') then
                CURRENT_ADDR <= X"00010000";
            elsif((COUNTER = X"00000040" OR COUNTER = X"00000041") AND STALL_D = '0') then
                CURRENT_ADDR <= X"00000000";
                PAST_ADDR    <= X"00000000";
            elsif(COUNTER = X"00000051" AND STALL_D = '0') then
                CURRENT_ADDR <= X"00010001";
            elsif(COUNTER > X"00000001" AND STALL_D = '0') then
                CURRENT_ADDR <= STD_LOGIC_VECTOR(UNSIGNED(CURRENT_ADDR) + 4);
            end if;
        end if;
        
    end process;

end TB_IF_STAGE_BEHAVE;