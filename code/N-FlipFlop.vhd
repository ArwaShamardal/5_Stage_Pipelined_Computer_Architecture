
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


ENTITY my_nDFF IS
   GENERIC ( m : integer);
   PORT( Clk : IN std_logic;
      d : IN std_logic_vector(m-1 DOWNTO 0);
      q : OUT std_logic_vector(m-1 DOWNTO 0));
END my_nDFF;

ARCHITECTURE b_my_nDFF OF
   my_nDFF IS
       COMPONENT my_DFF IS
           PORT( d,Clk : IN std_logic;
           q : OUT std_logic);
       END COMPONENT;


BEGIN
   loop1: FOR i IN 0 TO m-1 GENERATE
   fx: my_DFF PORT MAP(d(i),Clk,q(i));
   END GENERATE;
END ARCHITECTURE;
