----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.03.2019 14:16:14
-- Design Name: 
-- Module Name: TB_MEM_STAGE - Behavioral
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


entity TB_MEM_STAGE is
--  Port ( );
end TB_MEM_STAGE;

architecture Behavioral of TB_MEM_STAGE is

-- Dummy memory
component DUMMY_MEM is
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           REQ : in STD_LOGIC;
           REQ_TYPE : in STD_LOGIC;
           REQ_SIZE : in STD_LOGIC_VECTOR(1 downto 0);
           MEM_ADDR : in STD_LOGIC_VECTOR(63 downto 0);
           MEM_VALUE_IN : in STD_LOGIC_VECTOR(63 downto 0);
           MEM_VALUE_OUT : out STD_LOGIC_VECTOR(63 downto 0));
end component;

-- Mem stage
component MEM_STAGE is 
    Port ( DATA_OPERAND_IN :  in STD_LOGIC_VECTOR(63 downto 0);
           MEM_ADDR_IN :      in STD_LOGIC_VECTOR(63 downto 0);
           OP_TYPE :          in STD_LOGIC_VECTOR(3 downto 0);
           LSU_OP :           in STD_LOGIC_VECTOR(3 downto 0);
             
           MEM_LINK_VALUE_IN :  in STD_LOGIC_VECTOR(63 downto 0);
           MEM_LINK_VALUE_OUT : out STD_LOGIC_VECTOR(63 downto 0);
           MEM_LINK_ADDR :      out STD_LOGIC_VECTOR(63 downto 0);
           MEM_LINK_SIZE :      out STD_LOGIC_VECTOR(1 downto 0);
           MEM_LINK_REQ_TYPE :  out STD_LOGIC;
           MEM_LINK_REQ :       out STD_LOGIC;
                  
             
           DATA_OPERAND_OUT : out STD_LOGIC_VECTOR(63 downto 0);
           SIG_INVALID :      out STD_LOGIC    
      );
end component;

signal NOTIFIED : STD_LOGIC := '0';

signal CLK_D : STD_LOGIC := '0';
signal RST_D : STD_LOGIC := '0';

signal REQ_D : STD_LOGIC := '0';
signal REQ_TYPE_D : STD_LOGIC := '0';
signal REQ_SIZE_D : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
signal MEM_ADDR_D : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
signal MEM_VALUE_IN_D : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
signal MEM_VALUE_OUT_D : STD_LOGIC_VECTOR(63 downto 0) := (others=> '0');

signal DATA_OPERAND_IN_D : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
signal MEM_ADDR_IN_D : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
signal OP_TYPE_D : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
signal LSU_OP_D : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
signal DATA_OPERAND_OUT_D : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
signal SIG_INVALID_D : STD_LOGIC := '0';

signal COUNTER_D : integer := 0;
constant CLK_PERIOD : time := 10ns;

begin

    -- MAP Ports 
    MEM_MAP: DUMMY_MEM Port Map(
        CLK => CLK_D,
        RST => RST_D,
        REQ => REQ_D,
        REQ_TYPE => REQ_TYPE_D,
        REQ_SIZE => REQ_SIZE_D,
        MEM_ADDR => MEM_ADDR_D,
        MEM_VALUE_IN => MEM_VALUE_OUT_D,
        MEM_VALUE_OUT => MEM_VALUE_IN_D
    );

    STAGE_MAP: MEM_STAGE Port MAP ( 
           DATA_OPERAND_IN => DATA_OPERAND_IN_D,
           MEM_ADDR_IN => MEM_ADDR_IN_D,
           OP_TYPE => OP_TYPE_D,
           LSU_OP => LSU_OP_D,
             
           MEM_LINK_VALUE_IN => MEM_VALUE_IN_D,
           MEM_LINK_VALUE_OUT => MEM_VALUE_OUT_D,
           MEM_LINK_ADDR => MEM_ADDR_D,
           MEM_LINK_SIZE => REQ_SIZE_D,
           MEM_LINK_REQ_TYPE => REQ_TYPE_D,
           MEM_LINK_REQ => REQ_D,
                  
           DATA_OPERAND_OUT => DATA_OPERAND_OUT_D,
           SIG_INVALID => SIG_INVALID_D
      );   

    TEST_PROC_CLK: process
    begin
        CLK_D <= '0';
        wait for CLK_PERIOD / 2;
        CLK_D <= '1';
        wait for CLK_PERIOD / 2;
    end process TEST_PROC_CLK;
    
    TEST_PROC_RUN: process
    begin        
        if(COUNTER_D < 1) then -- RESET
            RST_D <= '1';
            wait for CLK_PERIOD;
        elsif(COUNTER_D < 2) then -- STOP RESET
            RST_D <= '0';
            wait for CLK_PERIOD;
        elsif(COUNTER_D < 3) then -- NON Mem OP type
            for i in 0 to 15 loop
                if(i /= 4 AND i /= 5) then
                    OP_TYPE_D <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, OP_TYPE_D'length));
                    DATA_OPERAND_IN_D <= X"F0F1F2F3F4F5F6F7";
                    WAIT FOR CLK_PERIOD;
                    assert(REQ_D = '0')
                    report "Error NON_MEM_OP -> Wrong MEM_LINK_REQ value.";
                    assert(SIG_INVALID_D = '0')
                    report "Error NON_MEM_OP -> Wrong SIG_INVALID value.";
                    assert(DATA_OPERAND_OUT_D = DATA_OPERAND_IN_D)
                    report "Error NON_MEM_OP -> Wrong DATA_OPERAND_OUT value.";
                end if;
            end loop;
        elsif(COUNTER_D < 4) then -- LB VALID
            OP_TYPE_D <= "0100";           
            DATA_OPERAND_IN_D <= X"F0F1F2F3F4F5F6F7";
            
            MEM_ADDR_IN_D <= X"00000000000000F0";
            LSU_OP_D <= "0000";
            WAIT FOR CLK_PERIOD;
            assert(REQ_D = '1')
            report "Error LOAD_MEM_OP BYTE -> Wrong MEM_LINK_REQ value.";
            assert(SIG_INVALID_D = '0')
            report "Error LOAD_MEM_OP BYTE -> Wrong SIG_INVALID value.";
            assert(DATA_OPERAND_OUT_D = X"FFFFFFFFFFFFFFF0")
            report "Error LOAD_MEM_OP BYTE -> Wrong DATA_OPERAND_OUT value.";
            assert(REQ_SIZE_D = "00")
            report "Error LOAD_MEM_OP BYTE -> Wrong MEM_LINK_SIZE value.";
            assert(REQ_TYPE_D = '0')
            report "Error LOAD_MEM_OP BYTE -> Wrong MEM_LINK_REQ_TYPE value.";
            assert(MEM_ADDR_D = X"00000000000000F0")
            report "Error LOAD_MEM_OP BYTE -> Wrong MEM_ADDR value.";

            MEM_ADDR_IN_D <= X"0000000000000001";
            LSU_OP_D <= "0000";
            WAIT FOR CLK_PERIOD;
            assert(REQ_D = '1')
            report "Error LOAD_MEM_OP BYTE -> Wrong MEM_LINK_REQ value.";
            assert(SIG_INVALID_D = '0')
            report "Error LOAD_MEM_OP BYTE -> Wrong SIG_INVALID value.";
            assert(DATA_OPERAND_OUT_D = X"0000000000000001")
            report "Error LOAD_MEM_OP BYTE -> Wrong DATA_OPERAND_OUT value.";
            assert(REQ_SIZE_D = "00")
            report "Error LOAD_MEM_OP BYTE -> Wrong MEM_LINK_SIZE value.";
            assert(REQ_TYPE_D = '0')
            report "Error LOAD_MEM_OP BYTE -> Wrong MEM_LINK_REQ_TYPE value.";
            assert(MEM_ADDR_D = X"0000000000000001")
            report "Error LOAD_MEM_OP BYTE -> Wrong MEM_ADDR value.";
            
        elsif(COUNTER_D < 5) then -- LH VALID
            OP_TYPE_D <= "0100";           
            DATA_OPERAND_IN_D <= X"F0F1F2F3F4F5F6F7";
            
            MEM_ADDR_IN_D <= X"00000000000000F0";
            LSU_OP_D <= "0001";
            WAIT FOR CLK_PERIOD;
            assert(REQ_D = '1')
            report "Error LOAD_MEM_OP HALF -> Wrong MEM_LINK_REQ value.";
            assert(SIG_INVALID_D = '0')
            report "Error LOAD_MEM_OP HALF -> Wrong SIG_INVALID value.";
            assert(DATA_OPERAND_OUT_D = X"FFFFFFFFFFFFF1F0")
            report "Error LOAD_MEM_OP HALF -> Wrong DATA_OPERAND_OUT value.";
            assert(REQ_SIZE_D = "01")
            report "Error LOAD_MEM_OP HALF -> Wrong MEM_LINK_SIZE value.";
            assert(REQ_TYPE_D = '0')
            report "Error LOAD_MEM_OP HALF -> Wrong MEM_LINK_REQ_TYPE value.";
            assert(MEM_ADDR_D = X"00000000000000F0")
            report "Error LOAD_MEM_OP HALF -> Wrong MEM_ADDR value.";

            MEM_ADDR_IN_D <= X"0000000000000001";
            LSU_OP_D <= "0001";
            WAIT FOR CLK_PERIOD;
            assert(REQ_D = '1')
            report "Error LOAD_MEM_OP HALF -> Wrong MEM_LINK_REQ value.";
            assert(SIG_INVALID_D = '0')
            report "Error LOAD_MEM_OP HALF -> Wrong SIG_INVALID value.";
            assert(DATA_OPERAND_OUT_D = X"0000000000000201")
            report "Error LOAD_MEM_OP HALF -> Wrong DATA_OPERAND_OUT value.";
            assert(REQ_SIZE_D = "01")
            report "Error LOAD_MEM_OP HALF -> Wrong MEM_LINK_SIZE value.";
            assert(REQ_TYPE_D = '0')
            report "Error LOAD_MEM_OP HALF -> Wrong MEM_LINK_REQ_TYPE value.";
            assert(MEM_ADDR_D = X"0000000000000001")
            report "Error LOAD_MEM_OP HALF -> Wrong MEM_ADDR value.";    
            
        elsif(COUNTER_D < 6) then -- LW VALID
            OP_TYPE_D <= "0100";           
            DATA_OPERAND_IN_D <= X"F0F1F2F3F4F5F6F7";
            
            MEM_ADDR_IN_D <= X"00000000000000F0";
            LSU_OP_D <= "0010";
            WAIT FOR CLK_PERIOD;
            assert(REQ_D = '1')
            report "Error LOAD_MEM_OP WORD -> Wrong MEM_LINK_REQ value.";
            assert(SIG_INVALID_D = '0')
            report "Error LOAD_MEM_OP WORD -> Wrong SIG_INVALID value.";
            assert(DATA_OPERAND_OUT_D = X"FFFFFFFFF3F2F1F0")
            report "Error LOAD_MEM_OP WORD -> Wrong DATA_OPERAND_OUT value.";
            assert(REQ_SIZE_D = "10")
            report "Error LOAD_MEM_OP WORD -> Wrong MEM_LINK_SIZE value.";
            assert(REQ_TYPE_D = '0')
            report "Error LOAD_MEM_OP WORD -> Wrong MEM_LINK_REQ_TYPE value.";
            assert(MEM_ADDR_D = X"00000000000000F0")
            report "Error LOAD_MEM_OP WORD -> Wrong MEM_ADDR value.";

            MEM_ADDR_IN_D <= X"0000000000000001";
            LSU_OP_D <= "0010";
            WAIT FOR CLK_PERIOD;
            assert(REQ_D = '1')
            report "Error LOAD_MEM_OP WORD -> Wrong MEM_LINK_REQ value.";
            assert(SIG_INVALID_D = '0')
            report "Error LOAD_MEM_OP WORD -> Wrong SIG_INVALID value.";
            assert(DATA_OPERAND_OUT_D = X"0000000004030201")
            report "Error LOAD_MEM_OP WORD -> Wrong DATA_OPERAND_OUT value.";
            assert(REQ_SIZE_D = "10")
            report "Error LOAD_MEM_OP WORD -> Wrong MEM_LINK_SIZE value.";
            assert(REQ_TYPE_D = '0')
            report "Error LOAD_MEM_OP WORD -> Wrong MEM_LINK_REQ_TYPE value.";
            assert(MEM_ADDR_D = X"0000000000000001")
            report "Error LOAD_MEM_OP WORD -> Wrong MEM_ADDR value.";
              
        elsif(COUNTER_D < 7) then -- LD VALID
            OP_TYPE_D <= "0100";           
            DATA_OPERAND_IN_D <= X"F0F1F2F3F4F5F6F7";
            
            MEM_ADDR_IN_D <= X"00000000000000F0";
            LSU_OP_D <= "0011";
            WAIT FOR CLK_PERIOD;
            assert(REQ_D = '1')
            report "Error LOAD_MEM_OP DOUBLE -> Wrong MEM_LINK_REQ value.";
            assert(SIG_INVALID_D = '0')
            report "Error LOAD_MEM_OP DOUBLE -> Wrong SIG_INVALID value.";
            assert(DATA_OPERAND_OUT_D = X"F7F6F5F4F3F2F1F0")
            report "Error LOAD_MEM_OP DOUBLE -> Wrong DATA_OPERAND_OUT value.";
            assert(REQ_SIZE_D = "11")
            report "Error LOAD_MEM_OP DOUBLE -> Wrong MEM_LINK_SIZE value.";
            assert(REQ_TYPE_D = '0')
            report "Error LOAD_MEM_OP DOUBLE -> Wrong MEM_LINK_REQ_TYPE value.";
            assert(MEM_ADDR_D = X"00000000000000F0")
            report "Error LOAD_MEM_OP DOUBLE -> Wrong MEM_ADDR value.";

            MEM_ADDR_IN_D <= X"0000000000000001";
            LSU_OP_D <= "0011";
            WAIT FOR CLK_PERIOD;
            assert(REQ_D = '1')
            report "Error LOAD_MEM_OP DOUBLE -> Wrong MEM_LINK_REQ value.";
            assert(SIG_INVALID_D = '0')
            report "Error LOAD_MEM_OP DOUBLE -> Wrong SIG_INVALID value.";
            assert(DATA_OPERAND_OUT_D = X"0807060504030201")
            report "Error LOAD_MEM_OP DOUBLE -> Wrong DATA_OPERAND_OUT value.";
            assert(REQ_SIZE_D = "11")
            report "Error LOAD_MEM_OP DOUBLE -> Wrong MEM_LINK_SIZE value.";
            assert(REQ_TYPE_D = '0')
            report "Error LOAD_MEM_OP DOUBLE -> Wrong MEM_LINK_REQ_TYPE value.";
            assert(MEM_ADDR_D = X"0000000000000001")
            report "Error LOAD_MEM_OP DOUBLE -> Wrong MEM_ADDR value.";  
            
        elsif(COUNTER_D < 8) then -- LBU VALID
            OP_TYPE_D <= "0100";           
            DATA_OPERAND_IN_D <= X"F0F1F2F3F4F5F6F7";
            
            MEM_ADDR_IN_D <= X"00000000000000F0";
            LSU_OP_D <= "0100";
            WAIT FOR CLK_PERIOD;
            assert(REQ_D = '1')
            report "Error LOAD_MEM_OP UBYTE -> Wrong MEM_LINK_REQ value.";
            assert(SIG_INVALID_D = '0')
            report "Error LOAD_MEM_OP UBYTE -> Wrong SIG_INVALID value.";
            assert(DATA_OPERAND_OUT_D = X"00000000000000F0")
            report "Error LOAD_MEM_OP UBYTE -> Wrong DATA_OPERAND_OUT value.";
            assert(REQ_SIZE_D = "00")
            report "Error LOAD_MEM_OP UBYTE -> Wrong MEM_LINK_SIZE value.";
            assert(REQ_TYPE_D = '0')
            report "Error LOAD_MEM_OP UBYTE -> Wrong MEM_LINK_REQ_TYPE value.";
            assert(MEM_ADDR_D = X"00000000000000F0")
            report "Error LOAD_MEM_OP UBYTE -> Wrong MEM_ADDR value.";

            MEM_ADDR_IN_D <= X"0000000000000001";
            LSU_OP_D <= "0100";
            WAIT FOR CLK_PERIOD;
            assert(REQ_D = '1')
            report "Error LOAD_MEM_OP UBYTE -> Wrong MEM_LINK_REQ value.";
            assert(SIG_INVALID_D = '0')
            report "Error LOAD_MEM_OP UBYTE -> Wrong SIG_INVALID value.";
            assert(DATA_OPERAND_OUT_D = X"0000000000000001")
            report "Error LOAD_MEM_OP UBYTE -> Wrong DATA_OPERAND_OUT value.";
            assert(REQ_SIZE_D = "00")
            report "Error LOAD_MEM_OP UBYTE -> Wrong MEM_LINK_SIZE value.";
            assert(REQ_TYPE_D = '0')
            report "Error LOAD_MEM_OP UBYTE -> Wrong MEM_LINK_REQ_TYPE value.";
            assert(MEM_ADDR_D = X"0000000000000001")
            report "Error LOAD_MEM_OP UBYTE -> Wrong MEM_ADDR value.";
            
        elsif(COUNTER_D < 9) then -- LHU VALID
            OP_TYPE_D <= "0100";           
            DATA_OPERAND_IN_D <= X"F0F1F2F3F4F5F6F7";
            
            MEM_ADDR_IN_D <= X"00000000000000F0";
            LSU_OP_D <= "0101";
            WAIT FOR CLK_PERIOD;
            assert(REQ_D = '1')
            report "Error LOAD_MEM_OP UHALF -> Wrong MEM_LINK_REQ value.";
            assert(SIG_INVALID_D = '0')
            report "Error LOAD_MEM_OP UHALF -> Wrong SIG_INVALID value.";
            assert(DATA_OPERAND_OUT_D = X"000000000000F1F0")
            report "Error LOAD_MEM_OP UHALF -> Wrong DATA_OPERAND_OUT value.";
            assert(REQ_SIZE_D = "01")
            report "Error LOAD_MEM_OP UHALF -> Wrong MEM_LINK_SIZE value.";
            assert(REQ_TYPE_D = '0')
            report "Error LOAD_MEM_OP UHALF -> Wrong MEM_LINK_REQ_TYPE value.";
            assert(MEM_ADDR_D = X"00000000000000F0")
            report "Error LOAD_MEM_OP UHALF -> Wrong MEM_ADDR value.";

            MEM_ADDR_IN_D <= X"0000000000000001";
            LSU_OP_D <= "0101";
            WAIT FOR CLK_PERIOD;
            assert(REQ_D = '1')
            report "Error LOAD_MEM_OP UHALF -> Wrong MEM_LINK_REQ value.";
            assert(SIG_INVALID_D = '0')
            report "Error LOAD_MEM_OP UHALF -> Wrong SIG_INVALID value.";
            assert(DATA_OPERAND_OUT_D = X"0000000000000201")
            report "Error LOAD_MEM_OP UHALF -> Wrong DATA_OPERAND_OUT value.";
            assert(REQ_SIZE_D = "01")
            report "Error LOAD_MEM_OP UHALF -> Wrong MEM_LINK_SIZE value.";
            assert(REQ_TYPE_D = '0')
            report "Error LOAD_MEM_OP UHALF -> Wrong MEM_LINK_REQ_TYPE value.";
            assert(MEM_ADDR_D = X"0000000000000001")
            report "Error LOAD_MEM_OP UHALF -> Wrong MEM_ADDR value.";    
            
        elsif(COUNTER_D < 10) then -- LWU VALID
            OP_TYPE_D <= "0100";           
            DATA_OPERAND_IN_D <= X"F0F1F2F3F4F5F6F7";
            
            MEM_ADDR_IN_D <= X"00000000000000F0";
            LSU_OP_D <= "0110";
            WAIT FOR CLK_PERIOD;
            assert(REQ_D = '1')
            report "Error LOAD_MEM_OP UWORD -> Wrong MEM_LINK_REQ value.";
            assert(SIG_INVALID_D = '0')
            report "Error LOAD_MEM_OP UWORD -> Wrong SIG_INVALID value.";
            assert(DATA_OPERAND_OUT_D = X"00000000F3F2F1F0")
            report "Error LOAD_MEM_OP UWORD -> Wrong DATA_OPERAND_OUT value.";
            assert(REQ_SIZE_D = "10")
            report "Error LOAD_MEM_OP UWORD -> Wrong MEM_LINK_SIZE value.";
            assert(REQ_TYPE_D = '0')
            report "Error LOAD_MEM_OP UWORD -> Wrong MEM_LINK_REQ_TYPE value.";
            assert(MEM_ADDR_D = X"00000000000000F0")
            report "Error LOAD_MEM_OP UWORD -> Wrong MEM_ADDR value.";

            MEM_ADDR_IN_D <= X"0000000000000001";
            LSU_OP_D <= "0110";
            WAIT FOR CLK_PERIOD;
            assert(REQ_D = '1')
            report "Error LOAD_MEM_OP UWORD -> Wrong MEM_LINK_REQ value.";
            assert(SIG_INVALID_D = '0')
            report "Error LOAD_MEM_OP UWORD -> Wrong SIG_INVALID value.";
            assert(DATA_OPERAND_OUT_D = X"0000000004030201")
            report "Error LOAD_MEM_OP UWORD -> Wrong DATA_OPERAND_OUT value.";
            assert(REQ_SIZE_D = "10")
            report "Error LOAD_MEM_OP UWORD -> Wrong MEM_LINK_SIZE value.";
            assert(REQ_TYPE_D = '0')
            report "Error LOAD_MEM_OP UWORD -> Wrong MEM_LINK_REQ_TYPE value.";
            assert(MEM_ADDR_D = X"0000000000000001")
            report "Error LOAD_MEM_OP UWORD -> Wrong MEM_ADDR value."; 
                        
        elsif(COUNTER_D < 11) then -- Load INVALID
            OP_TYPE_D <= "0100";           
            DATA_OPERAND_IN_D <= X"F0F1F2F3F4F5F6F7";
            
            MEM_ADDR_IN_D <= X"00000000000000F0";
            for i in 7 to 15 loop
                LSU_OP_D <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, LSU_OP_D'length));
                WAIT FOR CLK_PERIOD;
                assert(REQ_D = '0')
                report "Error LOAD_MEM_OP INVALID -> Wrong MEM_LINK_REQ value.";
                assert(SIG_INVALID_D = '1')
                report "Error LOAD_MEM_OP INVALID -> Wrong SIG_INVALID value.";
            end loop;
            
        elsif(COUNTER_D < 12) then -- SB VALID
            OP_TYPE_D <= "0101";           
            DATA_OPERAND_IN_D <= X"F0F1F2F3F4F5F6F7";
            
            MEM_ADDR_IN_D <= X"00000000000000F0";
            LSU_OP_D <= "1000";
            WAIT FOR CLK_PERIOD;
            assert(REQ_D = '1')
            report "Error STORE_MEM_OP BYTE -> Wrong MEM_LINK_REQ value.";
            assert(SIG_INVALID_D = '0')
            report "Error STORE_MEM_OP BYTE -> Wrong SIG_INVALID value.";
            assert(DATA_OPERAND_OUT_D = X"F0F1F2F3F4F5F6F7")
            report "Error STORE_MEM_OP BYTE -> Wrong DATA_OPERAND_OUT value.";
            assert(REQ_SIZE_D = "00")
            report "Error STORE_MEM_OP BYTE -> Wrong MEM_LINK_SIZE value.";
            assert(REQ_TYPE_D = '1')
            report "Error STORE_MEM_OP BYTE -> Wrong MEM_LINK_REQ_TYPE value.";
            assert(MEM_ADDR_D = X"00000000000000F0")
            report "Error STORE_MEM_OP BYTE -> Wrong MEM_ADDR value.";
            assert(MEM_VALUE_OUT_D = X"00000000000000F7")
            report "Error STORE_MEM_OP BYTE -> Wrong MEM_LINK_VALUE_OUT value.";  
            
        elsif(COUNTER_D < 13) then -- SH VALID
            OP_TYPE_D <= "0101";           
            DATA_OPERAND_IN_D <= X"F0F1F2F3F4F5F6F7";
            
            MEM_ADDR_IN_D <= X"00000000000000F0";
            LSU_OP_D <= "1001";
            WAIT FOR CLK_PERIOD;
            assert(REQ_D = '1')
            report "Error STORE_MEM_OP HALF -> Wrong MEM_LINK_REQ value.";
            assert(SIG_INVALID_D = '0')
            report "Error STORE_MEM_OP HALF -> Wrong SIG_INVALID value.";
            assert(DATA_OPERAND_OUT_D = X"F0F1F2F3F4F5F6F7")
            report "Error STORE_MEM_OP HALF -> Wrong DATA_OPERAND_OUT value.";
            assert(REQ_SIZE_D = "01")
            report "Error STORE_MEM_OP HALF -> Wrong MEM_LINK_SIZE value.";
            assert(REQ_TYPE_D = '1')
            report "Error STORE_MEM_OP HALF -> Wrong MEM_LINK_REQ_TYPE value.";
            assert(MEM_ADDR_D = X"00000000000000F0")
            report "Error STORE_MEM_OP HALF -> Wrong MEM_ADDR value.";
            assert(MEM_VALUE_OUT_D = X"000000000000F6F7")
            report "Error STORE_MEM_OP HALF -> Wrong MEM_LINK_VALUE_OUT value.";  
            
        elsif(COUNTER_D < 14) then -- SW VALID
            OP_TYPE_D <= "0101";           
            DATA_OPERAND_IN_D <= X"F0F1F2F3F4F5F6F7";
            
            MEM_ADDR_IN_D <= X"00000000000000F0";
            LSU_OP_D <= "1010";
            WAIT FOR CLK_PERIOD;
            assert(REQ_D = '1')
            report "Error STORE_MEM_OP WORD -> Wrong MEM_LINK_REQ value.";
            assert(SIG_INVALID_D = '0')
            report "Error STORE_MEM_OP WORD -> Wrong SIG_INVALID value.";
            assert(DATA_OPERAND_OUT_D = X"F0F1F2F3F4F5F6F7")
            report "Error STORE_MEM_OP WORD -> Wrong DATA_OPERAND_OUT value.";
            assert(REQ_SIZE_D = "10")
            report "Error STORE_MEM_OP WORD -> Wrong MEM_LINK_SIZE value.";
            assert(REQ_TYPE_D = '1')
            report "Error STORE_MEM_OP WORD -> Wrong MEM_LINK_REQ_TYPE value.";
            assert(MEM_ADDR_D = X"00000000000000F0")
            report "Error STORE_MEM_OP WORD -> Wrong MEM_ADDR value.";
            assert(MEM_VALUE_OUT_D = X"00000000F4F5F6F7")
            report "Error STORE_MEM_OP WORD -> Wrong MEM_LINK_VALUE_OUT value.";  
            
        elsif(COUNTER_D < 15) then -- SD VALID
            OP_TYPE_D <= "0101";           
            DATA_OPERAND_IN_D <= X"F0F1F2F3F4F5F6F7";
            
            MEM_ADDR_IN_D <= X"00000000000000F0";
            LSU_OP_D <= "1011";
            WAIT FOR CLK_PERIOD;
            assert(REQ_D = '1')
            report "Error STORE_MEM_OP DOUBLE -> Wrong MEM_LINK_REQ value.";
            assert(SIG_INVALID_D = '0')
            report "Error STORE_MEM_OP DOUBLE -> Wrong SIG_INVALID value.";
            assert(DATA_OPERAND_OUT_D = X"F0F1F2F3F4F5F6F7")
            report "Error STORE_MEM_OP DOUBLE -> Wrong DATA_OPERAND_OUT value.";
            assert(REQ_SIZE_D = "11")
            report "Error STORE_MEM_OP DOUBLE -> Wrong MEM_LINK_SIZE value.";
            assert(REQ_TYPE_D = '1')
            report "Error STORE_MEM_OP DOUBLE -> Wrong MEM_LINK_REQ_TYPE value.";
            assert(MEM_ADDR_D = X"00000000000000F0")
            report "Error STORE_MEM_OP DOUBLE -> Wrong MEM_ADDR value.";
            assert(MEM_VALUE_OUT_D = X"F0F1F2F3F4F5F6F7")
            report "Error STORE_MEM_OP DOUBLE -> Wrong MEM_LINK_VALUE_OUT value.";
            
        elsif(COUNTER_D < 16) then -- Store INVALID
            OP_TYPE_D <= "0101";           
            DATA_OPERAND_IN_D <= X"F0F1F2F3F4F5F6F7";
            
            MEM_ADDR_IN_D <= X"00000000000000F0";
            for i in 0 to 15 loop
                if(i /= 8 and i /= 9 and i /= 10 and i /= 11) then
                    LSU_OP_D <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, LSU_OP_D'length));
                    WAIT FOR CLK_PERIOD;
                    assert(REQ_D = '0')
                    report "Error STORE_MEM_OP INVALID -> Wrong MEM_LINK_REQ value.";
                    assert(SIG_INVALID_D = '1')
                    report "Error STORE_MEM_OP INVALID -> Wrong SIG_INVALID value.";
                end if;
            end loop;                                        
        elsif(NOTIFIED = '0') then
            report "INFO: Test finished" severity note;
            NOTIFIED <= '1';
            wait for CLK_PERIOD;
        end if;
    
        COUNTER_D <= COUNTER_D + 1;
        
    end process TEST_PROC_RUN;
end Behavioral;
