
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
 
ENTITY StageFour IS 
	PORT(
             clk: IN std_logic;
	     writeBackIn: in std_logic_vector(2 downto 0);
	     instructionAdd2In: in std_logic_vector(2 downto 0);

	     memoryOutData: in std_logic_vector(31 DOWNTO 0);
	     resultIn: in std_logic_vector(31 downto 0);
	     outPortIn: in std_logic_vector(31 downto 0);

	     readAdd2: out std_logic_vector(2 DOWNTO 0);
             writeBackEnable:out std_logic;
	     writeData,outData: out std_logic_vector(31 DOWNTO 0)
);
END StageFour;

ARCHITECTURE StageFourArch OF StageFour is

	component my_nDFF IS
	   GENERIC ( m : integer);
	   PORT( Clk : IN std_logic;
	      d : IN std_logic_vector(m-1 DOWNTO 0);
	      q : OUT std_logic_vector(m-1 DOWNTO 0));
	END component;

Begin

	readAdd2<=instructionAdd2In;
	writeBackEnable<= writeBackIn(2);
	
	outData<= outPortIn when writeBackIn(1 downto 0) ="10";

        writeData<=memoryOutData when writeBackIn(1 downto 0) ="00"
	    else resultIn when writeBackIn(1 downto 0) ="01"
	    else outPortIn when writeBackIn(1 downto 0) ="10";

end ARCHITECTURE;