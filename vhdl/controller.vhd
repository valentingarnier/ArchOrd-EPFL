library ieee;
use ieee.std_logic_1164.all;

entity controller is
    port(
        clk        : in  std_logic;
        reset_n    : in  std_logic;
        -- instruction opcode
        op         : in  std_logic_vector(5 downto 0);
        opx        : in  std_logic_vector(5 downto 0);
        -- activates branch condition
        branch_op  : out std_logic;
        -- immediate value sign extention
        imm_signed : out std_logic;
        -- instruction register enable
        ir_en      : out std_logic;
        -- PC control signals
        pc_add_imm : out std_logic;
        pc_en      : out std_logic;
        pc_sel_a   : out std_logic;
        pc_sel_imm : out std_logic;
        -- register file enable
        rf_wren    : out std_logic;
        -- multiplexers selections
        sel_addr   : out std_logic;
        sel_b      : out std_logic;
        sel_mem    : out std_logic;
        sel_pc     : out std_logic;
        sel_ra     : out std_logic;
        sel_rC     : out std_logic;
        -- write memory output
        read       : out std_logic;
        write      : out std_logic;
        -- alu op
        op_alu     : out std_logic_vector(5 downto 0)
    );
end controller;

architecture synth of controller is
type state is(FETCH1, FETCH2, DECODE, R_OP, I_OP, STORE, BREAK, LOAD1, LOAD2);
signal currentState, nextState : state;
begin

controller1: process(currentState, op, opx)
begin
branch_op <= '0';
        imm_signed <= '0';
        ir_en <= '0';
        pc_add_imm <= '0';
        pc_en <= '0';
        pc_sel_a <= '0';
        pc_sel_imm <= '0';
        rf_wren <='0';
        sel_addr <= '0';
        sel_b <= '0';
        sel_mem <= '0';
        sel_pc <= '0';
        sel_ra <='0';
        sel_rC <= '0';
        read <= '0';
        write <= '0';

	case currentState is
	when FETCH1 => 
		read <= '1';
		nextState <= FETCH2;
	when FETCH2 => 
		pc_en <= '1';
		ir_en <= '1';
		nextState <= DECODE;
	when DECODE => 
		case op is
		when "111010" =>
			if(opx = "001110" OR opx = "011011") then
				nextState <= R_OP;
			elsif(opx = "110100") then
				nextState <= BREAK;
			end if;
		when "000100" => nextState <= I_OP;
		when "010111" => nextState <= LOAD1;
		when "010101" => nextState <= STORE;
		when others => nextState <= FETCH1;
		end case;
	when I_OP =>
		rf_wren <= '1';
		imm_signed <= '1';
		nextState <= FETCH1;
	when R_OP =>
		sel_rC <= '1';
		sel_b <= '1';
		rf_wren <= '1';
		nextState <= FETCH1;
	when LOAD1 =>
		sel_addr <= '1';
		sel_b <= '0';
		read <= '1';
		imm_signed <= '1';
		nextState <= LOAD2;
	when LOAD2 =>
		sel_rC <= '0';
		rf_wren <= '1';
		sel_mem <= '1';
		nextState <= FETCH1;
	when STORE =>
		sel_addr <= '1';
		sel_b <= '0';
		write <= '1';
		imm_signed <= '1';
		nextState <= FETCH1;
	when BREAK =>
		nextState <= BREAK; 
	when others => nextState <= FETCH1;
	end case;
end process;

changing_state : process(clk, currentState, reset_n)
begin
	if(reset_n = '0') then
		currentState <= FETCH1;
	elsif rising_edge(clk) then
		currentState <= nextState;
	end if;
end process;

writing_op_alu: process(op, opx)
begin

op_alu <= "000000";
if(op = "111010") then
	if(opx = "001110") then op_alu <= "101101";
	elsif(opx = "011011") then op_alu <= "110011";
	end if;
end if;
		--elsif(opx = "011011") then op_alu <= "110011";
end process;
end synth;