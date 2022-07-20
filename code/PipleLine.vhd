library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.all;


entity Pipeline is 
	port (
                  inputPortIn: in std_logic_vector(31 downto 0);
		  clck: in std_logic;

	          OUTdata: out std_logic_vector(31 downto 0)
        );
end Pipeline;

architecture PiplelineArch OF Pipeline IS 
	component memoryStage IS 
	GENERIC(n: integer := 16 );
	PORT(clk: IN std_logic;
	 
	     writeBackIn: IN std_logic_vector(2 downto 0);
	     outPortIn: IN std_logic_vector(31 downto 0);
	     resultIn: IN std_logic_vector(31 downto 0);
	     instructionAdd2In: IN std_logic_vector(2 downto 0);
	     PCvalueIN: IN std_logic_vector(31 DOWNTO 0);
	 
	     SP: INOUT std_logic_vector(31 DOWNTO 0);
	     controlSignals: IN std_logic_vector(8 DOWNTO 0);
	     REGISTERdata: IN std_logic_vector(31 DOWNTO 0);
	 
	     writeBackOut: Out std_logic_vector(2 downto 0);
	     outPortOut: Out std_logic_vector(31 downto 0);
	     resultOut: Out std_logic_vector(31 downto 0);
	     instructionAdd2Out: Out std_logic_vector(2 downto 0);
	     PCvalueOut: OUT std_logic_vector(31 DOWNTO 0);
	     CallReturnEnable: OUT std_logic;
	
	     OUTdata: OUT std_logic_vector(31 DOWNTO 0));
	END component;


	component StageZero is 
		port (
	              jmpPC,callretPC: in std_logic_vector(31 downto 0);
	              pcSelector: in std_logic_vector(1 downto 0);
	              clck: in std_logic;
	              instructionOut, pcCounterOut: OUT std_logic_vector(31 downto 0)
	        );
	end component; 
	component StageOne is 
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
	end component; 

	component StageFour IS 
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
	END component;



	component StageTwo is 
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
	end component; 










  
  signal FDinstructionSignal,FDpcCounterOutSignal,DEpcCounterOutSignal,EMpcCounterOutSignal
         ,MFcallRetPCSignal,MMspSignal,WDwriteData,MWoutPortOut
         ,DEinputPortIn,DEsignExtend,EMoutPortIn
         ,DEreg1Data
         ,DEreg2Data,EMreg2Data,EMresult,MWResult,MWoutData,EFjmpPC:std_logic_vector(31 downto 0);

  signal DEwriteBackSignal,EMwriteBackSignal,add2Signal,add2SignalMW,MWwriteBack
         ,DEadd1,DEadd2,EMadd2,MWadd2,WDwriteAdd:std_logic_vector(2 downto 0);

  signal DEexcution:std_logic_vector(17 downto 0);

  signal pcSelector:std_logic_vector(1 downto 0);
  signal DEmemorySignal,EMmemorySignal:std_logic_vector(8 downto 0);
  signal MFCallReturnEnableSignal,jmpEnableSignal,WDwriteEnable:std_logic;
Begin
       pcSelector<=MFCallReturnEnableSignal & jmpEnableSignal;


       Stage0: StageZero port map(jmpPC=>EFjmpPC , callretPC=>MFcallRetPCSignal , pcSelector=>pcSelector,clck=>clck

               ,instructionOut=>FDinstructionSignal,pcCounterOut=>FDpcCounterOutSignal);--OUT signals



       Stage1: StageOne port map(writeEnable=> WDwriteEnable , writeAdd=>WDwriteAdd , writeData=>WDwriteData 
              , instruction=>FDinstructionSignal, pcCounterIn=>FDpcCounterOutSignal , inputPortIn=>inputPortIn , clck=>clck

              ,readData1=>DEreg1Data , readData2=>DEreg2Data , pcCounterOut=>DEpcCounterOutSignal , inputPortOut=>DEinputPortIn,
               signExtend=>DEsignExtend , readAdd1=> DEadd1, readAdd2=>DEadd2 ,
               writeBack=>DEwriteBackSignal , memory=>DEmemorySignal , excution=>DEexcution);


--
       Stage2: StageTwo port map(clk=>clck , readData1=>DEreg1Data , readData2=>DEreg2Data , pcCounterOut=>DEpcCounterOutSignal , 
              inputPortOut=>DEinputPortIn , signExtend=>DEsignExtend , readAdd1=>DEadd1 , 
              readAdd2=>DEadd2 ,writeBack=>DEwriteBackSignal , memory=>DEmemorySignal , excution=>DEexcution , 

              jmpEnable=>jmpEnableSignal , outPortIn=>EMoutPortIn , resultIn=>EMresult , PCvalueIN=>EMpcCounterOutSignal ,
              REGISTERdata=> EMreg2Data, jmpPC=>EFjmpPC , controlSignals=>EMmemorySignal , writeBackIn=>EMwriteBackSignal , instructionAdd2In=>EMadd2);



       Stage3: memoryStage port map(clk=>clck , writeBackIn=>EMwriteBackSignal , outPortIn=>EMoutPortIn ,
               resultIn=>EMresult , instructionAdd2In=>EMadd2 , PCvalueIN=>EMpcCounterOutSignal , SP=>MMspSignal
               ,controlSignals=>EMmemorySignal,REGISTERdata=>EMreg2Data,
      
               writeBackOut=>MWwriteBack , outPortOut=>MWoutPortOut , resultOut=>MWResult , instructionAdd2Out=>MWadd2 , 
               PCvalueOut=>MFcallRetPCSignal , CallReturnEnable=>MFCallReturnEnableSignal , outData=>MWoutData);



       Stage4: StageFour port map(clk=>clck , writeBackIn=>MWwriteBack , instructionAdd2In=>MWadd2 , memoryOutData=>MWoutData,
               resultIn=>MWResult , outPortIn=>MWoutPortOut

               ,readAdd2=>WDwriteAdd , writeBackEnable=> WDwriteEnable, writeData=>WDwriteData , outData=>outData);


end architecture;
 
