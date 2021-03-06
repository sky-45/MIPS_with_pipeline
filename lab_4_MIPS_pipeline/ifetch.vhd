LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY IFetch IS
  PORT( PCSrc_if		: IN	STD_LOGIC; -- replaces "Branch AND Zero" (now in MEMory)
		PCwrite			: IN	STD_LOGIC; -- when HDU is used  --siempre 1 normalente
		Jump_if			: IN	STD_LOGIC;
		jump_address_if	: IN	STD_LOGIC_VECTOR(25 DOWNTO 0);
		Add_result_if 	: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		PC_plus_4_if	: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
		PC_out_if 		: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
		Instruction_if 	: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
		clock			: IN	STD_LOGIC;
		clki			: IN	STD_LOGIC;
		reset 			: IN 	STD_LOGIC
		);
END IFetch;

ARCHITECTURE behavior OF Ifetch IS
-- some convenient signals. You may need to add more signals
	SIGNAL PC, PC_plus_4: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Read_Address : STD_LOGIC_VECTOR( 9 DOWNTO 0);
	SIGNAL clock_int	: STD_LOGIC;
	signal pc_next : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal jmp_target : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
	--ROM for Instruction Memory
	inst_memory: altsyncram
	GENERIC MAP (
		operation_mode			=> "ROM",
		width_a					=> 32,
		widthad_a				=> 10,
		numwords_a 				=> 1024,		-- add this to use In-System Memory Content Editor
		outdata_aclr_a 			=> "NONE",		-- add this to use In-System Memory Content Editor
		width_byteena_a 		=> 1,			-- add this to use In-System Memory Content Editor
		clock_enable_input_a 	=> "BYPASS",	-- add this to use In-System Memory Content Editor
		clock_enable_output_a 	=> "BYPASS",	-- add this to use In-System Memory Content Editor
		lpm_type				=> "altsyncram",
		outdata_reg_a			=> "UNREGISTERED",
		init_file				=> "program.mif",
		intended_device_family 	=> "Cyclone II",
		LPM_HINT 				=> "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=inst")
	PORT MAP (
		clock0		=> clock_int,
		address_a 	=> Read_Address, 
		q_a 		=> Instruction_if);

	clock_int		<= clki;
	Read_Address	<= PC(11 downto 2); -- NOTE: address must be word aligned
-- TODO: Specify how to obtain PC+4
	PC_plus_4(1 downto 0) <= "00";
	PC_plus_4(31 downto 2) <= std_logic_vector(unsigned(PC(31 downto 2))+1);
	PC_plus_4_if <= PC_plus_4;
-- TODO: generate jump target for pipeline version
	jmp_target <= "0000"&jump_address_if&"00";
-- TODO: Mux to select Jump Target, Branch Target, or PC + 4
	pc_next <= 	jmp_target when Jump_if='1' else
				PC when PCwrite='0' else
				Add_result_if when PCSrc_if='1' else
				PC_plus_4;
-- TODO: Specify how the PC is updated
	PC_out_if <= PC;
	PROCESS(clock,reset)
		BEGIN
			if(reset='1') then
				PC<=(others => '0');
			elsif(rising_edge(clock)) then
				PC<=pc_next;
			end if;
	END PROCESS;
END behavior;
