
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


ENTITY my_nDFF_falling IS
   GENERIC ( m : integer);
   PORT( Clk,enable : IN std_logic;
      d : IN std_logic_vector(m-1 DOWNTO 0);
      q : OUT std_logic_vector(m-1 DOWNTO 0));
END my_nDFF_falling;

ARCHITECTURE b_my_nDFF_falling OF
   my_nDFF_falling IS
       COMPONENT my_DFF_falling IS
           PORT( d,Clk,enable : IN std_logic;
           q : OUT std_logic);
       END COMPONENT;


BEGIN
   loop1: FOR i IN 0 TO m-1 GENERATE
   fx: my_DFF_falling PORT MAP(d(i),Clk,enable,q(i));
   END GENERATE;
END ARCHITECTURE;
