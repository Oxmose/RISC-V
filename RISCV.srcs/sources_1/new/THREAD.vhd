----------------------------------------------------------------------------------
-- Author: Alexy Torres Aurora Dugo
-- 
-- Create Date: 23.03.2019 15:46:32
-- Design Name: THREAD
-- Module Name: THREAD - THREAD_FLOW
-- Project Name: RISCV
-- Target Devices: Digilent NEXYS4
-- Tool Versions: Vivado 2018.2
-- Description: 
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
USE IEEE.NUMERIC_STD.ALL;

ENTITY THREAD IS
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
END THREAD;


ARCHITECTURE THREAD_FLOW OF THREAD IS

-- Constants
-- NONE.

-- Types
-- NONE.

-- Signals
SIGNAL REGISTER_WRITES : STD_LOGIC;

SIGNAL SIG_INVALID_EXE : STD_LOGIC;
SIGNAL SIG_INVALID_ID :  STD_LOGIC;
SIGNAL SIG_INVALID_MEM : STD_LOGIC;

-- IF / ID
SIGNAL IF_ID_PC_WRITE  :    STD_LOGIC;
SIGNAL IF_ID_PC_IN :        STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL IF_ID_PC_OUT :       STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL IF_ID_INST_WRITE :   STD_LOGIC;
SIGNAL IF_ID_INST_IN :      STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL IF_ID_INST_OUT :     STD_LOGIC_VECTOR(31 DOWNTO 0);

SIGNAL IF_PC_WRITE :        STD_LOGIC;     
SIGNAL IF_PC_WRITE_VALUE :  STD_LOGIC_VECTOR(31 DOWNTO 0);

-- ID / EXE
SIGNAL ID_EX_OPERAND_0_IN :   STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL ID_EX_OPERAND_1_IN :   STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL ID_EX_OPERAND_OFF_IN : STD_LOGIC_VECTOR(31 DOWNTO 0);                                 
SIGNAL ID_EX_RD_ID_IN :       STD_LOGIC_VECTOR(4 DOWNTO 0);                         
SIGNAL ID_EX_ALU_OP_IN :      STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL ID_EX_BRANCH_OP_IN :   STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL ID_EX_LSU_OP_IN :      STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL ID_EX_OP_TYPE_IN :     STD_LOGIC_VECTOR(3 DOWNTO 0);

SIGNAL ID_EX_PC_OUT :          STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL ID_EX_OPERAND_0_OUT :   STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL ID_EX_OPERAND_1_OUT :   STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL ID_EX_OPERAND_OFF_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);                                 
SIGNAL ID_EX_RD_ID_OUT :       STD_LOGIC_VECTOR(4 DOWNTO 0);    
SIGNAL ID_EX_RS1_ID_OUT :      STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL ID_EX_RS2_ID_OUT :      STD_LOGIC_VECTOR(4 DOWNTO 0);                     
SIGNAL ID_EX_ALU_OP_OUT :      STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL ID_EX_BRANCH_OP_OUT :   STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL ID_EX_LSU_OP_OUT :      STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL ID_EX_OP_TYPE_OUT :     STD_LOGIC_VECTOR(3 DOWNTO 0);

SIGNAL ID_EX_OPERAND_0_WRITE :   STD_LOGIC;   
SIGNAL ID_EX_OPERAND_1_WRITE :   STD_LOGIC;   
SIGNAL ID_EX_OPERAND_OFF_WRITE : STD_LOGIC;   
SIGNAL ID_EX_RD_ID_WRITE :       STD_LOGIC; 
SIGNAL ID_EX_RS1_ID_WRITE :      STD_LOGIC;
SIGNAL ID_EX_RS2_ID_WRITE :      STD_LOGIC; 
SIGNAL ID_EX_ALU_OP_WRITE :      STD_LOGIC;   
SIGNAL ID_EX_BRANCH_OP_WRITE :   STD_LOGIC;   
SIGNAL ID_EX_OP_TYPE_WRITE :     STD_LOGIC;   
SIGNAL ID_EX_LSU_OP_WRITE :      STD_LOGIC;  
SIGNAL ID_EX_PC_WRITE :          STD_LOGIC; 

-- EXE / MEM
SIGNAL EX_MEM_ADDR_IN :     STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL EX_MEM_RD_VAL_IN :   STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL EX_MEM_RD_WRITE_IN : STD_LOGIC;

SIGNAL EX_MEM_ADDR_OUT :     STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL EX_MEM_RD_VAL_OUT :   STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL EX_MEM_RD_ID_OUT :    STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL EX_MEM_LSU_OP_OUT :   STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL EX_MEM_OP_TYPE_OUT :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL EX_MEM_RD_WRITE_OUT : STD_LOGIC;

SIGNAL EX_MEM_ADDR_WRITE :     STD_LOGIC;
SIGNAL EX_MEM_RD_VAL_WRITE :   STD_LOGIC;
SIGNAL EX_MEM_RD_ID_WRITE :    STD_LOGIC;
SIGNAL EX_MEM_RD_WRITE_WRITE : STD_LOGIC;
SIGNAL EX_MEM_LSU_OP_WRITE :   STD_LOGIC;
SIGNAL EX_MEM_OP_TYPE_WRITE :  STD_LOGIC;

-- MEM / WB
SIGNAL MEM_WB_RD_VAL_IN :    STD_LOGIC_VECTOR(31 DOWNTO 0);

SIGNAL MEM_WB_RD_VAL_OUT :   STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL MEM_WB_RD_ID_OUT :    STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL MEM_WB_RD_WRITE_OUT : STD_LOGIC;

SIGNAL MEM_WB_RD_VAL_WRITE :   STD_LOGIC;
SIGNAL MEM_WB_RD_ID_WRITE :    STD_LOGIC;
SIGNAL MEM_WB_RD_WRITE_WRITE : STD_LOGIC;

-- Register File
SIGNAL REG_FILE_IN :    STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL REG_FILE_OUT1 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL REG_FILE_OUT2 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL REG_FILE_RID1 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL REG_FILE_RID2 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL REG_FILE_WRID :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL REG_FILE_WRITE : STD_LOGIC;

-- Stomp logic
SIGNAL STOMP_RST : STD_LOGIC;

-- Components

COMPONENT REGISTER_32B IS
    PORT ( CLK : IN STD_LOGIC;
           RST : IN STD_LOGIC;
           WR :  IN STD_LOGIC;
           D :   IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           Q :   OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END COMPONENT REGISTER_32B;

COMPONENT REGISTER_5B IS
    PORT ( CLK : IN STD_LOGIC;
           RST : IN STD_LOGIC;
           WR :  IN STD_LOGIC;
           D :   IN STD_LOGIC_VECTOR(4 DOWNTO 0);
           Q :   OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
    );
END COMPONENT REGISTER_5B;

COMPONENT REGISTER_4B IS
    PORT ( CLK : IN STD_LOGIC;
           RST : IN STD_LOGIC;
           WR :  IN STD_LOGIC;
           D :   IN STD_LOGIC_VECTOR(3 DOWNTO 0);
           Q :   OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END COMPONENT REGISTER_4B;

COMPONENT REGISTER_1B IS
    PORT ( CLK : IN STD_LOGIC;
           RST : IN STD_LOGIC;
           WR :  IN STD_LOGIC;
           D :   IN STD_LOGIC;
           Q :   OUT STD_LOGIC
    );
END COMPONENT REGISTER_1B;

COMPONENT IF_STAGE IS 
    PORT ( CLK :            IN STD_LOGIC;
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
           SIG_ALIGN :      OUT STD_LOGIC
    );
END COMPONENT IF_STAGE;

COMPONENT ID_STAGE IS 
    PORT ( INSTRUCTION_DATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
           
           REG_RVAL1 :        IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           REG_RVAL2 :        IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           
           RD_IN_EXE :        IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           RD_IN_MEM :        IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           RD_IN_WB :         IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
           RD_ID_EXE :        IN STD_LOGIC_VECTOR(4 DOWNTO 0); 
           RD_ID_MEM :        IN STD_LOGIC_VECTOR(4 DOWNTO 0); 
           RD_ID_WB :         IN STD_LOGIC_VECTOR(4 DOWNTO 0); 
           RD_WR_EXE :        IN STD_LOGIC;
           RD_WR_MEM :        IN STD_LOGIC;
           RD_WR_WB :         IN STD_LOGIC;
           
           OPERAND_0 :        OUT STD_LOGIC_VECTOR(31 DOWNTO 0);    
           OPERAND_1 :        OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           OPERAND_OFF :      OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           
           RD :               OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
           
           ALU_OP :           OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
           BRANCH_OP :        OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
           LSU_OP :           OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
           OP_TYPE :          OUT STD_LOGIC_VECTOR(3 DOWNTO 0);           
           
           REG_RID1_OUT :     OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
           REG_RID2_OUT :     OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
           
           SIG_INVALID :      out STD_LOGIC
    );      
END COMPONENT ID_STAGE;

COMPONENT EXE_STAGE IS 
    PORT ( OPERAND_0 :        IN STD_LOGIC_VECTOR(31 DOWNTO 0);    
           OPERAND_1 :        IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           OPERAND_OFF :      IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           
           PC_IN :            IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           
           ALU_OP :           IN STD_LOGIC_VECTOR(3 DOWNTO 0);
           BRANCH_OP :        IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
           OP_TYPE :          IN STD_LOGIC_VECTOR(3 DOWNTO 0);
           
           PC_OUT :           OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           RD_OUT :           OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            
           ADDR_OUT :         OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           
           B_TAKEN :          OUT STD_LOGIC;
           RD_WRITE :         OUT STD_LOGIC;
           
           SIG_INVALID :      OUT STD_LOGIC     
    ); 
END COMPONENT EXE_STAGE;

COMPONENT MEM_STAGE IS
      PORT ( DATA_OPERAND_IN :  IN STD_LOGIC_VECTOR(31 DOWNTO 0);
             MEM_ADDR_IN :      IN STD_LOGIC_VECTOR(31 DOWNTO 0);
             OP_TYPE :          IN STD_LOGIC_VECTOR(3 DOWNTO 0);
             LSU_OP :           IN STD_LOGIC_VECTOR(3 DOWNTO 0);
             
             MEM_LINK_VALUE_IN :  IN STD_LOGIC_VECTOR(31 DOWNTO 0);
             MEM_LINK_VALUE_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
             MEM_LINK_ADDR :      OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
             MEM_LINK_SIZE :      OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
             MEM_LINK_REQ_TYPE :  OUT STD_LOGIC;
             MEM_LINK_REQ :       OUT STD_LOGIC;
                  
             
             DATA_OPERAND_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
             SIG_INVALID :      OUT STD_LOGIC    
      );
END COMPONENT MEM_STAGE;

COMPONENT WB_STAGE IS
    PORT ( RD_VAL_IN :   in STD_LOGIC_VECTOR (31 downto 0);
           RD_REG_IN :   in STD_LOGIC_VECTOR (4 downto 0);           
           RD_WRITE_IN : in STD_LOGIC;
           
           RD_VAL_OUT :   out STD_LOGIC_VECTOR (31 downto 0);
           RD_REG_OUT :   out STD_LOGIC_VECTOR (4 downto 0);
           RD_WRITE_OUT : out STD_LOGIC
    );
END COMPONENT WB_STAGE;

COMPONENT REG_BANK IS 
    PORT ( CLK :    IN STD_LOGIC;
           RST :    IN STD_LOGIC;
           STALL :  IN STD_LOGIC;
           WRITE:   IN STD_LOGIC;
           RRID1 :  IN STD_LOGIC_VECTOR(4 DOWNTO 0);  
           RRID2 :  IN STD_LOGIC_VECTOR(4 DOWNTO 0);  
           WRID :   IN STD_LOGIC_VECTOR(4 DOWNTO 0);  
           WRVAL :  IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           RRVAL1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
           RRVAL2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );          
END COMPONENT REG_BANK;

BEGIN

-- Internal `register don't write on stall
REGISTER_WRITES <= NOT STALL;

-- Internal SIG_INVALID
SIG_INVALID <= SIG_INVALID_EXE OR SIG_INVALID_ID OR SIG_INVALID_MEM;

-- Stomp logic 
STOMP_RST <= RST OR IF_PC_WRITE;

------------------------------------------------------------------
-- IF STAGE
------------------------------------------------------------------
-- Map IF-ID registers
IF_ID_PC : REGISTER_32B PORT MAP(
    CLK => CLK, 
    RST => STOMP_RST, 
    WR  => IF_ID_PC_WRITE, 
    D   => IF_ID_PC_IN, 
    Q   => IF_ID_PC_OUT
);
                                 
IF_ID_INSTRUCTION : REGISTER_32B PORT MAP(
    CLK => CLK, 
    RST => STOMP_RST, 
    WR  => IF_ID_INST_WRITE, 
    D   => IF_ID_INST_IN, 
    Q   => IF_ID_INST_OUT
);

-- Manage registers write conditions
IF_ID_PC_WRITE   <= REGISTER_WRITES;
IF_ID_INST_WRITE <= REGISTER_WRITES;

-- Map IF stage
IF_STAGE_MAP : IF_STAGE PORT MAP(
    CLK                => CLK, 
    RST                => RST,
    STALL              => STALL, 
    EF_JUMP            => IF_PC_WRITE,
    JUMP_INST_ADDR     => IF_PC_WRITE_VALUE,
    INST_MEM_DATA      => INST_MEM_IN,
    MEM_LINK_VALUE_OUT => INST_MEM_OUT,
    MEM_LINK_ADDR      => INST_MEM_ADDR,
    MEM_LINK_SIZE      => INST_MEM_REQ_SIZE,
    MEM_LINK_REQ_TYPE  => INST_MEM_REQ_TYPE,
    MEM_LINK_REQ       => INST_MEM_REQ,
    PC                 => IF_ID_PC_IN, 
    INSTRUCTION        => IF_ID_INST_IN,
    SIG_ALIGN          => SIG_ALIGN
);

------------------------------------------------------------------
-- ID STAGE
------------------------------------------------------------------
-- Map ID-EXE registers
ID_EX_OPERAND_0 : REGISTER_32B PORT MAP(
    CLK => CLK, 
    RST => STOMP_RST, 
    WR  => ID_EX_OPERAND_0_WRITE, 
    D   => ID_EX_OPERAND_0_IN, 
    Q   => ID_EX_OPERAND_0_OUT
);
ID_EX_OPERAND_1 : REGISTER_32B PORT MAP(
    CLK => CLK, 
    RST => STOMP_RST, 
    WR  => ID_EX_OPERAND_1_WRITE, 
    D   => ID_EX_OPERAND_1_IN, 
    Q   => ID_EX_OPERAND_1_OUT
);
ID_EX_OPERAND_OFF : REGISTER_32B PORT MAP(
    CLK => CLK, 
    RST => STOMP_RST, 
    WR  => ID_EX_OPERAND_OFF_WRITE, 
    D   => ID_EX_OPERAND_OFF_IN, 
    Q   => ID_EX_OPERAND_OFF_OUT
);
ID_EX_RD_ID : REGISTER_5B PORT MAP(
    CLK => CLK, 
    RST => STOMP_RST, 
    WR  => ID_EX_RD_ID_WRITE, 
    D   => ID_EX_RD_ID_IN, 
    Q   => ID_EX_RD_ID_OUT
);
ID_EX_ALU_OP : REGISTER_4B PORT MAP(
    CLK => CLK, 
    RST => STOMP_RST, 
    WR  => ID_EX_ALU_OP_WRITE, 
    D   => ID_EX_ALU_OP_IN, 
    Q   => ID_EX_ALU_OP_OUT
);
ID_EX_BRANCH_OP : REGISTER_4B PORT MAP(
    CLK => CLK, 
    RST => STOMP_RST, 
    WR  => ID_EX_BRANCH_OP_WRITE, 
    D   => ID_EX_BRANCH_OP_IN, 
    Q   => ID_EX_BRANCH_OP_OUT
);
ID_EX_LSU_OP : REGISTER_4B PORT MAP(
    CLK => CLK, 
    RST => STOMP_RST, 
    WR  => ID_EX_LSU_OP_WRITE, 
    D   => ID_EX_LSU_OP_IN, 
    Q   => ID_EX_LSU_OP_OUT
);
ID_EX_OP_TYPE : REGISTER_4B PORT MAP(
    CLK => CLK, 
    RST => STOMP_RST, 
    WR  => ID_EX_OP_TYPE_WRITE, 
    D   => ID_EX_OP_TYPE_IN, 
    Q   => ID_EX_OP_TYPE_OUT
);
ID_EX_PC : REGISTER_32B PORT MAP(
    CLK => CLK, 
    RST => STOMP_RST, 
    WR  => ID_EX_PC_WRITE, 
    D   => IF_ID_PC_OUT, 
    Q   => ID_EX_PC_OUT
);
ID_EX_RS1 : REGISTER_5B PORT MAP(
    CLK => CLK, 
    RST => STOMP_RST, 
    WR  => ID_EX_RS1_ID_WRITE, 
    D   => REG_FILE_RID1, 
    Q   => ID_EX_RS1_ID_OUT
);
ID_EX_RS2 : REGISTER_5B PORT MAP(
    CLK => CLK, 
    RST => STOMP_RST, 
    WR  => ID_EX_RS2_ID_WRITE, 
    D   => REG_FILE_RID2, 
    Q   => ID_EX_RS2_ID_OUT
);

-- Manage registers write conditions
ID_EX_OPERAND_0_WRITE   <= REGISTER_WRITES;
ID_EX_OPERAND_1_WRITE   <= REGISTER_WRITES;
ID_EX_OPERAND_OFF_WRITE <= REGISTER_WRITES;
ID_EX_RD_ID_WRITE       <= REGISTER_WRITES;
ID_EX_ALU_OP_WRITE      <= REGISTER_WRITES;
ID_EX_BRANCH_OP_WRITE   <= REGISTER_WRITES; 
ID_EX_OP_TYPE_WRITE     <= REGISTER_WRITES;
ID_EX_LSU_OP_WRITE      <= REGISTER_WRITES;
ID_EX_PC_WRITE          <= REGISTER_WRITES;
ID_EX_RS1_ID_WRITE      <= REGISTER_WRITES;
ID_EX_RS2_ID_WRITE      <= REGISTER_WRITES;

-- Map ID stage
ID_STAGE_MAP : ID_STAGE PORT MAP(
    INSTRUCTION_DATA => IF_ID_INST_OUT,
    REG_RVAL1        => REG_FILE_OUT1,
    REG_RVAL2        => REG_FILE_OUT2, 
    RD_IN_EXE        => EX_MEM_RD_VAL_IN,
    RD_IN_MEM        => MEM_WB_RD_VAL_IN,
    RD_IN_WB         => REG_FILE_IN,
    RD_ID_EXE        => ID_EX_RD_ID_OUT,
    RD_ID_MEM        => EX_MEM_RD_ID_OUT,
    RD_ID_WB         => REG_FILE_WRID,    
    RD_WR_EXE        => EX_MEM_RD_WRITE_IN,
    RD_WR_MEM        => EX_MEM_RD_WRITE_OUT,
    RD_WR_WB         => REG_FILE_WRITE,            
    OPERAND_0        => ID_EX_OPERAND_0_IN,
    OPERAND_1        => ID_EX_OPERAND_1_IN,
    OPERAND_OFF      => ID_EX_OPERAND_OFF_IN,                               
    RD               => ID_EX_RD_ID_IN,                              
    ALU_OP           => ID_EX_ALU_OP_IN,
    BRANCH_OP        => ID_EX_BRANCH_OP_IN,
    LSU_OP           => ID_EX_LSU_OP_IN,
    OP_TYPE          => ID_EX_OP_TYPE_IN,
    REG_RID1_OUT     => REG_FILE_RID1,
    REG_RID2_OUT     => REG_FILE_RID2,
    SIG_INVALID      => SIG_INVALID_ID
);

------------------------------------------------------------------
-- EXE STAGE
------------------------------------------------------------------
-- Map EXE-MEM registers
EX_MEM_RD_ID : REGISTER_5B PORT MAP(
    CLK => CLK, 
    RST => RST, 
    WR  => EX_MEM_RD_ID_WRITE, 
    D   => ID_EX_RD_ID_OUT, 
    Q   => EX_MEM_RD_ID_OUT
);
EX_MEM_RD_WRITE : REGISTER_1B PORT MAP(
    CLK => CLK, 
    RST => RST, 
    WR  => EX_MEM_RD_WRITE_WRITE, 
    D   => EX_MEM_RD_WRITE_IN, 
    Q   => EX_MEM_RD_WRITE_OUT
);
EX_MEM_ADDR : REGISTER_32B PORT MAP(
    CLK => CLK, 
    RST => RST, 
    WR  => EX_MEM_ADDR_WRITE, 
    D   => EX_MEM_ADDR_IN, 
    Q   => EX_MEM_ADDR_OUT
);
EX_MEM_RD_VAL : REGISTER_32B PORT MAP(
    CLK => CLK, 
    RST => RST, 
    WR  => EX_MEM_RD_VAL_WRITE, 
    D   => EX_MEM_RD_VAL_IN, 
    Q   => EX_MEM_RD_VAL_OUT
);
EX_MEM_LSU_OP : REGISTER_4B PORT MAP(
    CLK => CLK, 
    RST => RST, 
    WR  => EX_MEM_LSU_OP_WRITE, 
    D   => ID_EX_LSU_OP_OUT, 
    Q   => EX_MEM_LSU_OP_OUT
);
EX_MEM_OP_TYPE : REGISTER_4B PORT MAP(
    CLK => CLK, 
    RST => RST, 
    WR  => EX_MEM_OP_TYPE_WRITE, 
    D   => ID_EX_OP_TYPE_OUT, 
    Q   => EX_MEM_OP_TYPE_OUT
);

-- Manage registers write conditions
EX_MEM_RD_ID_WRITE    <= REGISTER_WRITES;
EX_MEM_RD_WRITE_WRITE <= REGISTER_WRITES;
EX_MEM_ADDR_WRITE     <= REGISTER_WRITES;
EX_MEM_RD_VAL_WRITE   <= REGISTER_WRITES;
EX_MEM_LSU_OP_WRITE   <= REGISTER_WRITES;
EX_MEM_OP_TYPE_WRITE  <= REGISTER_WRITES;

-- Map EXE stage
EXE_STAGE_MAP : EXE_STAGE PORT MAP ( 
    OPERAND_0   => ID_EX_OPERAND_0_OUT,
    OPERAND_1   => ID_EX_OPERAND_1_OUT,
    OPERAND_OFF => ID_EX_OPERAND_OFF_OUT,
    PC_IN       => ID_EX_PC_OUT,   
    ALU_OP      => ID_EX_ALU_OP_OUT,
    BRANCH_OP   => ID_EX_BRANCH_OP_OUT,
    OP_TYPE     => ID_EX_OP_TYPE_OUT,
    PC_OUT      => IF_PC_WRITE_VALUE,
    RD_OUT      => EX_MEM_RD_VAL_IN,
    ADDR_OUT    => EX_MEM_ADDR_IN,
    B_TAKEN     => IF_PC_WRITE,
    RD_WRITE    => EX_MEM_RD_WRITE_IN,
    SIG_INVALID => SIG_INVALID_EXE
); 

------------------------------------------------------------------
-- MEM STAGE
------------------------------------------------------------------
-- Map MEM-WB registers
MEM_WB_RD_VAL : REGISTER_32B PORT MAP(
    CLK => CLK, 
    RST => RST, 
    WR  => MEM_WB_RD_VAL_WRITE, 
    D   => MEM_WB_RD_VAL_IN, 
    Q   => MEM_WB_RD_VAL_OUT
);
MEM_WB_RD_ID : REGISTER_5B PORT MAP(
    CLK => CLK, 
    RST => RST, 
    WR  => MEM_WB_RD_ID_WRITE, 
    D   => EX_MEM_RD_ID_OUT, 
    Q   => MEM_WB_RD_ID_OUT
);
MEM_WB_RD_WRITE : REGISTER_1B PORT MAP(
    CLK => CLK, 
    RST => RST, 
    WR  => MEM_WB_RD_WRITE_WRITE, 
    D   => EX_MEM_RD_WRITE_OUT, 
    Q   => MEM_WB_RD_WRITE_OUT
);

-- Manage registers write conditions
MEM_WB_RD_VAL_WRITE   <= REGISTER_WRITES;
MEM_WB_RD_ID_WRITE    <= REGISTER_WRITES;
MEM_WB_RD_WRITE_WRITE <= REGISTER_WRITES;

-- Map MEM stage
MEM_STAGE_MAP : MEM_STAGE PORT MAP(
    DATA_OPERAND_IN    => EX_MEM_RD_VAL_OUT,
    MEM_ADDR_IN        => EX_MEM_ADDR_OUT,
    OP_TYPE            => EX_MEM_OP_TYPE_OUT,
    LSU_OP             => EX_MEM_LSU_OP_OUT, 
    MEM_LINK_VALUE_IN  => DATA_MEM_IN,
    MEM_LINK_VALUE_OUT => DATA_MEM_OUT,
    MEM_LINK_ADDR      => DATA_MEM_ADDR,
    MEM_LINK_SIZE      => DATA_MEM_REQ_SIZE,
    MEM_LINK_REQ_TYPE  => DATA_MEM_REQ_TYPE,
    MEM_LINK_REQ       => DATA_MEM_REQ,    
    DATA_OPERAND_OUT   => MEM_WB_RD_VAL_IN,
    SIG_INVALID        => SIG_INVALID_MEM
);

------------------------------------------------------------------
-- WB STAGE
------------------------------------------------------------------

-- Map WB stage
WB_STAGE_MAP : WB_STAGE PORT MAP(
    RD_VAL_IN    => MEM_WB_RD_VAL_OUT,
    RD_REG_IN    => MEM_WB_RD_ID_OUT,        
    RD_WRITE_IN  => MEM_WB_RD_WRITE_OUT,
    RD_VAL_OUT   => REG_FILE_IN,
    RD_REG_OUT   => REG_FILE_WRID,
    RD_WRITE_OUT => REG_FILE_WRITE
);

------------------------------------------------------------------
-- REGISTER FILE
------------------------------------------------------------------
-- Map RF
REG_FILE_MAP : REG_BANK PORT MAP(
    CLK    => CLK,
    RST    => RST,
    STALL  => STALL,
    WRITE  => REG_FILE_WRITE,
    RRID1  => REG_FILE_RID1,
    RRID2  => REG_FILE_RID2,
    WRID   => REG_FILE_WRID,
    WRVAL  => REG_FILE_IN,
    RRVAL1 => REG_FILE_OUT1,
    RRVAL2 => REG_FILE_OUT2
);

END THREAD_FLOW;
