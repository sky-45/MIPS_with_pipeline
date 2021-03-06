LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY HDU IS
  PORT( if_id_read_register_rs	: IN 	STD_LOGIC_VECTOR(4 DOWNTO 0);
		if_id_read_register_rt	: IN 	STD_LOGIC_VECTOR(4 DOWNTO 0);
		write_register_rt_ex	: IN	STD_LOGIC_VECTOR(4 DOWNTO 0);
		MemRead_ex				: IN	STD_LOGIC;
		bubble					: OUT	STD_LOGIC;
		if_id_write				: OUT	STD_LOGIC;
		PCwrite					: OUT	STD_LOGIC
		);
	END HDU;

ARCHITECTURE behav OF HDU IS

-- TODO: you may need to add convenient signals here
	signal temp : std_logic;
BEGIN

-- TODO: generate concurrent assignments for signals and outputs
--	Load-use hazard (according to Patterson & Hennessy's book, 4th edition):
--	if (ID/EX.MemRead and ((ID/EX.RegisterRt = IF/ID.RegisterRs) or (ID/EX.RegisterRt = IF/ID.RegisterRt)))
--		bubble = 1
--	but the equation is not complete, and should avoid a hazard when register 0 is involved
--	the correct equation should be:
--	if (ID/EX.MemRead and (ID/EX.RegisterRt ≠ 0) and ((ID/EX.RegisterRt = IF/ID.RegisterRs) or (ID/EX.RegisterRt = IF/ID.RegisterRt)))
--		bubble = 1
	temp		<= '0' when ( MemRead_ex='1' and write_register_rt_ex/="00000" and (write_register_rt_ex=if_id_read_register_rs or write_register_rt_ex=if_id_read_register_rt)) else '1';
	bubble		<= temp;	--0 HDU detected, 1 normal
	if_id_write	<= temp;	--0 HDU detected, 1 normal
	PCwrite		<= temp;	--0 HDU detected, 1 normal

END behav;
