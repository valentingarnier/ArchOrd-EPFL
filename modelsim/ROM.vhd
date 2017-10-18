library ieee;
use ieee.std_logic_1164.all;

entity ROM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        rddata  : out std_logic_vector(31 downto 0)
    );
end ROM;

architecture synth of ROM is

component ROM_Block is 
	PORT
		(
		address	: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock : IN STD_LOGIC  := '1';
		q : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
end component;
	signal dataOut : std_logic_vector(31 downto 0);
begin
	block0 : ROM_block
	port map(address => address,
		clock => clk,
		q => dataOut);

	tri_state : process(address)
	begin
		rddata <= (others => 'Z');
		if((read AND cs) = '1') then
		rddata <= dataOut;
		end if;
	end process;
end synth;
