LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY MIPS_pipe IS
  PORT( reset			: IN	STD_LOGIC;
		clk_50MHz		: IN 	STD_LOGIC; 
		PC				: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
     	Instruction_out	: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		read_data_1_out	: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
		read_data_2_out	: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
		ALU_result_out	: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
		read_data_out	: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		Branch_out		: OUT	STD_LOGIC;
		Zero_out		: OUT	STD_LOGIC;
		Overflow_out	: OUT	STD_LOGIC;
		Memwrite_out	: OUT	STD_LOGIC; 
		Regwrite_out	: OUT 	STD_LOGIC);
END MIPS_pipe;

ARCHITECTURE structure OF MIPS_pipe IS

  COMPONENT PLL IS
	PORT(inclk0		: IN  STD_LOGIC;
		 c0			: OUT STD_LOGIC;
		 c1			: OUT STD_LOGIC);
	END COMPONENT;

  COMPONENT IFetch
	PORT(PCSrc_if		: IN	STD_LOGIC; -- replaces "Branch AND Zero" (now in MEMory)
		 PCwrite		: IN	STD_LOGIC; -- when HDU is used
		 Jump_if		: IN	STD_LOGIC;
		 jump_address_if: IN	STD_LOGIC_VECTOR(25 DOWNTO 0);
		 Add_result_if 	: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 PC_plus_4_if	: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 PC_out_if 		: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 Instruction_if : OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 clock			: IN	STD_LOGIC;
		 clki			: IN	STD_LOGIC;
		 reset 			: IN 	STD_LOGIC);
  END COMPONENT; 

  COMPONENT IF_ID IS
	PORT(PC_plus_4_if		: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 Instruction_if		: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 PC_plus_4_id		: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 Instruction_id		: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 if_id_write		: IN	STD_LOGIC; -- when HDU is used
		 if_flush			: IN	STD_LOGIC; -- from Branch logic
		 clock				: IN	STD_LOGIC;
		 reset				: IN 	STD_LOGIC);
  END COMPONENT;
  
  COMPONENT IDecode
	PORT(Instruction_id			: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 RegWrite 				: IN 	STD_LOGIC;
		 read_data_1_id			: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 read_data_2_id			: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 Sign_extend_id 		: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 Opcode_id				: OUT	STD_LOGIC_VECTOR( 5 DOWNTO 0);
		 write_register_rt_id	: OUT	STD_LOGIC_VECTOR( 4 DOWNTO 0);
		 write_register_rd_id	: OUT	STD_LOGIC_VECTOR( 4 DOWNTO 0);
		 read_register_rs_id	: OUT	STD_LOGIC_VECTOR( 4 DOWNTO 0); -- for FU
		 read_register_rt_id	: OUT	STD_LOGIC_VECTOR( 4 DOWNTO 0); -- for FU
		 write_data_id			: IN	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 write_register_id		: IN	STD_LOGIC_VECTOR( 4 DOWNTO 0);
		 REGSelA				: IN	STD_LOGIC; --to be used with FU
		 REGSelB				: IN	STD_LOGIC; --to be used with FU
		 clock					: IN	STD_LOGIC;
		 reset					: IN 	STD_LOGIC);
  END COMPONENT;

  COMPONENT ID_EX IS
	PORT(RegWrite_id 			: IN 	STD_LOGIC;
		 MemtoReg_id 			: IN 	STD_LOGIC;
		 Branch_id 				: IN 	STD_LOGIC;
		 MemRead_id 			: IN 	STD_LOGIC;
		 MemWrite_id 			: IN 	STD_LOGIC;
		 RegDst_id 				: IN 	STD_LOGIC;
		 ALUOp_id 				: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0);
		 ALUSrc_id 				: IN 	STD_LOGIC;
		 Opcode_id				: IN	STD_LOGIC_VECTOR( 5 DOWNTO 0);
		 PC_plus_4_id 			: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 read_data_1_id			: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 read_data_2_id			: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 Sign_extend_id 		: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 write_register_rt_id	: IN	STD_LOGIC_VECTOR( 4 DOWNTO 0);
		 write_register_rd_id	: IN	STD_LOGIC_VECTOR( 4 DOWNTO 0);
		 read_register_rs_id	: IN	STD_LOGIC_VECTOR( 4 DOWNTO 0); -- for FU
		 read_register_rt_id	: IN	STD_LOGIC_VECTOR( 4 DOWNTO 0); -- for FU
		 RegWrite_ex 			: OUT 	STD_LOGIC;
		 MemtoReg_ex 			: OUT 	STD_LOGIC;
		 Branch_ex 				: OUT 	STD_LOGIC;
		 MemRead_ex 			: OUT 	STD_LOGIC;
		 MemWrite_ex 			: OUT 	STD_LOGIC;
		 RegDst_ex 				: OUT 	STD_LOGIC;
		 ALUOp_ex 				: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0);
		 ALUSrc_ex 				: OUT 	STD_LOGIC;
		 Opcode_ex				: OUT	STD_LOGIC_VECTOR( 5 DOWNTO 0);
		 PC_plus_4_ex 			: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 read_data_1_ex			: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 read_data_2_ex			: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 Sign_extend_ex 		: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 write_register_rt_ex	: OUT	STD_LOGIC_VECTOR( 4 DOWNTO 0);
		 write_register_rd_ex	: OUT	STD_LOGIC_VECTOR( 4 DOWNTO 0);
		 read_register_rs_ex	: OUT	STD_LOGIC_VECTOR( 4 DOWNTO 0); -- for FU
		 read_register_rt_ex	: OUT	STD_LOGIC_VECTOR( 4 DOWNTO 0); -- for FU
		 clock					: IN	STD_LOGIC;
		 reset					: IN 	STD_LOGIC);
  END COMPONENT;

  COMPONENT control
	PORT(Instruction_id : IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 Jump_id		: OUT 	STD_LOGIC;
		 RegWrite_id	: OUT 	STD_LOGIC;
		 MemtoReg_id 	: OUT 	STD_LOGIC;
		 Branch_id		: OUT 	STD_LOGIC;
		 MemRead_id 	: OUT 	STD_LOGIC;
		 MemWrite_id	: OUT 	STD_LOGIC;
		 RegDst_id		: OUT 	STD_LOGIC;
		 ALUop_id 		: OUT 	STD_LOGIC_VECTOR(1 DOWNTO 0);
		 ALUSrc_id		: OUT 	STD_LOGIC;
		 bubble			: IN	STD_LOGIC; -- to stall the pipeline
		 id_flush		: IN	STD_LOGIC);-- to flush instructions
  END COMPONENT;

  COMPONENT EXEcute
	PORT(Opcode_ex 				: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0); -- for arithmetic/logic I-format instructions
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
		 Overflow_ex			: OUT	STD_LOGIC;
		 Add_Result_ex 			: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ALU_Result_ex 			: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 write_data_ex			: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 write_register_ex		: OUT	STD_LOGIC_VECTOR( 4 DOWNTO 0);
		 ForwardA				: IN	STD_LOGIC_VECTOR( 1 DOWNTO 0); -- for FU
		 ForwardB				: IN	STD_LOGIC_VECTOR( 1 DOWNTO 0); -- for FU
		 ALU_Result_mem 		: IN	STD_LOGIC_VECTOR(31 DOWNTO 0); -- forwarded from MEM
		 write_data_wb			: IN	STD_LOGIC_VECTOR(31 DOWNTO 0));-- forwarded from WB
  END COMPONENT;

  COMPONENT EX_MEM
	PORT(RegWrite_ex 			: IN 	STD_LOGIC;
		 MemtoReg_ex 			: IN 	STD_LOGIC;
		 Branch_ex 				: IN 	STD_LOGIC;
		 MemRead_ex 			: IN 	STD_LOGIC;
		 MemWrite_ex 			: IN 	STD_LOGIC;
		 Add_Result_ex 			: IN	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 Zero_ex				: IN	STD_LOGIC;
		 ALU_Result_ex 			: IN	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 write_data_ex			: IN	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 write_register_ex		: IN	STD_LOGIC_VECTOR( 4 DOWNTO 0);
		 RegWrite_mem 			: OUT 	STD_LOGIC;
		 MemtoReg_mem 			: OUT	STD_LOGIC;
		 Branch_mem 			: OUT 	STD_LOGIC;
		 MemRead_mem 			: OUT 	STD_LOGIC;
		 MemWrite_mem 			: OUT 	STD_LOGIC;
		 Add_Result_mem 		: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 Zero_mem				: OUT	STD_LOGIC;
		 ALU_Result_mem 		: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 write_data_mem			: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 write_register_mem		: OUT	STD_LOGIC_VECTOR( 4 DOWNTO 0);
		 clock					: IN	STD_LOGIC;
		 reset					: IN 	STD_LOGIC);
  END COMPONENT;

  COMPONENT MEMory
	PORT(Branch_mem		: IN	STD_LOGIC;
		 Zero_mem		: IN	STD_LOGIC;
		 MemRead_mem	: IN	STD_LOGIC;
		 Memwrite_mem	: IN 	STD_LOGIC;
		 ALU_Result_mem	: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 write_data_mem	: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 PCSrc_mem		: OUT	STD_LOGIC;
		 branch_flush	: OUT	STD_LOGIC;
		 read_data_mem	: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 clkd			: IN	STD_LOGIC);
  END COMPONENT;

  COMPONENT MEM_WB
	PORT(RegWrite_mem 			: IN 	STD_LOGIC;
		 MemtoReg_mem 			: IN	STD_LOGIC;
		 read_data_mem			: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ALU_Result_mem 		: IN	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 write_register_mem		: IN	STD_LOGIC_VECTOR( 4 DOWNTO 0);
		 RegWrite_wb 			: OUT 	STD_LOGIC;
		 MemtoReg_wb 			: OUT	STD_LOGIC;
		 read_data_wb			: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ALU_Result_wb 			: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 write_register_wb		: OUT	STD_LOGIC_VECTOR( 4 DOWNTO 0);
		 clock					: IN	STD_LOGIC;
		 reset					: IN 	STD_LOGIC);
  END COMPONENT;

  COMPONENT WriteBack
	PORT(read_data_wb	: IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ALU_result_wb	: IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		 MemtoReg_wb	: IN  STD_LOGIC;
		 write_data_wb	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
  END COMPONENT;

  COMPONENT FU
	PORT(read_register_rs_ex	: IN	STD_LOGIC_VECTOR(4 DOWNTO 0);
		 read_register_rt_ex	: IN	STD_LOGIC_VECTOR(4 DOWNTO 0);
		 write_register_mem		: IN	STD_LOGIC_VECTOR(4 DOWNTO 0);
		 write_register_wb		: IN	STD_LOGIC_VECTOR(4 DOWNTO 0);
		 RegWrite_mem 			: IN 	STD_LOGIC;
		 RegWrite_wb 			: IN 	STD_LOGIC;
		 ForwardA				: OUT	STD_LOGIC_VECTOR(1 DOWNTO 0);
		 ForwardB				: OUT	STD_LOGIC_VECTOR(1 DOWNTO 0);
		 RegWrite_ex			: IN	STD_LOGIC; -- to solve WB hazard
		 write_register_ex		: IN	STD_LOGIC_VECTOR(4 DOWNTO 0); -- to solve WB hazard
		 read_register_rs_id	: IN	STD_LOGIC_VECTOR(4 DOWNTO 0); -- to solve WB hazard
		 read_register_rt_id	: IN	STD_LOGIC_VECTOR(4 DOWNTO 0); -- to solve WB hazard
		 REGSelA				: OUT	STD_LOGIC;  -- to solve WB hazard
		 REGSelB				: OUT	STD_LOGIC); -- to solve WB hazard
  END COMPONENT;
--  
  COMPONENT HDU
	PORT(if_id_read_register_rs	: IN 	STD_LOGIC_VECTOR(4 DOWNTO 0);
		 if_id_read_register_rt	: IN 	STD_LOGIC_VECTOR(4 DOWNTO 0);
		 write_register_rt_ex	: IN	STD_LOGIC_VECTOR(4 DOWNTO 0);
		 MemRead_ex				: IN	STD_LOGIC;
		 bubble					: OUT	STD_LOGIC;
		 if_id_write			: OUT	STD_LOGIC;
		 PCwrite				: OUT	STD_LOGIC);
  END COMPONENT;
  
-- TODO: declare signals used to connect VHDL components
-- signals for IF  stage
	SIGNAL Instruction_if		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Add_result_mem		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL PC_plus_4_if			: STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal PC_out_if 			: STD_LOGIC_VECTOR(31 DOWNTO 0); -- ...
-- signals for ID  stage
	SIGNAL PC_plus_4_id			: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Instruction_id		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL read_data_1_id 		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL read_data_2_id 		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Sign_Extend_id		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Opcode_id			: STD_LOGIC_VECTOR( 5 DOWNTO 0);
	SIGNAL write_register_rt_id	: STD_LOGIC_VECTOR( 4 DOWNTO 0);
	SIGNAL write_register_rd_id	: STD_LOGIC_VECTOR( 4 DOWNTO 0);
	SIGNAL read_register_rs_id	: STD_LOGIC_VECTOR( 4 DOWNTO 0);
	SIGNAL read_register_rt_id	: STD_LOGIC_VECTOR( 4 DOWNTO 0);
	SIGNAL RegWrite_id 			: STD_LOGIC;
	SIGNAL MemtoReg_id 			: STD_LOGIC;
	SIGNAL Branch_id 			: STD_LOGIC;
	SIGNAL MemRead_id 			: STD_LOGIC;
	SIGNAL MemWrite_id 			: STD_LOGIC;
	SIGNAL RegDst_id 			: STD_LOGIC;
	SIGNAL ALUop_id 			: STD_LOGIC_VECTOR( 1 DOWNTO 0);
	SIGNAL ALUSrc_id 			: STD_LOGIC;
	SIGNAL REGSelA_id			: STD_LOGIC;
	SIGNAL REGSelB_id			: STD_LOGIC;
-- signals for EXE stage
	SIGNAL RegWrite_ex 			: STD_LOGIC;
	SIGNAL MemtoReg_ex 			: STD_LOGIC;
	SIGNAL Branch_ex 			: STD_LOGIC;
	SIGNAL MemRead_ex 			: STD_LOGIC;
	SIGNAL MemWrite_ex 			: STD_LOGIC;
	SIGNAL RegDst_ex			: STD_LOGIC;
	SIGNAL ALUOp_ex 			: STD_LOGIC_VECTOR( 1 DOWNTO 0);
	SIGNAL ALUSrc_ex			: STD_LOGIC;
	SIGNAL Opcode_ex			: STD_LOGIC_VECTOR( 5 DOWNTO 0);
	SIGNAL PC_plus_4_ex			: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL read_data_1_ex 		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL read_data_2_ex 		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Sign_Extend_ex		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL write_register_rt_ex	: STD_LOGIC_VECTOR( 4 DOWNTO 0);
	SIGNAL write_register_rd_ex	: STD_LOGIC_VECTOR( 4 DOWNTO 0);
	SIGNAL Zero_ex				: STD_LOGIC;
	SIGNAL Add_result_ex		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_result_ex		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL write_data_ex		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL write_register_ex	: STD_LOGIC_VECTOR( 4 DOWNTO 0);
	SIGNAL ForwardA_ex			: STD_LOGIC_VECTOR( 1 DOWNTO 0);
	SIGNAL ForwardB_ex			: STD_LOGIC_VECTOR( 1 DOWNTO 0);
	SIGNAL read_register_rs_ex	: STD_LOGIC_VECTOR( 4 DOWNTO 0);
	SIGNAL read_register_rt_ex	: STD_LOGIC_VECTOR( 4 DOWNTO 0);
-- signals for MEM stage
	SIGNAL RegWrite_mem			: STD_LOGIC;
	SIGNAL MemtoReg_mem			: STD_LOGIC;
	SIGNAL PCsrc_mem			: STD_LOGIC;
	SIGNAL Branch_mem			: STD_LOGIC;
	SIGNAL MemRead_mem			: STD_LOGIC;
	SIGNAL MemWrite_mem			: STD_LOGIC;
	SIGNAL Zero_mem				: STD_LOGIC;
	SIGNAL ALU_result_mem		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL write_data_mem		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL read_data_mem		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL write_register_mem	: STD_LOGIC_VECTOR( 4 DOWNTO 0);
-- signals for WB  stage
	SIGNAL Regwrite_wb 			: STD_LOGIC;
	SIGNAL MemtoReg_wb 			: STD_LOGIC;
	SIGNAL read_data_wb			: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_result_wb		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL write_register_wb	: STD_LOGIC_VECTOR( 4 DOWNTO 0);
	SIGNAL write_data_wb		: STD_LOGIC_VECTOR(31 DOWNTO 0);
-- signals for Control
	SIGNAL bubble				: STD_LOGIC;
	SIGNAL Jump_id				: STD_LOGIC;
	SIGNAL branch_flush			: STD_LOGIC;
	SIGNAL if_id_write			: STD_LOGIC;
	SIGNAL PCwrite				: STD_LOGIC;
-- signals for clocks
	SIGNAL clock				: STD_LOGIC;
	SIGNAL clkram				: STD_LOGIC;
-- signas for FU
	
BEGIN
	-- TODO: copy important signals to output pins 
	PC				<= PC_out_if;
    Instruction_out	<= Instruction_id;
	read_data_1_out	<= read_data_1_id;
	read_data_2_out	<= read_data_2_id;
	ALU_result_out	<= ALU_result_ex;
	read_data_out	<= read_data_mem;
	Branch_out		<= Branch_mem;
	Zero_out		<= Zero_mem;
	--Overflow_out	<=
	Memwrite_out	<= MemWrite_mem;
	Regwrite_out	<= RegWrite_wb;
	-- TODO: connect the MIPS components  
	CLOCKS: PLL
	PORT MAP(
		inclk0 	=> clk_50MHz,
		c0 		=> clock,
		c1 		=> clkram
			);
	
	IFE: IFetch
	PORT MAP(
		PCSrc_if		=> PCsrc_mem,
		PCwrite			=> PCwrite,
		Jump_if			=> Jump_id,
		jump_address_if	=> Instruction_id(25 DOWNTO 0),
		Add_result_if 	=> Add_result_mem,
		PC_plus_4_if	=> PC_plus_4_if,
		PC_out_if 		=> PC_out_if,
		Instruction_if	=> Instruction_if,
		clock			=> clock,
		clki			=> clkram,
		reset			=> reset
			);

	IFID: IF_ID
	PORT MAP(
		PC_plus_4_if		=> PC_plus_4_if,
		Instruction_if		=> Instruction_if,
		PC_plus_4_id		=> PC_plus_4_id,
		Instruction_id		=> Instruction_id,
		if_id_write			=> if_id_write,
		if_flush			=> branch_flush,
		clock				=> clock,
		reset				=> reset
			);

	ID: IDecode
   	PORT MAP(
		Instruction_id			=> Instruction_id,
		RegWrite 				=> Regwrite_wb,
		read_data_1_id			=> read_data_1_id,
		read_data_2_id			=> read_data_2_id,
		Sign_extend_id 			=> Sign_Extend_id,
		Opcode_id				=> Opcode_id,
		write_register_rt_id	=> write_register_rt_id,
		write_register_rd_id	=> write_register_rd_id,
		read_register_rs_id		=> read_register_rs_id,
		read_register_rt_id		=> read_register_rt_id,
		write_data_id			=> write_data_wb,
		write_register_id		=> write_register_wb,
		REGSelA					=> REGSelA_id,
		REGSelB					=> REGSelB_id,
		clock					=> clock,
		reset					=> reset
			);

	IDEX: ID_EX
	PORT MAP(
		RegWrite_id 			=> RegWrite_id,
		MemtoReg_id 			=> MemtoReg_id,
		Branch_id 				=> Branch_id,
		MemRead_id 				=> MemRead_id,
		MemWrite_id 			=> MemWrite_id,
		RegDst_id 				=> RegDst_id,
		ALUOp_id 				=> ALUop_id,
		ALUSrc_id 				=> ALUSrc_id,
		Opcode_id				=> Opcode_id,
		PC_plus_4_id 			=> PC_plus_4_id,
		read_data_1_id			=> read_data_1_id,
		read_data_2_id			=> read_data_2_id,
		Sign_extend_id 			=> Sign_Extend_id,
		write_register_rt_id	=> write_register_rt_id,
		write_register_rd_id	=> write_register_rd_id,
		read_register_rs_id		=> read_register_rs_id,
		read_register_rt_id		=> read_register_rt_id,
		RegWrite_ex 			=> RegWrite_ex,
		MemtoReg_ex 			=> MemtoReg_ex,
		Branch_ex 				=> Branch_ex,
		MemRead_ex 				=> MemRead_ex,
		MemWrite_ex 			=> MemWrite_ex,
		RegDst_ex 				=> RegDst_ex,
		ALUOp_ex 				=> ALUOp_ex,
		ALUSrc_ex 				=> ALUSrc_ex,
		Opcode_ex				=> Opcode_ex,
		PC_plus_4_ex 			=> PC_plus_4_ex,
		read_data_1_ex			=> read_data_1_ex,
		read_data_2_ex			=> read_data_2_ex,
		Sign_extend_ex 			=> Sign_Extend_ex,
		write_register_rt_ex	=> write_register_rt_ex,
		write_register_rd_ex	=> write_register_rd_ex,
		read_register_rs_ex		=> read_register_rs_ex,
		read_register_rt_ex		=> read_register_rt_ex,
		clock					=> clock,
		reset					=> reset
			);

	CTL: control
	PORT MAP(
		Instruction_id	=> Instruction_id,
		Jump_id			=> Jump_id,
		RegWrite_id		=> RegWrite_id,
		MemtoReg_id 	=> MemtoReg_id,
		Branch_id		=> Branch_id,
		MemRead_id 		=> MemRead_id,
		MemWrite_id		=> MemWrite_id,
		RegDst_id		=> RegDst_id,
		ALUop_id 		=> ALUop_id,
		ALUSrc_id		=> ALUSrc_id,
		bubble			=> bubble,
		id_flush		=> branch_flush
			);

	EXE: EXEcute
   	PORT MAP(
		Opcode_ex 				=> Opcode_ex,
		RegDst_ex				=> RegDst_ex,
		ALUOp_ex 				=> ALUOp_ex,
		ALUSrc_ex 				=> ALUSrc_ex,
		PC_plus_4_ex 			=> PC_plus_4_ex,
		Read_data_1_ex			=> read_data_1_ex,
		Read_data_2_ex			=> read_data_2_ex,
		Sign_extend_ex			=> Sign_Extend_ex,
		write_register_rt_ex	=> write_register_rt_ex,
		write_register_rd_ex	=> write_register_rd_ex,
		Zero_ex 				=> Zero_ex,
		Overflow_ex				=> Overflow_out,
		Add_Result_ex 			=> Add_result_ex,
		ALU_Result_ex 			=> ALU_result_ex,
		write_data_ex			=> write_data_ex,
		write_register_ex		=> write_register_ex,
		ForwardA				=> ForwardA_ex,
		ForwardB				=> ForwardB_ex,
		ALU_Result_mem 			=> ALU_result_mem,
		write_data_wb			=> write_data_wb
			);

	EXMEM: EX_MEM
	PORT MAP(
		RegWrite_ex 			=> RegWrite_ex,
		MemtoReg_ex 			=> MemtoReg_ex,
		Branch_ex 				=> Branch_ex,
		MemRead_ex 				=> MemRead_ex,
		MemWrite_ex 			=> MemWrite_ex,
		Add_Result_ex 			=> Add_result_ex,
		Zero_ex					=> Zero_ex,
		ALU_Result_ex 			=> ALU_result_ex,
		write_data_ex			=> write_data_ex,
		write_register_ex		=> write_register_ex,
		RegWrite_mem 			=> RegWrite_mem,
		MemtoReg_mem 			=> MemtoReg_mem,
		Branch_mem 				=> Branch_mem,
		MemRead_mem 			=> MemRead_mem,
		MemWrite_mem 			=> MemWrite_mem,
		Add_Result_mem 			=> Add_result_mem,
		Zero_mem				=> Zero_mem,
		ALU_Result_mem 			=> ALU_result_mem,
		write_data_mem			=> write_data_mem,
		write_register_mem		=> write_register_mem,
		clock					=> clock,
		reset					=> reset
			);

	MEM: MEMory
	PORT MAP(
		Branch_mem		=> Branch_mem,
		Zero_mem		=> Zero_mem,
		MemRead_mem		=> MemRead_mem,
		Memwrite_mem	=> MemWrite_mem,
		ALU_Result_mem	=> ALU_result_mem,
		write_data_mem	=> write_data_mem,
		PCSrc_mem		=> PCsrc_mem,
		branch_flush	=> branch_flush,
		read_data_mem	=> read_data_mem,
		clkd			=> clkram
			);

	MEMWB: MEM_WB
	PORT MAP(
		RegWrite_mem 		=> RegWrite_mem,
		MemtoReg_mem 		=> MemtoReg_mem,
		read_data_mem		=> read_data_mem,
		ALU_Result_mem 		=> ALU_result_mem,
		write_register_mem	=> write_register_mem,
		RegWrite_wb 		=> Regwrite_wb,
		MemtoReg_wb 		=> MemtoReg_wb,
		read_data_wb		=> read_data_wb,
		ALU_Result_wb 		=> ALU_result_wb,
		write_register_wb	=> write_register_wb,
		clock				=> clock,
		reset				=> reset
			);

	WB: Writeback
	PORT MAP(
		read_data_wb	=> read_data_wb,
		ALU_result_wb	=> ALU_result_wb,
		MemtoReg_wb		=> MemtoReg_wb,
		write_data_wb	=> write_data_wb
			);

	FWD: FU
	PORT MAP(
		read_register_rs_ex		=> read_register_rs_ex,
		read_register_rt_ex		=> read_register_rt_ex,
		write_register_mem		=> write_register_mem,
		write_register_wb		=> write_register_wb,
		RegWrite_mem 			=> RegWrite_mem,
		RegWrite_wb 			=> Regwrite_wb,
		ForwardA				=> ForwardA_ex,
		ForwardB				=> ForwardB_ex,
		RegWrite_ex				=> RegWrite_ex,
		write_register_ex		=> write_register_ex,
		read_register_rs_id		=> read_register_rs_id,
		read_register_rt_id		=> read_register_rt_id,
		REGSelA					=> REGSelA_id,
		REGSelB					=> REGSelB_id
			);

	HAZ: HDU
	PORT MAP(
		if_id_read_register_rs	=> Instruction_id(25 downto 21),
		if_id_read_register_rt	=> Instruction_id(20 downto 16),
		write_register_rt_ex	=> write_register_rt_ex,
		MemRead_ex				=> MemRead_ex,
		bubble					=> bubble,
		if_id_write				=> if_id_write,
		PCwrite					=> PCwrite
			);
			
END structure;
