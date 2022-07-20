library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


ENTITY my_DFF IS
   PORT( d,clk : IN std_logic; 
   q : OUT std_logic);
END my_DFF;


ARCHITECTURE a_my_DFF OF my_DFF IS
   BEGIN
       PROCESS(clk)
          BEGIN
             if rising_edge(clk) then
                q <= d;
             END IF;
       END PROCESS;
END a_my_DFF;