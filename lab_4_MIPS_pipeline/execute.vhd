LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY EXEcute IS
  PORT(	Opcode_ex 				: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0); -- for arithmetic/logic I-format instructions
		RegDst_ex				: IN	STD_LOGIC;
		ALUOp_ex 				: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0);
		ALUSrc_ex 				: IN 	STD_LOGIC;
		PC_plus_4_ex 			: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		Read_data_1_ex			: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		Read_data_2_ex			: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		Sign_extend_ex			: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		write_register_rt_ex	: IN	STD_LOGIC_VECTOR( 4 DOWNTO 0);
		write_register_rd_ex	: IN	STD_LOGIC_VECTOR( 4 DOWNTO 0);
		Zero_ex 				: OUT	STD_LOGIC;
		Overflow_ex				: OUT	STD_LOGIC;
		Add_Result_ex 			: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
		ALU_Result_ex 			: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
		write_data_ex			: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
		write_register_ex		: OUT	STD_LOGIC_VECTOR( 4 DOWNTO 0);
		ForwardA				: IN	STD_LOGIC_VECTOR( 1 DOWNTO 0); -- for FU
		ForwardB				: IN	STD_LOGIC_VECTOR( 1 DOWNTO 0); -- for FU
		ALU_Result_mem 			: IN	STD_LOGIC_VECTOR(31 DOWNTO 0); -- forwarded from MEM
		write_data_wb			: IN	STD_LOGIC_VECTOR(31 DOWNTO 0)  -- forwarded from WB
		);
END EXEcute;

-- TODO: Implement the behavioral description of EXE stage
ARCHITECTURE behavior OF EXEcute IS
	SIGNAL Func_opcode	: STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL ALU_ctl		: STD_LOGIC_VECTOR(3 DOWNTO 0);
-- TODO: you may need to include more signals for easier implementation
	signal alu_input_A,alu_input_B : std_logic_vector(31 downto 0);
	signal alu_out : std_logic_vector(32 downto 0);
	signal fu_data_A, fu_data_B : std_logic_vector(31 downto 0);
BEGIN
-- TODO: add necessary concurrent assignments
	write_register_ex <= write_register_rt_ex when RegDst_ex='0' else write_register_rd_ex;
	--FORWARD UNIT MUX
	alu_input_A <= 	ALU_Result_mem when ForwardA="10" else
					write_data_wb when ForwardA="01" else
					Read_data_1_ex when ForwardA="00" else
					X"00000000";
	fu_data_B <= 	ALU_Result_mem when ForwardB="10" else
					write_data_wb when ForwardB="01" else
					Read_data_2_ex when ForwardB="00" else
					X"00000000";
	alu_input_B <= fu_data_B when ALUSrc_ex='0' else Sign_extend_ex;
	write_data_ex <= fu_data_B;
	Func_opcode <= Sign_extend_ex(5 downto 0);
	ALU_Result_ex <= alu_out(31 downto 0);
	Zero_ex <= '1' when (alu_out(31 downto 0)=X"00000000") else '0';
	PROCESS (Opcode_ex, Func_opcode, ALUOp_ex)
	BEGIN
		-- something is missing here, complete!
		ALU_ctl <= B"0000";
		CASE ALUOp_ex IS
			WHEN "00" => ALU_ctl <= B"0000"; -- lw/sw: ALU performs add (Ainput with Binput, signed)
			WHEN "01" => ALU_ctl <= B"0010"; -- beq  : ALU performs sub (Ainput with Binput, signed)
			WHEN "10" => 
				CASE Func_opcode IS
					WHEN "100000" => ALU_ctl <= B"0000"; -- add  rd,rs,rt
					WHEN "100001" => ALU_ctl <= B"0001"; -- addu rd,rs,rt
					WHEN "100010" => ALU_ctl <= B"0010"; -- sub  rd,rs,rt
					WHEN "100011" => ALU_ctl <= B"0011"; -- subu rd,rs,rt
					WHEN "101010" => ALU_ctl <= B"0100"; -- slt  rd,rs,rt (if rs<rt, then rd <- 1)
					WHEN "101011" => ALU_ctl <= B"0101"; -- sltu rd,rs,rt (if rs<rt, then rd <- 1)
					WHEN "100100" => ALU_ctl <= B"0110"; -- and  rd,rs,rt
					WHEN "100101" => ALU_ctl <= B"0111"; -- or   rd,rs,rt
					WHEN "100110" => ALU_ctl <= B"1001"; -- xor  rd,rs,rt
					WHEN "100111" => ALU_ctl <= B"1010"; -- nor  rd,rs,rt
					WHEN OTHERS => NULL; 
				END CASE;
			WHEN "11" => 
				CASE Opcode_ex IS
					WHEN "001000" => ALU_ctl <= B"0000"; -- addi  rt,rs,const16
					WHEN "001001" => ALU_ctl <= B"1000"; -- addiu rt,rs,const16 (rt <- rs + x0000::const16)
					WHEN "001010" => ALU_ctl <= B"0100"; -- slti  rt,rs,const16 (if rs < signext conts16, then rt <- 1)
					WHEN "001011" => ALU_ctl <= B"1100"; -- sltiu rt,rs,const16 (if rs < x0000::const16,  then rt <- 1)
					WHEN "001100" => ALU_ctl <= B"1110"; -- andi  rt,rs,const16 (rt <- rs and x0000::const16)
					WHEN "001101" => ALU_ctl <= B"1111"; -- ori   rt,rs,const16 (rt <- rs or  x0000::const16)
					WHEN "001110" => ALU_ctl <= B"1101"; -- xori  rt,rs,const16 (rt <- rs xor x0000::const16)
					WHEN OTHERS => NULL;
				END CASE;
			WHEN OTHERS => NULL;
		END CASE;
	END PROCESS;

	-- add a second process to generate the ALU_result_ex and Overflow_ex
	process(ALU_ctl,alu_input_A,alu_input_B,alu_out)
	begin
		alu_out<=(OTHERS => '0');
		Overflow_ex <= '0';
		case ALU_ctl is
			-- TIPO R
			when "0000" => alu_out <= std_logic_vector(signed(alu_input_A(31)&alu_input_A) + signed((alu_input_B(31)&alu_input_B)));
                    if(alu_out(32)/=alu_out(31)) then
                      Overflow_ex <='1';
                    end if;
			when "0001" => alu_out <= '0'&std_logic_vector(unsigned(alu_input_A) + unsigned(alu_input_B));
			when "0010" => alu_out <= std_logic_vector(signed(alu_input_A(31)&alu_input_A) - signed(alu_input_B(31)&alu_input_B));
                    if(alu_out(32) /= alu_out(31)) then
                      Overflow_ex <='1';
                    end if;
			when "0011" => alu_out <= '0'&std_logic_vector(unsigned(alu_input_A) - unsigned(alu_input_B));
			when "0100" => if(signed(alu_input_A)<signed(alu_input_B)) then
                       alu_out <= '0'&X"00000001";
                     else
                       alu_out <= '0'&X"00000000";
                     end if;
			when "0101" => if(unsigned(alu_input_A)<unsigned(alu_input_B)) then
                       alu_out <= '0'&X"00000001";
                     else
                       alu_out <= '0'&X"00000000";
                     end if;
			when "0110" => alu_out <= '0'&(alu_input_A and alu_input_B);
			when "0111" => alu_out <= '0'&(alu_input_A or alu_input_B);
			when "1001" => alu_out <= '0'&(alu_input_A xor alu_input_B);
			when "1010" => alu_out <= '0'&(alu_input_A nor alu_input_B);
			-- TIPO I
			when "1000" => alu_out <= '0'&std_logic_vector((unsigned(alu_input_A) + unsigned(X"0000"&alu_input_B(15 downto 0))));
			when "1100" => if(unsigned(alu_input_A)<unsigned(X"0000"&alu_input_B(15 downto 0))) then
                       alu_out <= '0'&X"00000001";
                     else
                       alu_out <= '0'&X"00000000";
                     end if;
			when "1110" => alu_out <= '0'&(alu_input_A and (X"0000"&alu_input_B(15 downto 0)));
			when "1111" => alu_out <= '0'&(alu_input_A or (X"0000"&alu_input_B(15 downto 0)));
			when "1101" => alu_out <= '0'&(alu_input_A xor (X"0000"&alu_input_B(15 downto 0)));
			WHEN OTHERS => NULL;
		end case;
	end process;
	Add_Result_ex(31 downto 2) <= std_logic_Vector(signed(PC_plus_4_ex(31 downto 2)) + signed(Sign_extend_ex(29 downto 0)));
	Add_Result_ex(1 downto 0) <= "00";
END behavior;
