library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

Entity RegisterFile is
   port(Clck,writeEnable : IN std_logic;
        readAdd1,readAdd2,writeAdd: in std_logic_vector(2 downto 0) ;
        writeData: in std_logic_vector(31 downto 0);
        readData1,readData2: out std_logic_vector(31 downto 0)
     );
end entity;



ARCHITECTURE RegisterFileArch OF RegisterFile IS
   component my_nDFF_falling is
     GENERIC ( m : integer :=32);
        PORT( Clk,enable : IN std_logic;
           d : IN std_logic_vector(m-1 DOWNTO 0);
           q : OUT std_logic_vector(m-1 DOWNTO 0));
    END component;

signal E0,E1,E2,E3,E4,E5,E6,E7: std_logic;
signal Data0,Data1,Data2,Data3,Data4,Data5,Data6,Data7:std_logic_vector(31 downto 0);
signal readDataSignal1,readDataSignal2:std_logic_vector(31 downto 0);

BEGIN
          E0 <= '1' when writeAdd="000" else '0';
          E1 <= '1' when writeAdd="001" else '0';
          E2 <= '1' when writeAdd="010" else '0';
          E3 <= '1' when writeAdd="011" else '0';
          E4 <= '1' when writeAdd="100" else '0';
          E5 <= '1' when writeAdd="101" else '0';
          E6 <= '1' when writeAdd="110" else '0';
          E7 <= '1' when writeAdd="111" else '0';

   R0: my_nDFF_falling port map(clck,E0,writeData,Data0);
   R1: my_nDFF_falling port map(clck,E1,writeData,Data1);
   R2: my_nDFF_falling port map(clck,E2,writeData,Data2);
   R3: my_nDFF_falling port map(clck,E3,writeData,Data3);
   R4: my_nDFF_falling port map(clck,E4,writeData,Data4);
   R5: my_nDFF_falling port map(clck,E5,writeData,Data5);
   R6: my_nDFF_falling port map(clck,E6,writeData,Data6);
   R7: my_nDFF_falling port map(clck,E7,writeData,Data7);



   readData1 <= Data0 when readAdd1="000"
           else Data1 when readAdd1="001"
           else Data2 when readAdd1="010"
           else Data3 when readAdd1="011"
           else Data4 when readAdd1="100"
           else Data5 when readAdd1="101"
           else Data6 when readAdd1="110"
           else Data7 when readAdd1="111";

   readData2 <= Data0 when readAdd2="000"
           else Data1 when readAdd2="001"
           else Data2 when readAdd2="010"
           else Data3 when readAdd2="011"
           else Data4 when readAdd2="100"
           else Data5 when readAdd2="101"
           else Data6 when readAdd2="110"
           else Data7 when readAdd2="111";


end ARCHITECTURE;
