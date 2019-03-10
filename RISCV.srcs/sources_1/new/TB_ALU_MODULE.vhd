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
    Port ( OP1 :      in STD_LOGIC_VECTOR(63 downto 0);
           OP2 :      in STD_LOGIC_VECTOR(63 downto 0);
           SEL :      in STD_LOGIC_VECTOR(5 downto 0);
           VOUT :     out STD_LOGIC_VECTOR(63 downto 0)
    );
end component;

signal OP1_D : STD_LOGIC_VECTOR(63 downto 0);
signal OP2_D : STD_LOGIC_VECTOR(63 downto 0);
signal SEL_D : STD_LOGIC_VECTOR(5 downto 0);
signal VOUT_D : STD_LOGIC_VECTOR(63 downto 0);
signal TEMP_SIG : STD_LOGIC_VECTOR(63 downto 0);

signal NOTIFY: STD_LOGIC;
signal COUNTER: INTEGER := 0;

constant CLK_PERIOD : time := 100ns;

begin

    ALU: ALU_MODULE Port Map (
        OP1 => OP1_D,
        OP2 => OP2_D,
        SEL => SEL_D,
        VOUT => VOUT_D
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
                    OP1_D <= X"000000000000040D";
                    OP2_D <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, OP2_D'length));
                    SEL_D <= "000000";
                    wait for CLK_PERIOD / 256;
                    assert(VOUT_D = STD_LOGIC_VECTOR(UNSIGNED(OP2_D) + UNSIGNED(OP1_D)))
                    report("ERROR: ADD value incorect");
                end loop;
                -- Overflow ADD
                OP1_D <= X"FFFFFFFFFFFFFFF1";
                OP2_D <= X"0000000000000000";
                wait for CLK_PERIOD / 10000000;
                for i in 0 to 128 loop                    
                    OP2_D <= STD_LOGIC_VECTOR(UNSIGNED(OP2_D) + 1);
                    SEL_D <= "000000";
                    wait for CLK_PERIOD / 256;
                    assert(VOUT_D = STD_LOGIC_VECTOR(UNSIGNED(OP2_D) + UNSIGNED(OP1_D)))
                    report("ERROR: ADD value incorect");
                end loop;
            ------------------- TEST SUBSTRACTION --------------------------
            elsif(COUNTER < 4) then                
                -- Normal SUB
                for i in 0 to 128 loop
                    OP1_D <= X"000000000000040D";
                    OP2_D <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, OP2_D'length));
                    SEL_D <= "001001";
                    wait for CLK_PERIOD / 256;
                    assert(VOUT_D = STD_LOGIC_VECTOR(SIGNED(OP1_D) - SIGNED(OP2_D)))
                    report("ERROR: SUB value incorect");
                end loop;
                -- Overflow SUB
                OP1_D <= X"0000000000000000";
                OP2_D <= X"0000000000000000";
                wait for CLK_PERIOD / 10000000;
                for i in 0 to 128 loop                    
                    OP2_D <= STD_LOGIC_VECTOR(UNSIGNED(OP2_D) + 1);
                    SEL_D <= "001001";
                    wait for CLK_PERIOD / 256;
                    assert(VOUT_D = STD_LOGIC_VECTOR(SIGNED(OP1_D) - SIGNED(OP2_D)))
                    report("ERROR: SUB value incorect");
                end loop;
             ------------------- TEST SLT --------------------------
             elsif(COUNTER < 5) then                
               -- SLT
                OP1_D <= X"000000000000040D";
                OP2_D <= X"F000000000000000";
                SEL_D <= "000010";
                wait for CLK_PERIOD / 5;
                assert(VOUT_D = X"0000000000000000")
                report("ERROR: SLT value incorect");
                OP1_D <= X"000000000000040D";
                OP2_D <= X"E000000000000000";
                SEL_D <= "000010";
                wait for CLK_PERIOD / 5;
                assert(VOUT_D = X"0000000000000000")
                report("ERROR: SLT value incorect");
                OP1_D <= X"EE0000000000040D";
                OP2_D <= X"F000000000000000";
                SEL_D <= "000010";
                wait for CLK_PERIOD / 5;
                assert(VOUT_D = X"0000000000000001")
                report("ERROR: SLT value incorect");
                OP1_D <= X"F00000000000040D";
                OP2_D <= X"7000000000000000";
                SEL_D <= "000010";
                wait for CLK_PERIOD / 5;
                assert(VOUT_D = X"0000000000000001")
                report("ERROR: SLT value incorect");
                OP1_D <= X"0000000000000012";
                OP2_D <= X"0000000000000112";
                SEL_D <= "000010";
                wait for CLK_PERIOD / 5;
                assert(VOUT_D = X"0000000000000001")
                report("ERROR: SLT value incorect");      
            ------------------- TEST SLTU --------------------------
            elsif(COUNTER < 6) then                
                OP1_D <= X"000000000000040D";
                OP2_D <= X"F000000000000000";
                SEL_D <= "000011";
                wait for CLK_PERIOD / 5;
                assert(VOUT_D = X"0000000000000001")
                report("ERROR: SLTU value incorect");
                OP1_D <= X"000000000000040D";
                OP2_D <= X"E000000000000000";
                SEL_D <= "000011";
                wait for CLK_PERIOD / 5;
                assert(VOUT_D = X"0000000000000001")
                report("ERROR: SLTU value incorect");
                OP1_D <= X"EE0000000000040D";
                OP2_D <= X"F000000000000000";
                SEL_D <= "000011";
                wait for CLK_PERIOD / 5;
                assert(VOUT_D = X"0000000000000001")
                report("ERROR: SLTU value incorect");
                OP1_D <= X"F00000000000040D";
                OP2_D <= X"7000000000000000";
                SEL_D <= "000011";
                wait for CLK_PERIOD / 5;
                assert(VOUT_D = X"0000000000000000")
                report("ERROR: SLTU value incorect");
                OP1_D <= X"0000000000000012";
                OP2_D <= X"0000000000000112";
                SEL_D <= "000011";
                wait for CLK_PERIOD / 5;
                assert(VOUT_D = X"0000000000000001")
                report("ERROR: SLTU value incorect");   
            ------------------- TEST AND OR XOR --------------------------
            elsif(COUNTER < 7) then                
                OP1_D <= X"AAAAAAAAAAAAAAAA";
                OP2_D <= X"55555555FFFFFFFF";
                SEL_D <= "000111";
                wait for CLK_PERIOD / 3;
                assert(VOUT_D = X"00000000AAAAAAAA")
                report("ERROR: AND value incorect");
                SEL_D <= "000110";
                wait for CLK_PERIOD / 3;
                assert(VOUT_D = X"FFFFFFFFFFFFFFFF")
                report("ERROR: OR value incorect");
                SEL_D <= "000100";
                wait for CLK_PERIOD / 3;
                assert(VOUT_D = X"FFFFFFFF55555555")
                report("ERROR: XOR value incorect");       
            ------------------- TEST SLL --------------------------
            elsif(COUNTER < 8) then                
                OP1_D <= X"FFFFFFFFFFFFFFFF";
                TEMP_SIG <= X"FFFFFFFFFFFFFFFF";
                OP2_D <= X"0000000000000001";
                SEL_D <= "000001";
                for i in 0 to 64 loop
                    if(i = 0) then
                        OP2_D <= X"0000000000000000"; 
                    else 
                        OP2_D <= X"0000000000000001";
                    end if;
                    wait for CLK_PERIOD / 130;
                    assert(VOUT_D = STD_LOGIC_VECTOR(UNSIGNED(TEMP_SIG) sll i))
                    report("ERROR: SLL value incorect 0");
                    if(i /= 0) then
                        assert(VOUT_D(0) = '0')
                        report("ERROR: SLL value incorect 1");
                    end if;
                    wait for CLK_PERIOD / 130;
                    OP1_D <= VOUT_D;                    
                end loop;
                OP1_D <= X"FFFFFFFFFFFFFFFF";
                OP2_D <= X"000000000000003F";
                SEL_D <= "000001";
                wait for CLK_PERIOD / 130;
                assert(VOUT_D = STD_LOGIC_VECTOR(UNSIGNED(OP1_D) sll 63))
                report("ERROR: SLL value incorect");
                assert(VOUT_D(0) = '0')
                report("ERROR: SLL value incorect");
                OP1_D <= X"FFFFFFFFFFFFFFFF";
                OP2_D <= X"000000000000000E";
                SEL_D <= "000001";
                wait for CLK_PERIOD / 130;
                assert(VOUT_D = STD_LOGIC_VECTOR(UNSIGNED(OP1_D) sll 14))
                report("ERROR: SLL value incorect");
                assert(VOUT_D(0) = '0')
                report("ERROR: SLL value incorect");
            ------------------- TEST SRL --------------------------
            elsif(COUNTER < 9) then                
                OP1_D <= X"FFFFFFFFFFFFFFFF";
                OP2_D <= X"0000000000000001";
                TEMP_SIG <= X"FFFFFFFFFFFFFFFF";
                SEL_D <= "000101";
                for i in 0 to 64 loop
                    if(i = 0) then
                        OP2_D <= X"0000000000000000"; 
                    else 
                        OP2_D <= X"0000000000000001";
                    end if;
                    wait for CLK_PERIOD / 130;
                    assert(VOUT_D = STD_LOGIC_VECTOR(UNSIGNED(TEMP_SIG) srl i))
                    report("ERROR: SRL value incorect 0");
                    if(i /= 0) then
                        assert(VOUT_D(63) = '0')
                        report("ERROR: SRL value incorect 1");
                    end if;
                    wait for CLK_PERIOD / 130;
                    OP1_D <= VOUT_D;                    
                end loop;
                OP1_D <= X"FFFFFFFFFFFFFFFF";
                OP2_D <= X"000000000000003F";
                SEL_D <= "000101";
                wait for CLK_PERIOD / 130;
                assert(VOUT_D = STD_LOGIC_VECTOR(UNSIGNED(OP1_D) srl 63))
                report("ERROR: SRL value incorect");
                assert(VOUT_D(63) = '0')
                report("ERROR: SRL value incorect");
                OP1_D <= X"FFFFFFFFFFFFFFFF";
                OP2_D <= X"000000000000000E";
                SEL_D <= "000101";
                wait for CLK_PERIOD / 130;
                assert(VOUT_D = STD_LOGIC_VECTOR(UNSIGNED(OP1_D) srl 14))
                report("ERROR: SRL value incorect");    
                assert(VOUT_D(63) = '0')
                report("ERROR: SRL value incorect");     
            ------------------- TEST SRA --------------------------
            elsif(COUNTER < 10) then                
                OP1_D <= X"FFFFFFFFFFFFFFFF";
                OP2_D <= X"0000000000000001";
                TEMP_SIG <= X"FFFFFFFFFFFFFFFF";
                SEL_D <= "001000";
                for i in 0 to 64 loop
                    if(i = 0) then
                        OP2_D <= X"0000000000000000"; 
                    else 
                        OP2_D <= X"0000000000000001";
                    end if;
                    wait for CLK_PERIOD / 130;
                    assert(VOUT_D = to_stdlogicvector(to_bitvector(TEMP_SIG) sra i))
                    report("ERROR: SRA value incorect 0");
                    assert(VOUT_D(63) = '1')
                    report("ERROR: SRA value incorect 1");
                    wait for CLK_PERIOD / 130;
                    OP1_D <= VOUT_D;                    
                end loop;
                OP1_D <= X"0FFFFFFFFFFFFFFF";
                OP2_D <= X"000000000000003F";
                SEL_D <= "001000";
                wait for CLK_PERIOD / 66;
                assert(VOUT_D = to_stdlogicvector(to_bitvector(OP1_D) sra 63))
                report("ERROR: SRA value incorect 2");
                assert(VOUT_D(63) = '0')
                report("ERROR: SRA value incorect 3");
                OP1_D <= X"FFFFFFFFFFFFFFFF";
                OP2_D <= X"000000000000003F";
                SEL_D <= "001000";
                wait for CLK_PERIOD / 66;
                assert(VOUT_D = X"FFFFFFFFFFFFFFFF")
                report("ERROR: SRA value incorect 4");     
            ------------------- TEST EQ --------------------------
            elsif(COUNTER < 11) then                
                OP1_D <= X"FFFFFFFF00000000";
                OP2_D <= X"00000000FFFFFFFF";
                SEL_D <= "001010";
                wait for CLK_PERIOD / 5;
                assert(VOUT_D = X"0000000000000000")
                report("ERROR: EQ value incorect");
                
                OP1_D <= X"00000000FFFFFFFF";
                OP2_D <= X"FFFFFFFF00000000";
                SEL_D <= "001010";
                wait for CLK_PERIOD / 5;
                assert(VOUT_D = X"0000000000000000")
                report("ERROR: EQ value incorect");
                
                OP1_D <= X"00000000FFFFFFFF";
                OP2_D <= X"00000000FFFFFFFF";
                SEL_D <= "001010";
                wait for CLK_PERIOD / 5;
                assert(VOUT_D = X"0000000000000001")
                report("ERROR: EQ value incorect");
                
                OP1_D <= X"FFFFFFFF00000000";
                OP2_D <= X"FFFFFFFF00000000";
                SEL_D <= "001010";
                wait for CLK_PERIOD / 5;
                assert(VOUT_D = X"0000000000000001")
                report("ERROR: EQ value incorect");
                
                OP1_D <= X"0000000000000012";
                OP2_D <= X"0000000000000112";
                SEL_D <= "001010";
                wait for CLK_PERIOD / 5;
                assert(VOUT_D = X"0000000000000000")
                report("ERROR: EQ value incorect");         
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
