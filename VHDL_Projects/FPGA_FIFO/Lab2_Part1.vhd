-- Mark Lee     ECE 351/357 Lab 2       11 October 2019
--
-- This VHDL program utilizes a Block RAM memory module from the
-- Vivado IP catalog to implement a FIFO structure. I use a debounced
-- pulse from a button on the BASYS3 board to clock the reading and 
-- writing of data. 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;
use ieee.std_logic_unsigned.all;

entity Lab2_Part1 is
    Port ( enable, BTNCC, CLKK: in std_logic;
           input: in std_logic_vector (7 downto 0);
           status_flags: out std_logic_vector(5 downto 0);
           Anodes: out std_logic_vector (3 downto 0);
           Cathodes: out std_logic_vector (6 downto 0)
    );
end Lab2_Part1;

architecture Behavioral of Lab2_Part1 is

signal DB_pulse: std_logic;
signal enable_sig: std_logic := '1';
signal sig: std_logic := '0';
signal read_sig: std_logic_vector(3 downto 0) := "0000";
signal write_sig: std_logic_vector(3 downto 0) := "0000";
signal full_status: std_logic_vector(5 downto 0) := "100100";
signal wea_sig: std_logic_vector(0 downto 0);
signal address: std_logic_vector(3 downto 0) := "0000";
signal output: std_logic_vector(7 downto 0);
signal LED_BCD: std_logic_vector(3 downto 0);
signal counter: std_logic_vector(19 downto 0);

--Instantiate the debounced pulse functionality and Block RAM component
component DB_CLK
    port(CLK, BTNC: in std_logic;
         DB: out std_logic);
end component;

COMPONENT blk_mem_gen_0
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;

begin
    --Instantiate the debounced pulse functionality and Block RAM component
    CLK_Component : DB_CLK port map(CLK => CLKK, BTNC => BTNCC, DB => DB_pulse);
    BRAM : blk_mem_gen_0 PORT MAP (clka => DB_pulse, ena => enable_sig, wea => wea_sig,
           addra => address, dina => input, douta => output);

    --Increment counter until counter(18) changes value --> approximately 10ms has passed
    process(CLKK)
    begin
        if(rising_edge(CLKK)) then
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
    
    --When 10ms has passed, alternate displays. The leftmost display
    --shows the address, and the right two displays show the read/written
    --data in binary coded decimal (BCD)
    process(counter(18))
    begin
        case counter(19 downto 18) is
            when "00" =>
                Anodes <= "1110";
                LED_BCD <= output(3 downto 0);
            when "01" =>
                Anodes <= "1101";
                LED_BCD <= output(7 downto 4);
            when "10" =>
                Anodes <= "0111";
                LED_BCD <= address;
            when others =>
                Anodes <= "0111";
                LED_BCD <= address;
        end case;
    end process;

    --Update the address and read/write signals when enable
    --changes and the read/write signals change
    process(enable, read_sig, write_sig)
    begin  
        if(enable = '0') then
            address <= read_sig;
            wea_sig <= "0";
        else
            address <= write_sig;
            wea_sig <= "1";
        end if;
    end process;
  
    process is
    begin
        wait until falling_edge(DB_pulse);
            
        if(enable = '0') then
            sig <= '0';
               
            --If the memory is not empty on read, read the value 
            --from memory and increment the read pointer
            if(full_status(3 downto 0) /= "0100") then
                read_sig <= read_sig + 1;
            end if;
    
        else    
            sig <= '1';
            
            --If the memory is not full on write, write the value
            --to memory and increment the write pointer 
            if(full_status(3 downto 0) /= "1000") then
                write_sig <= write_sig + 1;
            end if;
        end if;
    end process;
    
    process(read_sig, write_sig)
    begin
 
        --If the read pointer was incremented and is only one behind
        --the write pointer, then there is only one value in memory
        --(almost empty)
        if(read_sig + 1 = write_sig and sig = '0') then
            full_status <= "100001";
        --If the read pointer was incremented and is only one ahead
        --of the write pointer, then memory is almost full
        elsif(read_sig = write_sig + 1 and sig = '0') then
            full_status <= "100010";
        --If the read pointer was incremented and now equals the write
        --pointer, then the memory is now empty
        elsif(read_sig = write_sig and sig = '0') then
            full_status <= "100100";
        --There is no scenario where a value is read and memory is full.
        --If none of the other conditions are met, then turn 
        --status_flags(3 downto 0) off
        elsif(sig = '0') then
            full_status <= "100000";
        end if;
        
        --If the write pointer was incremented and is only one ahead
        --of the read pointer, then there is only one value in memory
        --(almost empty)
        if(write_sig = read_sig + 1 and sig = '1') then
           full_status <= "010001";
            
        ---If the write pointer was incremented and is only one behind
        --the read pointer, then memory is almost full
        elsif(write_sig + 1 = read_sig and sig = '1') then
            full_status <= "010010";
        
        --If the write pointer was incremented and now equals the read
        --pointer, then the memory is now full
        elsif(write_sig = read_sig and sig = '1') then
            full_status <= "011000";
        
        --There is no scenario where a value is written and memory is empty.
        --If none of the other conditions are met, then turn 
        --status_flags(3 downto 0) off
        elsif(sig = '1') then
            full_status <= "010000";
        end if;
    end process;

    --Set LED flags
    process(full_status)
    begin
        status_flags <= full_status;
    end process;
    
end Behavioral;
