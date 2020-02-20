library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity AND_Gate is
    Port (A, B: in std_logic;
          Q: out std_logic);
end AND_Gate;

architecture Behavioral of AND_Gate is

begin
    Q <= A and B;
end Behavioral;
