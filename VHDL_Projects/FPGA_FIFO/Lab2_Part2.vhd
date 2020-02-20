library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;
use ieee.std_logic_unsigned.all;

entity Lab2_Part2 is
    Port( enable, BTNCC, CLKK: in std_logic;
          input: in std_logic_vector (7 downto 0);
          status_flags: out std_logic_vector(5 downto 0);
          Anodes: out std_logic_vector (3 downto 0);
          Cathodes: out std_logic_vector (6 downto 0)
    );
end Lab2_Part2;

architecture Behavioral of Lab2_Part2 is

signal DB_pulse: std_logic;
signal renable_sig: std_logic := '1';
signal sig: std_logic := '0';
signal read_sig: std_logic_vector(3 downto 0) := "0000";
signal write_sig: std_logic_vector(3 downto 0) := "0000";
signal full_status: std_logic_vector(5 downto 0);
signal wea_sig: std_logic;
signal address: std_logic_vector(3 downto 0) := "0000";
signal output: std_logic_vector(7 downto 0);
signal LED_BCD: std_logic_vector(3 downto 0);
signal counter: std_logic_vector(19 downto 0);
signal data: std_logic_vector(7 downto 0); 

component DB_CLK
    port(CLK, BTNC: in std_logic;
         DB: out std_logic);
end component;

COMPONENT fifo_generator_0
  PORT (
    clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    almost_full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    almost_empty : OUT STD_LOGIC
  );
END COMPONENT;

begin
    CLK_Component : DB_CLK port map(CLK => CLKK, BTNC => BTNCC, DB => DB_pulse);
    FIFO : fifo_generator_0 PORT MAP (clk => DB_pulse, din => input, wr_en => wea_sig, 
           rd_en => renable_sig, dout => output, full => full_status(3), 
           almost_full => full_status(1), empty => full_status(2), almost_empty => full_status(0));

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
    
    --When 10ms has passed, alternate displays. The right 
    --two displays show the read/written data in binary 
    --coded decimal (BCD)
    process(counter(18))
    begin
      --  if(enable = '1') then
            case counter(19 downto 18) is
                when "00" =>
                    Anodes <= "1110";
                    LED_BCD <= data(3 downto 0);
                when "01" =>
                    Anodes <= "1101";
                    LED_BCD <= data(7 downto 4);
                when "10" =>
                    Anodes <= "1110";
                    LED_BCD <= data(3 downto 0);
                when "11" =>
                    Anodes <= "1101";
                    LED_BCD <= data(7 downto 4);
                when others=>
            end case;
       -- else
         --   case counter(19 downto 18) is
           --     when "00" =>
             --       Anodes <= "1110";
               --     LED_BCD <= output(3 downto 0);
 --               when "01" =>
   --                 Anodes <= "1101";
     --               LED_BCD <= output(7 downto 4);
       --         when "10" =>
         --           Anodes <= "1110";
           ---         LED_BCD <= output(3 downto 0);
  --              when "11" =>
    --                Anodes <= "1101";
      --              LED_BCD <= output(7 downto 4);
        --        when others =>
         --   end case;
        --end if;
    end process;

   -- process is
   -- begin
     --   wait until falling_edge(DB_pulse);
       -- if(enable = '0') then
            
            
            --If the memory is not empty, read the value from memory
            --and increment the read pointer
         --   if(full_status(3 downto 0) /= "0100") then
           --     address <= read_sig;
             --   wea_sig <= '0';
         --       renable_sig <= '1';
           --     read_sig <= read_sig + 1;
       --     end if;
       -- else
         --   sig <= '1';
           -- if(full_status(3 downto 0) /= "1000") then
          --      address <= write_sig;
            --    renable_sig <= '0';
              --  wea_sig <= '1';
                --write_sig <= write_sig + 1;
--            end if;
  --      end if;
   -- end process;
    
    process(full_status)
    begin
        if(enable = '0') then
            if(full_status(3 downto 0) = "0101") then
                status_flags <= "100100";
            elsif(full_status(3 downto 0) = "1010") then 
                status_flags <= "101000";
            else
                status_flags(5 downto 4) <= "10";
                status_flags(3 downto 0) <= full_status(3 downto 0);
            end if;
        else
            if(full_status(3 downto 0) = "0101") then
                status_flags <= "010100";
            elsif(full_status(3 downto 0) = "1010") then 
                status_flags <= "011000";
            else
                status_flags(5 downto 4) <= "01";
                status_flags(3 downto 0) <= full_status(3 downto 0);
            end if; 
        end if;
    end process;
    
    process(enable, renable_sig, wea_sig)
    begin  
        if(enable = '0') then
            data <= output;
        else
            data <= input;
        end if;
    end process;
    
    process is
    begin
        wait until falling_edge(DB_pulse);
        if(enable = '0') then 
            full_status(5 downto 4) <= "10";
            renable_sig <= '1';
            wea_sig <= '0';
        else
            full_status(5 downto 4) <= "01";
            renable_sig <= '0';
            wea_sig <= '1';
        end if;
    end process;
    
    --process(full_status)
    --begin
      --  status_flags <= full_status;
    --end process;

end Behavioral;
