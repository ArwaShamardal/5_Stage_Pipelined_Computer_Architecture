library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.all;


------------------------------------------------------------------------------------------------------------------------
-----------------------------CONTAINS DATA INPUTS TO BE Changed (writeEnable) & (writeData,WriteAddress)--------------------------------------
-------------------------------------------------------------------------------------------------------------------------


entity StageOne is 
	port (    		writeEnable: in std_logic;                     --For testing, Values from next stages
		                writeAdd: in std_logic_vector(2 downto 0);     --For testing, Values from next stages
		                writeData: in std_logic_vector(31 downto 0);   --For testing, Values from next stages
                  instruction, pcCounterIn,inputPortIn: in std_logic_vector(31 downto 0);
		  clck: in std_logic;
	 	  readData1,readData2,pcCounterOut,inputPortOut,signExtend: out std_logic_vector(31 downto 0);
	 	  readAdd1,readAdd2,writeBack: out std_logic_vector(2 downto 0);
	 	  memory: out std_logic_vector(8 downto 0);
	 	  excution: out std_logic_vector(17 downto 0)
        );
end StageOne; 


ARCHITECTURE StageOneArch OF StageOne IS

   component ControlUnit is 
	port (    instOPCode: in std_logic_vector(2 downto 0);
                  instFunction: in std_logic_vector(6 downto 0);
	 	  excution: out std_logic_vector(17 downto 0);
		  memory: out std_logic_vector(8 downto 0);
		  writeBack: out std_logic_vector(2 downto 0));
   end component;


   component RegisterFile is
	port(Clck,writeEnable : IN std_logic;
	        readAdd1,readAdd2,writeAdd: in std_logic_vector(2 downto 0) ;
	        writeData: in std_logic_vector(31 downto 0);
	        readData1,readData2: out std_logic_vector(31 downto 0)
	     );
   end component;

   component my_nDFF IS
       GENERIC ( m : integer);
       PORT( Clk : IN std_logic;
             d : IN std_logic_vector(m-1 DOWNTO 0);
             q : OUT std_logic_vector(m-1 DOWNTO 0));
   END  component;


   signal readDataSignal1,readDataSignal2,signExtendSignal,inputPortOutSignal:std_logic_vector(31 downto 0);
   signal excutionSignal: std_logic_vector(17 downto 0);
   signal memorySignal: std_logic_vector(8 downto 0);
   signal writeBackSignal:  std_logic_vector(2 downto 0);

   Begin

     signExtendSignal(15 downto 0)<=  instruction(31 downto 16);
     signExtendSignal(31 downto 16)<= (Others => '0');


     myCU: ControlUnit port map(instruction(15 downto 13),instruction(6 downto 0),excutionSignal,memorySignal,writeBackSignal);
     myRF: RegisterFile port map(clck,writeEnable,instruction(9 downto 7),instruction(12 downto 10)
           ,writeAdd,writeData,readDataSignal1,readDataSignal2);

     writeBackRegister:  my_nDFF generic map (m   => 3) port map(clck,writeBackSignal,writeBack);
     memoryRegister:  my_nDFF generic map (m   => 9) port map(clck,memorySignal,memory);
     excutionRegister:  my_nDFF generic map (m   => 18) port map(clck,excutionSignal,excution);

     readOneRegister:  my_nDFF generic map (m   => 32) port map(clck,readDataSignal1,readData1);
     readTwoRegister:  my_nDFF generic map (m   => 32) port map(clck,readDataSignal2,readData2);

     inputPortReg1:     my_nDFF generic map (m   => 32) port map(clck,inputPortIn,inputPortOutSignal);
     inputPortReg:     my_nDFF generic map (m   => 32) port map(clck,inputPortOutSignal,inputPortOut);
     pcPlusOneReg:     my_nDFF generic map (m   => 32) port map(clck,pcCounterIn,pcCounterOut);

     signExtendReg:    my_nDFF generic map (m   => 32) port map(clck,signExtendSignal,signExtend);

     readOneAddReg:    my_nDFF generic map (m   => 3) port map(clck,instruction(9 downto 7),readAdd1);
     readTwoAddReg:    my_nDFF generic map (m   => 3) port map(clck,instruction(12 downto 10),readAdd2);
end ARCHITECTURE;


