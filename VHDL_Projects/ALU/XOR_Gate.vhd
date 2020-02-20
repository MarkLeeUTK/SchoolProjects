library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity XOR_Gate is
    Port (A, B: in std_logic;
          Q: out std_logic);
end XOR_Gate;

architecture Behavioral of XOR_Gate is

begin
    Q <= A xor B;
end Behavioral;
