-- Mark Lee     ECE 351/357 Lab 3       9 November 2019
--
-- This VHDL program 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;
use ieee.std_logic_unsigned.all;

entity Lab3_Part2 is
    Port (Button, Clock: in std_logic;
          input: in signed(7 downto 0);
          op_code: in std_logic_vector(4 downto 0);
          Anodes: out std_logic_vector(3 downto 0);
          Cathodes: out std_logic_vector(6 downto 0);
          sign_bits: out std_logic_vector(1 downto 0));
end Lab3_Part2;

architecture Behavioral of Lab3_Part2 is

    signal DB_pulse: std_logic;
    signal clock_A, clock_B: std_logic;
    signal A_input, B_input, A_output, B_output: signed(7 downto 0);
    signal LED_BCD: signed(3 downto 0);
    signal counter: std_logic_vector(19 downto 0);
    signal output: signed(15 downto 0);
    signal anodes_sig: std_logic_vector(3 downto 0);
    signal B_temp, C_temp: std_logic_vector(7 downto 0);
    signal sum: signed(7 downto 0);
    signal sub: std_logic := '0';

    --Instantiate the debounced pulse functionality
    component DB_CLK
        port(CLK, BTNC: in std_logic;
             DB: out std_logic);
    end component;

begin
    --Instantiate the debounced pulse functionality and Block RAM component
    CLK_Component : DB_CLK port map(CLK => Clock, BTNC => Button, DB => DB_pulse);
    A0: for i in 0 to 7 generate
        A1: entity work.D_FlipFlop(Behavioral)
            port map(CLK=>clock_A, D=>A_input(i), Q=>A_output(i));
        end generate;
    B0: for i in 0 to 7 generate
        B1: entity work.D_FlipFlop(Behavioral)
            port map(CLK=>clock_B, D=>B_input(i), Q=>B_output(i));
        end generate;
    
    B_temp(0) <= B_output(0) xor sub;
    adder1: entity work.Full_Adder(Behavioral) 
            port map(A => A_output(0), B => B_temp(0), Cin => sub, Cout => C_temp(0), Sum => sum(0));
    adders: for i in 1 to 7 generate
                B_temp(i) <= B_output(i) xor Sub;
                adder2: entity work.Full_Adder(Behavioral)
                        port map(A => A_output(i), B => B_temp(i), Cin => C_temp(i-1), Cout => C_temp(i), Sum => sum(i));
            end generate;   
       
    process is
        variable product: signed(15 downto 0);
    begin
        wait until falling_edge(DB_pulse);
        
        case op_code is
            when "00001" =>
                sub <= '0';
                A_input <= sum;
                clock_A <= not clock_A;
            when "00010" =>
                sub <= '1';
                A_input <= sum;
                clock_A <= not clock_A;
            when "00011" =>
                product := A_output * B_output;
                A_input <= product(15 downto 8);
                B_input <= product(7 downto 0);
                clock_A <= not clock_A;
                clock_B <= not clock_B;
            when "00100" =>
                A_input <= A_output and B_output;
                clock_A <= not clock_A;
            when "00101" =>
                A_input <= A_output or B_output;
                clock_A <= not clock_A;
            when "00110" =>
                A_input <= A_output xor B_output;
                clock_A <= not clock_A;
            when "00111" =>
                A_input <= not A_output;
                clock_A <= not clock_A;
            when "01000" =>
                A_input <= signed(shift_left(unsigned(A_output), to_integer(B_output)));
                clock_A <= not clock_A;
            when "01001" =>
                A_input <= signed(shift_right(unsigned(A_output), to_integer(B_output)));
                clock_A <= not clock_A;
            when "01010" =>
                A_input <= shift_right(signed(A_output), to_integer(B_output));
                clock_A <= not clock_A;
            when "01011" =>
                A_input <= rotate_left(A_output, to_integer(B_output));
                clock_A <= not clock_A;
            when "01100" =>
                A_input <= rotate_right(A_output, to_integer(B_output));
                clock_A <= not clock_A;
            when "01101" => 
                --A_signed <= signed(input);
                A_input <= input;
                clock_A <= not clock_A;
            when "01110" =>
                --B_signed <= signed(input);
                B_input <= input;
                clock_B <= not clock_B;
            when "01111" =>
                output(7 downto 0) <= A_output;
                anodes_sig <= "0011";
      
                if(A_output(7) = '1') then
                    sign_bits <= "10";
                else
                    sign_bits <= "00";
                end if; 
                
            when "10000" =>
                output(7 downto 0) <= B_output;
                anodes_sig <= "0011";
             
                if(B_output(7) = '1') then
                    sign_bits <= "10";
                else
                    sign_bits <= "00";
                end if; 
                
            when "10001" =>
                output(7 downto 0) <= B_output;
                output(15 downto 8) <= A_output;
                anodes_sig <= "1111";

                if(A_output(7) = '1' and B_output(7) = '1') then
                    sign_bits <= "11";
                elsif(A_output(7) = '1' and B_output(7) = '0') then
                    sign_bits <= "10";
                elsif(A_output(7) = '0' and B_output(7) = '1') then
                    sign_bits <= "01";
                else
                    sign_bits <= "00";
                end if; 
             
            when others =>
        end case;
    end process;
    
    --Increment counter until counter(18) changes value --> approximately 10ms has passed
    process(Clock)
    begin
        if(rising_edge(Clock)) then
            counter <= counter + 1;
        end if;
    end process;

    --When the value for LED_BCD changes, change the output on the display
    process(LED_BCD)
    begin
        case LED_BCD is
            when "0000" => Cathodes <= "0000001"; -- "0"
            when "0001" => Cathodes <= "1001111"; -- "1"
            when "0010" => Cathodes <= "0010010"; -- "2"
            when "0011" => Cathodes <= "0000110"; -- "3"
            when "0100" => Cathodes <= "1001100"; -- "4"
            when "0101" => Cathodes <= "0100100"; -- "5"
            when "0110" => Cathodes <= "0100000"; -- "6"
            when "0111" => Cathodes <= "0001111"; -- "7"
            when "1000" => Cathodes <= "0000000"; -- "8"
            when "1001" => Cathodes <= "0000100"; -- "9"
            when "1010" => Cathodes <= "0000010"; -- "A"
            when "1011" => Cathodes <= "1100000"; -- "b"
            when "1100" => Cathodes <= "0110001"; -- "C"
            when "1101" => Cathodes <= "1000010"; -- "d"
            when "1110" => Cathodes <= "0110000"; -- "E"
            when "1111" => Cathodes <= "0111000"; -- "F"
            when others =>
        end case;
    end process;
    
    --When 10ms has passed, alternate displays. 
    --[INSERT MORE INFO HERE]
    process(counter(18))
    begin
        if(anodes_sig = "0011") then
            case counter(19) is
                when '0' =>
                    Anodes <= "1110";
                    LED_BCD <= output(3 downto 0);
                when '1' =>
                    Anodes <= "1101";
                    LED_BCD <= output(7 downto 4);
                when others =>
            end case;
        elsif(anodes_sig = "1111") then
            case counter(19 downto 18) is
                when "00" =>
                        Anodes <= "1110";
                        LED_BCD <= output(3 downto 0);
                when "01" =>
                        Anodes <= "1101";
                        LED_BCD <= output(7 downto 4);
                when "10" =>
                        Anodes <= "1011";
                        LED_BCD <= output(11 downto 8);
                when "11" =>
                        Anodes <= "0111";
                        LED_BCD <= output(15 downto 12);
                when others =>
            end case;
         end if;
    end process;
    
end Behavioral;

