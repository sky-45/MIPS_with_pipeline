LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY MEMory IS
  PORT(	Branch_mem		: IN	STD_LOGIC;
		Zero_mem		: IN	STD_LOGIC;
		MemRead_mem		: IN	STD_LOGIC;
		Memwrite_mem	: IN 	STD_LOGIC;
		ALU_Result_mem	: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		write_data_mem	: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		PCSrc_mem		: OUT	STD_LOGIC;
		branch_flush	: OUT	STD_LOGIC;
		read_data_mem	: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		clkd			: IN	STD_LOGIC
		);
END MEMory;

ARCHITECTURE behavior OF MEMory IS
	
	SIGNAL write_clock 	: STD_LOGIC;

BEGIN
	data_memory : altsyncram
	GENERIC MAP (
		operation_mode			=> "SINGLE_PORT",
		width_a 				=> 32,
		widthad_a 				=> 10,
		numwords_a 				=> 1024,		-- add this to use In-System Memory Content Editor
		outdata_aclr_a 			=> "NONE",		-- add this to use In-System Memory Content Editor
		width_byteena_a 		=> 1,			-- add this to use In-System Memory Content Editor
		clock_enable_input_a 	=> "BYPASS",	-- add this to use In-System Memory Content Editor
		clock_enable_output_a 	=> "BYPASS",	-- add this to use In-System Memory Content Editor
		power_up_uninitialized 	=> "FALSE",		-- add this to use In-System Memory Content Editor
		lpm_type 				=> "altsyncram",
		outdata_reg_a 			=> "UNREGISTERED",
		init_file 				=> "dmemory.mif",
		intended_device_family	=> "Cyclone II",
		LPM_HINT 				=> "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=data")
	PORT MAP (
		wren_a 		=> Memwrite_mem,
		clock0 		=> write_clock,
		address_a 	=> ALU_Result_mem(11 DOWNTO 2), -- NOTE: must be word aligned address
		data_a 		=> write_data_mem,
		q_a 		=> read_data_mem);
	-- Load memory address register with write clock
	write_clock		<= clkd;
	PCSrc_mem		<= Branch_mem and Zero_mem; -- only for beq
	branch_flush	<= Branch_mem and Zero_mem; -- only for beq
END behavior;

