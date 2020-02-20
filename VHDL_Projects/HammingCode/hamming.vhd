-- Mark Lee   ECE 357    9/27/2019
-- Lab 1: (15,11) Hamming Encoder/Decoder

-- This program implements the (15,11) Hamming Code on the BASYS3 board. Inputs 
-- are the 16 switches, outputs are 4 LEDs and the 7-segment displays. There are 
-- two modes to this code: encode and decode. Encode computes the parity bits 
-- for the 11 data bits, and displays them on the LEDs. Decode computes the 
-- error syndrome for the 15 bit value, and displays the location of the faulty 
-- bit on the LEDs and the 7-segment displays.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity hamming is
    --Self-explanatory variables. CLK is used to alternate between two 7-segment 
    -- displays.
    Port ( CLK: in STD_LOGIC; 
           switches : in STD_LOGIC_VECTOR (15 downto 0);
           LEDS : out STD_LOGIC_VECTOR (3 downto 0);
           Anodes : out STD_LOGIC_VECTOR (3 downto 0);
           Cathodes : out STD_LOGIC_VECTOR (6 downto 0));
end hamming;

architecture Behavioral of hamming is
     -- a holds the encode value, p1-p8 hold the parity bits, counter is needed 
     -- to divide the clock rate, displayed_number and error_syndrome are used to 
     -- display the right number when alternating displays, and LED_BCD translates 
     -- binary to decimal.
     signal a, p1, p2, p4, p8 : std_logic;
     signal counter: std_logic_vector(19 downto 0);
     signal displayed_number : std_logic_vector(7 downto 0);
     signal error_syndrome : std_logic_vector(3 downto 0);
     signal LED_BCD : std_logic_vector(3 downto 0);
begin
    a <= switches(0);

    --Increment counter until counter(18) changes value --> approximately 10ms 
    --has passed
    process(CLK)
    begin
        if(rising_edge(CLK)) then
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
            when "1010" => Cathodes <= "0000010"; -- a
            when "1011" => Cathodes <= "1100000"; -- b
            when "1100" => Cathodes <= "0110001"; -- C
            when "1101" => Cathodes <= "1000010"; -- d
            when "1110" => Cathodes <= "0110000"; -- E
            when "1111" => Cathodes <= "0111000"; -- F
            when others =>
        end case;
    end process;
    
    --When 10ms has passed, alternate displays if in decode mode. If in
    --encode mode, no need to alternate; just display 'E'.
    process(counter(18))
    begin
        if(a = '1') then
            Anodes <= "1110";
            LED_BCD <= "1110";
        else
            --Turn on/off a certain display, and change the value displayed
            case counter(18) is
            when '0' => 
                Anodes <= "1110";
                LED_BCD <= displayed_number(3 downto 0);
            when '1' =>
                Anodes <= "1101";
                LED_BCD <= displayed_number(7 downto 4);
            when others =>
            end case;
        end if;
    end process;

    --When a changes, re-calculate the parity bits. x1-x4 needed to save
    --intermediate values in a process
    process(a)
        variable x1, x2, x3, x4: std_logic;
    begin
        --xor a parity bit's associated bit positions to find the proper parity value
        x1 := switches(13) xor switches(11) xor switches(9) xor switches(7) xor
              switches(5) xor switches(3) xor switches(1);
        x2 := switches(13) xor switches(10) xor switches(9) xor switches(6) xor
              switches(5) xor switches(2) xor switches(1);
        x3 := switches(11) xor switches(10) xor switches(9) xor switches(4) xor 
              switches(3) xor switches(2) xor switches(1);
        x4 := switches(7) xor switches(6) xor switches(5) xor switches(4) xor
              switches(3) xor switches(2) xor switches(1);
            
        p1 <= x1;
        p2 <= x2;
        p4 <= x3;
        p8 <= x4;
       
        --If in encode mode, display the computed parity bits on the LEDs
        if (a = '1') then     
            if(p1 = '1') then LEDS(0) <= '1';
            else LEDS(0) <= '0';
            end if;
            
            if(p2 = '1') then LEDS(1) <= '1';
            else LEDS(1) <= '0';
            end if;
            
            if(p4 = '1') then LEDS(2) <= '1';
            else LEDS(2) <= '0';
            end if;
            
            if(p8 = '1') then LEDS(3) <= '1';
            else LEDS(3) <= '0';
            end if; 

        --If in decode mode, you have to check to make sure the calculated
        --parity bit matches the actual input parity bit. If it doesn't, 
        --then it is wrong, and the error syndrome bit at the same place
        --covered by the parity bit is set to 1. If the parities match, then
        --the input parity is correct, and the associated error syndrome bit
        --is 0. There are 4 if/else statements below corresponding to the 
        --four parity values p1-p8 you have to verify.
        else
            if(switches(15) = p1) then 
                LEDS(0) <= '0';
                error_syndrome(0) <= '0';
            else 
                LEDS(0) <= '1';
                error_syndrome(0) <= '1';
            end if;
            
            if(switches(14) = p2) then 
                LEDS(1) <= '0';
                error_syndrome(1) <= '0';
            else 
                LEDS(1) <= '1';
                error_syndrome(1) <= '1';
            end if;
            
            if(switches(12) = p4) then 
                LEDS(2) <= '0';
                error_syndrome(2) <= '0';
            else 
                LEDS(2) <= '1';
                error_syndrome(2) <= '1';
            end if;
            
            if(switches(8) = p8) then 
                LEDS(3) <= '0';
                error_syndrome(3) <= '0';
            else 
                LEDS(3) <= '1';
                error_syndrome(3) <= '1';
            end if;
            
            --This last piece of logic is for alternating displays. If the 
            --error syndrome is greater than 9, it will have a 1 in the tens
            --place and error_syndrome-10 in the ones place. Otherwise, just
            --display a 0 in the tens place and error_syndrome in the ones.
            if(error_syndrome > "1001") then
                displayed_number(7 downto 4) <= "0001";
                displayed_number(3 downto 0) <= error_syndrome - "1010";
            else
                displayed_number(7 downto 4) <= "0000";
                displayed_number(3 downto 0) <= error_syndrome;
            end if;
         end if;
    end process;
end Behavioral;
