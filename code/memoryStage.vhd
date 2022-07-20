LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
 
ENTITY memoryStage IS 
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

END memoryStage;
 
ARCHITECTURE arch OF memoryStage IS
 
	component my_nDFF IS
	   GENERIC ( m : integer);
	   PORT( Clk : IN std_logic;
	      d : IN std_logic_vector(m-1 DOWNTO 0);
	      q : OUT std_logic_vector(m-1 DOWNTO 0));
	END component;
 
 
	TYPE ram_type IS ARRAY(0 TO (1024*1024)-1) of std_logic_vector(15 DOWNTO 0);
	SIGNAL ram : ram_type ;
	SIGNAL INAddress: std_logic_vector(19 DOWNTO 0);
	SIGNAL DataToWrite: std_logic_vector(31 DOWNTO 0);
	SIGNAL outdataSignal,spPlusOne,OutDataReg: std_logic_vector(31 DOWNTO 0);
	SIGNAL spSignal: std_logic_vector(31 DOWNTO 0):=X"000FFFFE";
	SIGNAL spWrapAround: std_logic;
        Signal TestInteger:integer;
 
BEGIN

-- mux1
	INAddress <= resultIn(19 downto 0) WHEN controlSignals(2) = '0'
	ELSE SP(19 downto 0) WHEN controlSignals(2) = '1';
	 
-- mux2
	DataToWrite <= outPortIn WHEN controlSignals(1 DOWNTO 0) = "00"
	ELSE PCvalueIn WHEN controlSignals(1 DOWNTO 0) = "01"
	ELSE REGISTERdata;
	
        TestInteger<=to_integer(unsigned((INAddress)));
--Writing/reading data
--	ram(to_integer(unsigned((INAddress)))) <= DataToWrite(15 DOWNTO 0)
--            when controlSignals(4 DOWNTO 3) = "01" ;
--	ram(to_integer(unsigned((std_logic_vector(to_unsigned(to_integer(unsigned(INAddress)) + 1, 20)))))) <= DataToWrite(31 DOWNTO 16)
--            when controlSignals(4 DOWNTO 3) = "01" ;

	OutDataReg(15 DOWNTO 0) <= ram(to_integer(unsigned((INAddress))))
            when controlSignals(4 DOWNTO 3) = "10";--
	OutDataReg(31 DOWNTO 16) <= ram(to_integer(unsigned((std_logic_vector(to_unsigned(to_integer(unsigned(INAddress)) + 1, 20))))))
            when controlSignals(4 DOWNTO 3) = "10";


-- changing SP value
       spWrapAround <= '0' when (spSignal(19 downto 0)= X"FFFFF" and controlSignals(5) = '1')
              else '1';
       SP <= spSignal ;


	PROCESS(clk) IS
	BEGIN
	     IF rising_edge(clk) THEN
	        IF controlSignals(4 DOWNTO 3) = "01" THEN --write
	           ram(to_integer(unsigned((INAddress)))) <= DataToWrite(15 DOWNTO 0);
	           ram(to_integer(unsigned((std_logic_vector(to_unsigned(to_integer(unsigned(INAddress)) + 1, 20)))))) <= DataToWrite(31 DOWNTO 16);
	        END IF;

		IF controlSignals(6) = '1' THEN
	                IF (controlSignals(5) = '1' and spSignal(19 downto 0)=X"FFFFE") then
	                         spSignal <= X"00000000";
	                elsIF (controlSignals(5) = '1' and spSignal(19 downto 0)=X"FFFFF") then
	                         spSignal <= X"00000001";
	                elsIF (controlSignals(5) = '0' and spSignal(19 downto 0)=X"00000") then
	                         spSignal <= X"000FFFFE";
	                elsIF (controlSignals(5) = '0' and spSignal(19 downto 0)=X"00001") then
	                         spSignal <= X"000FFFFF";
	                else 
			      IF controlSignals(5) = '1' THEN
			         spSignal <= std_logic_vector(to_unsigned(to_integer(unsigned(SP)) + 2, 32));
			      ELSIF controlSignals(5) = '0' THEN 
			         spSignal <= std_logic_vector(to_unsigned(to_integer(unsigned(SP)) - 2, 32));
		              END IF;
		      END IF;
		END IF;
	     END IF;
--(spSignal(19 downto 0)/=X"00000" and spSignal(19 downto 0)/=X"00001" and spSignal(19 downto 0)/=X"FFFFF" and spSignal(19 downto 0)/=X"FFFFE")
	
	-- mux3
	END PROCESS;


	PCvalueOut <= OutDataReg when (controlSignals(7) = '1'  and controlSignals(8) = '1')
	        else outPortIn when (controlSignals(7) = '0'  and controlSignals(8) = '1'); 

	CallReturnEnable <= controlSignals(8);

     writeBackRegister:  my_nDFF generic map (m   => 3) port map(clk,writeBackIn,writeBackOut);
     outportRegister:     my_nDFF generic map (m   => 32) port map(clk,outPortIn,outPortOut);
     resultRegister:   my_nDFF generic map (m   => 32) port map(clk,resultIn,resultOut);
     Add2Register:   my_nDFF generic map (m   => 3) port map(clk,instructionAdd2In,instructionAdd2Out);
     OutDataRegister:  my_nDFF generic map (m   => 32) port map(clk,OutDataReg,OutData);
 
END arch;
