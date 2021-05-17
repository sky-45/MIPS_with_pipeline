LIBRARY IEEE; 
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY IDecode IS
  PORT(	Instruction_id			: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		RegWrite 				: IN 	STD_LOGIC;
		read_data_1_id			: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		read_data_2_id			: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		Sign_extend_id 			: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		Opcode_id				: OUT	STD_LOGIC_VECTOR( 5 DOWNTO 0);
		write_register_rt_id	: OUT	STD_LOGIC_VECTOR( 4 DOWNTO 0);
		write_register_rd_id	: OUT	STD_LOGIC_VECTOR( 4 DOWNTO 0);
		read_register_rs_id		: OUT	STD_LOGIC_VECTOR( 4 DOWNTO 0); -- for FU
		read_register_rt_id		: OUT	STD_LOGIC_VECTOR( 4 DOWNTO 0); -- for FU
		write_data_id			: IN	STD_LOGIC_VECTOR(31 DOWNTO 0);
		write_register_id		: IN	STD_LOGIC_VECTOR( 4 DOWNTO 0);
		REGSelA					: IN	STD_LOGIC; --to be used with FU
		REGSelB					: IN	STD_LOGIC; --to be used with FU
		clock					: IN	STD_LOGIC;
		reset					: IN 	STD_LOGIC
		);
END IDecode;

ARCHITECTURE behavior OF IDecode IS

	TYPE register_file IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL register_array				: register_file;
	SIGNAL read_register_1_address		: STD_LOGIC_VECTOR( 4 DOWNTO 0);
	SIGNAL read_register_2_address		: STD_LOGIC_VECTOR( 4 DOWNTO 0);
	SIGNAL Instruction_immediate_value	: STD_LOGIC_VECTOR(15 DOWNTO 0);
-- you may need to add some signals if problem found at synthesizing this module
	
BEGIN
	read_register_1_address 	<= Instruction_id(25 DOWNTO 21);
	read_register_2_address 	<= Instruction_id(20 DOWNTO 16);
	Instruction_immediate_value <= Instruction_id(15 DOWNTO  0);
	Opcode_id					<= Instruction_id(31 DOWNTO  26); -- complete
	write_register_rt_id		<= Instruction_id(20 DOWNTO  16); -- complete
	write_register_rd_id		<= Instruction_id(15 DOWNTO  11); -- complete
	read_register_rs_id			<= Instruction_id(25 downto 21); -- complete for FU
	read_register_rt_id			<= Instruction_id(20 downto 16); -- complete for FU
	
	-- TODO: Read Register 1 Operation
	-- in case of WB Hazard, there will be a MUX after the Register File that is controlled by REGSelA. Check file fu.vhd
	read_data_1_id <= register_array(to_integer(unsigned(read_register_1_address))) when REGSelA='0' else
						write_data_id;
	-- TODO: Read Register 2 Operation
	-- in case of WB Hazard, there will be a MUX after the Register File that is controlled by REGSelB. Check file fu.vhd
	read_data_2_id <= register_array(to_integer(unsigned(read_register_2_address))) when REGSelB='0' else
						write_data_id;
	-- TODO: Generate Sign_extend signal
    Sign_extend_id <= X"0000"&Instruction_immediate_value when Instruction_immediate_value(15)='0' else
						X"FFFF"&Instruction_immediate_value ;
-- TODO: Specify the process to update the register file
PROCESS (clock, reset)
	BEGIN
	if(reset='1') then
		register_array <= (OTHERS => (OTHERS => '0'));
	elsif(rising_edge(clock)) then
		if(RegWrite='1' and not(write_register_id="00000")) then
			register_array(to_integer(unsigned(write_register_id)))<=write_data_id;
		end if;
	end if;
	END PROCESS;
END behavior;
