----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.03.2019 20:48:27
-- Design Name: 
-- Module Name: TB_THREAD - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TB_THREAD is
--  Port ( );
end TB_THREAD;

architecture Behavioral of TB_THREAD is

constant CLK_PERIOD : time := 10ns;
signal   counter : integer := 0;

component DUMMY_MEM is
    generic(MEM_FILE : string := "inst.txt");
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           REQ : in STD_LOGIC;
           REQ_TYPE : in STD_LOGIC;
           REQ_SIZE : in STD_LOGIC_VECTOR(1 downto 0);
           MEM_ADDR : in STD_LOGIC_VECTOR(31 downto 0);
           MEM_VALUE_IN : in STD_LOGIC_VECTOR(31 downto 0);
           MEM_VALUE_OUT : out STD_LOGIC_VECTOR(31 downto 0)
           );
end component;

COMPONENT THREAD IS
    PORT ( -- Usual signals
           CLK :   IN STD_LOGIC;
           RST :   IN STD_LOGIC;
           STALL : IN STD_LOGIC;
           
           -- Exception signals
           SIG_ALIGN :   OUT STD_LOGIC;
           SIG_INVALID : OUT STD_LOGIC;
           
           -- Intruction memory link 
           INST_MEM_IN :       IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           INST_MEM_OUT :      OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           INST_MEM_ADDR :     OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           INST_MEM_REQ_SIZE : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
           INST_MEM_REQ_TYPE : OUT STD_LOGIC;
           INST_MEM_REQ :      OUT STD_LOGIC;
           
           -- Data memory link
           DATA_MEM_IN :       IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           DATA_MEM_OUT :      OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           DATA_MEM_ADDR :     OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           DATA_MEM_REQ_SIZE : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
           DATA_MEM_REQ_TYPE : OUT STD_LOGIC;
           DATA_MEM_REQ :      OUT STD_LOGIC
           
    );
END COMPONENT THREAD;

SIGNAL CLK_D : STD_LOGIC := '0';
SIGNAL RST_D : STD_LOGIC := '0';
SIGNAL STALL_D : STD_LOGIC := '0';
SIGNAL SIG_ALIGN_D : STD_LOGIC := '0';
SIGNAL SIG_INVALID_D : STD_LOGIC := '0';

SIGNAL INST_REQ_D : STD_LOGIC;
SIGNAL INST_REQ_TYPE_D : STD_LOGIC;
SIGNAL INST_REQ_SIZE_D : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL INST_MEM_ADDR_D : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL INST_MEM_VALUE_IN_D : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL INST_MEM_VALUE_OUT_D : STD_LOGIC_VECTOR(31 DOWNTO 0);

SIGNAL DATA_REQ_D : STD_LOGIC;
SIGNAL DATA_REQ_TYPE_D : STD_LOGIC;
SIGNAL DATA_REQ_SIZE_D : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL DATA_MEM_ADDR_D : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL DATA_MEM_VALUE_IN_D : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL DATA_MEM_VALUE_OUT_D : STD_LOGIC_VECTOR(31 DOWNTO 0);

begin

DUMMY_MEM_INST : DUMMY_MEM
    GENERIC MAP(MEM_FILE => "inst.txt")
    PORT MAP(
    CLK => CLK_D,
    RST => RST_D,
    REQ => INST_REQ_D,
    REQ_TYPE => INST_REQ_TYPE_D,
    REQ_SIZE => INST_REQ_SIZE_D,
    MEM_ADDR => INST_MEM_ADDR_D,
    MEM_VALUE_IN => INST_MEM_VALUE_IN_D,
    MEM_VALUE_OUT => INST_MEM_VALUE_OUT_D
);

DUMMY_MEM_DATA : DUMMY_MEM 
    GENERIC MAP(MEM_FILE => "DATA_RAM.txt")
    PORT MAP(
        CLK => CLK_D,
        RST => RST_D,
        REQ => DATA_REQ_D,
        REQ_TYPE => DATA_REQ_TYPE_D,
        REQ_SIZE => DATA_REQ_SIZE_D,
        MEM_ADDR => DATA_MEM_ADDR_D,
        MEM_VALUE_IN => DATA_MEM_VALUE_IN_D,
        MEM_VALUE_OUT => DATA_MEM_VALUE_OUT_D
    );

THREAD_MAP : THREAD PORT MAP(
   CLK => CLK_D,
   RST => RST_D,
   STALL => STALL_D,
   
   -- Exception signals
   SIG_ALIGN => SIG_ALIGN_D,
   SIG_INVALID => SIG_INVALID_D,
   
  
  -- Intruction memory link 
  INST_MEM_IN => INST_MEM_VALUE_OUT_D,
  INST_MEM_OUT => INST_MEM_VALUE_IN_D,
  INST_MEM_ADDR => INST_MEM_ADDR_D,
  INST_MEM_REQ_SIZE => INST_REQ_SIZE_D,
  INST_MEM_REQ_TYPE => INST_REQ_TYPE_D,
  INST_MEM_REQ => INST_REQ_D,
  
  -- Data memory link
  DATA_MEM_IN => DATA_MEM_VALUE_OUT_D,
  DATA_MEM_OUT => DATA_MEM_VALUE_IN_D,
  DATA_MEM_ADDR => DATA_MEM_ADDR_D,
  DATA_MEM_REQ_SIZE => DATA_REQ_SIZE_D,
  DATA_MEM_REQ_TYPE => DATA_REQ_TYPE_D,
  DATA_MEM_REQ => DATA_REQ_D 
);

CLK_PROC : process
begin
    CLK_D <= '0';
    WAIT FOR CLK_PERIOD / 2;
    CLK_D <= '1';
    WAIT FOR CLK_PERIOD / 2;
end process;

process(CLK_D)
begin
    if(rising_edge(CLK_D)) then
         IF(counter = 0) then
            RST_D <= '1';
            STALL_D <= '0';
         else
            RST_D <= '0';         
         end if;         
         counter <= counter + 1;
         
         
         
         -- Check current instruction (0x68 = error, 0x7C = success)
         assert(INST_MEM_ADDR_D /= X"00000068")
         report "ERROR: Test failed" severity failure;
         assert(INST_MEM_ADDR_D /= X"0000007C")
         report "SUCCESS: Test succeeded" severity note;
         
     end if;
     
     if(counter > 2) then
         assert(SIG_INVALID_D = '0')
         report "ERROR: SIG Invalid" severity failure;
         assert(SIG_ALIGN_D = '0')
         report "ERROR: SIG Align" severity failure;
      end if;         
end process;

end Behavioral;
