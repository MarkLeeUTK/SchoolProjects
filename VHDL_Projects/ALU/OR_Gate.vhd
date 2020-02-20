library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity OR_Gate is
    Port (A, B: in std_logic;
          Q: out std_logic);
end OR_Gate;

architecture Behavioral of OR_Gate is

begin
    Q <= A or B;
end Behavioral;
