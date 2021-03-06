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
type state is(FETCH1, FETCH2, DECODE, R_OP, I_OP, STORE, BREAK, LOAD1, LOAD2, BRANCH, CALL, JUMP, R_OP_IMM, I_OP_IMM);
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
			case opx is
			when "110100" => nextState <= BREAK;
			when "000101" | "001101" => nextState <= JUMP;
			when "010010" | "011010" | "111010" => nextState <= R_OP_IMM;
			when others => nextState <= R_OP;
			end case;
		when "000100" => nextState <= I_OP;
		when "010111" => nextState <= LOAD1;
		when "010101" => nextState <= STORE;
		when "000110" | "001110" | "010110" | "011110" | "100110" | "101110" | "110110"  => nextState <= BRANCH;
		when "000000" => nextState <= CALL;
		when "001100" | "010100" | "011100" => nextState <= I_OP_IMM;
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
	when BRANCH => 
		sel_b <= '1';
		pc_add_imm <= '1';
		branch_op <= '1';
		nextState <= FETCH1;
	when CALL =>
		pc_sel_imm <= '1';
		pc_en <= '1';
		sel_ra <= '1';
		sel_pc <= '1';
		sel_mem <= '1';
		rf_wren <= '1';
		nextState <= FETCH1;
	when JUMP => 
		pc_en <= '1';
		pc_sel_a <= '1';
		nextState <= FETCH1;
	when R_OP_IMM =>
		 sel_rC <= '1';
		rf_wren <= '1';
		nextState <= FETCH1;
	when I_OP_IMM =>
		rf_wren <= '1';
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
	elsif(opx = "010010") then op_alu <= "110010";
	elsif(opx = "011010") then op_alu <= "110011";
	elsif(opx = "111010") then op_alu <= "110111";
	elsif(opx = "110001") then op_alu <= "000000"; --add
	elsif(opx = "111001") then op_alu <= "001000"; --sub
	elsif(opx = "001000") then op_alu <= "011001"; --cmpge
	elsif(opx = "010000") then op_alu <= "011010"; --cmplt
	elsif(opx = "000110") then op_alu <= "100000"; --nor
	elsif(opx = "001110") then op_alu <= "100001"; --and
	elsif(opx = "010110") then op_alu <= "100010"; --or
	elsif(opx = "011110") then op_alu <= "100011"; --xor
	elsif(opx = "010011") then op_alu <= "110010"; --sll
	elsif(opx = "011011") then op_alu <= "110011"; --srl
	elsif(opx = "111011") then op_alu <= "110111"; --sra
	end if;
--BRANCH
elsif(op = "001110") then op_alu <= "011001"; --bge
elsif(op = "010110") then op_alu <= "011010"; --blt
elsif(op = "011110") then op_alu <= "011011"; --bne
elsif(op = "100110") then op_alu <= "011100"; --beq
elsif(op = "101110") then op_alu <= "011101"; --bgeu
elsif(op = "110110") then op_alu <= "011110"; --bltu
--IOP
elsif(op = "000100") then op_alu <= "000000"; --addi
elsif(op = "001100") then op_alu <= "100001"; --andi
elsif(op = "010100") then op_alu <= "100010"; --ori
elsif(op = "011100") then op_alu <= "100011"; --xori
--ROP

--ROPIMM 

	
end if;
end process;
end synth;
