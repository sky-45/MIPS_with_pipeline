LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY FU IS
  PORT( read_register_rs_ex	: IN	STD_LOGIC_VECTOR(4 DOWNTO 0);
		read_register_rt_ex	: IN	STD_LOGIC_VECTOR(4 DOWNTO 0);
		write_register_mem	: IN	STD_LOGIC_VECTOR(4 DOWNTO 0);
		write_register_wb	: IN	STD_LOGIC_VECTOR(4 DOWNTO 0);
		RegWrite_mem 		: IN 	STD_LOGIC;
		RegWrite_wb 		: IN 	STD_LOGIC;
		ForwardA			: OUT	STD_LOGIC_VECTOR(1 DOWNTO 0);
		ForwardB			: OUT	STD_LOGIC_VECTOR(1 DOWNTO 0);
		RegWrite_ex			: IN	STD_LOGIC; -- to solve WB hazard
		write_register_ex	: IN	STD_LOGIC_VECTOR(4 DOWNTO 0); -- to solve WB hazard
		read_register_rs_id	: IN	STD_LOGIC_VECTOR(4 DOWNTO 0); -- to solve WB hazard
		read_register_rt_id	: IN	STD_LOGIC_VECTOR(4 DOWNTO 0); -- to solve WB hazard
		REGSelA				: OUT	STD_LOGIC; -- to solve WB hazard
		REGSelB				: OUT	STD_LOGIC  -- to solve WB hazard
		);
	END FU;

ARCHITECTURE behav OF FU IS

-- TODO: you may need to add convenient signals here
BEGIN

-- TODO: use concurrent assignments for signals and outputs
--  Equations from Patterson & Hennessy's Book, 4th edition
--	EX hazard:
--	if (EX/MEM.RegWrite and (EX/MEM.RegisterRd ≠ 0) and (EX/MEM.RegisterRd = ID/EX.RegisterRs))
--		ForwardA = 10
--	if (EX/MEM.RegWrite and (EX/MEM.RegisterRd ≠ 0) and (EX/MEM.RegisterRd = ID/EX.RegisterRt))
--		ForwardB = 10
--
--	MEM hazard:
--	if (MEM/WB.RegWrite and (MEM/WB.RegisterRd ≠ 0) 
--		and not (EX/MEM.RegWrite and (EX/MEM.RegisterRd ≠ 0) and (EX/MEM.RegisterRd = ID/EX.RegisterRs)) 
--		and (MEM/WB.RegisterRd = ID/EX.RegisterRs))
--			ForwardA = 01
--	if (MEM/WB.RegWrite and (MEM/WB.RegisterRd ≠ 0) 
--		and not (EX/MEM.RegWrite and (EX/MEM.RegisterRd ≠ 0) and (EX/MEM.RegisterRd = ID/EX.RegisterRt)) 
--		and (MEM/WB.RegisterRd = ID/EX.RegisterRt))
--			ForwardB = 01
	ForwardA	<= 	"10" when ( RegWrite_mem='1' and (write_register_mem/="00000") and (write_register_mem=read_register_rs_ex)) else
					"01" when ( RegWrite_wb='1' and (write_register_wb/="00000") 
						--and not( (RegWrite_mem='1' and write_register_mem/="00000") and (write_register_mem=read_register_rs_ex))
						and (write_register_wb=read_register_rs_ex)) else
					"00"; --corregidoooo
	ForwardB	<= 	"10" when ( RegWrite_mem='1' and (write_register_mem/="00000") and (write_register_mem=read_register_rt_ex)) else
					"01" when ( RegWrite_wb='1' and (write_register_wb/="00000")
						--and not( (RegWrite_mem='1' and write_register_mem/="00000") and (write_register_mem=read_register_rt_ex)) --
						and (write_register_wb=read_register_rt_ex)) else
					"00"; --corregidoooo

-- According to Patterson & Hennessy's Book there is no WB hazard because it is
-- assumed that on the same clock cycle the Register File is updated and read with 
-- the correct data on the ID stage. If the Register File and all flip-flops are edge
-- triggered, there will be a hazard if a register is read on the ID stage and at the 
-- same time is written back on WB stage. 
-- You need to modify the ID stage to deliver the forwarded value from WB into ID/EX
--  WB hazards:
--  if (MEM/WB.RegWrite and (MEM/WB.RegisterRd ≠ 0) and (MEM/WB.RegisterRd = IF/ID.RegisterRs))
--		then REGSelA = 1
--  if (MEM/WB.RegWrite and (MEM/WB.RegisterRd ≠ 0) and (MEM/WB.RegisterRd = IF/ID.RegisterRt))
--		then REGSelB = 1
--
-- but you are not considering double or triple data hazards that may occur while WB hazard
-- example A:				example B:
-- WB 	add $1, $2, $3		WB	add $1, $2, $3
-- MEM	sub $8, $9, $10		MEM	sub $8, $9, $10
-- EXE	and $4, $6, $7		EXE and $1, $6, $7
-- ID	or  $5, $1, $4		ID	or  $5, $1, $1 
-- example A: we forward $1 from WB, and $4 from AND is forwarded in the next clock
-- example B: double data hazard. We do not forward $1 from WB, instead $1 from AND is forwarded in the next clock
-- example C:				example D:
-- WB 	add $1, $2, $3		WB	add $1, $2, $3
-- MEM	sub $4, $9, $10		MEM	sub $1, $9, $10
-- EXE	and $8, $6, $7		EXE and $8, $6, $7
-- ID	or  $5, $1, $4		ID	or  $5, $1, $1
-- example C: we forward $1 from WB, and $4 from SUB is forwarded in the next clock
-- example D: double data hazard. We do not forward $1 from WB, instead $1 from SUB is forwarded in the next clock
-- example E:
-- WB	add $1, $2, $3
-- MEM	sub $1, $9, $10
-- EXE	and $1, $6, $7
-- ID	or  $5, $1, $1
-- example E: triple data hazard. Hazard between ID and EXE is resolved in the next clock.
-- hazard between ID and MEM is resolved in the next clock. We do not forward $1 in WB to ID
-- Then, the complete equations for WB hazard would be:
--  WB hazards:
--  if (MEM/WB.RegWrite and (MEM/WB.RegisterRd ≠ 0) and (MEM/WB.RegisterRd = IF/ID.RegisterRs))
--		and not {[EX/MEM.RegWrite and (EX/MEM.RegisterRd ≠ 0) and (EX/MEM.RegisterRd = IF/ID.RegisterRs)] or
--				 [ID/EXE.RegWrite and (ID/EXE.RegisterRd ≠ 0) and (ID/EXE.RegisterRd = IF/ID.RegisterRs)]}
--		then REGSelA = 1
--  if (MEM/WB.RegWrite and (MEM/WB.RegisterRd ≠ 0) and (MEM/WB.RegisterRd = IF/ID.RegisterRt))
--		and not {[EX/MEM.RegWrite and (EX/MEM.RegisterRd ≠ 0) and (EX/MEM.RegisterRd = IF/ID.RegisterRt)] or
--				 [ID/EXE.RegWrite and (ID/EXE.RegisterRd ≠ 0) and (ID/EXE.RegisterRd = IF/ID.RegisterRt)]}
--		then REGSelB = 1
	REGSelA	<= '1' when ( (RegWrite_wb='1' and write_register_wb/="00000" and (write_register_wb=read_register_rs_id))
				and not(( RegWrite_mem='1' and write_register_mem/="00000" and (write_register_mem=read_register_rs_id)) or 
				( RegWrite_ex='1' and write_register_ex/="00000" and (write_register_ex=read_register_rs_id))) ) else
				'0';
	REGSelB	<= '1' when ( (RegWrite_wb='1' and write_register_wb/="00000" and (write_register_wb=read_register_rt_id))
				and not((RegWrite_mem='1' and write_register_mem/="00000" and (write_register_mem=read_register_rt_id)) or 
				(RegWrite_ex='1' and write_register_ex/="00000" and (write_register_ex=read_register_rt_id))) ) else
				'0';
END behav;
