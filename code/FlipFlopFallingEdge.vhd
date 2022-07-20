library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


ENTITY my_DFF_falling IS
   PORT( d,clk,enable: IN std_logic; 
   q : OUT std_logic);
END entity;


ARCHITECTURE a_my_DFF_falling OF my_DFF_falling IS
   BEGIN
       PROCESS(clk,enable)
          BEGIN
             if falling_edge(clk) then
                if(enable='1') then
                    q <= d;
                End if;
             END IF;
       END PROCESS;
END architecture ;
