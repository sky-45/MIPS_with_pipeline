LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY if_id IS
	PORT(PC_plus_4_if		: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 Instruction_if		: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 PC_plus_4_id		: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 Instruction_id		: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		 if_id_write		: IN	STD_LOGIC; -- when HDU is used
		 if_flush			: IN	STD_LOGIC; -- from Branch logic
		 clock				: IN	STD_LOGIC;
		 reset				: IN 	STD_LOGIC
		);
END if_id;

-- TODO: Implement the behavioral description of IF/ID register
ARCHITECTURE behavior OF if_id IS
	
BEGIN
	PROCESS (clock, reset)
		BEGIN
			IF (reset='1') THEN
				-- complete
				Instruction_id <= X"00000000"; 
				PC_plus_4_id <= X"00000000";
			ELSIF rising_edge(clock) THEN
				-- complete
				if(if_flush='1') then
					Instruction_id <= X"00000000"; 
					PC_plus_4_id <= X"00000000";
				elsif(if_id_write='1') then
					Instruction_id <= Instruction_if;
					PC_plus_4_id <= PC_plus_4_if;
				end if;
			END IF;
	END PROCESS;
END behavior;
