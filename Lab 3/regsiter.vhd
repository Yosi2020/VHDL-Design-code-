----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/08/2025 12:54:49 PM
-- Design Name: 
-- Module Name: regsiter - Behavioral
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
use IEEE.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity regsiter_file is
  Port ( 
  clk  : in std_logic;
  reset : in std_logic;
  Asel : in std_logic_vector(4 downto 0);
  Bsel : in std_logic_vector(4 downto 0);
  Dsel : in std_logic_vector(4 downto 0);
  Dlen : in std_logic;
  Dbus : in std_logic_vector(31 downto 0);
  Aout : out std_logic_vector(31 downto 0);
  Bout : out std_logic_vector(31 downto 0)
  
  
);
end regsiter_file;

architecture Behavioral of regsiter_file is
    -- this two codes will help us to map values in register 0 to 31
    type eyu_t is array (0 to 31) of std_logic_vector(31 downto 0);
    signal eyu : eyu_t := (others => (others=>'0'));

begin
    process(clk)
    begin
       if rising_edge(clk) then
            if reset = '1' then 
                eyu <= (others => (others=> '0'));
            elsif Dlen = '1' and Dsel /= "00000" then
                eyu(to_integer(unsigned(Dsel))) <= Dbus; 
            end if;
       end if; 
    end process;
   Aout <= (others => '0') when Asel = "00000" else eyu(TO_INTEGER(unsigned(Asel))); 
   Bout <= (others => '0') when Bsel = "00000" else eyu(TO_INTEGER(unsigned(Bsel)));
end Behavioral;