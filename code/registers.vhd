LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY reg IS
GENERIC(n: integer := 32 );
PORT(CLK, RESET, enable: IN std_logic;
     IP: IN std_logic_vector(n-1 DOWNTO 0);
     OP: OUT std_logic_vector(n-1 DOWNTO 0));
END reg;

ARCHITECTURE nBit_reg OF reg IS
BEGIN 
PROCESS(enable, CLK)
BEGIN 
IF enable = '1' THEN 
   IF rising_edge(CLK) THEN
      OP <= IP;
   END IF;
ELSIF RESET = '1' THEN 
    OP <= (others=>'0'); 
END IF;  
END PROCESS; 
END nBit_reg;