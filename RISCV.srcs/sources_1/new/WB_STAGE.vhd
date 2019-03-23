----------------------------------------------------------------------------------
-- Author: Alexy Torres Aurora Dugo
-- 
-- Create Date: 23.03.2019 15:21:34
-- Design Name: WB_STAGE
-- Module Name: WB_STAGE - WB_STAGE_FLOW
-- Project Name: RISCV 
-- Target Devices: Digilent NEXYS4
-- Tool Versions: Vivado 2018.2
-- Description: Write back (or commit) stage, used to update destination register
--              value.
--              IN: 32 bits, RD_VAL_IN the value to commit to RD
--              IN: 5 bits, RD_REG_IN the id of RD
--              IN: 1 bit, RD_WRITE_IN must be set to 1 is RD should be updated
--              OUT: 32 bits, RD_VAL_OUT the value to commit to RD
--              OUT: 5 bits, RD_REG_OUT the id of RD
--              OUT: 1 bit, RD_WRITE_OUT is set to 1 if RD should be updated
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

ENTITY WB_STAGE IS
    PORT ( RD_VAL_IN :   in STD_LOGIC_VECTOR (31 downto 0);
           RD_REG_IN :   in STD_LOGIC_VECTOR (4 downto 0);           
           RD_WRITE_IN : in STD_LOGIC;
           
           RD_VAL_OUT :   out STD_LOGIC_VECTOR (31 downto 0);
           RD_REG_OUT :   out STD_LOGIC_VECTOR (4 downto 0);
           RD_WRITE_OUT : out STD_LOGIC
    );
END WB_STAGE;

-- At the current stage of developemnt, this stage is pretty useless.
ARCHITECTURE WB_STAGE_FLOW OF WB_STAGE IS

-- Constants
-- NONE.

-- Types
-- NONE.

-- Signals
-- NONE.

-- Components
-- None.

BEGIN
    -- Just link the input to the output
    RD_VAL_OUT   <= RD_VAL_IN;
    RD_REG_OUT   <= RD_REG_IN;
    RD_WRITE_OUT <= RD_WRITE_IN;
END WB_STAGE_FLOW;
