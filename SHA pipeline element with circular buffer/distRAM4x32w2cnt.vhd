--(c) Fekete Balázs Valér fbv81bp@outlook.hu fbv81bp@gmail.com All rights reserved!

LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity distRAM4x32w2cnt is
    Port ( clock : in STD_LOGIC;
           data : in STD_LOGIC_VECTOR (31 downto 0);
           reg1 : out STD_LOGIC_VECTOR (31 downto 0));
end distRAM4x32w2cnt;

architecture Behavioral of distRAM4x32w2cnt is

    type ramT is array(0 to 3) of std_logic_vector(31 downto 0);
    signal ram : ramT := (x"00000000", x"00000000", x"00000000", x"00000000");
    signal cnt0 : std_logic_vector(1 downto 0) := "00"; 
    signal cnt1 : std_logic_vector(1 downto 0) := "01";
    signal reg1o : std_logic_vector(31 downto 0) := x"00000000";

begin

    proc : process(clock)
    begin
        if rising_edge(clock) then
            cnt0 <= cnt0 + '1';
            cnt1 <= cnt1 + '1';
            ram(conv_integer(cnt0)) <= data;
            reg1o <= ram(conv_integer(cnt1));
        end if;
    end process;

    reg1 <= reg1o;

end Behavioral;
