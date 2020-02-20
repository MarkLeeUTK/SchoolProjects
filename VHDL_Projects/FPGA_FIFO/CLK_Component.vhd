library IEEE;use ieee.std_logic_1164.all;

entity DB_CLK is
    port( 
        CLK: in std_logic;
        BTNC: in std_logic;
        DB: out std_logic);
end DB_CLK;

architecture behavorial of DB_CLK is

component SingPul --declare entity SingPul as a component
    port( 
        clk1,key: in std_logic;
        pulse: out std_logic);
end component;

component CDiv   --declare entity CDiv as a component
    port( 
        Cin: in std_logic;
        Cout: out std_logic);
end component;

signal clks: std_logic;     --signal CLKS internal to entity TOP, not an IO port 

begin
    cdiv1: CDiv port map(Cin => CLK, Cout => clks); --instantiate CDiv once-- with explicit port map
    SingPull: SingPul port map(clks,BTNC,DB);    --instantiate SingPul once with-- "in order" port map 
end behavorial;
