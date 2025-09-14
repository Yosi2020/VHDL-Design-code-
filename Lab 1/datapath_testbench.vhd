----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/13/2025 12:39:21 PM
-- Design Name: 
-- Module Name: datapath_TESTBench - Behavioral
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
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity datapath_TESTBench is
--  Port ( );
end datapath_TESTBench;

architecture Behavioral of datapath_TESTBench is
  -- control
  signal clk : std_logic := '0';
  signal reset : std_logic := '1';
  signal Asel : std_logic_vector(4 downto 0) := (others=>'0');
  signal Bsel : std_logic_vector(4 downto 0) := (others=>'0');
  signal Dsel : std_logic_vector(4 downto 0) := (others=>'0');
  signal Dlen : std_logic := '0';
  signal PCAsel : std_logic := '0';
  signal IMMBsel : std_logic := '0';
  signal PCDsel : std_logic := '0';
  signal PCle : std_logic := '0';
  signal PCie : std_logic := '0';
  signal isBR : std_logic := '0';
  signal BRcond : std_logic_vector(2 downto 0) := (others=>'0');
  signal ALUFunc : std_logic_vector(3 downto 0) := (others=>'0');
  signal IMM : std_logic_vector(31 downto 0) := (others=>'0');
  signal PC_q : std_logic_vector(31 downto 0);
  signal alu_y : std_logic_vector(31 downto 0);
  signal regA_q : std_logic_vector(31 downto 0);
  signal regB_q : std_logic_vector(31 downto 0);

  -- ALU
  constant ALU_ADD : std_logic_vector(3 downto 0) := "0000"; -- add
  constant ALU_SUB : std_logic_vector(3 downto 0) := "0001"; -- sub
  constant ALU_OR : std_logic_vector(3 downto 0) := "0011"; -- or
  constant ALU_XOR : std_logic_vector(3 downto 0) := "0100";
  constant ALU_AND : std_logic_vector(3 downto 0) := "0010";
  constant ALU_SLT : std_logic_vector(3 downto 0) := "0101";
  constant ALU_SLTU : std_logic_vector(3 downto 0) := "0110";
  constant ALU_SLL : std_logic_vector(3 downto 0) := "0111";
  constant ALU_SRL : std_logic_vector(3 downto 0) := "1000";
  constant ALU_SRA : std_logic_vector(3 downto 0) := "1001";

  -- branch
  constant BR_BEQ : std_logic_vector(2 downto 0) := "000";
  constant BR_BNE : std_logic_vector(2 downto 0) := "001";
  constant BR_BLT : std_logic_vector(2 downto 0) := "010"; -- signed <
  constant BR_BGE : std_logic_vector(2 downto 0) := "011"; -- signed >=
  constant BR_BLTU : std_logic_vector(2 downto 0) := "110"; -- unsigned <
  constant BR_BGEU : std_logic_vector(2 downto 0) := "111"; -- unsigned >=

  -- register from x0-x15
  constant X0 : std_logic_vector(4 downto 0) := "00000";
  constant X1 : std_logic_vector(4 downto 0) := "00001";
  constant X2 : std_logic_vector(4 downto 0) := "00010";
  constant X3 : std_logic_vector(4 downto 0) := "00011";
  constant X4 : std_logic_vector(4 downto 0) := "00100";
  constant X5 : std_logic_vector(4 downto 0) := "00101";
  constant X6 : std_logic_vector(4 downto 0) := "00110";
  constant X7 : std_logic_vector(4 downto 0) := "00111";
  constant X8 : std_logic_vector(4 downto 0) := "01000";
  constant X9 : std_logic_vector(4 downto 0) := "01001";
  constant X10 : std_logic_vector(4 downto 0) := "01010";
  constant X11 : std_logic_vector(4 downto 0) := "01011";
  constant X12 : std_logic_vector(4 downto 0) := "01100";
  constant X13 : std_logic_vector(4 downto 0) := "01101";
  constant X14 : std_logic_vector(4 downto 0) := "01110";
  constant X15 : std_logic_vector(4 downto 0) := "01111";

  -- toggle inline
  signal t_add, t_sub, t_and, t_or, t_xor,
         t_sll, t_srl, t_sra,
         t_slt, t_sltu,
         t_pcinc, t_beq, t_bne, t_blt, t_bge, t_bltu, t_bgeu, t_jal : std_logic := '0';

begin
   -- clock
  clk <= not clk after 5 ns;

  -- calling data_path
  uut: entity work.data_path
    port map(
      clk      => clk,
      reset    => reset,
      Asel     => Asel,
      Bsel     => Bsel,
      Dsel     => Dsel,
      Dlen     => Dlen,
      PCAsel   => PCAsel,
      IMMBsel  => IMMBsel,
      PCDsel   => PCDsel,
      PCle     => PCle,
      PCie     => PCie,
      isBR     => isBR,
      BRcond   => BRcond,
      ALUFunc  => ALUFunc,
      IMM      => IMM,
      PC_q     => PC_q,
      alu_y    => alu_y,
      regA_q   => regA_q,
      regB_q   => regB_q
    );
    
    -- stimulus
  stim: process
    variable pc_before : std_logic_vector(31 downto 0);
  begin
    -- resting
    reset <= '1';  wait until rising_edge(clk);
                 --  wait until rising_edge(clk);
    reset <= '0';  wait until rising_edge(clk);
    
    --reseting PC into 0
    assert PC_q = x"00000000" report "PC not zero after reset" severity failure;

    -- x1 = 5
    Asel<=X0; 
    Bsel<=X0; 
    PCAsel<='0'; 
    IMMBsel<='1'; 
    IMM<=x"00000005"; 
    ALUFunc<=ALU_ADD;
    PCDsel<='0'; 
    wait until rising_edge(clk); 
    Dsel<=X1; 
    Dlen<='1'; 
    wait until rising_edge(clk); 
    Dlen <= '0';
    Asel<=X1; 
    wait for 1 ns; 
    --checking the output from the register (Error handler)
    assert regA_q = x"00000005" report "x1 write/read failed" severity failure;


    -- x2 = 3
    Asel<=X0; 
    Bsel<=X0; 
    IMMBsel<='1'; 
    IMM<=x"00000003"; 
    ALUFunc<=ALU_ADD;
    PCDsel<='0'; 
    wait until rising_edge(clk);
    Dsel<=X2; 
    Dlen<='1'; 
    wait until rising_edge(clk); 
    Dlen<='0';
    Asel<=X2; 
    -- Error handler
    wait for 1 ns; 
    assert regA_q = x"00000003" report "x2 write/read failed" severity failure;


    -- ADD x3 = 8
    t_add<='1'; wait for 1 ns;
    Asel<=X1; 
    Bsel<=X2; 
    PCAsel<='0'; 
    IMMBsel<='0'; 
    ALUFunc<=ALU_ADD;
    PCDsel<='0';
    wait until rising_edge(clk); 
    Dsel<=X3; 
    Dlen<='1'; 
    wait until rising_edge(clk); 
    Dlen<='0';
    assert alu_y = x"00000008" report "ADD wrong" severity failure; -- Error handler
    Asel<=X3; wait for 1 ns; 
    assert regA_q = x"00000008" report "x3 writeback wrong" severity failure; -- Error handler
    t_add<='0'; wait for 1 ns;

    -- SUB x4 = 2
    t_sub<='1'; 
    wait for 1 ns;
    Asel<=X1; 
    Bsel<=X2; 
    ALUFunc<=ALU_SUB; 
    PCDsel<='0'; 
    wait until rising_edge(clk); 
    Dsel<=X4; 
    Dlen<='1';
    wait until rising_edge(clk); 
    Dlen<='0';
    assert alu_y = x"00000002" report "SUB wrong" severity failure; -- Error Handler
    Asel<=X4; wait for 1 ns; 
    assert regA_q = x"00000002" report "x4 writeback wrong" severity failure; -- Error Handler
    t_sub<='0'; wait for 1 ns;

    -- AND 
    t_and<='1'; wait for 1 ns;
    Asel<=X1; 
    Bsel<=X2; 
    ALUFunc<=ALU_AND; 
    wait until rising_edge(clk); 
    Dsel<=X5; 
    Dlen<='1'; 
    PCDsel<='0';
    wait until rising_edge(clk); 
    Dlen<='0'; 
    assert alu_y = x"00000001" report "AND wrong" severity failure; -- Error Handler
    t_and<='0'; wait for 1 ns;
 
    -- OR
    t_or<='1'; wait for 1 ns;
    ALUFunc<=ALU_OR ; 
    wait until rising_edge(clk); 
    Dsel<=X6; 
    Dlen<='1'; 
    wait until rising_edge(clk); 
    Dlen<='0';
    assert alu_y = x"00000007" report "OR wrong" severity failure; -- Error Handler
    t_or<='0'; wait for 1 ns;

    --XOR
    t_xor<='1'; wait for 1 ns;
    ALUFunc<=ALU_XOR; 
    wait until rising_edge(clk); 
    Dsel<=X7; 
    Dlen<='1'; 
    wait until rising_edge(clk); 
    Dlen<='0';
    assert alu_y = x"00000006" report "XOR wrong" severity failure; -- Error Handler
    t_xor<='0'; wait for 1 ns;

    -- shift, for good test I choose immediate = -128, and shamt = 4
    Asel<=X0; 
    Bsel<=X0; 
    IMMBsel<='1'; 
    IMM<=x"FFFFFF80"; 
    ALUFunc<=ALU_ADD; 
    PCDsel<='0'; 
    wait until rising_edge(clk); 
    Dsel<=X8; 
    Dlen<='1';
    wait until rising_edge(clk); 
    Dlen<='0';
    Asel<=X0; 
    Bsel<=X0; 
    IMMBsel<='1'; 
    IMM<=x"00000004"; 
    ALUFunc<=ALU_ADD; 
    PCDsel<='0'; 
    wait until rising_edge(clk); 
    Dsel<=X9; 
    Dlen<='1';
    wait until rising_edge(clk); 
    Dlen<='0';

    -- SLL
    t_sll<='1'; wait for 1 ns;
    Asel<=X8; 
    Bsel<=X9; 
    ALUFunc<=ALU_SLL; 
    PCDsel<='0'; 
    Dsel<=X10; 
    Dlen<='1';
    --wait until rising_edge(clk); 
    Dlen<='0';
    assert alu_y /= x"00000000" report "SLL unexpected zero" severity failure; -- Error Handler
    t_sll<='0'; wait for 1 ns;

    -- SRL
    t_srl<='1'; wait for 1 ns;
    Asel<=X8; 
    Bsel<=X9; 
    ALUFunc<=ALU_SRL; 
    Dsel<=X11; 
    Dlen<='1';
    --wait until rising_edge(clk); 
    Dlen<='0';
    assert alu_y(31) = '0' report "SRL must zero-fill" severity failure; -- Error Handler
    t_srl<='0'; wait for 1 ns;

    -- sra
    t_sra<='1'; wait for 1 ns;
    Asel<=X8; 
    Bsel<=X9; 
    ALUFunc<=ALU_SRA; 
    wait until rising_edge(clk); 
    Dsel<=X12; 
    Dlen<='1';
    wait until rising_edge(clk); 
    Dlen<='0';
    assert alu_y(31) = '1' report "SRA must sign-extend" severity failure; -- Error Handler
    t_sra<='0'; wait for 1 ns;

    -- SLT / SLTU i choose the testing numbers -4 vs 2
    Asel<=X0; 
    Bsel<=X0; 
    IMMBsel<='1'; 
    IMM<=x"FFFFFFFC"; 
    ALUFunc<=ALU_ADD; PCDsel<='0'; Dsel<=X13; Dlen<='1';
    wait until rising_edge(clk); 
    Dlen<='0';
    Asel<=X0; 
    Bsel<=X0; 
    IMMBsel<='1'; 
    IMM<=x"00000002"; 
    ALUFunc<=ALU_ADD; 
    PCDsel<='0'; 
    Dsel<=X14; 
    Dlen<='1';
    wait until rising_edge(clk); 
    Dlen<='0';
    
    -- SLT
    t_slt<='1'; wait for 1 ns;
    Asel<=X13; 
    Bsel<=X14; 
    ALUFunc<=ALU_SLT; 
    wait until rising_edge(clk);  
    Dsel<=X15; 
    Dlen<='1'; 
    PCDsel<='0';
    wait until rising_edge(clk); 
    Dlen<='0';
    assert alu_y = x"00000001" report "SLT wrong" severity failure; -- Error Handler
    t_slt<='0'; wait for 1 ns;

    -- sltu
    t_sltu<='1'; wait for 1 ns;
    Asel<=X13; 
    Bsel<=X14; 
    ALUFunc<=ALU_SLTU; 
    wait until rising_edge(clk); 
    Dsel<=X15; 
    Dlen<='1';
    --PCDsel<='0';
    wait until rising_edge(clk); 
    Dlen<='0';
    assert alu_y = x"00000000" report "SLTU wrong" severity failure; -- Error Handler
    t_sltu<='0'; wait for 1 ns;

    -- when PCie is 1 ==> PC +4
    t_pcinc<='1'; wait for 1 ns;
    wait until rising_edge(clk);
    pc_before := PC_q; 
    PCie<='1'; 
    wait until rising_edge(clk); 
    wait until rising_edge(clk);
    PCie<='0';
    assert unsigned(PC_q) = (unsigned(pc_before) + TO_UNSIGNED(4, pc_before'length)) report "PC + 4 failed" severity failure;  -- Error Handler
    t_pcinc<='0'; wait for 1 ns;
    
    -- branch
    -- A=B
    t_beq<='1'; wait for 1 ns;
    PCAsel<='1'; 
    IMMBsel<='1'; 
    IMM<=x"00000010"; 
    ALUFunc<=ALU_ADD; 
    Asel<=X1; 
    Bsel<=X1; 
    wait until rising_edge(clk);
    pc_before := PC_q;
    isBR<='1'; 
    BRcond<=BR_BEQ; 
    wait until rising_edge(clk); 
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    isBR<='0';
    assert unsigned(PC_q) = unsigned(pc_before) + 16 report "BEQ taken failed" severity failure;  -- Error Handler
    t_beq<='0'; wait for 1 ns;

    -- A!=B
    t_bne<='1'; wait for 1 ns;
    PCAsel<='1'; 
    IMMBsel<='1'; 
    IMM<=x"00000010"; 
    ALUFunc<=ALU_ADD;
    Asel<=X1; 
    Bsel<=X1; 
    pc_before := PC_q;
    isBR<='1'; 
    BRcond<=BR_BNE; 
    wait until rising_edge(clk); 
    isBR<='0';
    assert PC_q = pc_before report "BNE not-taken failed" severity failure; -- Error Handler
    t_bne<='0'; wait for 1 ns;

    -- blt
    t_blt<='1'; wait for 1 ns;
    PCAsel<='1'; 
    IMMBsel<='1'; 
    IMM<=x"00000010"; 
    ALUFunc<=ALU_ADD;
    Asel<=X13; 
    Bsel<=X14; 
    pc_before := PC_q;
    isBR<='1'; 
    BRcond<=BR_BLT; 
    wait until rising_edge(clk); 
    isBR<='0';
    assert unsigned(PC_q) = unsigned(pc_before) + 16 report "BLT taken failed" severity failure; -- Error Handler
    t_blt<='0'; wait for 1 ns;

    -- BGE 
    t_bge<='1'; wait for 1 ns;
    PCAsel<='1'; 
    IMMBsel<='1'; 
    IMM<=x"00000010"; 
    ALUFunc<=ALU_ADD;
    Asel<=X13; 
    Bsel<=X14; 
    pc_before := PC_q;
    isBR<='1'; 
    BRcond<=BR_BGE; 
    --wait until rising_edge(clk); 
    isBR<='0';
    assert PC_q = pc_before report "BGE not-taken failed" severity failure; -- Error Handler
    t_bge<='0'; wait for 1 ns;

    -- BLTU 
    t_bltu<='1'; wait for 1 ns;
    PCAsel<='1'; 
    IMMBsel<='1'; 
    IMM<=x"00000010"; 
    ALUFunc<=ALU_ADD;
    Asel<=X13; 
    Bsel<=X14; 
    pc_before := PC_q;
    isBR<='1'; BRcond<=BR_BLTU; 
    --wait until rising_edge(clk); 
    isBR<='0';
    assert PC_q = pc_before report "BLTU not-taken failed" severity failure; -- Error Handler
    t_bltu<='0'; wait for 1 ns;

    -- BGEU 
    t_bgeu<='1'; wait for 1 ns;
    PCAsel<='1'; 
    IMMBsel<='1'; 
    IMM<=x"00000010"; 
    ALUFunc<=ALU_ADD;
    Asel<=X13; 
    Bsel<=X14; 
    wait until rising_edge(clk); 
    pc_before := PC_q;
    isBR<='1'; 
    BRcond<=BR_BGEU; 
    wait until rising_edge(clk); 
    isBR<='0';
    assert unsigned(PC_q) = unsigned(pc_before) + 16 report "BGEU taken failed" severity failure; -- Error Handler
    t_bgeu<='0'; wait for 1 ns;

    -- JAL-like: rd := PC, PC <- PC + 32
    t_jal<='1'; wait for 1 ns;
    wait until rising_edge(clk);
    pc_before := PC_q;
    PCAsel<='1'; 
    IMMBsel<='1'; 
    IMM<=x"00000020"; 
    ALUFunc<=ALU_ADD;
    wait until rising_edge(clk);
    PCDsel<='1'; 
    Dsel<=X8; 
    Dlen<='1'; 
    PCle<='1';
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    Dlen<='0'; 
    PCle<='0'; 
    PCDsel<='0';
    assert unsigned(PC_q) = unsigned(pc_before) +32 report "JAL-like PC load failed" severity failure;
    Asel<=X8; wait for 1 ns; 
    assert regA_q = pc_q report "JAL-like rd=PC failed" severity failure;
    t_jal<='0'; wait for 1 ns;

    wait;
  end process;

end Behavioral;
