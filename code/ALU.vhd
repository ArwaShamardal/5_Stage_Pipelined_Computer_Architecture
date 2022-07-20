LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY ALU IS 
PORT(Read1: IN std_logic_vector(31 downto 0);
     Read2: IN std_logic_vector(31 downto 0);
     operation: IN std_logic_vector(7 downto 0);
     enableALU: IN std_logic;
     result: Out std_logic_vector(31 downto 0);
     flags: OUT std_logic_vector(2 downto 0));
END ALU;

ARCHITECTURE arch_ALU OF ALU IS 
SIGNAL temp: std_logic_vector(31 downto 0);
SIGNAL resultReg: std_logic_vector(31 downto 0);
SIGNAL isShift: std_logic_Vector(1 downto 0);


BEGIN 

isShift<= "00"  WHEN (operation(6) = '1' and enableALU = '1' and operation(0) = '0') --SHL
     else "11"  WHEN (operation(6) = '1' and enableALU = '1' and operation(0) = '1') --SHR)
     else "10";

resultReg <=  
--shift_left(read2,operation(5 downto 1))  WHEN isShift = "00" --SHL
--        ELSE read2 srl  operation(5 downto 1) WHEN isShift = "00"--SHR

         (NOT Read2) WHEN (operation(7 downto 0) = "01000000" and enableALU = '1') -- NOT
        ELSE (std_logic_vector(to_signed(to_integer(unsigned(Read2)) + 1, 32))) WHEN (operation(7 downto 0) = "01000001" and enableALU = '1') -- INC
        ELSE (std_logic_vector(to_signed(to_integer(unsigned(Read2)) - 1, 32))) WHEN (operation(7 downto 0) = "01000010" and enableALU = '1') -- DEC
        ELSE read1 WHEN (operation(7 downto 0) = "01000011" and enableALU = '1') -- MOV
        ELSE (std_logic_vector(to_signed(to_integer(unsigned(Read1)) + to_integer(unsigned(Read2)), 32))) WHEN (operation(7 downto 0) = "01000111" and enableALU = '1') -- ADD
        ELSE (std_logic_vector(to_unsigned(to_integer(unsigned(Read1)) - to_integer(unsigned(Read2)), 32))) WHEN (operation(7 downto 0) = "01000100" and enableALU = '1') -- SUB
        ELSE (Read1 AND Read2) WHEN (operation(7 downto 0) = "01000101" and enableALU = '1') -- AND
        ELSE (Read1 OR Read2) WHEN (operation(7 downto 0) = "01000110" and enableALU = '1') -- OR
        ELSE (std_logic_vector(to_signed(to_integer(unsigned(Read2)) + to_integer(unsigned(read1)), 32))) WHEN (operation(7 downto 0) = "01010111" and enableALU = '1') -- ADDI
        ELSE (std_logic_vector(to_signed(to_integer(unsigned(Read2)) + to_integer(unsigned(read1)), 32))) WHEN (operation(7 downto 0) = "01100111" and enableALU = '1') -- STD
        ELSE (std_logic_vector(to_signed(to_integer(unsigned(Read1)) + to_integer(unsigned(read2)), 32))) WHEN (operation(7 downto 0) = "01110111" and enableALU = '1'); -- LDD

---------------------------- TODO: SHIFT FLAGS ----------------------------
--carry <= () WHEN (operation(7 downto 6) = "11" and enable = '1' and operation(0) = '0') --SHL
--ELSE () WHEN (operation(7 downto 6) = "11" and enable = '1' and operation(0) = '1') --SHR

result <= resultReg;

flags(0) <= '1' WHEN ((resultReg = X"00000000") AND (NOT(NOT operation(6 downto 5) = "00")) AND (NOT(operation(7 downto 0) = "01000011")) AND (enableALU = '1'))
ELSE '0';

flags(1) <= '1' WHEN ((resultReg = X"00000000") AND (NOT(NOT operation(6 downto 5) = "00")) AND (NOT(operation(7 downto 0) = "01000011")) AND (enableALU = '1'))-------- CHECK if result negative here
ELSE '0';

END arch_ALU;

---------------------------- SAME CHANGE IN FLAGS ----------------------------
--ELSE () WHEN (operation(7 downto 0) = "01000000" and enable = '1') -- NOT
--ELSE () WHEN (operation(7 downto 0) = "01000001" and enable = '1') -- INC
--ELSE () WHEN (operation(7 downto 0) = "01000010" and enable = '1') -- DEC
--ELSE () WHEN (operation(7 downto 0) = "01000111" and enable = '1') -- ADD
--ELSE () WHEN (operation(7 downto 0) = "01010111" and enable = '1') -- ADDI
--ELSE () WHEN (operation(7 downto 0) = "01000100" and enable = '1') -- SUB
--ELSE () WHEN (operation(7 downto 0) = "01000101" and enable = '1') -- AND
--ELSE () WHEN (operation(7 downto 0) = "01000110" and enable = '1') -- OR

---------------------------- NO CHANGE IN FLAGS ----------------------------
--ELSE (carry) WHEN (operation(7 downto 0) = "01000011" and enable = '1') -- MOV
--ELSE () WHEN (operation(7 downto 0) = "01100111" and enable = '1') -- STD
--ELSE () WHEN (operation(7 downto 0) = "01110111" and enable = '1'); -- LDD