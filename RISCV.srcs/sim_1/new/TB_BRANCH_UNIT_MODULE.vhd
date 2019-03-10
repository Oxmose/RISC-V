----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.03.2019 12:00:40
-- Design Name: 
-- Module Name: TB_BRANCH_UNIT_MODULE - Behavioral
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

entity TB_BRANCH_UNIT_MODULE is
end TB_BRANCH_UNIT_MODULE;

architecture Behavioral of TB_BRANCH_UNIT_MODULE is

component BRANCH_UNIT_MODULE is
    Port ( OP1 :         in STD_LOGIC_VECTOR(63 downto 0);
           OP2 :         in STD_LOGIC_VECTOR(63 downto 0);
           OFF :         in STD_LOGIC_VECTOR(63 downto 0);
           RD_IN :       in STD_LOGIC_VECTOR(63 downto 0);
           PC_IN :       in STD_LOGIC_VECTOR(63 downto 0);
           SEL :         in STD_LOGIC_VECTOR(3 downto 0);
           RD_OUT :      out STD_LOGIC_VECTOR(63 downto 0);
           PC_OUT :      out STD_LOGIC_VECTOR(63 downto 0);
           B_TAKEN :     out STD_LOGIC;
           SIG_INVALID : out STD_LOGIC
    );
end component;

signal OP1_D :    STD_LOGIC_VECTOR(63 downto 0);
signal OP2_D :    STD_LOGIC_VECTOR(63 downto 0);
signal OFF_D :    STD_LOGIC_VECTOR(63 downto 0);
signal RD_IN_D :  STD_LOGIC_VECTOR(63 downto 0);
signal PC_IN_D :  STD_LOGIC_VECTOR(63 downto 0);
signal SEL_D :    STD_LOGIC_VECTOR(3 downto 0);
signal RD_OUT_D : STD_LOGIC_VECTOR(63 downto 0);
signal PC_OUT_D : STD_LOGIC_VECTOR(63 downto 0);
signal B_TAKEN_D :  STD_LOGIC;
signal SIG_INVAL_D :  STD_LOGIC;

signal NOTIFY: STD_LOGIC;
signal COUNTER: INTEGER := 0;

constant CLK_PERIOD : time := 10ns;

begin

BU: BRANCH_UNIT_MODULE Port Map(
    OP1 => OP1_D,
    OP2 => OP2_D,
    OFF => OFF_D,
    RD_IN => RD_IN_D,
    PC_IN => PC_IN_D,
    SEL => SEL_D,
    RD_OUT => RD_OUT_D,
    PC_OUT => PC_OUT_D,
    B_TAKEN => B_TAKEN_D,
    SIG_INVALID => SIG_INVAL_D
);

process
begin

    for i in 0 to 512 loop
        -- Init
        if(COUNTER < 1) then        
           PC_IN_D <= x"0000000000000004";
           OP1_D  <= x"0000000000000100";
           OFF_D <= X"0000000000000010";
           RD_IN_D <= X"00000000000FE450";
           NOTIFY <= '0';
           wait for CLK_PERIOD;
        -- AUIPC
        elsif(COUNTER < 2) then
            SEL_D <= "1000";
            
            wait for CLK_PERIOD;
            
            assert(SIG_INVAL_D = '0')
            report "ERROR: AUIPC -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = X"0000000000000014")
            report "ERROR: AUIPC -> Wrong PC Value.";
            
            assert(RD_OUT_D = X"0000000000000014")
            report "ERROR: AUIPC -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '1')
            report "ERROR: AUIPC -> Wrong BRANCH_TAKEN Value.";
       
       -- JAL
        elsif(COUNTER < 3) then
            SEL_D <= "1001";
            
            wait for CLK_PERIOD;
            
            assert(SIG_INVAL_D = '0')
            report "ERROR: JAL -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = X"0000000000000024")
            report "ERROR: JAL -> Wrong PC Value.";
            
            assert(RD_OUT_D = X"0000000000000008")
            report "ERROR: JAL -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '1')
            report "ERROR: JAL -> Wrong BRANCH_TAKEN Value.";
        -- JALR
        elsif(COUNTER < 4) then
            SEL_D <= "1010";
            OFF_D <= X"0000000000000011";
            wait for CLK_PERIOD;
            
            assert(SIG_INVAL_D = '0')
            report "ERROR: JALR -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = X"0000000000000110")
            report "ERROR: JALR -> Wrong PC Value.";
            
            assert(RD_OUT_D = X"0000000000000008")
            report "ERROR: JALR -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '1')
            report "ERROR: JALR -> Wrong BRANCH_TAKEN Value.";
        -- BEQ
        elsif(COUNTER < 5) then
            SEL_D <= "0000";
            OFF_D <= X"0000000000000010";
            OP1_D  <= x"0000000000000100";
            OP2_D  <= x"0000000000000100";
            wait for CLK_PERIOD / 2;
            
            assert(SIG_INVAL_D = '0')
            report "ERROR: BEQ -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = X"0000000000000024")
            report "ERROR: BEQ -> Wrong PC Value.";
            
            assert(RD_OUT_D = RD_IN_D)
            report "ERROR: BEQ -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '1')
            report "ERROR: BEQ -> Wrong BRANCH_TAKEN Value.";
            
            OP1_D  <= x"0000000000000100";
            OP2_D  <= x"1000000000000100";
            wait for CLK_PERIOD / 2;
            
            assert(SIG_INVAL_D = '0')
            report "ERROR: BEQ -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = X"0000000000000004")
            report "ERROR: BEQ -> Wrong PC Value.";
            
            assert(RD_OUT_D = RD_IN_D)
            report "ERROR: BEQ -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '0')
            report "ERROR: BEQ -> Wrong BRANCH_TAKEN Value.";
        
        -- BNE
        elsif(COUNTER < 6) then
            SEL_D <= "0001";
            OFF_D <= X"0000000000000010";
            OP1_D  <= x"0000000000000100";
            OP2_D  <= x"1000000000000100";
            wait for CLK_PERIOD / 2;
            
            assert(SIG_INVAL_D = '0')
            report "ERROR: BNE -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = X"0000000000000024")
            report "ERROR: BNE -> Wrong PC Value.";
            
            assert(RD_OUT_D = RD_IN_D)
            report "ERROR: BNE -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '1')
            report "ERROR: BNE -> Wrong BRANCH_TAKEN Value.";
            
            OP1_D  <= x"0000000000000100";
            OP2_D  <= x"0000000000000100";
            wait for CLK_PERIOD / 2;
            
            assert(SIG_INVAL_D = '0')
            report "ERROR: BNE -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = X"0000000000000004")
            report "ERROR: BNE -> Wrong PC Value.";
            
            assert(RD_OUT_D = RD_IN_D)
            report "ERROR: BNE -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '0')
            report "ERROR: BNE -> Wrong BRANCH_TAKEN Value.";
            
        -- BLT
        elsif(COUNTER < 7) then
            SEL_D <= "0100";
            OFF_D <= X"0000000000000010";
            OP1_D  <= x"0000000000000100";
            OP2_D  <= x"1000000000000100";
            wait for CLK_PERIOD / 4;
            
            assert(SIG_INVAL_D = '0')
            report "ERROR: BLT -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = X"0000000000000024")
            report "ERROR: BLT -> Wrong PC Value.";
            
            assert(RD_OUT_D = RD_IN_D)
            report "ERROR: BLT -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '1')
            report "ERROR: BLT -> Wrong BRANCH_TAKEN Value.";
            
            OP1_D  <= x"0000000000000100";
            OP2_D  <= x"0000000000000100";
            wait for CLK_PERIOD / 4;
            
            assert(SIG_INVAL_D = '0')
            report "ERROR: BLT -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = X"0000000000000004")
            report "ERROR: BLT -> Wrong PC Value.";
            
            assert(RD_OUT_D = RD_IN_D)
            report "ERROR: BLT -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '0')
            report "ERROR: BLT -> Wrong BRANCH_TAKEN Value.";
            
            OP1_D  <= x"0000000001000100";
            OP2_D  <= x"0000000000000100";
            wait for CLK_PERIOD / 4;
            
            assert(SIG_INVAL_D = '0')
            report "ERROR: BLT -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = X"0000000000000004")
            report "ERROR: BLT -> Wrong PC Value.";
            
            assert(RD_OUT_D = RD_IN_D)
            report "ERROR: BLT -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '0')
            report "ERROR: BLT -> Wrong BRANCH_TAKEN Value.";
            
            OP1_D  <= x"8000000001000100";
            OP2_D  <= x"0000000000000100";
            wait for CLK_PERIOD / 4;
            
            assert(SIG_INVAL_D = '0')
            report "ERROR: BLT -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = X"0000000000000024")
            report "ERROR: BLT -> Wrong PC Value.";
            
            assert(RD_OUT_D = RD_IN_D)
            report "ERROR: BLT -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '1')
            report "ERROR: BLT -> Wrong BRANCH_TAKEN Value.";
        -- BGE
        elsif(COUNTER < 8) then
            SEL_D <= "0101";
            OFF_D <= X"0000000000000010";
            OP1_D  <= x"0000000000000100";
            OP2_D  <= x"1000000000000100";
            wait for CLK_PERIOD / 4;
            
            assert(SIG_INVAL_D = '0')
            report "ERROR: BGE -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = X"0000000000000004")
            report "ERROR: BGE -> Wrong PC Value.";
            
            assert(RD_OUT_D = RD_IN_D)
            report "ERROR: BGE -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '0')
            report "ERROR: BGE -> Wrong BRANCH_TAKEN Value.";
            
            OP1_D  <= x"0000000000000100";
            OP2_D  <= x"0000000000000100";
            wait for CLK_PERIOD / 4;
            
            assert(SIG_INVAL_D = '0')
            report "ERROR: BGE -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = X"0000000000000024")
            report "ERROR: BGE -> Wrong PC Value.";
            
            assert(RD_OUT_D = RD_IN_D)
            report "ERROR: BGE -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '1')
            report "ERROR: BGE -> Wrong BRANCH_TAKEN Value.";
            
            OP1_D  <= x"0000000001000100";
            OP2_D  <= x"0000000000000100";
            wait for CLK_PERIOD / 4;
            
            assert(SIG_INVAL_D = '0')
            report "ERROR: BGE -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = X"0000000000000024")
            report "ERROR: BGE -> Wrong PC Value.";
            
            assert(RD_OUT_D = RD_IN_D)
            report "ERROR: BGE -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '1')
            report "ERROR: BGE -> Wrong BRANCH_TAKEN Value.";
            
            OP1_D  <= x"8000000001000100";
            OP2_D  <= x"0000000000000100";
            wait for CLK_PERIOD / 4;
            
            assert(SIG_INVAL_D = '0')
            report "ERROR: BGE -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = X"0000000000000004")
            report "ERROR: BGE -> Wrong PC Value.";
            
            assert(RD_OUT_D = RD_IN_D)
            report "ERROR: BGE -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '0')
            report "ERROR: BGE -> Wrong BRANCH_TAKEN Value.";
        -- BLTU
        elsif(COUNTER < 9) then
            SEL_D <= "0110";
            OFF_D <= X"0000000000000010";
            OP1_D  <= x"0000000000000100";
            OP2_D  <= x"1000000000000100";
            wait for CLK_PERIOD / 4;
            
            assert(SIG_INVAL_D = '0')
            report "ERROR: BLTU -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = X"0000000000000024")
            report "ERROR: BLTU -> Wrong PC Value.";
            
            assert(RD_OUT_D = RD_IN_D)
            report "ERROR: BLTU -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '1')
            report "ERROR: BLTU -> Wrong BRANCH_TAKEN Value.";
            
            OP1_D  <= x"0000000000000100";
            OP2_D  <= x"0000000000000100";
            wait for CLK_PERIOD / 4;
            
            assert(SIG_INVAL_D = '0')
            report "ERROR: BLTU -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = X"0000000000000004")
            report "ERROR: BLTU -> Wrong PC Value.";
            
            assert(RD_OUT_D = RD_IN_D)
            report "ERROR: BLTU -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '0')
            report "ERROR: BLTU -> Wrong BRANCH_TAKEN Value.";
            
            OP1_D  <= x"0000000001000100";
            OP2_D  <= x"0000000000000100";
            wait for CLK_PERIOD / 4;
            
            assert(SIG_INVAL_D = '0')
            report "ERROR: BLTU -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = X"0000000000000004")
            report "ERROR: BLTU -> Wrong PC Value.";
            
            assert(RD_OUT_D = RD_IN_D)
            report "ERROR: BLTU -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '0')
            report "ERROR: BLTU -> Wrong BRANCH_TAKEN Value.";
            
            OP1_D  <= x"8000000001000100";
            OP2_D  <= x"0000000000000100";
            wait for CLK_PERIOD / 4;
            
            assert(SIG_INVAL_D = '0')
            report "ERROR: BLTU3 -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = X"0000000000000004")
            report "ERROR: BLTU -> Wrong PC Value.";
            
            assert(RD_OUT_D = RD_IN_D)
            report "ERROR: BLTU -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '0')
            report "ERROR: BLTU -> Wrong BRANCH_TAKEN Value.";
        -- BGEU
        elsif(COUNTER < 10) then
            SEL_D <= "0111";
            OFF_D <= X"0000000000000010";
            OP1_D  <= x"0000000000000100";
            OP2_D  <= x"1000000000000100";
            wait for CLK_PERIOD / 4;
            
            assert(SIG_INVAL_D = '0')
            report "ERROR: BGEU0 -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = X"0000000000000004")
            report "ERROR: BGEU0 -> Wrong PC Value.";
            
            assert(RD_OUT_D = RD_IN_D)
            report "ERROR: BGEU0 -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '0')
            report "ERROR: BGEU0 -> Wrong BRANCH_TAKEN Value.";
            
            OP1_D  <= x"0000000000000100";
            OP2_D  <= x"0000000000000100";
            wait for CLK_PERIOD / 4;
            
            assert(SIG_INVAL_D = '0')
            report "ERROR: BGEU1 -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = X"0000000000000024")
            report "ERROR: BGEU1 -> Wrong PC Value.";
            
            assert(RD_OUT_D = RD_IN_D)
            report "ERROR: BGEU1 -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '1')
            report "ERROR: BGEU1 -> Wrong BRANCH_TAKEN Value.";
            
            OP1_D  <= x"0000000001000100";
            OP2_D  <= x"0000000000000100";
            wait for CLK_PERIOD / 4;
            
            assert(SIG_INVAL_D = '0')
            report "ERROR: BGEU2 -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = X"0000000000000024")
            report "ERROR: BGEU2 -> Wrong PC Value.";
            
            assert(RD_OUT_D = RD_IN_D)
            report "ERROR: BGEU2 -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '1')
            report "ERROR: BGEU2 -> Wrong BRANCH_TAKEN Value.";
            
            OP1_D  <= x"8000000001000100";
            OP2_D  <= x"0000000000000100";
            wait for CLK_PERIOD / 4;
            
            assert(SIG_INVAL_D = '0')
            report "ERROR: BGEU3 -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = X"0000000000000024")
            report "ERROR: BGEU3 -> Wrong PC Value.";
            
            assert(RD_OUT_D = RD_IN_D)
            report "ERROR: BGEU3 -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '1')
            report "ERROR: BGEU3 -> Wrong BRANCH_TAKEN Value."; 
        -- INVAL
        elsif(COUNTER < 11) then

            SEL_D <= "0010";
            wait for CLK_PERIOD / 7;
            
            assert(SIG_INVAL_D = '1')
            report "ERROR: INVAL -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = PC_IN_D)
            report "ERROR: INVAL -> Wrong PC Value.";
            
            assert(RD_OUT_D = RD_IN_D)
            report "ERROR: INVAL -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '0')
            report "ERROR: INVAL -> Wrong BRANCH_TAKEN Value.";
            
            SEL_D <= "0011";
            wait for CLK_PERIOD / 7;
            
            assert(SIG_INVAL_D = '1')
            report "ERROR: INVAL -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = PC_IN_D)
            report "ERROR: INVAL -> Wrong PC Value.";
            
            assert(RD_OUT_D = RD_IN_D)
            report "ERROR: INVAL -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '0')
            report "ERROR: INVAL -> Wrong BRANCH_TAKEN Value.";
            
            SEL_D <= "1011";
            wait for CLK_PERIOD / 7;
            
            assert(SIG_INVAL_D = '1')
            report "ERROR: INVAL -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = PC_IN_D)
            report "ERROR: INVAL -> Wrong PC Value.";
            
            assert(RD_OUT_D = RD_IN_D)
            report "ERROR: INVAL -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '0')
            report "ERROR: INVAL -> Wrong BRANCH_TAKEN Value.";
            
            SEL_D <= "1100";
            wait for CLK_PERIOD / 7;
            
            assert(SIG_INVAL_D = '1')
            report "ERROR: INVAL -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = PC_IN_D)
            report "ERROR: INVAL -> Wrong PC Value.";
            
            assert(RD_OUT_D = RD_IN_D)
            report "ERROR: INVAL -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '0')
            report "ERROR: INVAL -> Wrong BRANCH_TAKEN Value.";
            
            SEL_D <= "1101";
            wait for CLK_PERIOD / 7;
            
            assert(SIG_INVAL_D = '1')
            report "ERROR: INVAL -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = PC_IN_D)
            report "ERROR: INVAL -> Wrong PC Value.";
            
            assert(RD_OUT_D = RD_IN_D)
            report "ERROR: INVAL -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '0')
            report "ERROR: INVAL -> Wrong BRANCH_TAKEN Value.";
            
            SEL_D <= "1110";
            wait for CLK_PERIOD / 7;
            
            assert(SIG_INVAL_D = '1')
            report "ERROR: INVAL -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = PC_IN_D)
            report "ERROR: INVAL -> Wrong PC Value.";
            
            assert(RD_OUT_D = RD_IN_D)
            report "ERROR: INVAL -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '0')
            report "ERROR: INVAL -> Wrong BRANCH_TAKEN Value.";
            
            SEL_D <= "1111";
            wait for CLK_PERIOD / 7;
            
            assert(SIG_INVAL_D = '1')
            report "ERROR: INVAL -> Wrong INVAL Value.";
            
            assert(PC_OUT_D = PC_IN_D)
            report "ERROR: INVAL -> Wrong PC Value.";
            
            assert(RD_OUT_D = RD_IN_D)
            report "ERROR: INVAL -> Wrong RD Value.";
            
            assert(B_TAKEN_D = '0')
            report "ERROR: INVAL -> Wrong BRANCH_TAKEN Value.";
                                 
        elsif (NOTIFY = '0') then
            NOTIFY <= '1';
            report "Test finished" severity note;   
            wait for CLK_PERIOD;
        else  
            wait for CLK_PERIOD;
        end if;   
        COUNTER <= COUNTER + 1;
    end loop;  
end process;


end Behavioral;