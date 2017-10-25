library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_unit is
    port(
        a  : in  std_logic_vector(31 downto 0);
        b  : in  std_logic_vector(4 downto 0);
        op : in  std_logic_vector(2 downto 0);
        r  : out std_logic_vector(31 downto 0)
    );
end shift_unit;

architecture synth of shift_unit is
	signal s_shift_left : std_logic_vector(31 downto 0);
begin
	sh_left : process (a, b)
		variable v : std_logic_vector(31 downto 0);
	begin
		-- The variable v will contain the intermediate value.
		-- For each bit of b, we check if we have to shift v.
		v := a; -- v initialization
		-- shift by 1
		if (b(0) = '1') then
			v := v(30 downto 0) & '0';
		end if;
		-- shift by 2
		if (b(1) = '1') then 
			v := v(29 downto 0) & (1 downto 0 => '0');
		end if;
		-- shift by 4
		if (b(2) = '1') then
			v := v(27 downto 0) & (3 downto 0 => '0');
		end if;
		-- shift by 8
		if (b(3) = '1') then
			v := v(23 downto 0) & (7 downto 0 => '0');
		end if;
		-- shift by 16
		if (b(4) = '1') then v := v(15 downto 0) & (15 downto 0 => '0');
		end if;
		s_shift_left <= v;
	end process;
r <= s_shift_left; 
end synth;
