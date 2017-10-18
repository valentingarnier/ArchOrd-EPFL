library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        write   : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        wrdata  : in  std_logic_vector(31 downto 0);
        rddata  : out std_logic_vector(31 downto 0));
end RAM;

architecture synth of RAM is
	type ram_type is array (0 to 1023) of std_logic_vector(31 downto 0);
	signal ram: ram_type := (others => (others =>'0'));
	signal save_address : std_logic_vector(9 downto 0);
	signal result_cs_read : std_logic;
begin
	flip_flop : process(clk)
	begin
		if rising_edge(clk) then
			save_address <= address;
			result_cs_read <= read AND cs;
		end if;
	end process;
	
	tri_state : process(result_cs_read, save_address)
	begin
		rddata <= (others => 'Z');
		if(result_cs_read = '1') then
		rddata <= ram(to_integer(unsigned(save_address)));
		end if;
	end process;

	write_process : process(clk, write, address) 
	begin
		if rising_edge(clk) then
			if(write = '1') then
				ram(to_integer(unsigned(address))) <= wrdata;
			end if;
		end if;
	end process;
end synth;
