library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_sub is
    port(
        a        : in  std_logic_vector(31 downto 0);
        b        : in  std_logic_vector(31 downto 0);
        sub_mode : in  std_logic;
        carry    : out std_logic;
        zero     : out std_logic;
        r        : out std_logic_vector(31 downto 0)
    );
end add_sub;

architecture synth of add_sub is
	signal secondOperand : std_logic_vector(31 downto 0);
	signal carryOut : std_logic;
	signal totalZero : std_logic;
	signal result : std_logic_vector(32 downto 0);
	signal sub_mode_full : std_logic_vector(31 downto 0); 
	signal resultForAdder : std_logic_vector(31 downto 0);
begin
	sub_mode_full <= "0000000000000000000000000000000" & sub_mode;
	XORgate : process(b, sub_mode)
	begin
		if (sub_mode = '1') then
			secondOperand <= not b;
		else secondOperand <= b;
		end if;
	end process XORgate;

	carryOut <= result(32);
	resultForAdder <= result(31 downto 0);

	adder : process(a, secondOperand, sub_mode_full)
	begin	
		result <= std_logic_vector(unsigned('0' & a) + unsigned('0' & secondOperand) + unsigned('0' & sub_mode_full)); 	
	end process adder;

	check0 : process (resultForAdder)
	begin
		if(signed(resultForAdder) = 0) then
		totalZero <= '1';
		else totalZero <= '0';
		end if;
	end process check0;
r <= resultForAdder;
zero <= totalZero;
carry <= carryOut;
end synth;
