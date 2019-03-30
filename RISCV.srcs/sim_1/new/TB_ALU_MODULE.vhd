----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.03.2019 17:09:34
-- Design Name: 
-- Module Name: TB_ALU_MODULE - Behavioral
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

entity TB_ALU_MODULE is
end TB_ALU_MODULE;


architecture TB_ALU_MODULE_BEHAVE of TB_ALU_MODULE is

component ALU_MODULE is 
    Port ( OP1 :         in STD_LOGIC_VECTOR(31 downto 0);
           OP2 :         in STD_LOGIC_VECTOR(31 downto 0);
           SEL :         in STD_LOGIC_VECTOR(3 downto 0);
           VOUT :        out STD_LOGIC_VECTOR(31 downto 0);
           SIG_INVALID : out STD_LOGIC
    );
end component;

signal OP1_D : STD_LOGIC_VECTOR(31 downto 0);
signal OP2_D : STD_LOGIC_VECTOR(31 downto 0);
signal SEL_D : STD_LOGIC_VECTOR(3 downto 0);
signal VOUT_D : STD_LOGIC_VECTOR(31 downto 0);
signal TEMP_SIG : STD_LOGIC_VECTOR(31 downto 0);
signal SIG_INVALID_D : STD_LOGIC;

signal NOTIFY: STD_LOGIC;
signal COUNTER: INTEGER := 0;

constant CLK_PERIOD : time := 100ns;

begin

    ALU: ALU_MODULE Port Map (
        OP1 => OP1_D,
        OP2 => OP2_D,
        SEL => SEL_D,
        VOUT => VOUT_D,
        SIG_INVALID => SIG_INVALID_D
    );

    TEST_CLK_DRIVE: process
    begin             
        for i in 0 to 512 loop
            -- Init
            if(COUNTER < 1) then               
                NOTIFY <= '0';
                wait for CLK_PERIOD;
                
            ------------------- TEST ADDITION --------------------------
            elsif(COUNTER < 3) then
                -- Normal ADD
                for i in 0 to 128 loop
                    OP1_D <= X"0000040D";
                    OP2_D <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, OP2_D'length));
                    SEL_D <= "0000";
                    wait for CLK_PERIOD / 256;
                    assert(VOUT_D = STD_LOGIC_VECTOR(UNSIGNED(OP2_D) + UNSIGNED(OP1_D)))
                    report("ERROR: ADD value incorect");
                    
                    assert(SIG_INVALID_D = '0')
                    report("ERROR: ADD -> Wrong SIGN_INVALID Value.");
                end loop;
                -- Overflow ADD
                OP1_D <= X"FFFFFFF1";
                OP2_D <= X"00000000";
                wait for CLK_PERIOD / 10000000;
                for i in 0 to 128 loop                    
                    OP2_D <= STD_LOGIC_VECTOR(UNSIGNED(OP2_D) + 1);
                    SEL_D <= "0000";
                    wait for CLK_PERIOD / 256;
                    assert(VOUT_D = STD_LOGIC_VECTOR(UNSIGNED(OP2_D) + UNSIGNED(OP1_D)))
                    report("ERROR: ADD value incorect");
                    assert(SIG_INVALID_D = '0')
                    report("ERROR: ADD -> Wrong SIGN_INVALID Value.");
                end loop;
            ------------------- TEST SUBSTRACTION --------------------------
            elsif(COUNTER < 4) then                
                -- Normal SUB
                for i in 0 to 128 loop
                    OP1_D <= X"0000040D";
                    OP2_D <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, OP2_D'length));
                    SEL_D <= "1001";
                    wait for CLK_PERIOD / 256;
                    assert(VOUT_D = STD_LOGIC_VECTOR(SIGNED(OP1_D) - SIGNED(OP2_D)))
                    report("ERROR: SUB value incorect");
                    
                    assert(SIG_INVALID_D = '0')
                    report("ERROR: SUB -> Wrong SIGN_INVALID Value.");
                end loop;
                -- Overflow SUB
                OP1_D <= X"00000000";
                OP2_D <= X"00000000";
                wait for CLK_PERIOD / 10000000;
                for i in 0 to 128 loop                    
                    OP2_D <= STD_LOGIC_VECTOR(UNSIGNED(OP2_D) + 1);
                    SEL_D <= "1001";
                    wait for CLK_PERIOD / 256;
                    assert(VOUT_D = STD_LOGIC_VECTOR(SIGNED(OP1_D) - SIGNED(OP2_D)))
                    report("ERROR: SUB value incorect");
                    
                    assert(SIG_INVALID_D = '0')
                    report("ERROR: SUB -> Wrong SIGN_INVALID Value.");
                end loop;
             ------------------- TEST SLT --------------------------
             elsif(COUNTER < 5) then                
               -- SLT
                OP1_D <= X"0000040D";
                OP2_D <= X"F0000000";
                SEL_D <= "0010";
                wait for CLK_PERIOD / 5;
                assert(SIG_INVALID_D = '0')
                report("ERROR: SLT -> Wrong SIGN_INVALID Value.");
                assert(VOUT_D = X"00000000")
                report("ERROR: SLT value incorect");
                OP1_D <= X"0000040D";
                OP2_D <= X"E0000000";
                SEL_D <= "0010";
                wait for CLK_PERIOD / 5;
                assert(SIG_INVALID_D = '0')
                report("ERROR: SLT -> Wrong SIGN_INVALID Value.");
                assert(VOUT_D = X"00000000")
                report("ERROR: SLT value incorect");
                OP1_D <= X"EE00040D";
                OP2_D <= X"F0000000";
                SEL_D <= "0010";
                wait for CLK_PERIOD / 5;
                assert(SIG_INVALID_D = '0')
                report("ERROR: SLT -> Wrong SIGN_INVALID Value.");
                assert(VOUT_D = X"00000001")
                report("ERROR: SLT value incorect");
                OP1_D <= X"F000040D";
                OP2_D <= X"70000000";
                SEL_D <= "0010";
                wait for CLK_PERIOD / 5;
                assert(SIG_INVALID_D = '0')
                report("ERROR: SLTD -> Wrong SIGN_INVALID Value.");
                assert(VOUT_D = X"00000001")
                report("ERROR: SLT value incorect");
                OP1_D <= X"00000012";
                OP2_D <= X"00000112";
                SEL_D <= "0010";
                wait for CLK_PERIOD / 5;
                assert(SIG_INVALID_D = '0')
                report("ERROR: SLT -> Wrong SIGN_INVALID Value.");
                assert(VOUT_D = X"00000001")
                report("ERROR: SLT value incorect");      
            ------------------- TEST SLTU --------------------------
            elsif(COUNTER < 6) then                
                OP1_D <= X"0000040D";
                OP2_D <= X"F0000000";
                SEL_D <= "0011";
                wait for CLK_PERIOD / 5;
                assert(SIG_INVALID_D = '0')
                report("ERROR: SLTU -> Wrong SIGN_INVALID Value.");
                assert(VOUT_D = X"00000001")
                report("ERROR: SLTU value incorect");
                OP1_D <= X"0000040D";
                OP2_D <= X"E0000000";
                SEL_D <= "0011";
                wait for CLK_PERIOD / 5;
                assert(SIG_INVALID_D = '0')
                report("ERROR: SLTU -> Wrong SIGN_INVALID Value.");
                assert(VOUT_D = X"00000001")
                report("ERROR: SLTU value incorect");
                OP1_D <= X"EE00040D";
                OP2_D <= X"F0000000";
                SEL_D <= "0011";
                wait for CLK_PERIOD / 5;
                assert(SIG_INVALID_D = '0')
                report("ERROR: SLTU -> Wrong SIGN_INVALID Value.");
                assert(VOUT_D = X"00000001")
                report("ERROR: SLTU value incorect");
                OP1_D <= X"F000040D";
                OP2_D <= X"70000000";
                SEL_D <= "0011";
                wait for CLK_PERIOD / 5;
                assert(SIG_INVALID_D = '0')
                report("ERROR: SLTU -> Wrong SIGN_INVALID Value.");
                assert(VOUT_D = X"00000000")
                report("ERROR: SLTU value incorect");
                OP1_D <= X"00000012";
                OP2_D <= X"00000112";
                SEL_D <= "0011";
                wait for CLK_PERIOD / 5;
                assert(SIG_INVALID_D = '0')
                report("ERROR: SLTU -> Wrong SIGN_INVALID Value.");
                assert(VOUT_D = X"00000001")
                report("ERROR: SLTU value incorect");   
            ------------------- TEST AND OR XOR --------------------------
            elsif(COUNTER < 7) then                
                OP1_D <= X"AAAAAAAA";
                OP2_D <= X"5555FFFF";
                SEL_D <= "0111";
                wait for CLK_PERIOD / 3;
                assert(SIG_INVALID_D = '0')
                report("ERROR: AND -> Wrong SIGN_INVALID Value.");
                assert(VOUT_D = X"0000AAAA")
                report("ERROR: AND value incorect");
                SEL_D <= "0110";
                wait for CLK_PERIOD / 3;
                assert(SIG_INVALID_D = '0')
                report("ERROR: OR -> Wrong SIGN_INVALID Value.");
                assert(VOUT_D = X"FFFFFFFF")
                report("ERROR: OR value incorect");
                SEL_D <= "0100";
                wait for CLK_PERIOD / 3;
                assert(SIG_INVALID_D = '0')
                report("ERROR: XOR -> Wrong SIGN_INVALID Value.");
                assert(VOUT_D = X"FFFF5555")
                report("ERROR: XOR value incorect");       
            ------------------- TEST SLL --------------------------
            elsif(COUNTER < 8) then                
                OP1_D <= X"FFFFFFFF";
                TEMP_SIG <= X"FFFFFFFF";
                OP2_D <= X"00000001";
                SEL_D <= "0001";
                for i in 0 to 31 loop
                    if(i = 0) then
                        OP2_D <= X"00000000"; 
                    else 
                        OP2_D <= X"00000001";
                    end if;
                    wait for CLK_PERIOD / 130;
                    assert(SIG_INVALID_D = '0')
                    report("ERROR: SLL -> Wrong SIGN_INVALID Value.");
                    assert(VOUT_D = STD_LOGIC_VECTOR(UNSIGNED(TEMP_SIG) sll i))
                    report("ERROR: SLL value incorect 0");
                    if(i /= 0) then
                        assert(VOUT_D(0) = '0')
                        report("ERROR: SLL value incorect 1");
                    end if;
                    wait for CLK_PERIOD / 130;
                    OP1_D <= VOUT_D;                    
                end loop;
                OP1_D <= X"FFFFFFFF";
                OP2_D <= X"0000003F";
                SEL_D <= "0001";
                wait for CLK_PERIOD / 130;
                assert(SIG_INVALID_D = '1')
                report("ERROR: SLL -> Wrong SIGN_INVALID Value.");
                assert(VOUT_D = STD_LOGIC_VECTOR(UNSIGNED(OP1_D) sll 31))
                report("ERROR: SLL value incorect");
                assert(VOUT_D(0) = '0')
                report("ERROR: SLL value incorect");
                OP1_D <= X"FFFFFFFF";
                OP2_D <= X"0000000E";
                SEL_D <= "0001";
                wait for CLK_PERIOD / 130;
                assert(SIG_INVALID_D = '0')
                report("ERROR: SLL -> Wrong SIGN_INVALID Value.");
                assert(VOUT_D = STD_LOGIC_VECTOR(UNSIGNED(OP1_D) sll 14))
                report("ERROR: SLL value incorect");
                assert(VOUT_D(0) = '0')
                report("ERROR: SLL value incorect");
            ------------------- TEST SRL --------------------------
            elsif(COUNTER < 9) then                
                OP1_D <= X"FFFFFFFF";
                OP2_D <= X"00000001";
                TEMP_SIG <= X"FFFFFFFF";
                SEL_D <= "0101";
                for i in 0 to 31 loop
                    if(i = 0) then
                        OP2_D <= X"00000000"; 
                    else 
                        OP2_D <= X"00000001";
                    end if;
                    wait for CLK_PERIOD / 130;
                    assert(SIG_INVALID_D = '0')
                    report("ERROR: SRL -> Wrong SIGN_INVALID Value.");
                    assert(VOUT_D = STD_LOGIC_VECTOR(UNSIGNED(TEMP_SIG) srl i))
                    report("ERROR: SRL value incorect 0");
                    if(i /= 0) then
                        assert(VOUT_D(31) = '0')
                        report("ERROR: SRL value incorect 1");
                    end if;
                    wait for CLK_PERIOD / 130;
                    OP1_D <= VOUT_D;                    
                end loop;
                OP1_D <= X"FFFFFFFF";
                OP2_D <= X"0000003F";
                SEL_D <= "0101";
                wait for CLK_PERIOD / 130;
                assert(SIG_INVALID_D = '1')
                report("ERROR: SRL -> Wrong SIGN_INVALID Value.");
                assert(VOUT_D = STD_LOGIC_VECTOR(UNSIGNED(OP1_D) srl 31))
                report("ERROR: SRL value incorect 2");
                assert(VOUT_D(31) = '0')
                report("ERROR: SRL value incorect 3");
                OP1_D <= X"FFFFFFFF";
                OP2_D <= X"0000000E";
                SEL_D <= "0101";
                wait for CLK_PERIOD / 130;
                assert(SIG_INVALID_D = '0')
                report("ERROR: SRL -> Wrong SIGN_INVALID Value.");
                assert(VOUT_D = STD_LOGIC_VECTOR(UNSIGNED(OP1_D) srl 14))
                report("ERROR: SRL value incorect 4");    
                assert(VOUT_D(31) = '0')
                report("ERROR: SRL value incorect 5");     
            ------------------- TEST SRA --------------------------
            elsif(COUNTER < 10) then                
                OP1_D <= X"FFFFFFFF";
                OP2_D <= X"00000001";
                TEMP_SIG <= X"FFFFFFFF";
                SEL_D <= "1000";
                for i in 0 to 31 loop
                    if(i = 0) then
                        OP2_D <= X"00000400"; 
                    else 
                        OP2_D <= X"00000401";
                    end if;
                    wait for CLK_PERIOD / 130;
                    assert(SIG_INVALID_D = '0')
                    report("ERROR: SRA -> Wrong SIGN_INVALID Value.");
                    assert(VOUT_D = to_stdlogicvector(to_bitvector(TEMP_SIG) sra i))
                    report("ERROR: SRA value incorect 0");
                    assert(VOUT_D(31) = '1')
                    report("ERROR: SRA value incorect 1");
                    wait for CLK_PERIOD / 130;
                    OP1_D <= VOUT_D;                    
                end loop;
                OP1_D <= X"0FFFFFFF";
                OP2_D <= X"0000043F";
                SEL_D <= "1000";
                wait for CLK_PERIOD / 66;
                assert(SIG_INVALID_D = '1')
                report("ERROR: SRA -> Wrong SIGN_INVALID Value.");
                assert(VOUT_D = to_stdlogicvector(to_bitvector(OP1_D) sra 31))
                report("ERROR: SRA value incorect 2");
                assert(VOUT_D(31) = '0')
                report("ERROR: SRA value incorect 3");
                OP1_D <= X"FFFFFFFF";
                OP2_D <= X"0000003F";
                SEL_D <= "1000";
                wait for CLK_PERIOD / 66;
                assert(SIG_INVALID_D = '1')
                report("ERROR: SRA -> Wrong SIGN_INVALID Value.");
                assert(VOUT_D = X"FFFFFFFF")
                report("ERROR: SRA value incorect 4");   
            -- INVALID
            elsif(COUNTER < 11) then               
                
                SEL_D <= "1010";
                wait for CLK_PERIOD / 6;
                assert(SIG_INVALID_D = '1')
                report("ERROR: INVALID -> Wrong SIGN_INVALID Value.");
                SEL_D <= "1011";
                wait for CLK_PERIOD / 6;
                assert(SIG_INVALID_D = '1')
                report("ERROR: INVALID -> Wrong SIGN_INVALID Value.");
                SEL_D <= "1100";
                wait for CLK_PERIOD / 6;
                assert(SIG_INVALID_D = '1')
                report("ERROR: INVALID -> Wrong SIGN_INVALID Value.");
                SEL_D <= "1101";
                wait for CLK_PERIOD / 6;
                assert(SIG_INVALID_D = '1')
                report("ERROR: INVALID -> Wrong SIGN_INVALID Value.");
                SEL_D <= "1110";
                wait for CLK_PERIOD / 6;
                assert(SIG_INVALID_D = '1')
                report("ERROR: INVALID -> Wrong SIGN_INVALID Value.");
                SEL_D <= "1111";
                wait for CLK_PERIOD / 6;
                assert(SIG_INVALID_D = '1')
                report("ERROR: INVALID -> Wrong SIGN_INVALID Value.");

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

end TB_ALU_MODULE_BEHAVE;
