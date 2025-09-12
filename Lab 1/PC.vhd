----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/08/2025 01:43:16 PM
-- Design Name: 
-- Module Name: PC - Behavioral
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

entity PC is
  Port ( 
      clk : in std_logic;
      reset : in std_logic;
      PCle : in std_logic;
      PCie : in std_logic;
      Branch_out: in std_logic;
      ALUout : in std_logic_vector(31 downto 0);
      eyu_out : out std_logic_vector(31 downto 0)
  );
end PC;

architecture Behavioral of PC is

   signal eyu : std_logic_vector(31 downto 0) := (others => '0');
   signal load_enable : std_logic;

begin

     load_enable <= PCle or Branch_out;
     process (clk)
     begin
         if rising_edge(clk) then
             if reset = '1' then 
                 eyu <= (others => '0');
             elsif load_enable = '1' then 
                 eyu <= ALUout;
             elsif PCie = '1' then
                 eyu <= std_logic_vector(unsigned(eyu) + 4);   
             end if;       
         end if;
         eyu_out <= eyu;
      end process;
end Behavioral;
