library ieee; 
use ieee.std_logic_1164.all; 

entity controller is
	port(	IR: 			in std_logic_vector(15 downto 0);
			C,Z: 			in std_logic;
			alu_z:		in std_logic;
			rf_a3:		in std_logic_vector(2 downto 0);
			decod_out: 	in std_logic_vector(7 downto 0);			
			rst, clk:	in std_logic;
		
			alu_sel: 	out std_logic_vector(1 downto 0);
			alu_a_sel: 	out std_logic_vector(1 downto 0); 
			alu_b_sel: 	out std_logic_vector(1 downto 0);
			c_w_en: 		out std_logic;
			z_w_en: 		out std_logic;

			T1_sel: 		out std_logic;
			T2_sel: 		out std_logic;
			T1_en:		out std_logic;
			T2_en:		out std_logic;

			rf_w_en:		out std_logic;			 			 
			a1_sel:		out std_logic_vector(1 downto 0);
			a2_sel:		out std_logic_vector(1 downto 0);
			a3_sel:		out std_logic_vector(1 downto 0);
			d3_sel:		out std_logic_vector(1 downto 0);
			r7_en:		out std_logic;	
			r7_sel:		out std_logic;	

			ir_en:		out std_logic;

			pc_sel:		out std_logic_vector(1 downto 0);
			pc_en:		out std_logic;

			ram_w_en:	out std_logic;			
			
			enco_sel:	out std_logic;
			enco_en:		out std_logic);
end entity;

architecture struct of controller is

type state_type is (hkt, rf_read, alu_op, rf_write, compute_addr, load, store, load_multi, 
						  lm_write, sm_read, store_multi, beq_compare, load_pc, branch, jump, jlr_state); 
signal current_state, next_state : state_type;


/*constant add: 	std_logic_vector(3 downto 0):= "0000";
constant ndu: 	std_logic_vector(3 downto 0):= "0010";
constant adi: 	std_logic_vector(3 downto 0):= "0001";
constant lhi: 	std_logic_vector(3 downto 0):= "0011";
constant lw: 	std_logic_vector(3 downto 0):= "0100";
constant sw: 	std_logic_vector(3 downto 0):= "0101";
constant lm: 	std_logic_vector(3 downto 0):= "0110";
constant sm: 	std_logic_vector(3 downto 0):= "0111";
constant beq: 	std_logic_vector(3 downto 0):= "1100";
constant jal: 	std_logic_vector(3 downto 0):= "1000";
constant jlr: 	std_logic_vector(3 downto 0):= "1001";*/

signal add		: std_logic;
signal ndu		: std_logic;
signal adi		: std_logic;
signal lhi		: std_logic;
signal lw		: std_logic;
signal sw		: std_logic;
signal lm		: std_logic;
signal sm		: std_logic;
signal beq		: std_logic;
signal jal		: std_logic;
signal jlr		: std_logic;
signal decod	: std_logic;

begin
	add	<= (not IR(15)) and (not IR(14)) and (not IR(13)) and (not IR(12));
	ndu	<=	(not IR(15)) and (not IR(14)) and IR(13) and (not IR(12));
	adi	<= (not IR(15)) and (not IR(14)) and (not IR(13)) and IR(12);
	lhi 	<= (not IR(15)) and (not IR(14)) and IR(13) and IR(12);	
	lw 	<= (not IR(15)) and IR(14) and (not IR(13)) and (not IR(12));
	sw 	<= (not IR(15)) and IR(14) and (not IR(13)) and IR(12);
	lm 	<= (not IR(15)) and IR(14) and IR(13) and (not IR(12));
	sm 	<= (not IR(15)) and IR(14) and IR(13) and IR(12);
	beq	<= IR(15) and IR(14) and (not IR(13)) and (not IR(12));
	jal 	<= IR(15) and (not IR(14)) and (not IR(13)) and (not IR(12));
	jlr	<=	IR(15) and (not IR(14)) and (not IR(13)) and IR(12);
	
	decod	<= '1' when decod_out = "00000000" else
				'0';
	
	process(clk, rst)
   begin
		if (rst = '0') then -- go to state zero if reset
			current_state <= hkt;
		elsif rising_edge(clk) then -- otherwise update the states
			current_state <= next_state;
			
			null;
		end if; 
	end process;
	 
	process(all)
	begin
	
	case current_state is
-----------------------------------------HKT-----------------------------------------
			when hkt =>
				alu_sel			<=		"00";
				alu_a_sel 		<=		"10";
				alu_b_sel 		<= 	"10";
				c_w_en 			<= 	'0';
				z_w_en 			<= 	'0';

				T1_sel 			<=		'X';
				T2_sel 			<=		'X';
				T1_en 			<=		'X';
				T2_en 			<=		'X';

				rf_w_en			<=		'0'; 	 			 
				a1_sel 			<= 	"XX";
				a2_sel 			<=		"XX";
				a3_sel 			<=		"XX";
				d3_sel 			<=		"XX";
				r7_en				<= 	'0';	
				r7_sel			<= 	'X';

				ir_en 			<=		'1';

				pc_sel 			<=		"00";
				pc_en 			<=		'1';
				
				ram_w_en			<=		'0';	

				enco_sel 		<=		'X';
				enco_en 			<=		'X';
				
				next_state		<=		rf_read;

-----------------------------------------rf_read-----------------------------------------				
			when rf_read =>
				alu_sel			<=		"XX";
				alu_a_sel 		<=		"XX";
				alu_b_sel 		<= 	"XX";
				c_w_en 			<= 	'0';
				z_w_en 			<= 	'0';

				T1_sel 			<=		'1';
				T2_sel 			<=		'0';
				T1_en 			<=		'1';
				T2_en 			<=		'1';

				rf_w_en			<=		'0'; 	 			 
				--a1_sel 			<= 	"00";
				--a2_sel 			<=		"00";
				a3_sel 			<=		"XX";
				d3_sel 			<=		"XX";
				--r7_en				<= 	'0';	
				--r7_sel			<= 	'X';	
				
				ir_en 			<=		'0';

				pc_sel 			<=		"XX";
				pc_en 			<=		'0';

				ram_w_en			<=		'0';	
				
				if LM or SM then 
					enco_sel 		<=		'1';
					enco_en 			<=		'1';
				else
					enco_sel 		<=		'X';
					enco_en 			<=		'X';
				end if;
		
				if (ADD = '1' or NDU = '1') 
				and ((IR(1) = '1' and	C = '0') or (IR(0) = '1' and	Z = '0')) then			--ADZ/NDZ/ADC/NDC
					r7_en				<= 	'1';	
					r7_sel			<= 	'1';
				else 
					r7_en				<= 	'0';	
					r7_sel			<= 	'X';	
				end if;
				
				
				if LW or SW then
					a1_sel 			<= 	"01";
					a2_sel 			<=		"01";
				elsif JAL or JLR then
					a1_sel			<= 	"01";
					a2_sel			<=		"11";
				else 
					a1_sel 			<= 	"00";
					a2_sel 			<=		"00";
				end if;
			
				if ADI then					--ADI
					next_state		<=		alu_op;
					
					
				elsif ADD or NDU	then
					if IR(1 downto 0) = "00" then					--ADD/NDU
						next_state		<=		alu_op;
					elsif IR(1) = '1' and	C = '1' then			--ADC/NDC
						next_state		<=		alu_op;
					elsif IR(0) = '1' and	Z = '1' then			--ADZ/NDZ
						next_state		<=		alu_op;
					else 
						next_state		<=		hkt;
						end if;
						
				elsif LHI then				--LHI
					next_state		<=		rf_write;
					
				elsif LW or SW then			--LW/SW
					next_state 		<= 	compute_addr;
					
				elsif LM then
					next_state 		<= 	load_multi;
					
				elsif SM then
					next_state 		<= 	sm_read;
					
				elsif BEQ then
					next_state 		<= 	beq_compare;
					
				elsif JAL then
					next_state 		<= 	jump;
				
				elsif JLR then
					next_state 		<= 	jlr_state;
					
				else 
					next_state		<=		hkt;
				end if;
				
-----------------------------------------alu_op-----------------------------------------				
			when alu_op =>
				--alu_sel			<=		"00";
				--alu_a_sel 		<=		"00";
				--alu_b_sel 		<= 	"01";
				--c_w_en 			<= 	'1';
				z_w_en 			<= 	'1';

				T1_sel 			<=		'0';
				T2_sel 			<=		'X';
				T1_en 			<=		'1';
				T2_en 			<=		'0';

				rf_w_en			<=		'0'; 	 			 
				a1_sel 			<= 	"XX";
				a2_sel 			<=		"XX";
				a3_sel 			<=		"XX";
				d3_sel 			<=		"XX";
				r7_en				<= 	'0';	
				r7_sel			<= 	'X';	
				
				ir_en 			<=		'0';

				pc_sel 			<=		"XX";
				pc_en 			<=		'0';

				ram_w_en			<=		'0';	
				
				enco_sel 		<=		'X';
				enco_en 			<=		'X';
				
				if NDU or LW then
					c_w_en 			<= 	'0';
				else
					c_w_en 			<= 	'1';
				end if;
				
				if ADD or ADI or LW then
					alu_sel <= "00";
				elsif NDU then
					alu_sel <= "01";
				else 
					alu_sel <= "XX";
				end if;
			
				if ADD or NDU or LW then
					alu_b_sel <= "00";
				elsif ADI then
					alu_b_sel <= "01";
				else 
					alu_b_sel <= "XX";
				end if;
					
				if LW then
					alu_a_sel <= "11";
				else
					alu_a_sel <= "00";	
				end if;
			
				next_state		<=		rf_write;	
				
-----------------------------------------rf_write-----------------------------------------				
			when rf_write =>
				alu_sel			<=		"XX";
				alu_a_sel 		<=		"XX";
				alu_b_sel 		<= 	"XX";
				c_w_en 			<= 	'0';
				z_w_en 			<= 	'0';

				T1_sel 			<=		'X';
				T2_sel 			<=		'X';
				T1_en 			<=		'0';
				T2_en 			<=		'0';

				rf_w_en			<=		'1'; 	 			 
				a1_sel 			<= 	"XX";
				a2_sel 			<=		"XX";
				--a3_sel 		<=		"00";
				--d3_sel 		<=		"00";
				--r7_en			<= 	'0';	
				--r7_sel			<= 	'X';	
				
				ir_en 			<=		'0';

				--pc_sel 		<=		"XX";
				--pc_en 			<=		'0';

				ram_w_en			<=		'0';	

				enco_sel 		<=		'X';
				enco_en 			<=		'X';
				
				if ADI then
					a3_sel <= "11";
				elsif LW or LHI then
					a3_sel <= "01";
				else
					a3_sel <= "00";
				end if;
				
				if LHI then
					d3_sel 			<=		"01";
				else 
					d3_sel 			<=		"00";
				end if;
			
				if rf_a3(2) and rf_a3(1) and rf_a3(0) then
					r7_en			<= 	'0';	
					r7_sel		<= 	'X';
					pc_sel 		<= 	"10";
					pc_en 		<= 	'1';
				else	
					r7_en			<= 	'1';	
					r7_sel		<= 	'1';
					pc_sel 		<= 	"XX";
					pc_en 		<= 	'0';
				end if;
				
			next_state		<=		hkt;	

-----------------------------------------compute_addr-----------------------------------------				
			when compute_addr =>
				alu_sel			<=		"00";
				alu_a_sel 		<=		"00";
				alu_b_sel 		<= 	"01";
				c_w_en 			<= 	'0';
				z_w_en 			<= 	'0';

				T1_sel 			<=		'0';
				T2_sel 			<=		'X';
				T1_en 			<=		'1';
				T2_en 			<=		'0';

				rf_w_en			<=		'0'; 	 			 
				a1_sel 			<= 	"XX";
				a2_sel 			<=		"XX";
				a3_sel 			<=		"XX";
				d3_sel 			<=		"XX";
				r7_en				<= 	'0';	
				r7_sel			<= 	'X';	
				
				ir_en 			<=		'0';

				pc_sel 			<=		"XX";
				pc_en 			<=		'0';

				ram_w_en			<=		'0';	

				enco_sel 		<=		'X';
				enco_en 			<=		'X';
			
				if SW then
					next_state		<=		store;			
				else
					next_state		<=		load;
				end if;
-----------------------------------------load-----------------------------------------				
			when load =>
				alu_sel			<=		"XX";
				alu_a_sel 		<=		"XX";
				alu_b_sel 		<= 	"XX";
				c_w_en 			<= 	'0';
				z_w_en 			<= 	'0';

				T1_sel 			<=		'X';
				T2_sel 			<=		'1';
				T1_en 			<=		'0';
				T2_en 			<=		'1';

				rf_w_en			<=		'0'; 	 			 
				a1_sel 			<= 	"XX";
				a2_sel 			<=		"XX";
				a3_sel 			<=		"XX";
				d3_sel 			<=		"XX";
				r7_en				<= 	'0';	
				r7_sel			<= 	'X';	
				
				ir_en 			<=		'0';

				pc_sel 			<=		"XX";
				pc_en 			<=		'0';

				ram_w_en			<=		'0';	

				enco_sel 		<=		'X';
				enco_en 			<=		'X';
			
				next_state		<=		alu_op;	

-----------------------------------------store-----------------------------------------				
			when store =>
				alu_sel			<=		"XX";
				alu_a_sel 		<=		"XX";
				alu_b_sel 		<= 	"XX";
				c_w_en 			<= 	'0';
				z_w_en 			<= 	'0';

				T1_sel 			<=		'X';
				T2_sel 			<=		'X';
				T1_en 			<=		'0';
				T2_en 			<=		'0';

				rf_w_en			<=		'0'; 	 			 
				a1_sel 			<= 	"XX";
				a2_sel 			<=		"XX";
				a3_sel 			<=		"XX";
				d3_sel 			<=		"XX";
				r7_en				<= 	'1';	
				r7_sel			<= 	'1';	
				
				ir_en 			<=		'0';

				pc_sel 			<=		"XX";
				pc_en 			<=		'0';

				ram_w_en			<=		'1';	

				enco_sel 		<=		'X';
				enco_en 			<=		'X';
			
				next_state		<=		hkt;			
			
-----------------------------------------load_multi-----------------------------------------				
			when load_multi =>
				alu_sel			<=		"00";
				alu_a_sel 		<=		"00";
				alu_b_sel 		<= 	"10";
				c_w_en 			<= 	'0';
				z_w_en 			<= 	'0';

				T1_sel 			<=		'0';
				T2_sel 			<=		'1';
				T1_en 			<=		'1';
				T2_en 			<=		'1';

				rf_w_en			<=		'0'; 	 			 
				a1_sel 			<= 	"XX";
				a2_sel 			<=		"XX";
				a3_sel 			<=		"XX";
				d3_sel 			<=		"XX";
				r7_en				<= 	'0';	
				r7_sel			<= 	'X';	
				
				ir_en 			<=		'0';

				pc_sel 			<=		"XX";
				pc_en 			<=		'0';

				ram_w_en			<=		'0';	

				enco_sel 		<=		'X';
				enco_en 			<=		'0';
			
				next_state		<=		lm_write;	
	
-----------------------------------------lm_write-----------------------------------------				
			when lm_write =>
				alu_sel			<=		"XX";
				alu_a_sel 		<=		"XX";
				alu_b_sel 		<= 	"XX";
				c_w_en 			<= 	'0';
				z_w_en 			<= 	'0';

				T1_sel 			<=		'X';
				T2_sel 			<=		'X';
				T1_en 			<=		'0';
				T2_en 			<=		'0';

				rf_w_en			<=		'1'; 	 			 
				a1_sel 			<= 	"XX";
				a2_sel 			<=		"XX";
				a3_sel 			<=		"10";
				d3_sel 			<=		"10";
				--r7_en			<= 	'1';	
				--r7_sel			<= 	'1';	
				
				ir_en 			<=		'0';

				--pc_sel 		<=		"XX";
				--pc_en 			<=		'0';

				ram_w_en			<=		'0';	
				
				enco_sel 		<=		'0';
				enco_en 			<=		'1';
				
				
				if rf_a3(2) and rf_a3(1) and rf_a3(0) then
					pc_sel 		<= 	"10";
					pc_en 		<= 	'1';
				else	
					pc_sel 		<= 	"XX";
					pc_en 		<= 	'0';
				end if;
				
				if decod = '1' and IR(7) = '0' then
					r7_en				<= 	'1';	
					r7_sel			<= 	'1';
				else
					r7_en				<= 	'0';	
					r7_sel			<= 	'X';
				end if;
				
				if decod then
					next_state 		<=		hkt;
				else 
					next_state 		<= 	load_multi;
				end if;
				
-----------------------------------------sm_read-----------------------------------------				
			when sm_read =>
				alu_sel			<=		"XX";
				alu_a_sel 		<=		"XX";
				alu_b_sel 		<= 	"XX";
				c_w_en 			<= 	'0';
				z_w_en 			<= 	'0';

				T1_sel 			<=		'X';
				T2_sel 			<=		'0';
				T1_en 			<=		'0';
				T2_en 			<=		'1';

				rf_w_en			<=		'0'; 	 			 
				a1_sel 			<= 	"XX";
				a2_sel 			<=		"10";
				a3_sel 			<=		"XX";
				d3_sel 			<=		"XX";
				r7_en				<= 	'0';	
				r7_sel			<= 	'X';	
				
				ir_en 			<=		'0';

				pc_sel 			<=		"XX";
				pc_en 			<=		'0';

				ram_w_en			<=		'0';	

				enco_sel 		<=		'X';
				enco_en 			<=		'0';
			
				next_state		<=		store_multi;
				
-----------------------------------------store_multi-----------------------------------------				
			when store_multi =>
				alu_sel			<=		"00";
				alu_a_sel 		<=		"00";
				alu_b_sel 		<= 	"10";
				c_w_en 			<= 	'0';
				z_w_en 			<= 	'0';

				T1_sel 			<=		'0';
				T2_sel 			<=		'X';
				T1_en 			<=		'1';
				T2_en 			<=		'0';

				rf_w_en			<=		'0'; 	 			 
				a1_sel 			<= 	"XX";
				a2_sel 			<=		"XX";
				a3_sel 			<=		"XX";
				d3_sel 			<=		"XX";
				r7_en				<= 	'0';	
				r7_sel			<= 	'X';	
				
				ir_en 			<=		'0';

				pc_sel 			<=		"XX";
				pc_en 			<=		'0';

				ram_w_en			<=		'1';	

				enco_sel 		<=		'0';
				enco_en 			<=		'1';
				
				if decod then
					r7_en				<= 	'1';	
					r7_sel			<= 	'1';
					next_state		<=		hkt;
				else
					r7_en				<= 	'0';	
					r7_sel			<= 	'X';
					next_state		<=		sm_read;
				end if;

-----------------------------------------beq_compare-----------------------------------------				
			when beq_compare =>
				alu_sel			<=		"10";
				alu_a_sel 		<=		"00";
				alu_b_sel 		<= 	"00";
				c_w_en 			<= 	'0';
				z_w_en 			<= 	'0';

				T1_sel 			<=		'X';
				T2_sel 			<=		'X';
				T1_en 			<=		'0';
				T2_en 			<=		'0';

				rf_w_en			<=		'0'; 	 			 
				a1_sel 			<= 	"XX";
				a2_sel 			<=		"XX";
				a3_sel 			<=		"XX";
				d3_sel 			<=		"XX";
				--r7_en				<= 	'0';	
				--r7_sel			<= 	'X';	
				
				ir_en 			<=		'0';

				pc_sel 			<=		"XX";
				pc_en 			<=		'0';

				ram_w_en			<=		'0';	

				enco_sel 		<=		'X';
				enco_en 			<=		'X';
				
			
				if alu_z then 
					next_state		<=		load_pc;
					r7_en				<= 	'0';	
					r7_sel			<= 	'X';
				else 
					next_state		<=		hkt;
					r7_en				<= 	'1';	
					r7_sel			<= 	'1';	
				end if;

-----------------------------------------load_pc-----------------------------------------				
			when load_pc =>
				alu_sel			<=		"XX";
				alu_a_sel 		<=		"XX";
				alu_b_sel 		<= 	"XX";
				c_w_en 			<= 	'0';
				z_w_en 			<= 	'0';

				T1_sel 			<=		'1';
				T2_sel 			<=		'X';
				T1_en 			<=		'1';
				T2_en 			<=		'0';

				rf_w_en			<=		'0'; 	 			 
				a1_sel 			<= 	"10";
				a2_sel 			<=		"XX";
				a3_sel 			<=		"XX";
				d3_sel 			<=		"XX";
				r7_en				<= 	'0';	
				r7_sel			<= 	'X';	
				
				ir_en 			<=		'0';

				pc_sel 			<=		"XX";
				pc_en 			<=		'0';

				ram_w_en			<=		'0';	

				enco_sel 		<=		'X';
				enco_en 			<=		'X';
				
				next_state		<= 	branch;

-----------------------------------------branch-----------------------------------------				
			when branch =>
				alu_sel			<=		"00";
				alu_a_sel 		<=		"00";
				alu_b_sel 		<= 	"01";
				c_w_en 			<= 	'0';
				z_w_en 			<= 	'0';

				T1_sel 			<=		'X';
				T2_sel 			<=		'X';
				T1_en 			<=		'0';
				T2_en 			<=		'0';

				rf_w_en			<=		'0'; 	 			 
				a1_sel 			<= 	"XX";
				a2_sel 			<=		"XX";
				a3_sel 			<=		"XX";
				d3_sel 			<=		"XX";
				r7_en				<= 	'1';	
				r7_sel			<= 	'0';	
				
				ir_en 			<=		'0';

				pc_sel 			<=		"00";
				pc_en 			<=		'1';

				ram_w_en			<=		'0';	

				enco_sel 		<=		'X';
				enco_en 			<=		'X';
				
				next_state		<= 	hkt;		
	
-----------------------------------------jump-----------------------------------------				
			when jump =>
				alu_sel			<=		"00";
				alu_a_sel 		<=		"01";
				alu_b_sel 		<= 	"00";
				c_w_en 			<= 	'0';
				z_w_en 			<= 	'0';

				T1_sel 			<=		'X';
				T2_sel 			<=		'X';
				T1_en 			<=		'0';
				T2_en 			<=		'0';

				rf_w_en			<=		'1'; 	 			 
				a1_sel 			<= 	"XX";
				a2_sel 			<=		"XX";
				a3_sel 			<=		"01";
				d3_sel 			<=		"10";
				--r7_en				<= 	'0';	
				--r7_sel			<= 	'X';	
				
				ir_en 			<=		'0';

				--pc_sel 			<=		"00";
				--pc_en 			<=		'1';

				ram_w_en			<=		'0';	

				enco_sel 		<=		'X';
				enco_en 			<=		'X';
			
				if rf_a3(2) and rf_a3(1) and rf_a3(0) then
					r7_en			<= 	'0';	
					r7_sel		<= 	'X';
					pc_sel 		<= 	"10";
					pc_en 		<= 	'1';
				else	
					r7_en			<= 	'1';	
					r7_sel		<= 	'0';
					pc_sel 		<= 	"00";
					pc_en 		<= 	'1';
				end if;
			
				next_state		<=		hkt;	
			
-----------------------------------------jlr_state-----------------------------------------				
			when jlr_state =>
				alu_sel			<=		"XX";
				alu_a_sel 		<=		"XX";
				alu_b_sel 		<= 	"XX";
				c_w_en 			<= 	'0';
				z_w_en 			<= 	'0';

				T1_sel 			<=		'X';
				T2_sel 			<=		'X';
				T1_en 			<=		'0';
				T2_en 			<=		'0';

				rf_w_en			<=		'1'; 	 			 
				a1_sel 			<= 	"XX";
				a2_sel 			<=		"XX";
				a3_sel 			<=		"01";
				d3_sel 			<=		"10";
				--r7_en				<= 	'0';	
				--r7_sel			<= 	'X';	
				
				ir_en 			<=		'0';

				--pc_sel 		<=		"01";
				--pc_en 			<=		'1';

				ram_w_en			<=		'0';	

				enco_sel 		<=		'X';
				enco_en 			<=		'X';
			
				if rf_a3(2) and rf_a3(1) and rf_a3(0) then
					r7_en			<= 	'0';	
					r7_sel		<= 	'X';
					pc_sel 		<= 	"10";
					pc_en 		<= 	'1';
				else	
					r7_en			<= 	'1';	
					r7_sel		<= 	'0';
					pc_sel 		<= 	"01";
					pc_en 		<= 	'1';
				end if;
			
				next_state		<=		hkt;	
	end case;
	end process;
end struct;