library ieee; 
use ieee.std_logic_1164.all; 

entity encoder is 
	port(enco_in		: in std_logic_vector(7 downto 0);
		  addr_out		: out std_logic_vector(2 downto 0);
		  decod_out		: out std_logic_vector(7 downto 0);
		  enco_sel		: in std_logic;
		  enco_en, clk	: in std_logic);
end entity;

architecture struct of encoder is

component Reg is
	generic (width: integer:=16);
	port ( D: in std_logic_vector((width-1) downto 0);
			 Q: out std_logic_vector((width-1) downto 0);
			 clr, clk, en: in std_logic);
end component; 

component priority_encoder is 
	port(enco_in	: in std_logic_vector(7 downto 0);
		  decod_out	: out std_logic_vector(7 downto 0);
		  enco_out	: out std_logic_vector(2 downto 0));
end component;	

signal reg_in,reg_out		: std_logic_vector(7 downto 0);			
signal decoder_out			: std_logic_vector(7 downto 0);
signal decod_and_reg			: std_logic_vector(7 downto 0);

begin

Enco_reg: Reg generic map(8)
				  port map(reg_in, reg_out, '1', clk, enco_en); 	
PE: priority_encoder port map(reg_out, decoder_out, addr_out);

decod_and_reg	<=		decoder_out and reg_out;

reg_in 			<= 	enco_in when enco_sel
							else decod_and_reg;
			 
decod_out 		<= 	decod_and_reg;

end struct;		


library ieee; 
use ieee.std_logic_1164.all; 

entity priority_encoder is 
	port(enco_in	: in std_logic_vector(7 downto 0);
		  decod_out	: out std_logic_vector(7 downto 0);
		  enco_out	: out std_logic_vector(2 downto 0));
end entity;	

architecture struct of priority_encoder is
begin

	process(enco_in)
	begin
	if enco_in(7) then
		decod_out	<= not "10000000";
		enco_out 	<= "111";
	elsif enco_in(6) then
		decod_out	<= not"01000000";
		enco_out 	<= "110";
	elsif enco_in(5) then
		decod_out	<= not"00100000";
		enco_out 	<= "101";
	elsif enco_in(4) then
		decod_out	<= not"00010000";
		enco_out 	<= "100";
	elsif enco_in(3) then
		decod_out	<= not"00001000";
		enco_out 	<= "011";
	elsif enco_in(2) then
		decod_out	<= not"00000100";
		enco_out 	<= "010";
	elsif enco_in(1) then
		decod_out	<= not"00000010";
		enco_out 	<= "001";
	elsif enco_in(0) then
		decod_out	<= not"00000001";
		enco_out 	<= "000";
	else
		decod_out	<= (others => 'X');
		enco_out 	<= (others => 'X');
	end if;
	end process;

end struct;		