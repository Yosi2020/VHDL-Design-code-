library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity load_store_unit is
  generic (
    C_M_TARGET_SLAVE_BASE_ADDR : std_logic_vector := x"00000000";
    C_M_AXI_BURST_LEN          : integer := 1;
    C_M_AXI_ID_WIDTH           : integer := 1;
    C_M_AXI_ADDR_WIDTH         : integer := 32;
    C_M_AXI_DATA_WIDTH         : integer := 32;
    C_M_AXI_AWUSER_WIDTH       : integer := 1;
    C_M_AXI_ARUSER_WIDTH       : integer := 1;
    C_M_AXI_WUSER_WIDTH        : integer := 1;
    C_M_AXI_RUSER_WIDTH        : integer := 1;
    C_M_AXI_BUSER_WIDTH        : integer := 1
  );
  port (
    -- control
    Start_load  : in  std_logic;  -- 1-cycle pulse
    Start_store : in  std_logic;  -- 1-cycle pulse
    address     : in  std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
    store_data  : in  std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
    func3       : in  std_logic_vector(2 downto 0);          -- RV func3
    load_data   : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
    ls_ready    : out std_logic;                              -- done pulse

    -- AXI clock/reset
    M_AXI_ACLK    : in  std_logic;
    M_AXI_ARESETN : in  std_logic; -- active-low

    -- AXI Write Address
    M_AXI_AWID    : out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
    M_AXI_AWADDR  : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
    M_AXI_AWLEN   : out std_logic_vector(7 downto 0);
    M_AXI_AWSIZE  : out std_logic_vector(2 downto 0);
    M_AXI_AWBURST : out std_logic_vector(1 downto 0);
    M_AXI_AWLOCK  : out std_logic;
    M_AXI_AWCACHE : out std_logic_vector(3 downto 0);
    M_AXI_AWPROT  : out std_logic_vector(2 downto 0);
    M_AXI_AWQOS   : out std_logic_vector(3 downto 0);
    M_AXI_AWUSER  : out std_logic_vector(C_M_AXI_AWUSER_WIDTH-1 downto 0);
    M_AXI_AWVALID : out std_logic;
    M_AXI_AWREADY : in  std_logic;

    -- AXI Write Data
    M_AXI_WDATA   : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
    M_AXI_WSTRB   : out std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
    M_AXI_WLAST   : out std_logic;
    M_AXI_WUSER   : out std_logic_vector(C_M_AXI_WUSER_WIDTH-1 downto 0);
    M_AXI_WVALID  : out std_logic;
    M_AXI_WREADY  : in  std_logic;

    -- AXI Write Response
    M_AXI_BRESP   : in  std_logic_vector(1 downto 0);
    M_AXI_BVALID  : in  std_logic;
    M_AXI_BREADY  : out std_logic;

    -- AXI Read Address
    M_AXI_ARID    : out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
    M_AXI_ARADDR  : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
    M_AXI_ARLEN   : out std_logic_vector(7 downto 0);
    M_AXI_ARSIZE  : out std_logic_vector(2 downto 0);
    M_AXI_ARBURST : out std_logic_vector(1 downto 0);
    M_AXI_ARLOCK  : out std_logic;
    M_AXI_ARCACHE : out std_logic_vector(3 downto 0);
    M_AXI_ARPROT  : out std_logic_vector(2 downto 0);
    M_AXI_ARQOS   : out std_logic_vector(3 downto 0);
    M_AXI_ARUSER  : out std_logic_vector(C_M_AXI_ARUSER_WIDTH-1 downto 0);
    M_AXI_ARVALID : out std_logic;
    M_AXI_ARREADY : in  std_logic;

    -- AXI Read Data
    M_AXI_RDATA   : in  std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
    M_AXI_RRESP   : in  std_logic_vector(1 downto 0);
    M_AXI_RLAST   : in  std_logic;
    M_AXI_RVALID  : in  std_logic;
    M_AXI_RREADY  : out std_logic
  );
end load_store_unit;

architecture Behavioral of load_store_unit is
  type ls_state_type is (IDLE, READ_ADDR, READ_DATA, AW_W, WRITE_RESP);
  signal state : ls_state_type := IDLE;

  -- registered AXI outputs
  signal araddr_r  : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0) := (others => '0');
  signal arvalid_r : std_logic := '0';
  signal rready_r  : std_logic := '0';
  signal func3_r   : std_logic_vector(2 downto 0) := (others => '0');

  signal awaddr_r  : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0) := (others => '0');
  signal awvalid_r : std_logic := '0';
  signal wdata_r   : std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0) := (others => '0');
  signal wstrb_r   : std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0) := (others => '0');
  signal wlast_r   : std_logic := '0';
  signal wvalid_r  : std_logic := '0';
  signal bready_r  : std_logic := '0';

  signal load_data_r : std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0) := (others => '0');
  signal ls_ready_r  : std_logic := '0';
  signal addr_lsb_r  : std_logic_vector(1 downto 0) := (others => '0');

  -- this one is for sext8
  function sext8(b : std_logic_vector(7 downto 0)) return std_logic_vector is
    variable r : std_logic_vector(31 downto 0);
  begin
    r := (others => b(7)); r(7 downto 0) := b; return r;
  end;

  function sext16(h : std_logic_vector(15 downto 0)) return std_logic_vector is
    variable r : std_logic_vector(31 downto 0);
  begin
    r := (others => h(15)); r(15 downto 0) := h; return r;
  end;

  function wstrb_for(f3 : std_logic_vector(2 downto 0);
                     addr : std_logic_vector) return std_logic_vector is
    variable s : std_logic_vector(3 downto 0);
  begin
    case f3 is
      when "010" => s := "1111";                                -- Store word
      when "001" => if addr(1)='0' then s := "0011"; else s := "1100"; end if; -- Store H
      when "000" =>                                              -- Store byte
        case addr(1 downto 0) is
          when "00" => s := "0001";
          when "01" => s := "0010";
          when "10" => s := "0100";
          when others => s := "1000";
        end case;
      when others => s := "1111";
    end case;
    return s;
  end;

  function wdata_for(f3 : std_logic_vector(2 downto 0);
                     din : std_logic_vector;
                     addr: std_logic_vector) return std_logic_vector is
    variable w : std_logic_vector(31 downto 0) := (others => '0');
  begin
    case f3 is
      when "010" => w := din;                                   
      when "001" =>                                           
        if addr(1)='0' then w(15 downto 0) := din(15 downto 0);
                      else w(31 downto 16) := din(15 downto 0); end if;
      when "000" =>                                             
        case addr(1 downto 0) is
          when "00" => w(7  downto 0)  := din(7 downto 0);
          when "01" => w(15 downto 8)  := din(7 downto 0);
          when "10" => w(23 downto 16) := din(7 downto 0);
          when others => w(31 downto 24) := din(7 downto 0);
        end case;
      when others => w := din;
    end case;
    return w;
  end;

  function align_and_extend(f3 : std_logic_vector(2 downto 0);
                            rdat: std_logic_vector;
                            addr: std_logic_vector) return std_logic_vector is
    variable res : std_logic_vector(31 downto 0) := (others => '0');
    variable b   : std_logic_vector(7  downto 0);
    variable h   : std_logic_vector(15 downto 0);
  begin
    case f3 is
      when "010" => res := rdat;                                
      when "000" =>                                            
        case addr(1 downto 0) is
          when "00" => b := rdat(7  downto 0);
          when "01" => b := rdat(15 downto 8);
          when "10" => b := rdat(23 downto 16);
          when others => b := rdat(31 downto 24);
        end case; res := sext8(b);
      when "100" =>                                            
        case addr(1 downto 0) is
          when "00" => res(7 downto 0) := rdat(7  downto 0);
          when "01" => res(7 downto 0) := rdat(15 downto 8);
          when "10" => res(7 downto 0) := rdat(23 downto 16);
          when others => res(7 downto 0) := rdat(31 downto 24);
        end case;
      when "001" =>                                            
        if addr(1)='0' then h := rdat(15 downto 0); else h := rdat(31 downto 16); end if;
        res := sext16(h);
      when "101" =>                                            
        if addr(1)='0' then res(15 downto 0) := rdat(15 downto 0);
                        else res(15 downto 0) := rdat(31 downto 16); end if;
      when others => res := rdat;
    end case;
    return res;
  end;

begin
  M_AXI_ARID    <= (others => '0');
  M_AXI_ARLEN   <= (others => '0');       
  M_AXI_ARSIZE  <= "010";                 
  M_AXI_ARBURST <= "01";                  
  M_AXI_ARLOCK  <= '0';
  M_AXI_ARCACHE <= "0010";
  M_AXI_ARPROT  <= "000";
  M_AXI_ARQOS   <= (others => '0');
  M_AXI_ARUSER  <= (others => '0');

  M_AXI_AWID    <= (others => '0');
  M_AXI_AWLEN   <= (others => '0');
  M_AXI_AWSIZE  <= "010";
  M_AXI_AWBURST <= "01";
  M_AXI_AWLOCK  <= '0';
  M_AXI_AWCACHE <= "0010";
  M_AXI_AWPROT  <= "000";
  M_AXI_AWQOS   <= (others => '0');
  M_AXI_AWUSER  <= (others => '0');

  M_AXI_WUSER   <= (others => '0');

  -- registered outs
  M_AXI_ARADDR  <= araddr_r;
  M_AXI_ARVALID <= arvalid_r;
  M_AXI_RREADY  <= rready_r;

  M_AXI_AWADDR  <= awaddr_r;
  M_AXI_AWVALID <= awvalid_r;
  M_AXI_WDATA   <= wdata_r;
  M_AXI_WSTRB   <= wstrb_r;
  M_AXI_WLAST   <= wlast_r;
  M_AXI_WVALID  <= wvalid_r;
  M_AXI_BREADY  <= bready_r;

  load_data     <= load_data_r;
  ls_ready      <= ls_ready_r;

  --- FSM
  process(M_AXI_ACLK)
  begin
    if rising_edge(M_AXI_ACLK) then
      if M_AXI_ARESETN = '0' then
        state      <= IDLE;
        arvalid_r  <= '0'; rready_r  <= '0';
        awvalid_r  <= '0'; wvalid_r  <= '0'; wlast_r <= '0'; bready_r <= '0';
        ls_ready_r <= '0'; load_data_r <= (others => '0');
      else
        ls_ready_r <= '0'; 

        case state is
          when IDLE =>
            wlast_r <= '0';
            if Start_load = '1' then
              addr_lsb_r <= address(1 downto 0);
              araddr_r   <= address(C_M_AXI_ADDR_WIDTH-1 downto 2) & "00"; -- used for align
              func3_r    <= func3;
              arvalid_r  <= '1';
              rready_r   <= '0';
              state      <= READ_ADDR;
            elsif Start_store = '1' then
              addr_lsb_r <= address(1 downto 0);
              awaddr_r   <= address(C_M_AXI_ADDR_WIDTH-1 downto 2) & "00";
              awvalid_r  <= '1';
              wdata_r    <= wdata_for(func3, store_data, address(1 downto 0));
              wstrb_r    <= wstrb_for(func3, address(1 downto 0));
              wlast_r    <= '1'; --write last
              wvalid_r   <= '1';
              bready_r   <= '1';  -- accept response
              state      <= AW_W;
            end if;

          when READ_ADDR =>
            if M_AXI_ARREADY = '1' then
              arvalid_r <= '0';
              rready_r  <= '1';         -- be ready 
              state     <= READ_DATA;
            end if;

          when READ_DATA =>
            if (M_AXI_RVALID = '1') and (rready_r = '1') then
              load_data_r <= align_and_extend(func3_r, M_AXI_RDATA, addr_lsb_r);
              rready_r    <= '0';
              ls_ready_r  <= '1';
              state       <= IDLE;
            end if;

          --------------------------------------------------------------------
          when AW_W =>
            bready_r <= '1';
            if M_AXI_AWREADY = '1' then awvalid_r <= '0'; end if;
            if M_AXI_WREADY  = '1' then wvalid_r  <= '0'; end if;
            if ((awvalid_r='0' or M_AXI_AWREADY='1') and
                (wvalid_r ='0' or M_AXI_WREADY ='1')) then
              state <= WRITE_RESP;
            end if;

          --------------------------------------------------------------------
          when WRITE_RESP =>
            bready_r <= '1';
            if M_AXI_BVALID = '1' then
              bready_r   <= '0';
              ls_ready_r <= '1';
              state      <= IDLE;
            end if;

          when others =>
            state <= IDLE;
        end case;
      end if;
    end if;
  end process;

end Behavioral;
