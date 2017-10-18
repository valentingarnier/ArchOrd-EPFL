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

controller: process(currentState)
begin
	case currentState is
	when FETCH1 => 
		read <= '1';
		nextState <= FETCH2;
	when FETCH2 => 
		pc_en <= '1';
		ir_en <= '1';
		nextState <= DECODE;
	when DECODE => 
		case "00" & op is
		when X"3A" =>
			if(opx = X"0E" AND opx = X"1B") then
				nextState <= R_OP;
			elsif(opx = X"34") then
				nextState <= BREAK;
			end if;
		when X"04" => nextState <= I_OP;
		when X"17" => nextState <= LOAD1;
		when X"15" => nextState <= STORE;
		when others => nextState <= FETCH1; --question
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
		sel_b <= '1';
		read <= '1';
		imm_signed <= '1';
		nextState <= LOAD2;
	when LOAD2 =>
		sel_rC <= '1';
		rf_wren <= '1';
		sel_mem <= '1';
		nextState <= FETCH1;
	when STORE =>
		sel_addr <= '1';
		sel_b <= '1';
		write <= '1';
		imm_signed <= '1';
		nextState <= FETCH1;
	when BREAK =>
		nextState <= BREAK; 
	when others => nextState <= FETCH1;
	end case;
end process;

writing_op_alu: process(op, opx)
begin
	case op is
	when "111010" =>
		if(opx = "0011100") then op_alu <= "101101"; --on met n'importe quoi entre les deux, il seront pas lu
		elsif(opx = "011011") then op_alu <= "11011";
		end if;
	when others => op_alu <= (others => '0');
	end case;
end process;
end synth;
