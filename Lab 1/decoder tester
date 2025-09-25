----------------------------------------------------------------------------------
-- Company: 
-- Engineer: EYosiyas
-- 
-- Create Date: 09/25/2025 03:15:01 AM
-- Design Name: 
-- Module Name: testbench - Behavioral
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

entity testbench is
--  Port ( );
end testbench;

architecture Behavioral of testbench is
  constant T : time := 10 ns;

  -- UUT (connector) ports
  signal eyu_clk     : std_logic := '0';
  signal eyu_reset   : std_logic := '1';
  signal eyu_instr   : std_logic_vector(31 downto 0) := (others => '0');
  signal eyu_pc_q    : std_logic_vector(31 downto 0);
  signal eyu_alu_y   : std_logic_vector(31 downto 0);
  signal eyosi_A_q   : std_logic_vector(31 downto 0);
  signal eyosi_B_q   : std_logic_vector(31 downto 0);
  signal eyu_bad     : std_logic;

  -- ===== Encoder helpers =====

  -- ADDI rd, x0, imm12  (seed regs)
  function enc_addi_x0(rd : natural; imm12 : integer) return std_logic_vector is
    variable v  : unsigned(31 downto 0) := (others => '0');
    variable ui : signed(11 downto 0);
  begin
    ui := to_signed(imm12, 12);
    v  := to_unsigned(16#13#, 32);                      -- 0010011
    v  := v + shift_left(to_unsigned(rd, 32), 7);
    v  := v + shift_left(to_unsigned(0, 32), 12);
    v  := v + shift_left(resize(unsigned(ui), 32), 20);
    return std_logic_vector(v);
  end function;

  -- read back a register without changing state: ADDI x0, rs1, 0
  function enc_addi_read(rs1 : natural) return std_logic_vector is
    variable v : unsigned(31 downto 0) := (others => '0');
  begin
    v := to_unsigned(16#13#, 32);
    v := v + shift_left(to_unsigned(rs1, 32), 15);
    return std_logic_vector(v);
  end function;

  -- Generic I-type ALU
  function enc_I(rs1, rd, funct3 : natural; imm12 : integer) return std_logic_vector is
    variable v  : unsigned(31 downto 0) := (others => '0');
    variable ui : signed(11 downto 0);
  begin
    ui := to_signed(imm12, 12);
    v  := to_unsigned(16#13#, 32);                      -- 0010011
    v  := v + shift_left(resize(unsigned(ui), 32), 20); -- imm
    v  := v + shift_left(to_unsigned(rs1, 32), 15);
    v  := v + shift_left(to_unsigned(funct3, 32), 12);
    v  := v + shift_left(to_unsigned(rd, 32), 7);
    return std_logic_vector(v);
  end function;

  -- I-type shifts
  function enc_I_shift(rs1, rd, funct3, funct7, shamt : natural) return std_logic_vector is
    variable v   : unsigned(31 downto 0) := (others => '0');
    constant sh5 : natural := shamt mod 32;
  begin
    v := to_unsigned(16#13#, 32);                       -- 0010011
    v := v + shift_left(to_unsigned(funct7, 32), 25);
    v := v + shift_left(to_unsigned(sh5,   32), 20);
    v := v + shift_left(to_unsigned(rs1,   32), 15);
    v := v + shift_left(to_unsigned(funct3,32), 12);
    v := v + shift_left(to_unsigned(rd,    32), 7);
    return std_logic_vector(v);
  end function;

  -- R-type
  function enc_R(funct7, rs2, rs1, funct3, rd : natural) return std_logic_vector is
    variable v : unsigned(31 downto 0) := (others => '0');
  begin
    v := to_unsigned(16#33#, 32);                       -- 0110011
    v := v + shift_left(to_unsigned(funct7, 32), 25);
    v := v + shift_left(to_unsigned(rs2, 32), 20);
    v := v + shift_left(to_unsigned(rs1, 32), 15);
    v := v + shift_left(to_unsigned(funct3, 32), 12);
    v := v + shift_left(to_unsigned(rd, 32), 7);
    return std_logic_vector(v);
  end function;

  -- U-type (LUI/AUIPC)
  function enc_U(opcode, rd : natural; imm20 : integer) return std_logic_vector is
    variable v  : unsigned(31 downto 0) := (others => '0');
    variable ui : signed(19 downto 0);
  begin
    ui := to_signed(imm20, 20);
    v  := to_unsigned(opcode, 32);
    v  := v + shift_left(resize(unsigned(ui), 32), 12);
    v  := v + shift_left(to_unsigned(rd, 32), 7);
    return std_logic_vector(v);
  end function;

  -- B-type (offset in bytes)
  function enc_B(rs2, rs1, funct3 : natural; offset_bytes : integer) return std_logic_vector is
    variable v  : unsigned(31 downto 0) := (others => '0');
    variable imm : integer := offset_bytes / 2;
    variable ui  : signed(12 downto 0);
  begin
    ui := to_signed(imm, 13);
    v  := to_unsigned(16#63#, 32);                      -- 1100011
    v  := v + shift_left(to_unsigned(to_integer(unsigned(std_logic_vector(ui(12 downto 12)))), 32), 31);
    v  := v + shift_left(to_unsigned(to_integer(unsigned(std_logic_vector(ui(10 downto 5)))), 32), 25);
    v  := v + shift_left(to_unsigned(rs2, 32), 20);
    v  := v + shift_left(to_unsigned(rs1, 32), 15);
    v  := v + shift_left(to_unsigned(funct3, 32), 12);
    v  := v + shift_left(to_unsigned(to_integer(unsigned(std_logic_vector(ui(4 downto 1)))), 32), 8);
    v  := v + shift_left(to_unsigned(to_integer(unsigned(std_logic_vector(ui(11 downto 11)))), 32), 7);
    return std_logic_vector(v);
  end function;

  -- J-type (offset in bytes)
  function enc_J(rd : natural; offset_bytes : integer) return std_logic_vector is
    variable v  : unsigned(31 downto 0) := (others => '0');
    variable imm : integer := offset_bytes / 2;
    variable ui  : signed(20 downto 0);
  begin
    ui := to_signed(imm, 21);
    v  := to_unsigned(16#6F#, 32);                      -- 1101111
    v  := v + shift_left(to_unsigned(to_integer(unsigned(std_logic_vector(ui(20 downto 20)))), 32), 31);
    v  := v + shift_left(to_unsigned(to_integer(unsigned(std_logic_vector(ui(10 downto 1)))), 32), 21);
    v  := v + shift_left(to_unsigned(to_integer(unsigned(std_logic_vector(ui(11 downto 11)))), 32), 20);
    v  := v + shift_left(to_unsigned(to_integer(unsigned(std_logic_vector(ui(19 downto 12)))), 32), 12);
    v  := v + shift_left(to_unsigned(rd, 32), 7);
    return std_logic_vector(v);
  end function;

  -- Loads / Stores
  function enc_I_load(rs1, rd, funct3 : natural; imm12 : integer) return std_logic_vector is
    variable v  : unsigned(31 downto 0) := (others => '0');
    variable ui : signed(11 downto 0);
  begin
    ui := to_signed(imm12, 12);
    v  := to_unsigned(16#03#, 32);                      -- 0000011
    v  := v + shift_left(resize(unsigned(ui), 32), 20);
    v  := v + shift_left(to_unsigned(rs1, 32), 15);
    v  := v + shift_left(to_unsigned(funct3, 32), 12);
    v  := v + shift_left(to_unsigned(rd, 32), 7);
    return std_logic_vector(v);
  end function;

  function enc_S(rs2, rs1, funct3 : natural; imm12 : integer) return std_logic_vector is
    variable v  : unsigned(31 downto 0) := (others => '0');
    variable ui : signed(11 downto 0);
  begin
    ui := to_signed(imm12, 12);
    v  := to_unsigned(16#23#, 32);                      -- 0100011
    v  := v + shift_left(resize(unsigned(ui(11 downto 5)), 32), 25);
    v  := v + shift_left(to_unsigned(rs2, 32), 20);
    v  := v + shift_left(to_unsigned(rs1, 32), 15);
    v  := v + shift_left(to_unsigned(funct3, 32), 12);
    v  := v + shift_left(resize(unsigned(ui(4 downto 0)), 32), 7);
    return std_logic_vector(v);
  end function;

  function to_u32(slv : std_logic_vector) return unsigned is
  begin
    return unsigned(slv);
  end function;

begin
  -- clock
  eyu_clk <= not eyu_clk after T/2;

  -- UUT
  UUT: entity work.connector
    port map (
      clk         => eyu_clk,
      reset       => eyu_reset,
      eyu         => eyu_instr,
      pc_q        => eyu_pc_q,
      alu_y       => eyu_alu_y,
      regA_q      => eyosi_A_q,
      regB_q      => eyosi_B_q,
      eyu_illegal => eyu_bad
    );

  -- ===================== STIMULUS =====================
  process
    variable pc0 : unsigned(31 downto 0);
    --variable pc_before := std_logic_vector(31 downto 0);
  begin
    -- reset
    eyu_instr <= (others => '0');
    eyu_reset <= '1'; wait for 2*T;
    eyu_reset <= '0'; wait for 1*T;

    -- base sanity
    eyu_instr <= x"00000013"; wait for 5 ns;       -- NOP
    assert eyu_bad='0' report "NOP flagged illegal" severity warning;
    eyu_instr <= (others => '0'); wait for 5 ns;   -- illegal
    assert eyu_bad='1' report "All-zero opcode should be illegal" severity warning;

    -- seed regs: x1=5, x2=12, x3=-1, x4=-8
    eyu_instr <= enc_addi_x0(1, 5);  wait for 2*T;
    eyu_instr <= enc_addi_x0(2,12);  wait for 2*T;
    eyu_instr <= enc_addi_x0(3,-1);  wait for 2*T;
    eyu_instr <= enc_addi_x0(4,-8);  wait for 2*T;

    ---------------------- U-type ----------------------
    eyu_instr <= enc_U(16#37#, 5, 16#12345#);  wait for 2*T; eyu_instr <= enc_addi_read(5); wait for 1*T;
    assert to_u32(eyosi_A_q)=to_unsigned(16#12345000#,32) report "LUI x5 wrong" severity warning;

    pc0 := to_u32(eyu_pc_q);
    eyu_instr <= enc_U(16#17#, 10, 16#00100#); wait for 2*T; eyu_instr <= enc_addi_read(10); wait for 1*T;
    assert to_u32(eyosi_A_q)=pc0 + shift_left(to_unsigned(16#00100#,32),12) report "AUIPC x10 wrong" severity warning;

    ---------------------- I-type ----------------------
    eyu_instr <= enc_I(1, 15, 0, 7);  wait for 2*T; eyu_instr <= enc_addi_read(15); wait for 1*T;
    assert to_u32(eyosi_A_q)=to_unsigned(12,32) report "ADDI x15 wrong" severity warning;

    eyu_instr <= enc_I(1, 16, 6, 3);  wait for 2*T; eyu_instr <= enc_addi_read(16); wait for 1*T;
    assert to_u32(eyosi_A_q)=to_unsigned(7,32) report "ORI x16 wrong" severity warning;

    eyu_instr <= enc_I(1, 17, 4, 10); wait for 2*T; eyu_instr <= enc_addi_read(17); wait for 1*T;
    assert to_u32(eyosi_A_q)=to_unsigned(15,32) report "XORI x17 wrong" severity warning;

    eyu_instr <= enc_I(1, 18, 7, 14); wait for 2*T; eyu_instr <= enc_addi_read(18); wait for 1*T;
    assert to_u32(eyosi_A_q)=to_unsigned(4,32) report "ANDI x18 wrong" severity warning;

    eyu_instr <= enc_I(4, 22, 2, -16); wait for 2*T; eyu_instr <= enc_addi_read(22); wait for 1*T;
    assert to_u32(eyosi_A_q)=to_unsigned(0,32) report "SLTI x22 wrong" severity warning;

    eyu_instr <= enc_I(3, 23, 3, -1);  wait for 2*T; eyu_instr <= enc_addi_read(23); wait for 1*T;
    assert to_u32(eyosi_A_q)=to_unsigned(0,32) report "SLTIU x23 wrong" severity warning;

    eyu_instr <= enc_I_shift(2,19,1,0,1);   wait for 2*T; eyu_instr <= enc_addi_read(19); wait for 1*T;
    assert to_u32(eyosi_A_q)=to_unsigned(24,32) report "SLLI x19 wrong" severity warning;

    eyu_instr <= enc_I_shift(2,20,5,0,1);   wait for 2*T; eyu_instr <= enc_addi_read(20); wait for 1*T;
    assert to_u32(eyosi_A_q)=to_unsigned(6,32) report "SRLI x20 wrong" severity warning;

    eyu_instr <= enc_I_shift(4,21,5,32,1);  wait for 2*T; eyu_instr <= enc_addi_read(21); wait for 1*T;
    assert signed(eyosi_A_q)=to_signed(-4,32) report "SRAI x21 wrong" severity warning;

    ---------------------- R-type ----------------------
    eyu_instr <= enc_R(0, 2, 1, 0, 5);   wait for 2*T; eyu_instr <= enc_addi_read(5);  wait for 1*T;
    assert to_u32(eyosi_A_q)=to_unsigned(17,32) report "ADD x5 wrong" severity warning;

    eyu_instr <= enc_R(32,2, 1, 0, 6);   wait for 2*T; eyu_instr <= enc_addi_read(6);  wait for 1*T;
    assert signed(eyosi_A_q)=to_signed(-7,32) report "SUB x6 wrong" severity warning;

    eyu_instr <= enc_R(0, 2, 1, 7, 7);   wait for 2*T; eyu_instr <= enc_addi_read(7);  wait for 1*T;
    assert to_u32(eyosi_A_q)=to_unsigned(4,32) report "AND x7 wrong" severity warning;

    eyu_instr <= enc_R(0, 2, 1, 6, 8);   wait for 2*T; eyu_instr <= enc_addi_read(8);  wait for 1*T;
    assert to_u32(eyosi_A_q)=to_unsigned(13,32) report "OR x8 wrong" severity warning;

    eyu_instr <= enc_R(0, 2, 1, 4, 9);   wait for 2*T; eyu_instr <= enc_addi_read(9);  wait for 1*T;
    assert to_u32(eyosi_A_q)=to_unsigned(9,32) report "XOR x9 wrong" severity warning;

    eyu_instr <= enc_R(0, 2, 1, 1, 10);  wait for 2*T; eyu_instr <= enc_addi_read(10); wait for 1*T;
    assert to_u32(eyosi_A_q)=shift_left(to_unsigned(5,32), 12) report "SLL x10 wrong" severity warning;

    eyu_instr <= enc_R(0, 4, 1, 5, 11);  wait for 2*T; eyu_instr <= enc_addi_read(11); wait for 1*T;
    assert to_u32(eyosi_A_q)=to_unsigned(0,32) report "SRL x11 wrong" severity warning;

    eyu_instr <= enc_R(32,4, 1, 5, 12);  wait for 2*T; eyu_instr <= enc_addi_read(12); wait for 1*T;
    assert signed(eyosi_A_q)=to_signed(0,32) report "SRA x12 wrong" severity warning;

    eyu_instr <= enc_R(0, 3, 1, 2, 13);  wait for 2*T; eyu_instr <= enc_addi_read(13); wait for 1*T;
    assert to_u32(eyosi_A_q)=to_unsigned(0,32) report "SLT x13 wrong" severity warning;

    eyu_instr <= enc_R(0, 3, 1, 3, 14);  wait for 2*T; eyu_instr <= enc_addi_read(14); wait for 1*T;
    assert to_u32(eyosi_A_q)=to_unsigned(1,32) report "SLTU x14 wrong" severity warning;

    ---------------------- Branches ----------------------
    pc0 := to_u32(eyu_pc_q);  -- BEQ taken
    eyu_instr <= enc_B(1,1,0, 8); wait for 2*T; wait for 2*T; wait for 1*T;
    assert to_u32(eyu_pc_q)=pc0 + 8 report "BEQ taken wrong" severity warning;

    pc0 := to_u32(eyu_pc_q);  -- BNE not taken
    eyu_instr <= enc_B(1,1,1, 8); wait for 3*T; 
    assert to_u32(eyu_pc_q)=pc0 + 4 report "BNE not-taken wrong" severity warning;

    pc0 := to_u32(eyu_pc_q);  -- BLT signed taken: x4(-8) < x1(5)
    --pc_before := eyu_pc_q;
    eyu_instr <= enc_B(1,4,4, 8); wait for 2*T; wait for 2*T; wait for 1*T; 
    assert to_u32(eyu_pc_q)=unsigned(pc0) report "BLT taken wrong" severity warning;

    pc0 := to_u32(eyu_pc_q);  -- BGE signed not taken: -8 >= 5 false
    eyu_instr <= enc_B(1,4,5, 8); wait for 2*T; wait for 2*T; wait for 1*T;
    assert to_u32(eyu_pc_q)=unsigned(pc0) report "BGE not-taken wrong" severity warning;

    pc0 := to_u32(eyu_pc_q);  -- BLTU unsigned taken: 5 < 0xFFFF_FFFF
    eyu_instr <= enc_B(3,1,6, 8); wait for 2*T; wait for 1*T; wait for 2*T; wait for 1*T;
    assert to_u32(eyu_pc_q)=pc0 + 8 report "BLTU taken wrong" severity warning;

    pc0 := to_u32(eyu_pc_q);  -- BGEU unsigned taken: 0xFFFF_FFFF >= 5
    eyu_instr <= enc_B(1,3,7, 8); wait for 2*T; wait for 2*T; wait for 1*T;
    assert to_u32(eyu_pc_q)=pc0 + 8 report "BGEU taken wrong" severity warning;

    ---------------------- Jumps ----------------------
    pc0 := to_u32(eyu_pc_q);  -- JAL
    eyu_instr <= enc_J(6, 8); wait for 3*T;
    assert to_u32(eyu_pc_q)=pc0 + 8 report "JAL wrong (+8)" severity warning;

    -- JALR: (x1 + 4) & ~1  = 8  (since x1=5)
    eyu_instr <= enc_I(1, 7, 0, 4); wait for 3*T; wait for 4*T;
    assert to_u32(eyu_pc_q)=to_unsigned(8,32) report "JALR wrong (expect 8)" severity warning;

    ---------------------- Mem decode-only ----------------------
    eyu_instr <= enc_I_load(1, 7, 2, 12); wait for 1*T;  -- LW
    assert eyu_bad='0' report "LW illegal" severity warning;
    eyu_instr <= enc_S(2, 1, 2, 8);       wait for 1*T;  -- SW
    assert eyu_bad='0' report "SW illegal" severity warning;

    report "FULL TB finished" severity note;
    wait;
  end process;

end Behavioral;
