LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY mem_wb IS
   PORT(RegWrite_mem 		: IN 	STD_LOGIC;
		MemtoReg_mem 		: IN	STD_LOGIC;
		read_data_mem		: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		ALU_Result_mem 		: IN	STD_LOGIC_VECTOR(31 DOWNTO 0);
		write_register_mem	: IN	STD_LOGIC_VECTOR( 4 DOWNTO 0);
		RegWrite_wb 		: OUT 	STD_LOGIC;
		MemtoReg_wb 		: OUT	STD_LOGIC;
		read_data_wb		: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		ALU_Result_wb 		: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
		write_register_wb	: OUT	STD_LOGIC_VECTOR( 4 DOWNTO 0);
		clock				: IN	STD_LOGIC;
		reset				: IN 	STD_LOGIC
	   );
END mem_wb;

ARCHITECTURE behavior OF mem_wb IS

BEGIN           
	PROCESS (clock, reset)
		BEGIN
			IF reset = '1' THEN
				RegWrite_wb 		<= '0';
				MemtoReg_wb 		<= '0';
				read_data_wb		<= X"00000000";
				ALU_Result_wb 		<= X"00000000";
				write_register_wb	<= B"00000";
			ELSIF (clock'event) AND (clock = '1') THEN
				read_data_wb		<= read_data_mem;
				ALU_Result_wb 		<= ALU_Result_mem;
				write_register_wb	<= write_register_mem;
				RegWrite_wb 		<= RegWrite_mem;
				MemtoReg_wb 		<= MemtoReg_mem;
			END IF;
	END PROCESS;
END behavior;
