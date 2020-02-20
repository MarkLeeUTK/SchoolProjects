library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Full_Adder is
    Port (A, B, Cin: in std_logic;
          Sum, Cout: out std_logic);
end Full_Adder;

architecture Behavioral of Full_Adder is
    
    signal temp1, temp2, temp3: std_logic;
    
    component AND_Gate
        port(A, B: in std_logic;
             Q: out std_logic);
    end component;
    
    component OR_Gate
        port(A, B: in std_logic;
             Q: out std_logic);
    end component; 
    
    component XOR_Gate
        port(A, B: in std_logic;
             Q: out std_logic);
    end component; 
     
begin

   AND1: AND_Gate port map(A => A, B => B, Q => temp1);
   AND2: AND_Gate port map(A => temp3, B => Cin, Q => temp2);
   XOR1: XOR_Gate port map(A => A, B => B, Q => temp3);
   XOR2: XOR_Gate port map(A => temp3, B => Cin, Q => Sum);
   OR1: OR_Gate port map(A => temp1, B => temp2, Q => Cout);

end Behavioral;
