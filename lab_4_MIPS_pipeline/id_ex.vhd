LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY id_ex IS
   PORT(RegWrite_id 			: IN 	STD_LOGIC;
		MemtoReg_id 			: IN 	STD_LOGIC;
		Branch_id 				: IN 	STD_LOGIC;
		MemRead_id 				: IN 	STD_LOGIC;
		MemWrite_id 			: IN 	STD_LOGIC;
		RegDst_id 				: IN 	STD_LOGIC;
		ALUOp_id 				: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0);
		ALUSrc_id 				: IN 	STD_LOGIC;
		Opcode_id				: IN	STD_LOGIC_VECTOR( 5 DOWNTO 0);
		PC_plus_4_id 			: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		read_data_1_id			: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		read_data_2_id			: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		Sign_extend_id 			: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		write_register_rt_id	: IN	STD_LOGIC_VECTOR( 4 DOWNTO 0);
		write_register_rd_id	: IN	STD_LOGIC_VECTOR( 4 DOWNTO 0);
		read_register_rs_id		: IN	STD_LOGIC_VECTOR( 4 DOWNTO 0); -- for FU
		read_register_rt_id		: IN	STD_LOGIC_VECTOR( 4 DOWNTO 0); -- for FU
		RegWrite_ex 			: OUT 	STD_LOGIC;
		MemtoReg_ex 			: OUT 	STD_LOGIC;
		Branch_ex 				: OUT 	STD_LOGIC;
		MemRead_ex 				: OUT 	STD_LOGIC;
		MemWrite_ex 			: OUT 	STD_LOGIC;
		RegDst_ex 				: OUT 	STD_LOGIC;
		ALUOp_ex 				: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0);
		ALUSrc_ex 				: OUT 	STD_LOGIC;
		Opcode_ex				: OUT	STD_LOGIC_VECTOR( 5 DOWNTO 0);
		PC_plus_4_ex 			: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		read_data_1_ex			: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		read_data_2_ex			: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		Sign_extend_ex 			: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		write_register_rt_ex	: OUT	STD_LOGIC_VECTOR( 4 DOWNTO 0);
		write_register_rd_ex	: OUT	STD_LOGIC_VECTOR( 4 DOWNTO 0);
		read_register_rs_ex		: OUT	STD_LOGIC_VECTOR( 4 DOWNTO 0); -- for FU
		read_register_rt_ex		: OUT	STD_LOGIC_VECTOR( 4 DOWNTO 0); -- for FU
		clock					: IN	STD_LOGIC;
		reset					: IN 	STD_LOGIC
	   );
END id_ex;

ARCHITECTURE behavior OF id_ex IS

BEGIN           
	PROCESS (clock, reset)
		BEGIN
			IF reset = '1' THEN
				RegWrite_ex 			<= '0';
				MemtoReg_ex 			<= '0';
				Branch_ex 				<= '0';
				MemRead_ex 				<= '0';
				MemWrite_ex 			<= '0';
				RegDst_ex 				<= '0';
				ALUOp_ex 				<= B"00";
				ALUSrc_ex 				<= '0';
				Opcode_ex				<= B"000000";
				PC_plus_4_ex 			<= X"00000000";
				read_data_1_ex			<= X"00000000";
				read_data_2_ex			<= X"00000000";
				Sign_extend_ex			<= X"00000000";
				write_register_rt_ex	<= B"00000";
				write_register_rd_ex	<= B"00000";
				read_register_rs_ex		<= B"00000";
				read_register_rt_ex		<= B"00000";
			ELSIF (clock'event) AND (clock = '1') THEN
				ALUOp_ex 				<= ALUOp_id;
				ALUSrc_ex 				<= ALUSrc_id;
				Opcode_ex				<= Opcode_id;
				PC_plus_4_ex 			<= PC_plus_4_id;
				read_data_1_ex			<= read_data_1_id;
				read_data_2_ex			<= read_data_2_id;
				Sign_extend_ex			<= Sign_extend_id;
				write_register_rt_ex	<= write_register_rt_id;
				write_register_rd_ex	<= write_register_rd_id;
				read_register_rs_ex		<= read_register_rs_id;
				read_register_rt_ex		<= read_register_rt_id;
				RegWrite_ex 			<= RegWrite_id;
				MemtoReg_ex 			<= MemtoReg_id;
				Branch_ex 				<= Branch_id;
				MemRead_ex 				<= MemRead_id;
				MemWrite_ex 			<= MemWrite_id;
				RegDst_ex 				<= RegDst_id;
			END IF;
	END PROCESS;
END behavior;


