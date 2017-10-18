library ieee;
use ieee.std_logic_1164.all;

entity extend is
    port(
        imm16  : in  std_logic_vector(15 downto 0);
        signed : in  std_logic;
        imm32  : out std_logic_vector(31 downto 0)
    );
end extend;

architecture synth of extend is
signal complement2 : std_logic_vector(15 downto 0);
begin
	extend : process(imm16, signed)
	begin
		if((signed = '0') OR (signed = '1' AND (imm16(15) = '0'))) then
			imm32 <= "0000000000000000" & imm16;
		else imm32 <= "1111111111111111" & imm16;
		end if;
	end process;
end synth;
