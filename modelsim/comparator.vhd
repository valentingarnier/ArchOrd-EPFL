library ieee;
use ieee.std_logic_1164.all;

entity comparator is
    port(
        a_31    : in  std_logic;
        b_31    : in  std_logic;
        diff_31 : in  std_logic;
        carry   : in  std_logic;
        zero    : in  std_logic;
        op      : in  std_logic_vector(2 downto 0);
        r       : out std_logic
    );
end comparator;

architecture synth of comparator is
	signal result: std_logic;
begin
	comparison : process (op, zero, carry, a_31, b_31, diff_31)
	begin
		case op is
		when "100" => result <= zero;
		when "011" => result <= not zero;
		when "101" => result <= carry;
		when "110" => result <= not carry;
		when "001" => result <= (not(a_31) and b_31) or (not(diff_31) and (not(a_31) xor b_31));
		when "010" => result <= (a_31 and not(b_31)) or (diff_31 and (not(a_31) xor b_31));
		when others => result <= zero; 
		end case;	
	end process comparison;
r <= result;
end synth;
