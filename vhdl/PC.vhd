library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        en      : in  std_logic;
        sel_a   : in  std_logic;
        sel_imm : in  std_logic;
        add_imm : in  std_logic;
        imm     : in  std_logic_vector(15 downto 0);
        a       : in  std_logic_vector(15 downto 0);
        addr    : out std_logic_vector(31 downto 0)
    );
end PC;

architecture synth of PC is
signal myaddress : std_logic_vector(31 downto 0);
begin
	pc : process(clk, en, reset_n)
	begin
		if(en = '1') then
			if(add_imm = '1') then
				myaddress <= std_logic_vector(unsigned(myaddress) + unsigned(imm));
			myaddress <= std_logic_vector(unsigned(myaddress) + 4);
			end if;
			if(sel_imm = '1') then
				myaddress <= "00000000000000" & imm & "00";
			end if;
		end if;
	end process;

	synchronous : process(clk, reset_n)
	begin
		if (reset_n = '0') then
			myaddress <= (others => '0');
		elsif rising_edge(clk) then
			addr <= myaddress;
		end if;
	end process;
end synth;
