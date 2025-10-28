library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rom_model is
  generic (
    eyu_addr_width     : integer := 32;
    eyu_data_width     : integer := 32;   
    eyu_mem_depth_word : integer := 1024 
  );
  port (
    eyu_aclk    : in  std_logic;
    eyu_aresetn : in  std_logic;         
    eyu_s_araddr  : in  std_logic_vector(eyu_addr_width-1 downto 0);
    eyu_s_arvalid : in  std_logic;
    eyu_s_arready : out std_logic;
    eyu_s_rdata   : out std_logic_vector(eyu_data_width-1 downto 0);
    eyu_s_rresp   : out std_logic_vector(1 downto 0);
    eyu_s_rlast   : out std_logic;
    eyu_s_rvalid  : out std_logic;
    eyu_s_rready  : in  std_logic;
    eyu_s_awaddr  : in  std_logic_vector(eyu_addr_width-1 downto 0);
    eyu_s_awvalid : in  std_logic;
    eyu_s_awready : out std_logic;
    eyu_s_wdata   : in  std_logic_vector(eyu_data_width-1 downto 0);
    eyu_s_wstrb   : in  std_logic_vector(eyu_data_width/8-1 downto 0);
    eyu_s_wlast   : in  std_logic;
    eyu_s_wvalid  : in  std_logic;
    eyu_s_wready  : out std_logic;
    eyu_s_bresp   : out std_logic_vector(1 downto 0);
    eyu_s_bvalid  : out std_logic;
    eyu_s_bready  : in  std_logic
  );
end rom_model;

architecture Behavioral of rom_model is
  subtype eyu_word_t is std_logic_vector(eyu_data_width-1 downto 0);
  type eyu_rom_t is array (0 to eyu_mem_depth_word-1) of eyu_word_t;

  -- retrun little-endian 
  function swap_bytes(x : std_logic_vector(31 downto 0)) return std_logic_vector is
  begin
    return x(7 downto 0) & x(15 downto 8) & x(23 downto 16) & x(31 downto 24);
  end;

  -- my rom data
  signal eyu_rom : eyu_rom_t := (
     0 => x"83200010", 
     1 => x"23221010",  
     2 => x"03214010",
     3 => x"83208010", 
     4 => x"23261010", 
     5 => x"0321C010",  
     6 => x"83200011",
     7 => x"232A1010",
     8 => x"03214011",
     9 => x"83208011",
    10 => x"232E1010",
    11 => x"0321C011",
    12 => x"83200012",
    13 => x"23221012",
    14 => x"03214012",
    15 => x"83208012",
    16 => x"23261012",
    17 => x"0321C012",
    18 => x"83200013",
    19 => x"232A1012",
    20 => x"03214013",
    21 => x"83208013",
    22 => x"232E1012",
    23 => x"0321C013",
    24 => x"83200014",
    25 => x"23221014",
    26 => x"03214014",
    27 => x"83208014",
    28 => x"23261014",
    29 => x"0321C014",
    30 => x"83200015",
    31 => x"232A1014",
    32 => x"03214015",
    33 => x"83208015",
    34 => x"232E1014",
    35 => x"0321C015",
    36 => x"63000000",  

    -- my datas
    64 => x"EFBEADDE",  
    66 => x"FEAFBCCF",  
    68 => x"CD9C8FFC",  
    70 => x"DC8D9EED",  
    72 => x"ABFAE99A",  
    74 => x"BAEBF88B",  
    76 => x"89D8CBB8",  
    78 => x"98C9DAA9",  
    80 => x"67362556",  
    82 => x"76273447",  
    84 => x"45140774",  
    86 => x"54051665",  

    others => (others => '0')
  );

  -- read
  signal eyu_arready_r : std_logic := '0';
  signal eyu_rvalid_r  : std_logic := '0';
  signal eyu_rdata_r   : std_logic_vector(eyu_data_width-1 downto 0) := (others => '0');
  signal eyu_rresp_r   : std_logic_vector(1 downto 0) := "00";
  signal eyu_araddr_r  : std_logic_vector(eyu_addr_width-1 downto 0) := (others => '0');
  signal eyu_have_req  : std_logic := '0';

  -- write
  signal eyu_awaddr_r  : std_logic_vector(eyu_addr_width-1 downto 0) := (others => '0');
  signal eyu_wready_r  : std_logic := '0';
  signal eyu_awready_r : std_logic := '0';
  signal eyu_bvalid_r  : std_logic := '0';
  signal eyu_bresp_r   : std_logic_vector(1 downto 0) := "00";
  signal eyu_bpend     : std_logic := '0';
begin
  eyu_s_rlast <= '1';
  eyu_s_arready <= eyu_arready_r;
  eyu_s_rvalid  <= eyu_rvalid_r;
  eyu_s_rdata   <= eyu_rdata_r;
  eyu_s_rresp   <= eyu_rresp_r;

  eyu_s_awready <= eyu_awready_r;
  eyu_s_wready  <= eyu_wready_r;
  eyu_s_bvalid  <= eyu_bvalid_r;
  eyu_s_bresp   <= eyu_bresp_r;

  process(eyu_aclk)
  begin
    if rising_edge(eyu_aclk) then
      if eyu_aresetn='0' then
        eyu_arready_r <= '0';
        eyu_awready_r <= '0';
        eyu_wready_r  <= '0';
      else
        -- ready
        eyu_arready_r <= (not eyu_have_req) and (not eyu_rvalid_r);
        eyu_awready_r <= '1';
        eyu_wready_r  <= '1';
      end if;
    end if;
  end process;

  process(eyu_aclk)
    variable eyu_idx  : integer;
    variable wd_be    : eyu_word_t;
    variable wd_le    : eyu_word_t;
  begin
    if rising_edge(eyu_aclk) then
      if eyu_aresetn='0' then
        -- reset
        eyu_rvalid_r <= '0';
        eyu_rdata_r  <= (others => '0');
        eyu_rresp_r  <= "00";
        eyu_have_req <= '0';
        eyu_araddr_r <= (others => '0');
        eyu_awaddr_r <= (others => '0');
        eyu_bpend    <= '0';
        eyu_bvalid_r <= '0';
        eyu_bresp_r  <= "00";

      else
        -- write address
        if (eyu_s_awvalid='1' and eyu_awready_r='1') then
          eyu_awaddr_r <= eyu_s_awaddr;
        end if;

        -- write data
        if (eyu_s_wvalid='1' and eyu_wready_r='1') then
          eyu_idx := to_integer(unsigned(eyu_awaddr_r(eyu_addr_width-1 downto 2)));
          if (eyu_idx >= 0) and (eyu_idx < eyu_mem_depth_word) then
            wd_be := eyu_rom(eyu_idx);
            wd_le := swap_bytes(wd_be);
            for b in 0 to (eyu_data_width/8 - 1) loop
              if eyu_s_wstrb(b)='1' then
                wd_le(8*(b+1)-1 downto 8*b) := eyu_s_wdata(8*(b+1)-1 downto 8*b);
              end if;
            end loop;
            eyu_rom(eyu_idx) <= swap_bytes(wd_le);
            eyu_bresp_r <= "00";  
          else
            eyu_bresp_r <= "10";  
          end if;
          eyu_bpend <= '1';
        end if;

        if (eyu_bpend='1') and (eyu_bvalid_r='0') then
          eyu_bvalid_r <= '1';
          eyu_bpend    <= '0';
        elsif (eyu_bvalid_r='1') and (eyu_s_bready='1') then
          eyu_bvalid_r <= '0';
        end if;

        if (eyu_s_arvalid='1' and eyu_arready_r='1') then
          eyu_araddr_r <= eyu_s_araddr;
          eyu_have_req <= '1';
        end if;

        -- read data
        if (eyu_have_req='1' and eyu_rvalid_r='0') then
          eyu_idx := to_integer(unsigned(eyu_araddr_r(eyu_addr_width-1 downto 2)));
          if (eyu_idx >= 0) and (eyu_idx < eyu_mem_depth_word) then
            eyu_rdata_r <= swap_bytes(eyu_rom(eyu_idx));
            eyu_rresp_r <= "00";
          else
            eyu_rdata_r <= (others => '0');
            eyu_rresp_r <= "10";
          end if;
          eyu_rvalid_r <= '1';
          eyu_have_req <= '0';
        elsif (eyu_rvalid_r='1' and eyu_s_rready='1') then
          eyu_rvalid_r <= '0';
        end if;

      end if;
    end if;
  end process;

end Behavioral;
