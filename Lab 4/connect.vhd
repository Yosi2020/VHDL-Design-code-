library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fetch_connector is
  port (
    clk   : in  std_logic;
    reset : in  std_logic;

    M_AXI_ACLK    : out std_logic;
    M_AXI_ARESETN : out std_logic;

    -- read address
    M_AXI_ARID    : out std_logic_vector(0 downto 0);
    M_AXI_ARADDR  : out std_logic_vector(31 downto 0);
    M_AXI_ARLEN   : out std_logic_vector(7 downto 0);
    M_AXI_ARSIZE  : out std_logic_vector(2 downto 0);
    M_AXI_ARBURST : out std_logic_vector(1 downto 0);
    M_AXI_ARLOCK  : out std_logic;
    M_AXI_ARCACHE : out std_logic_vector(3 downto 0);
    M_AXI_ARPROT  : out std_logic_vector(2 downto 0);
    M_AXI_ARQOS   : out std_logic_vector(3 downto 0);
    M_AXI_ARUSER  : out std_logic_vector(0 downto 0);
    M_AXI_ARVALID : out std_logic;
    M_AXI_ARREADY : in  std_logic;

    -- read data
    M_AXI_RID     : in  std_logic_vector(0 downto 0);
    M_AXI_RDATA   : in  std_logic_vector(31 downto 0);
    M_AXI_RRESP   : in  std_logic_vector(1 downto 0);
    M_AXI_RLAST   : in  std_logic;
    M_AXI_RUSER   : in  std_logic_vector(0 downto 0);
    M_AXI_RVALID  : in  std_logic;
    M_AXI_RREADY  : out std_logic;

    -- Write
    M_AXI_AWID    : out std_logic_vector(0 downto 0);
    M_AXI_AWADDR  : out std_logic_vector(31 downto 0);
    M_AXI_AWLEN   : out std_logic_vector(7 downto 0);
    M_AXI_AWSIZE  : out std_logic_vector(2 downto 0);
    M_AXI_AWBURST : out std_logic_vector(1 downto 0);
    M_AXI_AWLOCK  : out std_logic;
    M_AXI_AWCACHE : out std_logic_vector(3 downto 0);
    M_AXI_AWPROT  : out std_logic_vector(2 downto 0);
    M_AXI_AWQOS   : out std_logic_vector(3 downto 0);
    M_AXI_AWUSER  : out std_logic_vector(0 downto 0);
    M_AXI_AWVALID : out std_logic;
    M_AXI_AWREADY : in  std_logic;

    M_AXI_WDATA   : out std_logic_vector(31 downto 0);
    M_AXI_WSTRB   : out std_logic_vector(3 downto 0);
    M_AXI_WLAST   : out std_logic;
    M_AXI_WUSER   : out std_logic_vector(0 downto 0);
    M_AXI_WVALID  : out std_logic;
    M_AXI_WREADY  : in  std_logic;

    M_AXI_BID     : in  std_logic_vector(0 downto 0);
    M_AXI_BRESP   : in  std_logic_vector(1 downto 0);
    M_AXI_BUSER   : in  std_logic_vector(0 downto 0);
    M_AXI_BVALID  : in  std_logic;
    M_AXI_BREADY  : out std_logic;

    -- data path connection
    pc_q        : out std_logic_vector(31 downto 0);
    alu_y       : out std_logic_vector(31 downto 0);
    regA_q      : out std_logic_vector(31 downto 0);
    regB_q      : out std_logic_vector(31 downto 0);
    eyu_BRcond  : inout std_logic_vector(2 downto 0);
    eyu_store_data : out std_logic_vector(31 downto 0);
    eyu_load_data : out std_logic_vector(31 downto 0);
    eyu_illegal : out std_logic
  );
end fetch_connector;

architecture Behavioral of fetch_connector is
  -- signal for fetch handshake
  signal s_start_read     : std_logic := '0';
  signal s_read_done      : std_logic := '0';
  signal s_read_done_d1   : std_logic := '0';
  signal s_error          : std_logic := '0';
  signal s_data           : std_logic_vector(0 to 31) := (others => '0');

  signal instr_c          : std_logic_vector(31 downto 0) := (others => '0');
  signal instr_r          : std_logic_vector(31 downto 0) := (others => '0');

  signal pc_s             : std_logic_vector(31 downto 0);
  signal rstn_axi         : std_logic := '0';
  signal exec_en          : std_logic := '0';  
  signal exec_en_g        : std_logic := '0';  
  signal inflight         : std_logic := '0';

  --connector 
  signal eyu_lsaddress    : std_logic_vector(31 downto 0);
  signal eyu_store_data_s   : std_logic_vector(31 downto 0);
  signal eyu_load_data_s  : std_logic_vector(31 downto 0);
  signal eyu_func3        : std_logic_vector(2 downto 0);
  signal eyu_isLOAD       : std_logic;
  signal eyu_isSTORE      : std_logic;

  -- memory controller
  signal mem_active       : std_logic := '0';  
  signal mem_check        : std_logic := '0';  
  signal lsu_start_load_s : std_logic := '0';  
  signal lsu_start_store_s: std_logic := '0';
  signal ls_ready         : std_logic;

  
  signal i_ARADDR  : std_logic_vector(31 downto 0);
  signal i_ARVALID : std_logic;
  signal i_ARREADY : std_logic;
  signal i_RVALID  : std_logic;
  signal i_RLAST   : std_logic;
  signal i_RREADY  : std_logic;
  -- fetch read
  signal i_ARLEN   : std_logic_vector(7 downto 0);
  signal i_ARSIZE  : std_logic_vector(2 downto 0);
  signal i_ARBURST : std_logic_vector(1 downto 0);
  signal i_ARLOCK  : std_logic;
  signal i_ARCACHE : std_logic_vector(3 downto 0);
  signal i_ARPROT  : std_logic_vector(2 downto 0);
  signal i_ARQOS   : std_logic_vector(3 downto 0);
  signal i_ARUSER  : std_logic_vector(0 downto 0);

  -- fetch write
  signal i_AWID : std_logic_vector(0 downto 0);
  signal i_WUSER : std_logic_vector(0 downto 0);
  signal i_AWADDR  : std_logic_vector(31 downto 0);
  signal i_AWVALID : std_logic;
  signal i_AWLEN   : std_logic_vector(7 downto 0);
  signal i_AWSIZE  : std_logic_vector(2 downto 0);
  signal i_AWBURST : std_logic_vector(1 downto 0);
  signal i_AWLOCK  : std_logic;
  signal i_AWCACHE : std_logic_vector(3 downto 0);
  signal i_AWPROT  : std_logic_vector(2 downto 0);
  signal i_AWQOS   : std_logic_vector(3 downto 0);
  signal i_AWUSER  : std_logic_vector(0 downto 0);

  signal i_WDATA   : std_logic_vector(31 downto 0);
  signal i_WSTRB   : std_logic_vector(3 downto 0);
  signal i_WLAST   : std_logic;
  signal i_WVALID  : std_logic;
  signal i_BREADY  : std_logic;
  
  signal i_ARID_d : std_logic_vector(0 downto 0);
  signal i_ARUSER_d : std_logic_vector (0 downto 0);

  -- this one is for lsu
  signal d_ARADDR  : std_logic_vector(31 downto 0);
  signal d_ARVALID : std_logic;
  signal d_ARREADY : std_logic;
  signal d_RDATA   : std_logic_vector(31 downto 0);
  signal d_RVALID  : std_logic;
  signal d_RLAST   : std_logic;
  signal d_RREADY  : std_logic;

  signal d_AWADDR  : std_logic_vector(31 downto 0);
  signal d_AWVALID : std_logic;
  signal d_AWREADY : std_logic;
  signal d_WDATA   : std_logic_vector(31 downto 0);
  signal d_WSTRB   : std_logic_vector(3 downto 0);
  signal d_WLAST   : std_logic;
  signal d_WVALID  : std_logic;
  signal d_WREADY  : std_logic;
  signal d_BRESP   : std_logic_vector(1 downto 0);
  signal d_BVALID  : std_logic;
  signal d_BREADY  : std_logic;
  signal d_RRESP : std_logic_vector(1 downto 0);
begin
  
  M_AXI_ACLK    <= clk;
  rstn_axi      <= not reset;
  M_AXI_ARESETN <= rstn_axi;

  -- maping each data
  gen_map: for i in 0 to 31 generate
    instr_c(i) <= s_data(i);
  end generate;

  -- exec enable for datapath connector 
  exec_en_g <= exec_en and not mem_active;

  -- connector for datapath and decoder
  U_CORE: entity work.connector
    port map (
      clk         => clk,
      reset       => reset,
      eyu         => instr_r,
      exec_en     => exec_en_g,     
      pc_q        => pc_s,
      alu_y       => alu_y,
      regA_q      => regA_q,
      regB_q      => regB_q,
      eyu_illegal => eyu_illegal,
      eyu_BRcond  => eyu_BRcond,
      eyu_lsaddress => eyu_lsaddress,
      eyu_store_data=> eyu_store_data_s,
      eyu_load_data => eyu_load_data_s,
      eyu_func3     => eyu_func3,
      eyu_isLOAD    => eyu_isLOAD,
      eyu_isSTORE   => eyu_isSTORE,
      ls_ready => ls_ready
    );
  pc_q <= pc_s;

  -- fetch
  U_FETCH: entity work.entity_name
    generic map (
      C_M_AXI_ID_WIDTH     => 1,
      C_M_AXI_ADDR_WIDTH   => 32,
      C_M_AXI_DATA_WIDTH   => 32,
      C_M_AXI_AWUSER_WIDTH => 1,
      C_M_AXI_ARUSER_WIDTH => 1,
      C_M_AXI_WUSER_WIDTH  => 1,
      C_M_AXI_RUSER_WIDTH  => 1,
      C_M_AXI_BUSER_WIDTH  => 1
    )
    port map (
      Start_read   => s_start_read,
      Read_address => pc_s,
      Read_Done    => s_read_done,
      Read_Data    => s_data,
      Error        => s_error,
      M_AXI_ACLK    => clk,
      M_AXI_ARESETN => rstn_axi,
      M_AXI_ARID    => i_ARID_d,      
      M_AXI_ARADDR  => i_ARADDR,
      M_AXI_ARLEN   => i_ARLEN,
      M_AXI_ARSIZE  => i_ARSIZE,
      M_AXI_ARBURST => i_ARBURST,
      M_AXI_ARLOCK  => i_ARLOCK,
      M_AXI_ARCACHE => i_ARCACHE,
      M_AXI_ARPROT  => i_ARPROT,
      M_AXI_ARQOS   => i_ARQOS,
      M_AXI_ARUSER  => i_ARUSER_d,
      M_AXI_ARVALID => i_ARVALID,
      M_AXI_ARREADY => i_ARREADY,
      M_AXI_RID     => M_AXI_RID,
      M_AXI_RDATA   => M_AXI_RDATA,
      M_AXI_RRESP   => M_AXI_RRESP,
      M_AXI_RLAST   => i_RLAST,
      M_AXI_RUSER   => M_AXI_RUSER,
      M_AXI_RVALID  => i_RVALID,
      M_AXI_RREADY  => i_RREADY,
      M_AXI_AWID    => i_AWID,
      M_AXI_AWADDR  => i_AWADDR,
      M_AXI_AWLEN   => i_AWLEN,
      M_AXI_AWSIZE  => i_AWSIZE,
      M_AXI_AWBURST => i_AWBURST,
      M_AXI_AWLOCK  => i_AWLOCK,
      M_AXI_AWCACHE => i_AWCACHE,
      M_AXI_AWPROT  => i_AWPROT,
      M_AXI_AWQOS   => i_AWQOS,
      M_AXI_AWUSER  => i_AWUSER,
      M_AXI_AWVALID => i_AWVALID,
      M_AXI_AWREADY => '0',
      M_AXI_WDATA   => i_WDATA,
      M_AXI_WSTRB   => i_WSTRB,
      M_AXI_WLAST   => i_WLAST,
      M_AXI_WUSER   => i_WUSER,
      M_AXI_WVALID  => i_WVALID,
      M_AXI_WREADY  => '0',
      M_AXI_BID     => M_AXI_BID,
      M_AXI_BRESP   => M_AXI_BRESP,
      M_AXI_BUSER   => M_AXI_BUSER,
      M_AXI_BVALID  => '0',
      M_AXI_BREADY  => open
    );

  -- load store
  U_LSU : entity work.load_store_unit
    port map (
      M_AXI_ACLK    => clk,
      M_AXI_ARESETN => rstn_axi,
      start_load    => lsu_start_load_s,
      start_store   => lsu_start_store_s,
      ls_ready      => ls_ready,
      address       => eyu_lsaddress,
      store_data    => eyu_store_data_s,
      load_data     => eyu_load_data_s,
      func3         => eyu_func3,
      M_AXI_ARADDR  => d_ARADDR,
      M_AXI_ARVALID => d_ARVALID,
      M_AXI_ARREADY => d_ARREADY,
      M_AXI_RDATA   => d_RDATA,
      M_AXI_RVALID  => d_RVALID,
      M_AXI_RLAST   => d_RLAST,
      M_AXI_RREADY  => d_RREADY,
      M_AXI_AWADDR  => d_AWADDR,
      M_AXI_AWVALID => d_AWVALID,
      M_AXI_AWREADY => d_AWREADY,
      M_AXI_WDATA   => d_WDATA,
      M_AXI_WSTRB   => d_WSTRB,
      M_AXI_WVALID  => d_WVALID,
      M_AXI_WLAST   => d_WLAST,
      M_AXI_WREADY  => d_WREADY,
      M_AXI_BRESP   => d_BRESP,
      M_AXI_BVALID  => d_BVALID,
      M_AXI_BREADY  => d_BREADY,
      M_AXI_RRESP => d_RRESP
    );
    eyu_store_data <= eyu_store_data_s;
    eyu_load_data <= eyu_load_data_s;

  -- doing bus
  M_AXI_ARADDR  <= d_ARADDR  when mem_active='1' else i_ARADDR;
  M_AXI_ARVALID <= d_ARVALID when mem_active='1' else i_ARVALID;
  M_AXI_RREADY  <= d_RREADY  when mem_active='1' else i_RREADY;
  M_AXI_ARID    <= (others => '0');
  M_AXI_ARLEN   <= (others => '0');
  M_AXI_ARSIZE  <= "010";
  M_AXI_ARBURST <= "01";
  M_AXI_ARLOCK  <= '0';
  M_AXI_ARCACHE <= "0010";
  M_AXI_ARPROT  <= "000";
  M_AXI_ARQOS   <= (others => '0');
  d_ARREADY <= M_AXI_ARREADY when mem_active='1' else '0';
  i_ARREADY <= M_AXI_ARREADY when mem_active='0' else '0';
  d_RDATA   <= M_AXI_RDATA;
  d_RVALID  <= M_AXI_RVALID when mem_active='1' else '0';
  d_RLAST   <= M_AXI_RLAST  when mem_active='1' else '0';
  i_RVALID  <= M_AXI_RVALID when mem_active='0' else '0';
  i_RLAST   <= M_AXI_RLAST  when mem_active='0' else '0';
  d_RRESP <= M_AXI_RRESP;
  M_AXI_AWADDR  <= d_AWADDR  when mem_active='1' else (others => '0');
  M_AXI_AWVALID <= d_AWVALID when mem_active='1' else '0';
  d_AWREADY     <= M_AXI_AWREADY when mem_active='1' else '0';
  M_AXI_WDATA   <= d_WDATA   when mem_active='1' else (others => '0');
  M_AXI_WSTRB   <= d_WSTRB   when mem_active='1' else (others => '0');
  M_AXI_WLAST   <= d_WLAST   when mem_active='1' else '0';
  M_AXI_WVALID  <= d_WVALID  when mem_active='1' else '0';
  d_WREADY      <= M_AXI_WREADY when mem_active='1' else '0';
  M_AXI_BREADY  <= d_BREADY  when mem_active='1' else '0';
  d_BRESP       <= M_AXI_BRESP;
  d_BVALID      <= M_AXI_BVALID when mem_active='1' else '0';

  process(clk)
  begin
    if rising_edge(clk) then
      if reset='1' then  -- reset
        inflight          <= '0';
        s_start_read      <= '0';
        s_read_done_d1    <= '0';
        exec_en           <= '0';
        instr_r           <= (others => '0');
        mem_active        <= '0';
        mem_check         <= '0';
        lsu_start_load_s  <= '0';
        lsu_start_store_s <= '0';
      else   -- start read
        s_start_read      <= '0';
        exec_en           <= '0';
        lsu_start_load_s  <= '0';
        lsu_start_store_s <= '0';
        s_read_done_d1    <= s_read_done;

        if (mem_active='0') and (inflight='0') and (mem_check='0') then -- fetch next instr
          s_start_read <= '1';
          inflight     <= '1';
        end if;

        if (s_read_done='1') and (s_read_done_d1='0') then -- instr retrun
          instr_r <= instr_c;
          exec_en <= '1';        
          inflight <= '0';
          mem_check <= '1';       
        end if;

        if mem_check='1' then
          mem_check <= '0';
          if (eyu_isLOAD='1' or eyu_isSTORE='1') then
            mem_active <= '1';           -- give bus to lsu
            if eyu_isLOAD='1' then
              lsu_start_load_s <= '1';   
            else
              lsu_start_store_s <= '1';
            end if;
          end if;
        end if;
        if ls_ready='1' then -- when lsu is done
          mem_active <= '0';
        end if;
      end if;
    end if;
  end process;

end Behavioral;