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
    Port ( INSTRUCTION_DATA : in STD_LOGIC_VECTOR (63 downto 0);
           OPCODE :           out STD_LOGIC_VECTOR(6 downto 0);
           RD :               out STD_LOGIC_VECTOR(4 downto 0);
           RS1 :              out STD_LOGIC_VECTOR(4 downto 0);
           RS2 :              out STD_LOGIC_VECTOR(4 downto 0);
           FUNCT3 :           out STD_LOGIC_VECTOR(2 downto 0);
           FUNCT7 :           out STD_LOGIC_VECTOR(6 downto 0);
           IMM_I :            out STD_LOGIC_VECTOR(31 downto 0);
           IMM_S :            out STD_LOGIC_VECTOR(31 downto 0);
           IMM_B :            out STD_LOGIC_VECTOR(31 downto 0);
           IMM_U :            out STD_LOGIC_VECTOR(31 downto 0);
           IMM_J :            out STD_LOGIC_VECTOR(31 downto 0);
           SIG_INVALID :      out STD_LOGIC
    );
end component;

signal INSTRUCTION_DATA_D : STD_LOGIC_VECTOR(63 downto 0);
signal OPCODE_D :           STD_LOGIC_VECTOR(6 downto 0);
signal RD_D :               STD_LOGIC_VECTOR(4 downto 0);
signal RS1_D :              STD_LOGIC_VECTOR(4 downto 0);
signal RS2_D :              STD_LOGIC_VECTOR(4 downto 0);
signal FUNCT3_D :           STD_LOGIC_VECTOR(2 downto 0);
signal FUNCT7_D :           STD_LOGIC_VECTOR(6 downto 0);
signal IMM_I_D :            STD_LOGIC_VECTOR(31 downto 0);
signal IMM_S_D :            STD_LOGIC_VECTOR(31 downto 0);
signal IMM_B_D :            STD_LOGIC_VECTOR(31 downto 0);
signal IMM_U_D :            STD_LOGIC_VECTOR(31 downto 0);
signal IMM_J_D :            STD_LOGIC_VECTOR(31 downto 0);
signal SIG_INVALID_D :      STD_LOGIC;

signal OP_DATA : STD_LOGIC_VECTOR(6 downto 0);
signal REG_DATA : STD_LOGIC_VECTOR(4 downto 0);
signal FUNCT3_DATA : STD_LOGIC_VECTOR(2 downto 0);
signal FUNCT7_DATA : STD_LOGIC_VECTOR(6 downto 0);

signal IMM_I_DATA : STD_LOGIC_VECTOR(11 downto 0);
signal IMM_S_DATA : STD_LOGIC_VECTOR(11 downto 0);
signal IMM_B_DATA : STD_LOGIC_VECTOR(11 downto 0);
signal IMM_U_DATA : STD_LOGIC_VECTOR(19 downto 0);
signal IMM_J_DATA : STD_LOGIC_VECTOR(19 downto 0);

signal NOTIFY: STD_LOGIC;

signal COUNTER: INTEGER := 0;

constant CLK_PERIOD : time := 10ns;

begin
    
     ID: ID_STAGE Port Map(
      INSTRUCTION_DATA => INSTRUCTION_DATA_D,
      OPCODE => OPCODE_D,
      RD => RD_D,
      RS1 => RS1_D,
      RS2 => RS2_D,
      FUNCT3 => FUNCT3_D,
      FUNCT7 => FUNCT7_D,
      IMM_I => IMM_I_D,
      IMM_S => IMM_S_D,
      IMM_B => IMM_B_D,
      IMM_U => IMM_U_D,
      IMM_J => IMM_J_D,
      SIG_INVALID => SIG_INVALID_D
   );
    
    TEST_CLK_DRIVE: process
    begin             
        for i in 0 to 512 loop
            -- Init
            if(COUNTER < 1) then
                OP_DATA <= (others => '1');
                REG_DATA <= (others => '1');
                FUNCT3_DATA <= (others => '1');
                FUNCT7_DATA <= (others => '1');
                IMM_I_DATA <= (others => '1');
                IMM_S_DATA <= (others => '1');
                IMM_B_DATA <= (others => '1');
                IMM_U_DATA <= (others => '1');
                IMM_J_DATA <= (others => '1');
                NOTIFY <= '0';
                wait for CLK_PERIOD;
            -- Test invalid 
            elsif(COUNTER < 130) then
                OP_DATA <= STD_LOGIC_VECTOR(UNSIGNED(OP_DATA) + 1);
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
            -- Test RD
            elsif(COUNTER < 132) then
                INSTRUCTION_DATA_D <= (others => '1');
                
                for i in 0 to 31 loop
                    REG_DATA <= STD_LOGIC_VECTOR(UNSIGNED(REG_DATA) + 1);
                    wait for CLK_PERIOD / 64;
                    INSTRUCTION_DATA_D(11 downto 7) <= REG_DATA;                
                    wait for CLK_PERIOD / 64;
                    
                    assert(RD_D = REG_DATA)
                    report "ERROR: Wrong RD Value.";                
                end loop;
            -- Test funct3
            elsif(COUNTER < 134) then
                INSTRUCTION_DATA_D <= (others => '1');
                
                for i in 0 to 7 loop
                    FUNCT3_DATA <= STD_LOGIC_VECTOR(UNSIGNED(FUNCT3_DATA) + 1);
                    wait for CLK_PERIOD / 16;
                    INSTRUCTION_DATA_D(14 downto 12) <= FUNCT3_DATA;                
                    wait for CLK_PERIOD / 16;
                    
                    assert(FUNCT3_D = FUNCT3_DATA)
                    report "ERROR: Wrong FUNCT3 Value.";                
                end loop;
            
            -- Test RS1
            elsif(COUNTER < 136) then
                INSTRUCTION_DATA_D <= (others => '1');
                
                for i in 0 to 31 loop
                    REG_DATA <= STD_LOGIC_VECTOR(UNSIGNED(REG_DATA) + 1);
                    wait for CLK_PERIOD / 64;
                    INSTRUCTION_DATA_D(19 downto 15) <= REG_DATA;                
                    wait for CLK_PERIOD / 64;
                    
                    assert(RS1_D = REG_DATA)
                    report "ERROR: Wrong RS1 Value.";                
                end loop;
            
            -- Test RS2
            elsif(COUNTER < 138) then
                INSTRUCTION_DATA_D <= (others => '1');
                
                for i in 0 to 31 loop
                    REG_DATA <= STD_LOGIC_VECTOR(UNSIGNED(REG_DATA) + 1);
                    wait for CLK_PERIOD / 64;
                    INSTRUCTION_DATA_D(24 downto 20) <= REG_DATA;                
                    wait for CLK_PERIOD / 64;
                    
                    assert(RS2_D = REG_DATA)
                    report "ERROR: Wrong RS2 Value.";                
                end loop;
                
            -- Test funct7
            elsif(COUNTER < 140) then
                INSTRUCTION_DATA_D <= (others => '1');
                
                for i in 0 to 31 loop
                    FUNCT7_DATA <= STD_LOGIC_VECTOR(UNSIGNED(FUNCT7_DATA) + 1);
                    wait for CLK_PERIOD / 64;
                    INSTRUCTION_DATA_D(31 downto 25) <= FUNCT7_DATA;                
                    wait for CLK_PERIOD / 64;
                    
                    assert(FUNCT7_D = FUNCT7_DATA)
                    report "ERROR: Wrong FUNCT7 Value.";                
                end loop;
            
            -- Test IMM_I
            elsif(COUNTER < 142) then
                INSTRUCTION_DATA_D <= (others => '1');
                
                for i in 0 to 4095 loop
                    IMM_I_DATA <= STD_LOGIC_VECTOR(UNSIGNED(IMM_I_DATA) + 1);
                    wait for CLK_PERIOD / 8192;
                    INSTRUCTION_DATA_D(31 downto 20) <= IMM_I_DATA;                
                    wait for CLK_PERIOD / 8192;
                    
                    assert(IMM_I_D(11 downto 0) = IMM_I_DATA)
                    report "ERROR: Wrong IMM_I Value.";       
                    for j in 11 to 31 loop
                        assert(IMM_I_D(j) = IMM_I_DATA(11))
                        report "ERROR: Wrong EXT IMM_I Value.";   
                    end loop;
                           
                end loop;
            
            -- Test IMM_S 
            elsif(COUNTER < 144) then
                INSTRUCTION_DATA_D <= (others => '1');
                
                for i in 0 to 4095 loop
                    IMM_S_DATA <= STD_LOGIC_VECTOR(UNSIGNED(IMM_S_DATA) + 1);
                    wait for CLK_PERIOD / 8192;
                    INSTRUCTION_DATA_D(31 downto 25) <= IMM_S_DATA(11 downto 5);  
                    INSTRUCTION_DATA_D(11 downto 7) <= IMM_S_DATA(4 downto 0);               
                    wait for CLK_PERIOD / 8192;
                    
                    assert(IMM_S_D(11 downto 0) = IMM_S_DATA)
                    report "ERROR: Wrong IMM_S Value.";       
                    for j in 11 to 31 loop
                        assert(IMM_S_D(j) = IMM_S_DATA(11))
                        report "ERROR: Wrong EXT IMM_S Value.";   
                    end loop;
                           
                end loop;
            
            -- Test IMM_B
            elsif(COUNTER < 148) then
                INSTRUCTION_DATA_D <= (others => '1');
                
                for i in 0 to 4095 loop
                    IMM_B_DATA <= STD_LOGIC_VECTOR(UNSIGNED(IMM_B_DATA) + 1);
                    wait for CLK_PERIOD / 8192;
                    INSTRUCTION_DATA_D(7) <= IMM_B_DATA(10);  
                    INSTRUCTION_DATA_D(11 downto 8) <= IMM_B_DATA(3 downto 0);      
                    INSTRUCTION_DATA_D(30 downto 25) <= IMM_B_DATA(9 downto 4);         
                    INSTRUCTION_DATA_D(31) <= IMM_B_DATA(11);   
                    wait for CLK_PERIOD / 8192;
                    
                    assert(IMM_B_D(0) = '0')
                    report "ERROR: Wrong IMM_B 0 Value.";
                    assert(IMM_B_D(11 downto 1) = IMM_B_DATA(10 downto 0))                  
                    report "ERROR: Wrong IMM_B Value.";       
                    for j in 12 to 31 loop
                        assert(IMM_B_D(j) = IMM_B_DATA(11))
                        report "ERROR: Wrong EXT IMM_B Value.";   
                    end loop;
                           
                end loop;
            
            -- Test IMM_U
            elsif(COUNTER < 150) then
                INSTRUCTION_DATA_D <= (others => '1');
                
                for i in 0 to 4095 loop
                    IMM_U_DATA <= STD_LOGIC_VECTOR(UNSIGNED(IMM_U_DATA) + 1);
                    wait for CLK_PERIOD / 8192;
                    INSTRUCTION_DATA_D(31 downto 12) <= IMM_U_DATA;   
                    wait for CLK_PERIOD / 8192;
                    
                    assert(IMM_U_D(11 downto 0) = "000000000000")
                    report "ERROR: Wrong IMM_U 0 Value.";
                    assert(IMM_U_D(31 downto 12) = IMM_U_DATA(19 downto 0))                
                    report "ERROR: Wrong IMM_U Value.";
                           
                end loop;
            
            -- Test IMM_J
            elsif(COUNTER < 152) then
                INSTRUCTION_DATA_D <= (others => '1');
                
                for i in 0 to 4095 loop
                    IMM_J_DATA <= STD_LOGIC_VECTOR(UNSIGNED(IMM_J_DATA) + 1);
                    wait for CLK_PERIOD / 8192;
                    INSTRUCTION_DATA_D(19 downto 12) <= IMM_J_DATA(18 downto 11);
                    INSTRUCTION_DATA_D(20) <= IMM_J_DATA(10);
                    INSTRUCTION_DATA_D(30 downto 21) <= IMM_J_DATA(9 downto 0);
                    INSTRUCTION_DATA_D(31) <= IMM_J_DATA(19);
                    wait for CLK_PERIOD / 8192;
                    
                    assert(IMM_J_D(0) = '0')
                    report "ERROR: Wrong IMM_J 0 Value.";
                    assert(IMM_J_D(19 downto 1) = IMM_J_DATA(18 downto 0))                
                    report "ERROR: Wrong IMM_J Value.";
                    for j in 20 to 31 loop
                        assert(IMM_J_D(j) = IMM_J_DATA(19))
                        report "ERROR: Wrong EXT IMM_J Value.";   
                    end loop;
                           
                end loop;
            
            elsif (NOTIFY = '0') then
                NOTIFY <= '1';
                report "Test finished" severity note;   
                wait for CLK_PERIOD / 2;
            else 
                wait for CLK_PERIOD;
            end if;
            
            COUNTER <= COUNTER + 1;
            
        end loop;        
    end process;

end TB_ID_STAGE_BEHAVE;
