----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.03.2019 19:34:18
-- Design Name: 
-- Module Name: DUMMY_MEM - DUMMY_MEM_BEHAVE
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
use ieee.std_logic_textio.all;
use std.textio.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DUMMY_MEM is
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           REQ : in STD_LOGIC;
           REQ_TYPE : in STD_LOGIC;
           REQ_SIZE : in STD_LOGIC_VECTOR(1 downto 0);
           MEM_ADDR : in STD_LOGIC_VECTOR(31 downto 0);
           MEM_VALUE_IN : in STD_LOGIC_VECTOR(31 downto 0);
           MEM_VALUE_OUT : out STD_LOGIC_VECTOR(31 downto 0));
end DUMMY_MEM;

architecture DUMMY_MEM_BEHAVE of DUMMY_MEM is
type ram_t is array (0 to 8192) of std_logic_vector(7 downto 0);
subtype word_t  is std_logic_vector(7 downto 0);

IMPURE FUNCTION init_rom RETURN ram_t IS
		FILE rom_file   : text OPEN read_mode IS "inst.txt";
		VARIABLE ret    : ram_t;
		VARIABLE l      : line;
		VARIABLE readV  : integer;
	BEGIN
		FOR i IN 0 TO 8192 LOOP
			IF(NOT ENDFILE(rom_file)) THEN
				readline(rom_file, l);
				hread(l, ret(i));
			END IF;
		END LOOP;
		
		RETURN ret;
	END FUNCTION init_rom;

signal SERVICING : STD_LOGIC := '0';


signal ram : ram_t := init_rom;


begin

process(CLK, RST, REQ)
begin
    if(RST = '1') then
        MEM_VALUE_OUT <= (others => '0');
    elsif(REQ = '1' AND SERVICING = '0') then  
        SERVICING <= '1';
        if(REQ_TYPE = '1') then
            if(REQ_SIZE = "00") then
                ram(TO_INTEGER(UNSIGNED(MEM_ADDR))) <= MEM_VALUE_IN(7 downto 0);
            elsif(REQ_SIZE = "01") then
                ram(TO_INTEGER(UNSIGNED(MEM_ADDR))) <= MEM_VALUE_IN(7 downto 0);
                ram(TO_INTEGER(UNSIGNED(MEM_ADDR) + 1)) <= MEM_VALUE_IN(15 downto 8);
            elsif(REQ_SIZE = "10") then
                ram(TO_INTEGER(UNSIGNED(MEM_ADDR))) <= MEM_VALUE_IN(7 downto 0);
                ram(TO_INTEGER(UNSIGNED(MEM_ADDR) + 1)) <= MEM_VALUE_IN(15 downto 8);
                ram(TO_INTEGER(UNSIGNED(MEM_ADDR) + 2)) <= MEM_VALUE_IN(23 downto 16);
                ram(TO_INTEGER(UNSIGNED(MEM_ADDR) + 3)) <= MEM_VALUE_IN(31 downto 24);
            end if;
            
        else 
            MEM_VALUE_OUT <= (others => '0');
            if(REQ_SIZE = "00") then
                MEM_VALUE_OUT(7 downto 0) <= ram(TO_INTEGER(UNSIGNED(MEM_ADDR)));
            elsif(REQ_SIZE = "01") then
                MEM_VALUE_OUT(7 downto 0) <= ram(TO_INTEGER(UNSIGNED(MEM_ADDR)));
                MEM_VALUE_OUT(15 downto 8) <= ram(TO_INTEGER(UNSIGNED(MEM_ADDR) + 1));
            elsif(REQ_SIZE = "10") then
                MEM_VALUE_OUT(7 downto 0) <= ram(TO_INTEGER(UNSIGNED(MEM_ADDR)));
                MEM_VALUE_OUT(15 downto 8) <= ram(TO_INTEGER(UNSIGNED(MEM_ADDR) + 1));
                MEM_VALUE_OUT(23 downto 16) <= ram(TO_INTEGER(UNSIGNED(MEM_ADDR) + 2));
                MEM_VALUE_OUT(31 downto 24) <= ram(TO_INTEGER(UNSIGNED(MEM_ADDR) + 3));
            end if;
        end if;
        SERVICING <= '0';
    end if;
end process;

end DUMMY_MEM_BEHAVE;
