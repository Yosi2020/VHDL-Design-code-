----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/12/2025 01:11:15 PM
-- Design Name: 
-- Module Name: my_package - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package my_package is
    subtype flag_t is std_logic;    
    type flag_array is array (31 downto 0) of flag_t;
    subtype cw_bit is std_logic;    
    type control_t_array is array (31 downto 0) of cw_bit;
    constant immBsel : integer := 0;
    constant pcDsel : integer := 1;
    constant pcAsel : integer := 2;
    constant pcle : integer := 3;
    constant pcie : integer := 4;
    constant dle : integer := 5;
    constant isBR : integer := 6;
    constant BR0 : integer := 7;
    constant BR1 : integer := 8;
    constant BR2 : integer := 9;
end my_package;