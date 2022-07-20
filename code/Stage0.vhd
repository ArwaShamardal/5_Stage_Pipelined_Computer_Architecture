library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.all;


entity StageZero is 
	port (
                  jmpPC,callretPC: in std_logic_vector(31 downto 0);
                  pcSelector: in std_logic_vector(1 downto 0);
		  clck: in std_logic;
                  instructionOut, pcCounterOut: OUT std_logic_vector(31 downto 0)
        );
end StageZero; 


ARCHITECTURE StageZeroArch OF StageZero IS
TYPE ram_type IS ARRAY(0 TO (1024*1024)-1) of std_logic_vector(15 DOWNTO 0);
SIGNAL ram : ram_type := ( 0 => X"8001", 1 => X"0000", 2 => X"8401",3 => X"0000",4 => X"8801",5 => X"0000",6 => X"8C01",7 => X"0000"
                          ,8 => X"9001", 9 => X"0000", 10 => X"9401",11 => X"0000",12 => X"9801",13 => X"0000",14 => X"9C01",15 => X"0000"
                          ,16 => X"2000" ,17 => X"2000" ,18=> X"4443" ,19=> X"2000" ,20=> X"2000" ,21=>X"8402",22=>X"0000"
                          ,OTHERS => X"0000" );--IN-Out

--                          ,8 => X"9001", 9 => X"0000", 10 => X"9401",11 => X"0000",12 => X"9801",13 => X"0000",14 => X"9C01",15 => X"0000"
-- in commands from Reg4 to Reg7


   component my_nDFF IS
       GENERIC ( m : integer);
       PORT( Clk : IN std_logic;
             d : IN std_logic_vector(m-1 DOWNTO 0);
             q : OUT std_logic_vector(m-1 DOWNTO 0));
   END  component;

  
  signal instruction,pcInReg,pcOutReg,instructionOutReg:std_logic_vector(31 downto 0);
  signal pcIn:std_logic_vector(19 downto 0):=X"00000";
  signal pcOut,pcInFinal,pcInJmps:std_logic_vector(19 downto 0);
  signal currentPCIndex:integer:=0;
  signal PCSelectorSignal:std_logic_vector(1 downto 0):="00";
  signal currentPCIndexPlusOne:integer;


Begin 

       pcPlusOneReg:     my_nDFF generic map (m   => 32) port map(clck,pcInReg,pcCounterOut);
       instructionReg:     my_nDFF generic map (m   => 32) port map(clck,instruction,instructionOutReg);


   pcInFinal<=X"00000" when (pcIn= X"FFFFF")
          else X"11111";

   instruction <= ram(to_integer(unsigned( pcInFinal))) & ram(currentPCIndex) when pcInFinal=X"00000" 
               else ram(currentPCIndex+1) & ram(currentPCIndex);

--   instructionOut<=instruction when pcSelector="01" or pcSelector="10"
--              else instructionOutReg;
   instructionOut<=instructionOutReg;

   currentPCIndex<=to_integer(unsigned( pcIn));

   currentPCIndexPlusOne<= 0 when pcInFinal=X"00000" 
               else to_integer(unsigned( pcIn))+1;

   pcInReg<=std_logic_vector(to_unsigned(currentPCIndexPlusOne, pcInReg'length));

   --pcOut<=pcIn;
--   pcIn<=pcOut when(pcSelector="00")
--       else pcInJmps;

   pcIn<=jmpPC(19 downto 0) when (pcSelector="01")
         else callretPC(19 downto 0) when (pcSelector="10")
         else pcOut;

       PROCESS(clck)
          BEGIN 
             IF rising_edge(clck) THEN
	                if(ram(currentPCIndex)(15)='0') then 
	                     pcOut <= std_logic_vector(to_unsigned((to_integer(unsigned( pcIn))) + 1, pcIn'length));
	                elsif(ram(currentPCIndex)(15)='1') then
	                     pcOut <= std_logic_vector(to_unsigned((to_integer(unsigned( pcIn))) + 2, pcIn'length)); 
	                End if;

--                elsif(pcSelector="01") then 
--	                     pcIn <= jmpPC(19 downto 0);
--                elsif(pcSelector="10") then 
--	                     pcIn <= callretPC(19 downto 0);


             End if;
       End process;





end ARCHITECTURE;




