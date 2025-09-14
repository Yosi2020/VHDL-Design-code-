----------------------------------------------------------------------------------
-- Company: sdsmt
-- Engineer: Eyosiyas
-- 
-- Create Date: 09/02/2025 11:33:10 AM
-- Design Name: Eyosiyas
-- Module Name: lab1 - Behavioral
-- Project Name: Lab1 ALUFUNC
-- Target Devices: None
-- Tool Versions: v1.0
-- Description: None
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

entity alu is
   Port ( 
   clk : in std_logic;
   reset : in std_logic;
   Aout : in std_logic_vector(31 downto 0);
   Bout : in std_logic_vector(31 downto 0);
   PCAsel : in std_logic;
   IMM : in std_logic_vector(31 downto 0);
   IMMBsel : in std_logic;
   PCout : in std_logic_vector(31 downto 0);
   ALUfun : in std_logic_vector(3 downto 0);
   eyu_out: out std_logic_vector(31 downto 0)
   );
end alu;

architecture Behavioral of alu is
    signal Abus : std_logic_vector(31 downto 0);
    signal Bbus : std_logic_vector(31 downto 0);
    signal eyu_alu : std_logic_vector(31 downto 0);
begin
    Abus <= PCout when PCAsel = '1' else Aout;
    Bbus <= IMM when IMMBsel = '1' else Bout;
    process(Abus, Bbus, ALUfun)
         variable eyu : std_logic_vector(31 downto 0);
         begin
             case ALUfun is
                when "0000" => eyu := std_logic_vector(signed(Abus) + signed(Bbus));
                when "0001" => eyu := std_logic_vector(signed(Abus) - signed(Bbus));
                when "0010" => eyu := Abus and Bbus;
                when "0011" => eyu := Abus or Bbus;
                when "0100" => eyu := Abus xor Bbus;
                when "0101" => eyu := (others => '0'); if signed(Abus) < signed(Bbus) then eyu(0) := '1'; end if;
                when "0110" => eyu := (others => '0'); if unsigned(Abus) < unsigned(Bbus) then eyu(0) := '1'; end if;  
                when "0111" => eyu := std_logic_vector(shift_left(unsigned(Abus), TO_INTEGER(unsigned(Bbus(4 downto 0)))));
                when "1000" => eyu := std_logic_vector(shift_right(unsigned(Abus), TO_INTEGER(unsigned(Bbus(4 downto 0)))));
                when "1001" => eyu := std_logic_vector(shift_right(signed(Abus), TO_INTEGER(unsigned(Bbus(4 downto 0)))));     
                when others => eyu := (others => '0');      
             end case;
             eyu_alu <= eyu;
         end process;
    process(clk)
    begin
         if rising_edge(clk) then
               if reset = '1' then
                    eyu_out <= (others => '0');
                else 
                     eyu_out <= eyu_alu;
                end if;
         end if;
    end process;

end Behavioral;
