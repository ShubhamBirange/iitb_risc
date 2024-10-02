library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all; 
use work.bus_multiplexer_pkg.all;

entity processor is
	port ( rst, clk: 	in std_logic;			 
			 R0_out:		 		out std_logic_vector(15 downto 0);
			 R1_out:		 		out std_logic_vector(15 downto 0);
			 R2_out:		 		out std_logic_vector(15 downto 0);
			 R3_out:		 		out std_logic_vector(15 downto 0);

			 IReg:		 		out std_logic_vector(15 downto 0));
			 --enco_out:			out std_logic_vector(7 downto 0));
end entity;

architecture struct of processor is

component ROM is
	port(	addr		: in std_logic_vector(15 downto 0);
			data_out	: out std_logic_vector(15 downto 0));
end component;

component RAM is
	port(	data_in	: in std_logic_vector(15 downto 0);
			addr		: in std_logic_vector(15 downto 0);
			w_en		: in std_logic := '0';
			clk		: in std_logic;
			data_out	: out std_logic_vector(15 downto 0));
end component;

component Reg is
	port ( D: 				in std_logic_vector(15 downto 0);
			 Q: 				out std_logic_vector(15 downto 0);
			 clr, clk, en: in std_logic);

end component; 

component reg_file is
	port ( A1, A2, A3: 	in std_logic_vector(2 downto 0);
			 d3: 				in std_logic_vector(15 downto 0);
			 clr, clk: 		in std_logic;
			 w_en: 			in std_logic;
			 d1, d2: 		out std_logic_vector(15 downto 0);
			 r7_en:			in std_logic;
			 r7_in:			in std_logic_vector(15 downto 0);
			 r0_out:		   out std_logic_vector(15 downto 0);
			 r1_out:		   out std_logic_vector(15 downto 0);
			 r2_out:		   out std_logic_vector(15 downto 0);
			 r3_out:		   out std_logic_vector(15 downto 0));
end component;

component ALU is
	port ( alu_a: 				in std_logic_vector(15 downto 0);
			 alu_b: 				in std_logic_vector(15 downto 0);
			 alu_sel:			in std_logic_vector(1 downto 0);
			 alu_out:			out std_logic_vector(15 downto 0);
			 C, Z:				out std_logic);
end component; 

component FF is
	port ( D: 		in std_logic;
			 Q: 		out std_logic;
			 clr,clk:in std_logic;
			 en: 		in std_logic);
end component;

component SE is
	generic (in_width: 	integer:=6;
				out_width: 	integer:=16);
	port (i: in std_logic_vector((in_width - 1) downto 0);
			o: out std_logic_vector((out_width - 1) downto 0));
end component;

component MUX is
        generic (bus_width : 	positive := 16;
                sel_width : 	positive := 3);
        port (  i : 		in bus_array(2**sel_width - 1 downto 0)(bus_width - 1 downto 0);
                sel :	in std_logic_vector(sel_width - 1 downto 0);
                o : 		out std_logic_vector(bus_width - 1 downto 0));
end component;

component encoder is 
	port(enco_in		: in std_logic_vector(7 downto 0);
		  addr_out		: out std_logic_vector(2 downto 0);
		  decod_out		: out std_logic_vector(7 downto 0);
		  enco_sel		: in std_logic;
		  enco_en, clk	: in std_logic);
end component;


component controller is
	port(	IR: 			in std_logic_vector(15 downto 0);
			C,Z: 			in std_logic;
			alu_z:		in std_logic;
			rf_a3:		in std_logic_vector(2 downto 0);
			decod_out:	in std_logic_vector(7 downto 0);
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
end component;

--signal clk							: std_logic;
signal count						: integer:=1;
signal tmp 							: std_logic := '0';
signal alu_out, alu_a, alu_b	: std_logic_vector(15 downto 0);
signal c_flag_in, z_flag_in	: std_logic;
signal c_flag_out, z_flag_out	: std_logic;
signal t1_in, t1_out				: std_logic_vector(15 downto 0);	
signal t2_in, t2_out				: std_logic_vector(15 downto 0);	
signal pc_in, pc_out				: std_logic_vector(15 downto 0);	
signal se6_out,se9_out			: std_logic_vector(15 downto 0);	
signal rf_a1,rf_a2,rf_a3		: std_logic_vector(2 downto 0);	
signal rf_d1,rf_d2,rf_d3		: std_logic_vector(15 downto 0);	
signal r7_in						: std_logic_vector(15 downto 0);		
signal ir_in, ir_out				: std_logic_vector(15 downto 0);	
signal rom_in, rom_out			: std_logic_vector(15 downto 0);	
signal ram_in, ram_out			: std_logic_vector(15 downto 0);	
signal addr_out					: std_logic_vector(2 downto 0);
signal decod_out					: std_logic_vector(7 downto 0);
signal r0,r1,r2,r3				: std_logic_vector(15 downto 0);		


---------------------Control Signals---------------------
signal alu_sel			: std_logic_vector(1 downto 0);
signal alu_a_sel		: std_logic_vector(1 downto 0); 
signal alu_b_sel		: std_logic_vector(1 downto 0);
signal c_w_en			: std_logic:='0';
signal z_w_en			: std_logic:='0';
 
signal T1_sel			: std_logic;
signal T2_sel			: std_logic;
signal T1_en			: std_logic:='0';
signal T2_en			: std_logic:='0';

signal rf_w_en			: std_logic:='0';			 			 
signal a1_sel			: std_logic_vector(1 downto 0);
signal a2_sel			: std_logic_vector(1 downto 0);
signal a3_sel			: std_logic_vector(1 downto 0);
signal d3_sel			: std_logic_vector(1 downto 0);
signal r7_en			: std_logic:='0';
signal r7_sel			: std_logic;

signal ir_en			: std_logic:='0';
  
signal pc_sel			: std_logic_vector(1 downto 0);
signal pc_en			: std_logic:='0';

signal ram_w_en		: std_logic:='0';
 
signal enco_sel		: std_logic;
signal enco_en			: std_logic:='0';

begin


/*clk_divider:process(clk_50Hz,rst)
begin
	if(rst='0') then
		count<=1;
		tmp<='0';
	elsif(clk_50Hz'event and clk_50Hz='1') then
		count <=count+1;
	if (count = 1) then
		tmp <= NOT tmp;
		count <= 1;
	end if;
	end if;
	clk <= tmp;
end process;*/


----------------------------------------ALU--------------------------------------------
	a: ALU port map(alu_a, alu_b,alu_sel,alu_out,c_flag_in,z_flag_in);
	MUX_alu_a:	MUX 	generic map(16,2)
							port map(i(0) 	=> t1_out, 
										i(1)	=> se9_out,
										i(2) 	=> pc_out, 
										i(3)	=> (others => '0'),
										sel=> alu_a_sel, 
										o    	=> alu_a);
	MUX_alu_b:	MUX 	generic map(16,2)
							port map(i(0) => t2_out, 
										i(1) => se6_out,
										i(2) => X"0001",
										i(3) => (others => 'X'),
										sel  => alu_b_sel, 
										o    => alu_b);	
										
	--alu_result	<= alu_out;
		
--------------------------------------C Flag--------------------------------------------

	C_flag: FF port map(c_flag_in, c_flag_out, rst, clk, c_w_en);
	--C <= c_flag_out;
				
--------------------------------------Z Flag--------------------------------------------

	Z_flag: FF port map(z_flag_in, z_flag_out, rst, clk, z_w_en);
	--Z <= z_flag_out;
	
---------------------------------------T1-----------------------------------------------

	T1: Reg port map(t1_in, t1_out, rst, clk, t1_en);		
	MUX_t1:	MUX 	generic map(16,1)
							port map(i(0) 	=> alu_out,  
										i(1) 	=> rf_d1, 
										sel(0)=> t1_sel, 
										o    	=> t1_in);	
										
	--T1_o <= t1_out;
										
----------------------------------------T2----------------------------------------------
				
	T2: Reg port map(t2_in, t2_out, rst, clk, t2_en);
	MUX_t2:	MUX 		generic map(16,1)
							port map(i(0) => rf_d2, 
										i(1) => ram_out,					
										sel(0)  => t2_sel, 
										o    => t2_in);
	--T2_o <= t2_out;
------------------------------------Register File---------------------------------------

	r: reg_file port map(rf_a1,rf_a2,rf_a3,rf_d3,rst,clk,rf_w_en,rf_d1,rf_d2,r7_en,r7_in,r0,r1,r2,r3);
	MUX_a1:	MUX 		generic map(3,2)
							port map(i(0) => ir_out(11 downto 9), 
										i(1) => ir_out(8 downto 6),
										i(2) => "111",
										i(3) => "XXX",
										sel  => a1_sel, 
										o    => rf_a1);
	MUX_a2:	MUX 		generic map(3,2)
							port map(i(0) => ir_out(8 downto 6),
										i(1) => ir_out(11 downto 9), 
										i(2) => addr_out,			-- Priority encoder		
										i(3) => "111",
										sel  => a2_sel, 
										o    => rf_a2);
	MUX_a3:	MUX 		generic map(3,2)
							port map(i(0) => ir_out(5 downto 3), 
										i(1) => ir_out(11 downto 9),
										i(2) => addr_out,			-- Priority encoder			
										i(3) => ir_out(8 downto 6),
										sel  => a3_sel, 
										o    => rf_a3);
	MUX_d3:	MUX 		generic map(16,2)
							port map(i(0) => t1_out, 
										i(1)(15 downto 7) => ir_out(8 downto 0),i(1)(6 downto 0)=> (others => '0'),
										i(2) => t2_out,					
										i(3) => pc_out,
										sel  => d3_sel, 
										o    => rf_d3);
	
	MUX_r7:	MUX 		generic map(16,1)
							port map(i(0) => pc_in, 
										i(1) => pc_out,					
										sel(0)  => r7_sel, 
										o    => r7_in);
										

	R0_out	<= r0;
	R1_out	<= r1;
	R2_out	<= r2;
	R3_out	<= r3;
					
--------------------------------------------IR----------------------------------------------
				
	IR: Reg port map(rom_out, ir_out, rst, clk, ir_en);	
	IReg <= ir_out;
	
----------------------------------------MEMORY----------------------------------------------
				
	ROM_0: ROM port map(pc_out, rom_out);

------------------------------------------RAM-----------------------------------------------
				
	RAM_0: RAM port map(t2_out, t1_out, ram_w_en, clk, ram_out);	
										
--------------------------------------------PC----------------------------------------------
				
	PC: Reg port map(pc_in, pc_out, rst, clk, pc_en);	
	MUX_pc:	MUX 		generic map(16,2)
							port map(i(0) 	=> alu_out, 
										i(1) 	=> t1_out,
										i(2) 	=> rf_d3,
										i(3)  => (others => 'X'),
										sel	=> pc_sel, 
										o    	=> pc_in);
	--PCreg <= pc_out;

-------------------------------------------SE6----------------------------------------------
	
	SE6: SE	generic map(6,16)
				port map(ir_out(5 downto 0), se6_out);
				
-------------------------------------------SE9----------------------------------------------
	
	SE9: SE	generic map(9,16)
				port map(ir_out(8 downto 0), se9_out);
										
---------------------------------------Proiority Encoder-------------------------------------

	e: encoder port map(ir_out(7 downto 0), addr_out, decod_out, enco_sel, enco_en, clk);
	--enco_out <= decod_out;

-------------------------------------------CONTROLLER----------------------------------------

	control: controller port map(	
			ir_out,
			c_flag_out,z_flag_out,
			z_flag_in,
			rf_a3,
			decod_out,
			rst, clk,
						
			alu_sel,
			alu_a_sel,
			alu_b_sel,
			c_w_en,
			z_w_en,

			T1_sel,
			T2_sel,
			T1_en,
			T2_en,

			rf_w_en,		 			 
			a1_sel,
			a2_sel,
			a3_sel,
			d3_sel,
			r7_en,
			r7_sel,
			
			ir_en,

			pc_sel,
			pc_en,

			ram_w_en,
			
			enco_sel,
			enco_en
	);
		
end struct;



library ieee; 
use ieee.std_logic_1164.all;

entity SE is
generic (in_width: 	integer:=6;
			out_width: 	integer:=16);
	port (i: in std_logic_vector((in_width - 1) downto 0);
			o: out std_logic_vector((out_width - 1) downto 0));
end entity;

architecture struct of SE is
begin
	
	process(all)
	begin
		
		case i(in_width - 1) is
		when '0' =>
			o <= ((out_width -1) downto in_width => '0') & i;
			
	   when others =>
			o <= ((out_width -1) downto in_width => '1') & i;

		end case; 
	end process;

end struct;