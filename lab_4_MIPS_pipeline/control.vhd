
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY control IS
  PORT( Instruction_id 	: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		Jump_id			: OUT 	STD_LOGIC;
		RegWrite_id		: OUT 	STD_LOGIC;
		MemtoReg_id 	: OUT 	STD_LOGIC;
		Branch_id		: OUT 	STD_LOGIC;
		MemRead_id 		: OUT 	STD_LOGIC;
		MemWrite_id		: OUT 	STD_LOGIC;
		RegDst_id		: OUT 	STD_LOGIC;
		ALUop_id 		: OUT 	STD_LOGIC_VECTOR(1 DOWNTO 0);
		ALUSrc_id		: OUT 	STD_LOGIC;
		bubble			: IN	STD_LOGIC; -- to stall the pipeline, = 1 <= stall
		id_flush		: IN	STD_LOGIC);-- to flush instructions
END control;

-- TODO: Implement the behavioral description of control unit
ARCHITECTURE behavior OF control IS

	SIGNAL Opcode : STD_LOGIC_VECTOR(5 DOWNTO 0);
	-- you may need to create some signals to generate the output signals
	signal check_R,check_logic_I,check_lw,check_sw,check_branch,check_jump: std_logic;
	signal clear : std_logic;
BEGIN           

	Opcode			<= Instruction_id (31 DOWNTO 26);
	
	check_R<='1' when Opcode="000000" else '0';
	check_logic_I<='1' when Opcode(5 downto 3)="001" else '0';
	check_lw <= '1' when Opcode="100011" else '0';
	check_sw <= '1'when Opcode="101011" else '0';
	check_branch <= '1'when Opcode="000100" else '0';
	check_jump <= '1' when Opcode="000010" else '0';
	clear <= not(bubble) or id_flush;
	-- TODO: Code to generate control signals using opcode bits
	Jump_id			<= (check_jump) when clear='0' else '0';
	RegWrite_id 	<= (check_R or check_logic_I or check_lw) when clear='0' else '0';
	MemtoReg_id 	<= check_lw when clear='0' else '0';
 	Branch_id		<= check_branch when clear='0' else '0';
  	MemRead_id		<= check_lw when clear='0' else '0';
   	MemWrite_id 	<= check_sw when clear='0' else '0';
  	RegDst_id    	<= check_R when clear='0' else '0';
	ALUOp_id(1) 	<= (check_R or check_logic_I) when clear='0' else '0';
	ALUOp_id(0) 	<= (check_branch or check_logic_I) when clear='0' else '0';
	ALUSrc_id  		<= (check_sw or check_lw or check_logic_I) when clear='0' else '0';
	
END behavior;
