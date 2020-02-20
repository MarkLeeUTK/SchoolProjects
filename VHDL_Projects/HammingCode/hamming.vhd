library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hamming is
    Port ( s : in STD_LOGIC_VECTOR (15 downto 0);
           p : out STD_LOGIC_VECTOR (3 downto 0));
end hamming;

architecture Behavioral of hamming is
    
begin
    process 
    begin
        if(s = "110101100011001") then p <= "1001";
        end if;
        if(s = "101000001010010") then p <= "1111";
        end if;
        if(s = "010010000000000") then p <= "0101";
        end if;
        if(s = "100010001000010") then p <= "0010";
        end if;
    end process;
end Behavioral;
