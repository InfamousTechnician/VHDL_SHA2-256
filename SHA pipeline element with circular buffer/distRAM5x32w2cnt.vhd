--(c) Fekete Balázs Valér fbv81bp@outlook.hu fbv81bp@gmail.com All rights reserved!

LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity distRAM5x32w2cnt is
    Port ( clock : in STD_LOGIC;
           data : in STD_LOGIC_VECTOR (31 downto 0);
           reg0 : out STD_LOGIC_VECTOR (31 downto 0);
           reg1 : out STD_LOGIC_VECTOR (31 downto 0));
end distRAM5x32w2cnt;

architecture Behavioral of distRAM5x32w2cnt is

    type ramT is array(0 to 4) of std_logic_vector(31 downto 0);
    signal ram : ramT := (x"00000000", x"00000000", x"00000000", x"00000000", x"00000000");
    signal cnt0 : std_logic_vector(2 downto 0) := "000"; 
    signal cnt1 : std_logic_vector(2 downto 0) := "001";
    signal reg0o, reg1o : std_logic_vector(31 downto 0) := x"00000000";

begin

    proc : process(clock)
    begin
        if rising_edge(clock) then
            if cnt0 = "100" then 
                cnt0 <= "000";
            else
                cnt0 <= cnt0 + '1';
            end if;
            if cnt1 = "100" then 
                cnt1 <= "000";
            else
                cnt1 <= cnt1 + '1';
            end if;
            ram(conv_integer(cnt0)) <= data;
            reg0o <= data;
            reg1o <= ram(conv_integer(cnt1));
        end if;
    end process;

    reg0 <= reg0o;
    reg1 <= reg1o;

end Behavioral;
