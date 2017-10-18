library ieee;
use ieee.std_logic_1164.all;

entity multiplexer is
    port(
        i0  : in  std_logic_vector(31 downto 0);
        i1  : in  std_logic_vector(31 downto 0);
        i2  : in  std_logic_vector(31 downto 0);
        i3  : in  std_logic_vector(31 downto 0);
        sel : in  std_logic_vector(1 downto 0);
        o   : out std_logic_vector(31 downto 0)
    );
end multiplexer;

architecture synth of multiplexer is
	signal result : std_logic_vector(31 downto 0);
begin
	multiplexer : process (sel, i0, i1, i2, i3)
	begin
		case sel is
		when "00" => result <= i0;
		when "01" => result <= i1;
		when "10" => result <= i2;
		when "11" => result <= i3;
		when others => result <= (others => '0');
		end case;
	end process multiplexer;
o <= result; 
end synth;
