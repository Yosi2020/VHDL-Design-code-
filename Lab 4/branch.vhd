----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/03/2025 01:10:14 PM
-- Design Name: 
-- Module Name: branch - Behavioral
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

entity branch is
  Port ( 
  clk : in std_logic;
  reset : in std_logic;
  isBR : in std_logic;
  BRcond : in std_logic_vector(2 downto 0);
  A : in std_logic_vector(31 downto 0);
  B : in std_logic_vector(31 downto 0);
  eyu_output : out std_logic
  );
end branch;

architecture Behavioral of branch is

    signal eyu_test : std_logic;

begin   
   process (isBR, BRcond, A, B)
       variable eyu : std_logic := '0';
   begin
   if isBR = '1' then
        eyu := '0';
        case BRcond is 
           when "000" => if A = B then eyu := '1'; end if;  -- equal
           when "001" => if A /= B then eyu := '1'; end if;  -- not equal
           when "100" => if signed(A) < signed(B) then eyu := '1'; end if; -- lessthan
           when "101" => if signed(A) > signed(B) then eyu := '1'; end if;  -- greaterthan
           when "110" => if unsigned(A) < unsigned(B) then eyu:= '1'; end if;  -- bltu
           when "111" => if unsigned(A) >= unsigned(B) then eyu:= '1'; end if; --- bgtu
           when others => eyu:='0';
        end case;
    end if;
    eyu_test <= eyu;
   end process;
   process(clk)
    begin
         --if rising_edge(clk) then
           ----    if reset = '1' then
          --          eyu_output <= '0';
               -- else 
                     eyu_output <= eyu_test;
                --end if;
         --end if;
    end process;
    
end Behavioral;
