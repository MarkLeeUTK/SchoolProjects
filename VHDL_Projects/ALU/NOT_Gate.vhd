library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity NOT_Gate is
    Port (A: in std_logic;
          Q: out std_logic);
end NOT_Gate;

architecture Behavioral of NOT_Gate is

begin
    Q <= not A;
end Behavioral;