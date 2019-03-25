--Implementation based upon https://csrc.nist.gov/csrc/media/publications/fips/180/2/archive/2002-08-01/documents/fips180-2.pdf

--MIT License
--
--Copyright (c) 2018 Balazs Valer Fekete
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY sha256for1chunkTB IS
END sha256for1chunkTB;
 
ARCHITECTURE behavior OF sha256for1chunkTB IS 
 
	 -- Component Declaration for the Unit Under Test (UUT)
 
	 COMPONENT sha256for1chunk
	 Port ( reset	 : in  STD_LOGIC;
			  clock	 : in  STD_LOGIC;
			  --input side signals
			  plain	 : in  STD_LOGIC_VECTOR(511 downto 0);
			  load : in  STD_LOGIC;
			  empty	: out STD_LOGIC;
			  --output side signals
			  digest	: out STD_LOGIC_VECTOR (255 downto 0);
			  ready	 : out STD_LOGIC);
	 END COMPONENT;
	 

	--Inputs
	signal reset : std_logic := '0';
	signal clock : std_logic := '0';
	signal plain : std_logic_vector(511 downto 0) := (others => '0');
	signal load : std_logic := '0';

 	--Outputs
	signal digest : std_logic_vector(255 downto 0);
	signal testPassed, ready, empty : std_logic;
	
	-- Clock period definitions
	constant clock_period : time := 10 ns;
	--standard"s test vector's result
	constant hash2b : std_logic_vector(255 downto 0) := x"ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad";
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
	uut: sha256for1chunk PORT MAP (
			 reset => reset,
			 clock => clock,
			 plain => plain,
			 load => load,
			 digest => digest,
			 ready => ready,
			 empty => empty
		  );

	-- Clock process definitions
	clock_process :process
	begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
	end process;
 

	-- Stimulus process
	stim_proc: process
	begin		
		reset <= '1';
		wait for clock_period;
		reset <= '0';
		load <= '1';
		--test vector from standard
		plain <= x"61626380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018";
		wait for clock_period;
		load <= '0';
		plain <= (others => '0');
		wait for clock_period*70;
		wait;
	end process;

testPassed <= '1' when hash2b = digest else '0';

END;
