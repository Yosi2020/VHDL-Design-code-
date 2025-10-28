library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity entity_name is
	generic (
		-- User parameters ends
		C_M_TARGET_SLAVE_BASE_ADDR : std_logic_vector	:= x"00000000"; -- Base address of targeted slave
		C_M_AXI_BURST_LEN	     : integer	:= 1; -- Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
		C_M_AXI_ID_WIDTH	     : integer	:= 1; -- Thread ID Width
		C_M_AXI_ADDR_WIDTH	   : integer	:= 32; -- Width of Address Bus
		C_M_AXI_DATA_WIDTH	   : integer	:= 32; -- Width of Data Bus
		C_M_AXI_AWUSER_WIDTH   : integer	:= 1; -- Width of User Write Address Bus
		C_M_AXI_ARUSER_WIDTH   : integer	:= 1; -- Width of User Read Address Bus
		C_M_AXI_WUSER_WIDTH	   : integer	:= 1; -- Width of User Write Data Bus
		C_M_AXI_RUSER_WIDTH	   : integer	:= 1; -- Width of User Read Data Bus
		C_M_AXI_BUSER_WIDTH	   : integer	:= 1  -- Width of User Response Bus
    );
	port (
		-- Users can add ports here. These are SUGGESTED user ports.
		Start_read	 : in std_logic;  -- Initiate AXI read transaction
    Read_address : in std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0); -- address to read from
 		Read_Done	: out std_logic; -- Asserts when transaction is complete
    Read_Data : out std_logic_vector(0 to C_M_AXI_DATA_WIDTH*C_M_AXI_BURST_LEN - 1); -- Data that was read (modify as needed)
		Error	: out std_logic; -- Asserts when ERROR is detected
		-- User ports ends
    -- Global AXI ports
		M_AXI_ACLK	: in std_logic;    -- Global Clock Signal.
		M_AXI_ARESETN	: in std_logic;  -- Global Reset Singal. This Signal is Active Low
    -- AXI Write Address Channel
		M_AXI_AWID	: out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0); -- Master Interface Write Address ID
		M_AXI_AWADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0); -- Master Interface Write Address
		M_AXI_AWLEN	: out std_logic_vector(7 downto 0); -- Burst length. The burst length gives the exact number of transfers in a burst
		M_AXI_AWSIZE	: out std_logic_vector(2 downto 0); -- Burst size. This signal indicates the size of each transfer in the burst
		M_AXI_AWBURST	: out std_logic_vector(1 downto 0); -- Burst type. The burst type and the size information, determine how the address for each transfer within the burst is calculated.
		M_AXI_AWLOCK	: out std_logic; -- Lock type. Provides additional information about the atomic characteristics of the transfer. 
		M_AXI_AWCACHE	: out std_logic_vector(3 downto 0); -- Memory type. This signal indicates how transactions are required to progress through a system.
		M_AXI_AWPROT	: out std_logic_vector(2 downto 0); -- Protection type. This signal indicates the privilege and security level of the transaction, and whether the transaction is a data access or an instruction access.
		M_AXI_AWQOS	: out std_logic_vector(3 downto 0); -- Quality of Service, QoS identifier sent for each write transaction.
		M_AXI_AWUSER	: out std_logic_vector(C_M_AXI_AWUSER_WIDTH-1 downto 0); -- Optional User-defined signal in the write address channel.
		M_AXI_AWVALID	: out std_logic; -- Write address valid. This signal indicates that the channel is signaling valid write address and control information.
		M_AXI_AWREADY	: in std_logic; -- Write address ready. This signal indicates that the slave is ready to accept an address and associated control signals
    -- AXI Write Data Channel
		M_AXI_WDATA	: out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0); -- Master Interface Write Data.
		M_AXI_WSTRB	: out std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0); -- Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.
		M_AXI_WLAST	: out std_logic; -- Write last. This signal indicates the last transfer in a write burst.
		M_AXI_WUSER	: out std_logic_vector(C_M_AXI_WUSER_WIDTH-1 downto 0); -- Optional User-defined signal in the write data channel.
		M_AXI_WVALID	: out std_logic; -- Write valid. This signal indicates that valid write data and strobes are available
		M_AXI_WREADY	: in std_logic; -- Write ready. This signal indicates that the slave can accept the write data.
    -- AXI Write Response Channel
		M_AXI_BID	: in std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0); -- Master Interface Write Response.
		M_AXI_BRESP	: in std_logic_vector(1 downto 0); -- Write response. This signal indicates the status of the write transaction.
		M_AXI_BUSER	: in std_logic_vector(C_M_AXI_BUSER_WIDTH-1 downto 0); -- Optional User-defined signal in the write response channel
		M_AXI_BVALID	: in std_logic; -- Write response valid. This signal indicates that the  channel is signaling a valid write response.
		M_AXI_BREADY	: out std_logic; -- Response ready. This signal indicates that the master can accept a write response.
    -- AXI Read Address Channel
		M_AXI_ARID	: out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0); -- Master Interface Read Address.
		M_AXI_ARADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0); -- Read address. This signal indicates the initial address of a read burst transaction.
		M_AXI_ARLEN	: out std_logic_vector(7 downto 0); -- Burst length. The burst length gives the exact number of transfers in a burst
		M_AXI_ARSIZE	: out std_logic_vector(2 downto 0); -- Burst size. This signal indicates the size of each transfer in the burst
		M_AXI_ARBURST	: out std_logic_vector(1 downto 0); -- Burst type. The burst type and the size information, determine how the address for each transfer within the burst is calculated.
		M_AXI_ARLOCK	: out std_logic; -- Lock type. Provides additional information about the atomic characteristics of the transfer.
		M_AXI_ARCACHE	: out std_logic_vector(3 downto 0); -- Memory type. This signal indicates how transactions are required to progress through a system.
		M_AXI_ARPROT	: out std_logic_vector(2 downto 0); -- Protection type. This signal indicates the privilege and security level of the transaction, and whether the transaction is a data access or an instruction access.
		M_AXI_ARQOS	: out std_logic_vector(3 downto 0); -- Quality of Service, QoS identifier sent for each read transaction
		M_AXI_ARUSER	: out std_logic_vector(C_M_AXI_ARUSER_WIDTH-1 downto 0); -- Optional User-defined signal in the read address channel.
		M_AXI_ARVALID	: out std_logic; -- Write address valid. This signal indicates that the channel is signaling valid read address and control information
		M_AXI_ARREADY	: in std_logic; -- Read address ready. This signal indicates that the slave is ready to accept an address and associated control signals
    -- AXI Read Data Channel
		M_AXI_RID	: in std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0); -- Read ID tag. This signal is the identification tag for the read data group of signals generated by the slave.
		M_AXI_RDATA	: in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0); -- Master Read Data
		M_AXI_RRESP	: in std_logic_vector(1 downto 0); -- Read response. This signal indicates the status of the read transfer
		M_AXI_RLAST	: in std_logic; -- Read last. This signal indicates the last transfer in a read burst
		M_AXI_RUSER	: in std_logic_vector(C_M_AXI_RUSER_WIDTH-1 downto 0); -- Optional User-defined signal in the read address channel.
		M_AXI_RVALID	: in std_logic; -- Read valid. This signal indicates that the channel is signaling the required read data.
		M_AXI_RREADY	: out std_logic -- Read ready. This signal indicates that the master can accept the read data and response information.
    );
end entity_name;

architecture implementation of entity_name is

    -- state type for the read address and data 
    type AR_State_Type is (AR_IDLE, AR_SEND_ADDR);
    signal eyu_ar_state : AR_State_Type := AR_IDLE;
    
    -- for R FSM
    type R_State_Type is (R_IDLE, R_WAIT_DATA, R_DONE);
    signal eyu_r_state : R_State_type := R_IDLE;
    
    -- book-keeping
    signal eyu_inflight : std_logic := '0';
    signal eyu_addr_reg : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0) := (others=>'0');
    signal eyu_read_done : std_logic :='0';
    signal eyu_arvalid : std_logic :='0';
    

begin
   
  -- Read Address
  M_AXI_ARID <= (others => '0');       
  M_AXI_ARLEN <= (others => '0');       
  M_AXI_ARSIZE <= "010";                 
  M_AXI_ARBURST <= "01";                  
  M_AXI_ARLOCK <= '0';                   
  M_AXI_ARCACHE <= "0011";                
  M_AXI_ARPROT <= "000";                 
  M_AXI_ARQOS <= (others => '0');       
  M_AXI_ARUSER <= (others => '0');       

  -- Write channels 
  M_AXI_AWID <= (others => '0');
  M_AXI_AWADDR <= (others => '0');
  M_AXI_AWLEN <= (others => '0');
  M_AXI_AWSIZE <= "010";        
  M_AXI_AWBURST <= "01";
  M_AXI_AWLOCK <= '0';
  M_AXI_AWCACHE <= "0011";
  M_AXI_AWPROT <= "000";
  M_AXI_AWQOS <= (others => '0');
  M_AXI_AWUSER <= (others => '0');
  M_AXI_AWVALID <= '0';          
  M_AXI_WDATA <= (others => '0');
  M_AXI_WSTRB <= (others => '0');
  M_AXI_WLAST <= '0';
  M_AXI_WUSER <= (others => '0');
  M_AXI_WVALID <= '0';
  M_AXI_BREADY <= '1';         
  Read_Done <= eyu_read_done; 
  M_AXI_ARVALID <= eyu_arvalid;
  
  -- Read Address Channel FSM
  
  AR_FSM_Process: process(M_AXI_ACLK) is
  begin
    if rising_edge(M_AXI_ACLK) then
      if (M_AXI_ARESETN = '0') then   
        -- reset and clear AR
        eyu_ar_state   <= AR_IDLE;
        eyu_arvalid <= '0';
        M_AXI_ARADDR <= (others => '0');
        eyu_inflight <= '0';
      else
        if eyu_read_done = '1' then 
             eyu_inflight <= '0';
        end if;
        
        case eyu_ar_state is
          when AR_IDLE =>
            -- Wait for a start of read request
            if (Start_read = '1') and (eyu_inflight='0') then
              -- Latch address and start the read transaction
              eyu_addr_reg <= Read_address;
              M_AXI_ARADDR <= Read_address;
              eyu_arvalid <= '1';   -- initiate ARVALID 
              eyu_ar_state <= AR_SEND_ADDR;
              eyu_inflight <= '1';
            end if;

          when AR_SEND_ADDR =>
            -- wait for slave to accept the address
            if (eyu_arvalid = '1' and M_AXI_ARREADY = '1') then
              -- address accepted
              eyu_arvalid <= '0';   
              eyu_ar_state  <= AR_IDLE;
            end if;

          --fowhen others =>
          --  eyu_ar_state <= AR_IDLE;
        end case;
      end if;
    end if;
  end process AR_FSM_Process;

  
  R_FSM_Process: process(M_AXI_ACLK) is
begin
  if rising_edge(M_AXI_ACLK) then
    if (M_AXI_ARESETN = '0') then
      eyu_r_state   <= R_IDLE;
      M_AXI_RREADY  <= '0';
      eyu_read_done <= '0';
      Error         <= '0';
      for i in 0 to C_M_AXI_DATA_WIDTH-1 loop
        Read_Data(i) <= '0';
      end loop;
    else
      case eyu_r_state is
        when R_IDLE =>
          M_AXI_RREADY  <= '0';
          eyu_read_done <= '0';
          Error         <= '0';
          if (eyu_inflight = '1') then
            M_AXI_RREADY <= '1';
            eyu_r_state  <= R_WAIT_DATA;
          end if;

        when R_WAIT_DATA =>
          if (M_AXI_RVALID = '1') then
            -- bit-accurate copy 31:0 -> 0..31
            for i in 0 to C_M_AXI_DATA_WIDTH-1 loop
              Read_Data(i) <= M_AXI_RDATA(i);
            end loop;
            if M_AXI_RRESP = "00" then
                Error <= '0';
            else
                Error <= '1';
            end if;
            
            if (M_AXI_RLAST = '1') then
              M_AXI_RREADY <= '0';
              eyu_r_state  <= R_DONE;      
            end if;
          end if;

        when R_DONE =>
          eyu_read_done <= '1'; -- 1-cycle pulse
          eyu_r_state   <= R_IDLE;
      end case;
    end if;
  end if;
end process R_FSM_Process;


end implementation;
