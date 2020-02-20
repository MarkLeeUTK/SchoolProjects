-- Pushbutton Debounce Module
LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
USE ieee.STD_LOGIC_UNSIGNED.all;

ENTITY SingPul IS
PORT (
  Clk1: IN STD_LOGIC; ---make it a low frequency Clock input
  Key: IN STD_LOGIC;  -- active low input
  pulse: OUT STD_LOGIC);
END SingPul;

ARCHITECTURE onepulse OF SingPul IS
  SIGNAL cnt: STD_LOGIC_VECTOR (1 DOWNTO 0);
BEGIN
  PROCESS (Clk1,Key)
  BEGIN 
   
   IF (Key = '1') THEN
      cnt <= "00";
    ELSIF (clk1'EVENT AND Clk1= '1') THEN
      IF (cnt /= "11") THEN cnt <= cnt + 1; END IF;
    END IF;
   
   IF (cnt = "10") AND (Key = '0') THEN
      pulse <= '1';
   ELSE pulse <= '0'; 
   END IF;

  END PROCESS; --You must BEGIN and END each PROCESS in VHDL.
END onepulse;
