library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_fetch_connector is end tb_fetch_connector;

architecture sim of tb_fetch_connector is
  constant TCK : time := 10 ns;

  signal clk   : std_logic := '0';
  signal reset : std_logic := '1';
  signal M_AXI_ACLK    : std_logic;
  signal M_AXI_ARESETN : std_logic;
  
  signal M_AXI_ARID    : std_logic_vector(0 downto 0);
  signal M_AXI_ARADDR  : std_logic_vector(31 downto 0);
  signal M_AXI_ARLEN   : std_logic_vector(7 downto 0);
  signal M_AXI_ARSIZE  : std_logic_vector(2 downto 0);
  signal M_AXI_ARBURST : std_logic_vector(1 downto 0);
  signal M_AXI_ARLOCK  : std_logic;
  signal M_AXI_ARCACHE : std_logic_vector(3 downto 0);
  signal M_AXI_ARPROT  : std_logic_vector(2 downto 0);
  signal M_AXI_ARQOS   : std_logic_vector(3 downto 0);
  signal M_AXI_ARUSER  : std_logic_vector(0 downto 0);
  signal M_AXI_ARVALID : std_logic;
  signal M_AXI_ARREADY : std_logic;

  signal M_AXI_RID     : std_logic_vector(0 downto 0);
  signal M_AXI_RDATA   : std_logic_vector(31 downto 0);
  signal M_AXI_RRESP   : std_logic_vector(1 downto 0);
  signal M_AXI_RLAST   : std_logic;
  signal M_AXI_RUSER   : std_logic_vector(0 downto 0);
  signal M_AXI_RVALID  : std_logic;
  signal M_AXI_RREADY  : std_logic;

  signal M_AXI_AWID    : std_logic_vector(0 downto 0);
  signal M_AXI_AWADDR  : std_logic_vector(31 downto 0);
  signal M_AXI_AWLEN   : std_logic_vector(7 downto 0);
  signal M_AXI_AWSIZE  : std_logic_vector(2 downto 0);
  signal M_AXI_AWBURST : std_logic_vector(1 downto 0);
  signal M_AXI_AWLOCK  : std_logic;
  signal M_AXI_AWCACHE : std_logic_vector(3 downto 0);
  signal M_AXI_AWPROT  : std_logic_vector(2 downto 0);
  signal M_AXI_AWQOS   : std_logic_vector(3 downto 0);
  signal M_AXI_AWUSER  : std_logic_vector(0 downto 0);
  signal M_AXI_AWVALID : std_logic;
  signal M_AXI_AWREADY : std_logic;

  signal M_AXI_WDATA   : std_logic_vector(31 downto 0);
  signal M_AXI_WSTRB   : std_logic_vector(3 downto 0);
  signal M_AXI_WLAST   : std_logic;
  signal M_AXI_WUSER   : std_logic_vector(0 downto 0);
  signal M_AXI_WVALID  : std_logic;
  signal M_AXI_WREADY  : std_logic;

  signal M_AXI_BID     : std_logic_vector(0 downto 0);
  signal M_AXI_BRESP   : std_logic_vector(1 downto 0);
  signal M_AXI_BUSER   : std_logic_vector(0 downto 0);
  signal M_AXI_BVALID  : std_logic;
  signal M_AXI_BREADY  : std_logic;

  signal pc_q, alu_y, regA_q, regB_q : std_logic_vector(31 downto 0);
  signal eyu_BRcond                   : std_logic_vector(2 downto 0);
  signal eyu_illegal                  : std_logic;
  signal eyu_load_data, eyu_store_data: std_logic_vector(31 downto 0);

  function hex32(slv : std_logic_vector(31 downto 0)) return string is
    constant HEX : string := "0123456789ABCDEF";
    variable s   : string(1 to 8);
    variable n   : integer;
  begin
    for i in 0 to 7 loop
      n := to_integer(unsigned(slv(31-4*i downto 28-4*i)));
      s(i+1) := HEX(n+1);
    end loop;
    return s;
  end function;

begin
  clk <= not clk after TCK/2;

  process
  begin
    reset <= '1';
    wait for 100 ns;
    reset <= '0';
    wait;
  end process;

  -- DUT
  U_DUT: entity work.fetch_connector
    port map (
      clk               => clk,
      reset             => reset,
      M_AXI_ACLK        => M_AXI_ACLK,
      M_AXI_ARESETN     => M_AXI_ARESETN,
      M_AXI_ARID        => M_AXI_ARID,
      M_AXI_ARADDR      => M_AXI_ARADDR,
      M_AXI_ARLEN       => M_AXI_ARLEN,
      M_AXI_ARSIZE      => M_AXI_ARSIZE,
      M_AXI_ARBURST     => M_AXI_ARBURST,
      M_AXI_ARLOCK      => M_AXI_ARLOCK,
      M_AXI_ARCACHE     => M_AXI_ARCACHE,
      M_AXI_ARPROT      => M_AXI_ARPROT,
      M_AXI_ARQOS       => M_AXI_ARQOS,
      M_AXI_ARUSER      => M_AXI_ARUSER,
      M_AXI_ARVALID     => M_AXI_ARVALID,
      M_AXI_ARREADY     => M_AXI_ARREADY,
      M_AXI_RID         => M_AXI_RID,
      M_AXI_RDATA       => M_AXI_RDATA,
      M_AXI_RRESP       => M_AXI_RRESP,
      M_AXI_RLAST       => M_AXI_RLAST,
      M_AXI_RUSER       => M_AXI_RUSER,
      M_AXI_RVALID      => M_AXI_RVALID,
      M_AXI_RREADY      => M_AXI_RREADY,
      M_AXI_AWID        => M_AXI_AWID,
      M_AXI_AWADDR      => M_AXI_AWADDR,
      M_AXI_AWLEN       => M_AXI_AWLEN,
      M_AXI_AWSIZE      => M_AXI_AWSIZE,
      M_AXI_AWBURST     => M_AXI_AWBURST,
      M_AXI_AWLOCK      => M_AXI_AWLOCK,
      M_AXI_AWCACHE     => M_AXI_AWCACHE,
      M_AXI_AWPROT      => M_AXI_AWPROT,
      M_AXI_AWQOS       => M_AXI_AWQOS,
      M_AXI_AWUSER      => M_AXI_AWUSER,
      M_AXI_AWVALID     => M_AXI_AWVALID,
      M_AXI_AWREADY     => M_AXI_AWREADY,
      M_AXI_WDATA       => M_AXI_WDATA,
      M_AXI_WSTRB       => M_AXI_WSTRB,
      M_AXI_WLAST       => M_AXI_WLAST,
      M_AXI_WUSER       => M_AXI_WUSER,
      M_AXI_WVALID      => M_AXI_WVALID,
      M_AXI_WREADY      => M_AXI_WREADY,
      M_AXI_BID         => M_AXI_BID,
      M_AXI_BRESP       => M_AXI_BRESP,
      M_AXI_BUSER       => M_AXI_BUSER,
      M_AXI_BVALID      => M_AXI_BVALID,
      M_AXI_BREADY      => M_AXI_BREADY,
      pc_q              => pc_q,
      alu_y             => alu_y,
      regA_q            => regA_q,
      regB_q            => regB_q,
      eyu_BRcond        => eyu_BRcond,
      eyu_illegal       => eyu_illegal,
      eyu_load_data     => eyu_load_data,
      eyu_store_data    => eyu_store_data
    );

  -- memory
  U_MEM: entity work.rom_model
    generic map (
      eyu_addr_width     => 32,
      eyu_data_width     => 32,
      eyu_mem_depth_word => 1024
    )
    port map (
      eyu_aclk      => M_AXI_ACLK,
      eyu_aresetn   => M_AXI_ARESETN,
      eyu_s_araddr  => M_AXI_ARADDR,
      eyu_s_arvalid => M_AXI_ARVALID,
      eyu_s_arready => M_AXI_ARREADY,
      eyu_s_rdata   => M_AXI_RDATA,
      eyu_s_rresp   => M_AXI_RRESP,
      eyu_s_rlast   => M_AXI_RLAST,
      eyu_s_rvalid  => M_AXI_RVALID,
      eyu_s_rready  => M_AXI_RREADY,
      eyu_s_awaddr  => M_AXI_AWADDR,
      eyu_s_awvalid => M_AXI_AWVALID,
      eyu_s_awready => M_AXI_AWREADY,
      eyu_s_wdata   => M_AXI_WDATA,
      eyu_s_wstrb   => M_AXI_WSTRB,
      eyu_s_wlast   => M_AXI_WLAST,
      eyu_s_wvalid  => M_AXI_WVALID,
      eyu_s_wready  => M_AXI_WREADY,
      eyu_s_bresp   => M_AXI_BRESP,
      eyu_s_bvalid  => M_AXI_BVALID,
      eyu_s_bready  => M_AXI_BREADY
    );

  eyu_load: process(clk)
  begin
    if rising_edge(clk) then
      if (reset='0') and (M_AXI_RVALID='1' and M_AXI_RREADY='1') then
        report "LOAD  AR=0x" & hex32(M_AXI_ARADDR) &
               " RDATA=0x" & hex32(M_AXI_RDATA);
      end if;
    end if;
  end process;

  eyu_store: process(clk)
  begin
    if rising_edge(clk) then
      if (reset='0') and (M_AXI_AWVALID='1' and M_AXI_AWREADY='1') then
        report "STORE AW=0x" & hex32(M_AXI_AWADDR) &
               " WDATA=0x" & hex32(M_AXI_WDATA);
      end if;
    end if;
  end process;

end architecture;
