library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.all;


entity StageTwo is 
	port (    
		  clk: in std_logic;
	 	  readData1,readData2,pcCounterOut,inputPortOut,signExtend: in std_logic_vector(31 downto 0);
	 	  readAdd1,readAdd2,writeBack: in std_logic_vector(2 downto 0);
	 	  memory: in std_logic_vector(8 downto 0);
	 	  excution: in std_logic_vector(17 downto 0);

		  jmpEnable: Out std_logic;
		  outPortIn,resultIn,PCvalueIN,REGISTERdata,jmpPC: out std_logic_vector(31 downto 0);
		  controlSignals: out std_logic_vector(8 DOWNTO 0);
		  writeBackIn,instructionAdd2In: Out std_logic_vector(2 downto 0)
        );
end entity; 



architecture StageThreeArch OF StageTwo IS 
	component my_nDFF IS
	   GENERIC ( m : integer);
	   PORT( Clk : IN std_logic;
	      d : IN std_logic_vector(m-1 DOWNTO 0);
	      q : OUT std_logic_vector(m-1 DOWNTO 0));
	END component;
	
	component ALU IS 
	PORT(Read1: IN std_logic_vector(31 downto 0);
	     Read2: IN std_logic_vector(31 downto 0);
	     operation: IN std_logic_vector(7 downto 0);
	     enableALU: IN std_logic;
	     result: Out std_logic_vector(31 downto 0);
	     flags: OUT std_logic_vector(2 downto 0));
	END component;


    signal data1, data2, outPortInSignal, REGISTERdataSignal, ALUresult, FinalResult:std_logic_vector(31 downto 0);
    signal ccr, ccr_signal: std_logic_vector (2 downto 0);
begin
    A1: alu port map (data1 , data2 , excution(7 downto 0) , excution(8) , ALUresult , ccr_signal);

    data1<=readData1 when excution(9)='0'
      else signExtend when excution(9)='1';

    data2<=readData2 when excution(10)='0'
      else signExtend when excution(10)='1';

    FinalResult<= ALUresult when excution(12 downto 11)="00"
             else signExtend when excution(12 downto 11)="01"
             else inputPortOut when excution(12 downto 11)="10";
    
    REGISTERdataSignal<=data1;
    outPortInSignal<=data2;

    

    data1Register: my_nDFF generic map (m   => 32) port map(clk,REGISTERdataSignal,REGISTERdata);
    outPortRegister: my_nDFF generic map (m   => 32) port map(clk,outPortInSignal,outPortIn);
    PCplusOne: my_nDFF generic map (m   => 32) port map(clk,pcCounterOut,PCvalueIN);
    add2Reg: my_nDFF generic map (m   => 3) port map(clk,readAdd2,instructionAdd2In);
    memoryReg: my_nDFF generic map (m   => 9) port map(clk,memory,controlSignals);
    writeBackReg: my_nDFF generic map (m   => 3) port map(clk,writeBack,writeBackIn);
    resultReg: my_nDFF generic map (m   => 32) port map(clk,FinalResult,resultIn);




end architecture;