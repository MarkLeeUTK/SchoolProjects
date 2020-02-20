-- Mark Lee    ECE 357   Lab 4
--
-- This program utilizes the VGA capabilties of the BASYS3 board to
-- display a blue-green checkerboard pattern on a connected display.
-- One square is highlighted red, and the user can move it around 
-- the checkerboard using buttons. A BRAM is instantiated to store
-- the initial color contents.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;
use ieee.std_logic_unsigned.all;

entity Lab4 is
    Port (BTN1, BTN2, BTN3, BTN4: in std_logic;
          Clock: in std_logic;
          reset: in std_logic;
          HS, VS: out std_logic;
          red, green, blue: out std_logic_vector(3 downto 0)
    );
end Lab4;

architecture Behavioral of Lab4 is

    signal DB1, DB2, DB3, DB4: std_logic;
    signal address: std_logic_vector(3 downto 0);
    signal temp_col, temp_row: integer;
    signal ena_sig: std_logic := '1';
    signal wea_sig: std_logic_vector(0 downto 0) := "1";
    signal BRAM_clock: std_logic := '0';
    signal pixel_clock: std_logic;
    signal row_in, row_out: std_logic_vector(19 downto 0); 
    signal BRAM_counter: integer := 0;
    signal row, column: std_logic_vector(10 downto 0);
    signal blank: std_logic;
    signal i: integer := 0;
    signal hs_sig, vs_sig: std_logic;
    signal red_row: integer := 7;
    signal red_col: integer := 9;
    signal ignore: std_logic := '0';
    
    component DB_CLK
        port(CLK, BTNC: in std_logic;
             DB: out std_logic);
    end component;
    
    component clockdivider
        port(clk_in: in std_logic;
             clk_out: out std_logic);
    end component;
    
    --BRAM
    component blk_mem_gen_0 is
        port ( 
            clka : in STD_LOGIC;
            ena : in STD_LOGIC;
            wea : in STD_LOGIC_VECTOR ( 0 downto 0 );
            addra : in STD_LOGIC_VECTOR ( 3 downto 0 );
            dina : in STD_LOGIC_VECTOR ( 19 downto 0 );
            douta : out STD_LOGIC_VECTOR ( 19 downto 0 )
        );
    end component;

    component vga_controller_640_60 is
        port(
            rst, pixel_clk : in std_logic;
            HS, VS, blank : out std_logic;
            hcount : out std_logic_vector(10 downto 0);
            vcount : out std_logic_vector(10 downto 0)
        );
    end component;

begin
    
    --Instantiate components
    CLK_Component0 : DB_CLK port map(CLK => Clock, BTNC => BTN1, DB => DB1);
    CLK_Component1 : DB_CLK port map(CLK => Clock, BTNC => BTN2, DB => DB2);
    CLK_Component2 : DB_CLK port map(CLK => Clock, BTNC => BTN3, DB => DB3);
    CLK_Component3 : DB_CLK port map(CLK => Clock, BTNC => BTN4, DB => DB4);
    BRAM : blk_mem_gen_0 port map (clka => BRAM_clock, ena => ena_sig, wea => wea_sig,
           addra => address, dina => row_in, douta => row_out);
    DivideCLK: clockdivider port map(clk_in => Clock, clk_out => pixel_clock);         
    VGA_Control: vga_controller_640_60 port map(rst => reset, pixel_clk => pixel_clock,
                HS => hs_sig, VS => vs_sig, hcount => column, vcount => row, blank => blank);
    
    --Initialize BRAM to contain checkerboard display color contents
    --A 1 represents a green pixel, a 0 represents a blue pixel, and the dash "-"
    --represents a red pixel
    process(Clock)
    begin
        if(rising_edge(Clock)) then
            
            --Counter variable to divide clock for each BRAM write
            BRAM_counter <= BRAM_counter + 1;
            
            --Initialize the color contents for each 32x32 block of pixels on the
            --display. The red dot is initialized in the center, row 7 column 9.
            if(BRAM_counter mod 500000 = 0 and i < 15) then
        
                if(i = 7) then
                    row_in <= "101010101-1010101010";
                elsif(i mod 2 = 0) then      
                    row_in <= "01010101010101010101";
                else
                    row_in <= "10101010101010101010";
                end if;
            
                address <= std_logic_vector(to_unsigned(i, 4));  
            
                --Increment address and activate BRAM clock to input the color values
                if(BRAM_clock = '0') then
                    i <= i + 1;
                end if;
            
                BRAM_clock <= not BRAM_clock;
            end if;
        end if;  
    end process;
    
    --Display each pixel on the screen, outputing the appropriate color based on which 
    --32x32 checkerboard block it's in. 
    process(column)
    begin
        HS <= hs_sig;
        VS <= vs_sig;
        
        --Only output color in the visible pixel range. 
        if(blank = '0') then
            
            --Divide pixel index by 32 to determine checkerboard index
            temp_row <= to_integer(shift_right(unsigned(row), 5));
            temp_col <= to_integer(shift_right(unsigned(column), 5));
            
            --Output colors accordingly
            if(temp_row = red_row and temp_col = red_col) then
                red <= "1111";
                green <= "0000";
                blue <= "0000";
            elsif((temp_row * (20 + 1) + temp_col) mod 2 = 0) then
                red <= "0000";
                green <= "1111";
                blue <= "0000";
            else
                red <= "0000";
                green <= "0000";
                blue <= "1111"; 
            end if;
        else
            red <= "0000";
            green <= "0000";
            blue <= "0000";    
        end if;   
    end process;
    
    --Move the red square!
    process(DB1, DB2, DB3, DB4, reset)
    begin
        --Reset the red square to the middle of the checkerboard 
        --when reset is active.
        if(reset = '1' and ignore = '0') then
            red_row <= 7;
            red_col <= 9;
            ignore <= '1';
        elsif(reset = '0') then
            ignore <= '0';
        end if;
    
        --If the top button is pressed, the red square moves up
        if falling_edge(DB1) then
            if(red_row = 0) then
                red_row <= 14;
            else
                red_row <= red_row - 1;
            end if;
        end if;
        
        --If the right button is pressed, the red square moves right
        if falling_edge(DB2) then
            if(red_col = 19) then
                red_col <= 0;
            else
                red_col <= red_col + 1;
            end if;
        end if;
        
        --If the bottom button is pressed, the red square moves down
        if falling_edge(DB3) then 
            if(red_row = 14) then
                red_row <= 0;
            else
                red_row <= red_row + 1;
            end if;
        end if;
        
        --If the left button is pressed, the red square moves left
        if falling_edge(DB4) then
            if(red_col = 0) then
                red_col <= 19;
            else
                red_col <= red_col - 1;
            end if;
        end if;
    end process;
end Behavioral;
