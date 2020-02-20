library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity D_FlipFlop is
    Port (CLK, D: in std_logic;
          Q: out std_logic);
end D_FlipFlop;

architecture Behavioral of D_FlipFlop is
begin
    process(CLK)
    begin
        Q <= D;
    end process;
end Behavioral;

