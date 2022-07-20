library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.all;

entity ControlUnit is 
	port (    instOPCode: in std_logic_vector(2 downto 0);
                  instFunction: in std_logic_vector(6 downto 0);
	 	  excution: out std_logic_vector(17 downto 0);
		  memory: out std_logic_vector(8 downto 0);
		  writeBack: out std_logic_vector(2 downto 0));
end ControlUnit; 




ARCHITECTURE ControlUnitArch OF ControlUnit IS

   signal opType: std_logic_vector(7 downto 0);
   signal rsltSrc,jmpType: std_logic_vector(1 downto 0);
   signal aluEnable,r1Src,r2Src,carrySelector,carryEnable,jmpEnable: std_logic;

   signal dataSrc: std_logic_vector(1 downto 0);
   signal addSrc,memWrite,memRead,spControl,spEnabler,callRet,callRetEnable: std_logic;

   signal writeBackSignal: std_logic_vector(1 downto 0);
   signal writeBackEnable: std_logic;

   BEGIN


----------------------------------------WriteBack Signals--------------------------------------------------------
         writeBackSignal <= "01" WHEN instOPCode="010" or  instOPCode="000" or ( instOPCode="100" and  
         (instFunction="1010111" or instFunction="0000000"  or instFunction="0000001" ))
             ELSE "10" WHEN (instOPCode="100" and instFunction="0000010" )
             ELSE "00";

         writeBackEnable <= '1' WHEN instOPCode="010" or  instOPCode="000" or ( instOPCode="100" and  
         (instFunction="1010111" or instFunction="0000000"  or instFunction="0000001"  or instFunction="1110111"))
         or ( instOPCode="001" and  instFunction="0100001")
             ELSE '0';

   writeBack<= writeBackEnable & writeBackSignal ;
----------------------------------------Memory Signals--------------------------------------------------------
         dataSrc <= "01" WHEN (instOPCode="001" and (instFunction="0000101" or instFunction="0000110" ))
             ELSE "10" WHEN (instOPCode="100" and instFunction="1100111" )
             ELSE "00";

         addSrc <= '1' WHEN (instOPCode="001" and (instFunction="0000101" or instFunction="0000110" 
         or instFunction="0100000" or instFunction="0100001"))
             ELSE '0';

         memWrite <= '1' WHEN (instOPCode="001" and (instFunction="0000101" or instFunction="0100000"))
         or (instOPCode="100" and instFunction="1100111")
             ELSE '0';

         memRead <= '1' WHEN (instOPCode="001" and (instFunction="0000110" or instFunction="0100001"))
         or (instOPCode="100" and instFunction="1110111")
             ELSE '0';

         spControl <= '1' WHEN (instOPCode="001" and (instFunction="0000110" or instFunction="0100001"))
             ELSE '0';

         spEnabler <= '1' WHEN (instOPCode="001" and (instFunction="0000101" or instFunction="0000110" 
         or instFunction="0100000" or instFunction="0100001"))
             ELSE '0';

         callRet <= '1' WHEN (instOPCode="001" and instFunction="0000110" )
             ELSE '0';

         callRetEnable <= '1' WHEN (instOPCode="001" and (instFunction="0000110" or instFunction="0000101" ))
             ELSE '0';

    memory<= callRetEnable & callRet & spEnabler & spControl & memRead & memWrite & addSrc & dataSrc;

----------------------------------------Execution Signals-----------------------------------------------------
         opType(6 downto 0) <= '1' & instFunction(5 downto 0) WHEN (instOPCode="000")
             Else instFunction;
         opType(7) <= '1' WHEN (instOPCode="000")
             Else '0';

         aluEnable <= '1' WHEN ((instOPCode="100" and instFunction(6)='1') or instOPCode="010" or instOPCode="000")
             ELSE '0';

         r1Src <= '1' WHEN (instOPCode="100" and (instFunction="1010111" or instFunction="1100111"))
             ELSE '0';

         r2Src <= '1' WHEN (instOPCode="100" and instFunction="1110111" )
             ELSE '0';

         rsltSrc <= "01" WHEN (instOPCode="100" and instFunction="0000000" )
             ELSE "10" WHEN (instOPCode="100" and instFunction="0000001" )
             ELSE "00";

         carrySelector <= '1' WHEN (instOPCode="001" and instFunction(4)='1' )
             Else '0';

         carryEnable <= '1' WHEN (instOPCode="001" and instFunction(4)='1' ) 
         or (instOPCode="010" and (instFunction="1000111" or instFunction="1000100") )
         or (instOPCode="100" and instFunction="1010111")
         or (instOPCode="000")
             Else '0';

         jmpType <= "01" WHEN (instOPCode="001" and instFunction="0000010" )
            ELSE "10" WHEN (instOPCode="001" and instFunction="0000011" )
            ELSE "11" WHEN (instOPCode="001" and instFunction="0000100" )
            ELSE "00";

         jmpEnable <= '1' WHEN (instOPCode="001" and (instFunction="0000001" or instFunction="0000010" 
         or instFunction="0000011" or instFunction="0000100"))
             Else '0';

    excution<= jmpEnable & jmpType & carryEnable & carrySelector & rsltSrc & r2Src & r1Src & aluEnable & opType;

END ARCHITECTURE;