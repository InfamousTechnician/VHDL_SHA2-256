--Implementation based upon https://csrc.nist.gov/csrc/media/publications/fips/180/2/archive/2002-08-01/documents/fips180-2.pdf

--MIT License
--
--Copyright (c) 2019 Balazs Valer Fekete
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

LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

ENTITY sha256forBTCpipeElement is
     Port (  --clock        : in  STD_LOGIC;
              --input side signals
              kIn       : in  STD_LOGIC_VECTOR(31 downto 0) := x"428a2f98";
              wIn       : in  STD_LOGIC_VECTOR(511 downto 0) := x"61626380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018";
              stateIn   : in  STD_LOGIC_VECTOR(255 downto 0) := x"6a09e667bb67ae853c6ef372a54ff53a510e527f9b05688c1f83d9ab5be0cd19";
              --output side signals
              wOut      : out STD_LOGIC_VECTOR(511 downto 0);
              stateOut  : out STD_LOGIC_VECTOR(255 downto 0));
end sha256forBTCpipeElement;

ARCHITECTURE Behavioral of sha256forBTCpipeElement is

    signal k_reg,s_sum,w_sum,a,s0,s1,su0,su1,maj,ch,r1,r2,r3,r4,r5,r6,r7 : STD_LOGIC_VECTOR(31 downto 0);
    type shift_regT is array (3 downto 0) of STD_LOGIC_VECTOR(31 downto 0);
    signal b,c,d,e,f,g,h : shift_regT;
    type wT is array (15 downto 0) of STD_LOGIC_VECTOR(31 downto 0);
    signal w : wT;
--test
    signal clock : std_logic;

BEGIN

    nlfsr: process(clock)
    begin
        if rising_edge(clock) then
            k_reg <= kIn;

            w(0) <= wIn(31 downto 0);
            w(1) <= wIn(63 downto 32);
            w(2) <= wIn(95 downto 64);
            w(3) <= wIn(127 downto 96);
            w(4) <= wIn(159 downto 128);
            w(5) <= wIn(191 downto 160);
            w(6) <= wIn(223 downto 192);
            w(7) <= wIn(255 downto 224);
            w(8) <= wIn(287 downto 256);
            w(9) <= wIn(319 downto 288);
            w(10) <= wIn(351 downto 320);
            w(11) <= wIn(383 downto 352);
            w(12) <= wIn(415 downto 384);
            w(13) <= wIn(447 downto 416);
            w(14) <= wIn(479 downto 448);
            w(15) <= wIn(511 downto 480);
            
            s0 <= (w(14)(6 downto 0) & w(14)(31 downto 7)) xor (w(14)(17 downto 0) & w(14)(31 downto 18)) xor ("000" & w(14)(31 downto 3));
            s1 <= (w(1)(16 downto 0) & w(1)(31 downto 17)) xor (w(1)(18 downto 0) & w(1)(31 downto 19)) xor ("0000000000" & w(1)(31 downto 10));
            s_sum <= s0 + s1;
            w_sum <= w(15) + w(6);
            wOut <= w(14) & w(13) & w(12) & w(11) & w(10) & w(9) & w(8) & w(7)
                    & w(6) & w(5) & w(4) & w(3) & w(2) & w(1) & w(0) & (w_sum + s_sum);
        end if;
    end process;
    

    compression: process(clock)
    begin
        if rising_edge(clock) then

            r7   <= stateIn(31 downto 0);
            h(0) <= stateIn(63 downto 32);
            g(0) <= stateIn(95 downto 64);
            f(0) <= stateIn(127 downto 96);
            e(0) <= stateIn(159 downto 128);
            d(0) <= stateIn(191 downto 160);
            c(0) <= stateIn(223 downto 192);
            b(0) <= stateIn(255 downto 224);

            r6 <= w(15) + k_reg;
            r5 <= ch + r6 + r7; --critical path
            r4 <= su1;
            r3 <= maj;
            r2 <= r3 + r4 + r5;
            r1 <= su0;
            
            a <= r1 + r2;
            b(3 downto 1) <= b(2 downto 0);
            c(3 downto 1) <= c(2 downto 0);
            d(3 downto 1) <= d(2 downto 0);
            e(1) <= e(0);
            e(2) <= e(1) + r4 + r5;
            e(3) <= e(2);
            f(3 downto 1) <= f(2 downto 0);
            g(3 downto 1) <= g(2 downto 0);
            h(3 downto 1) <= h(2 downto 0);

        end if;
    end process;

    ch <= (f(0) and g(0)) xor ((not f(0)) and h(0));
    su1 <= (f(0)(5 downto 0) & f(0)(31 downto 6)) xor (f(0)(10 downto 0) & f(0)(31 downto 11)) xor (f(0)(24 downto 0) & f(0)(31 downto 25));
    maj <= (b(0) and (c(0) xor d(0))) xor (c(0) and d(0));
    su0 <= (b(1)(1 downto 0) & b(1)(31 downto 2)) xor (b(1)(12 downto 0) & b(1)(31 downto 13)) xor (b(1)(21 downto 0) & b(1)(31 downto 22));

    stateOut <= a & b(3) & c(3) & d(3) & e(3) & f(3) & g(3) & h(3);

--test
    process begin
        clock <= '0';
        wait for 5 ns;
        clock <= '1';
        wait for 5 ns;
    end process;
    
    
end Behavioral;
