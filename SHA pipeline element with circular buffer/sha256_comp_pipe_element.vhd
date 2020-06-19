--(c) Fekete Balázs Valér fbv81bp@outlook.hu fbv81bp@gmail.com All rights reserved!

LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity sha256_comp_pipe_element is
    Port ( --clock : in STD_LOGIC;
           pipeIn : in STD_LOGIC_VECTOR (255 downto 0):= x"6a09e667bb67ae853c6ef372a54ff53a510e527f9b05688c1f83d9ab5be0cd19";
           kwSumIn : in STD_LOGIC_VECTOR (31 downto 0) := x"a3ec9318";
           pipeOut : out STD_LOGIC_VECTOR (255 downto 0));--x"5d6aebcd6a09e667bb67ae853c6ef372fa2a4622510e527f9b05688c1f83d9ab" after 1 cycle
                                                            --5d6aebcd6a09e667bb67ae853c6ef372fa2a4622510e527f9b05688c1f83d9ab  correct
end sha256_comp_pipe_element;

architecture Behavioral of sha256_comp_pipe_element is

    component distRAM5x32w2cnt is
        Port ( clock : in STD_LOGIC;
               data : in STD_LOGIC_VECTOR (31 downto 0);
               reg0 : out STD_LOGIC_VECTOR (31 downto 0);
               reg1 : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    component distRAM4x32w2cnt is
        Port ( clock : in STD_LOGIC;
               data : in STD_LOGIC_VECTOR (31 downto 0);
               reg1 : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    signal a, b, bIn, c, cIn, d, dIn, e, e4, eIn, f, fIn, g, gIn, h, hIn, r, rIn : std_logic_vector(31 downto 0) := x"00000000"; 
    signal r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r12, r13, r15, r16, r17, r18, r19, r20, r11sumR14 : std_logic_vector(31 downto 0) := x"00000000"; 
    signal ch, su1, maj, su0 : std_logic_vector(31 downto 0);
    
    --testing...
    signal clock : std_logic := '0';
    
begin
    --testing...
    process begin
        wait for 5 ns;
        clock <= not clock;
    end process;
    --...end testing

    bIn <= pipeIn(255 downto 224);
    cIn <= pipeIn(223 downto 192);
    dIn <= pipeIn(191 downto 160);
    eIn <= pipeIn(159 downto 128);
    fIn <= pipeIn(127 downto  96);
    gIn <= pipeIn( 95 downto  64);
    hIn <= pipeIn( 63 downto  32);
    rIn <= pipeIn( 31 downto   0);

    shiftRegB : distRAM5x32w2cnt Port Map (clock => clock, data => bIn, reg0 => r18, reg1 => b);
    shiftRegC : distRAM5x32w2cnt Port Map (clock => clock, data => cIn, reg0 => r19, reg1 => c);
    shiftRegD : distRAM5x32w2cnt Port Map (clock => clock, data => dIn, reg0 => r20, reg1 => d);
    shiftRegE : distRAM4x32w2cnt Port Map (clock => clock, data => eIn, reg1 => e4);
    shiftRegF : distRAM5x32w2cnt Port Map (clock => clock, data => fIn, reg0 => r15, reg1 => f);
    shiftRegG : distRAM5x32w2cnt Port Map (clock => clock, data => gIn, reg0 => r16, reg1 => g);
    shiftRegH : distRAM5x32w2cnt Port Map (clock => clock, data => hIn, reg0 => r17, reg1 => h);
    
    registers : process(clock) begin
        if rising_edge(clock) then
            r0 <= rIn;
            r1 <= r0;
            r2 <= r3;
            r3 <= kwSumIn;
            r4 <= r1 + r2;
            r5 <= ch;
            r6 <= su1;
            r7 <= r5 + r6;
            r8 <= r4 + r7;
            r9 <= maj;
            r10 <= r9;
            r12 <= su0;
            r13 <= r12;
            r11sumR14 <= r10 + r13;
            a <= r11sumR14 + r8;
            e <= e4 + r8;
         end if;
    end process;
    
    --compression's asynchron circuitry
    ch  <= (r15 and r16) xor ((not r15) and r17);
    su1 <= (r15(5 downto 0) & r15(31 downto 6)) xor (r15(10 downto 0) & r15(31 downto 11)) xor (r15(24 downto 0) & r15(31 downto 25));
    maj <= (r18 and (r19 xor r20)) xor (r19 and r20);
    su0 <= (r18(1 downto 0) & r18(31 downto 2)) xor (r18(12 downto 0) & r18(31 downto 13)) xor (r18(21 downto 0) & r18(31 downto 22));
    
    pipeOut <= a & b & c & d & e & f & g & h;

end Behavioral;
