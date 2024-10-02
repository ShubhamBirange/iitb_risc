library ieee; 
use ieee.std_logic_1164.all; 

entity Testbench is
end entity;

architecture Behave of Testbench is

component processor is
	port ( rst, clk: 	in std_logic;			 
			 R0_out:		 		out std_logic_vector(15 downto 0);
			 R1_out:		 		out std_logic_vector(15 downto 0);
			 R2_out:		 		out std_logic_vector(15 downto 0);
			 R3_out:		 		out std_logic_vector(15 downto 0);

			 IReg:		 		out std_logic_vector(15 downto 0));
end component;


constant CLK_PERIOD: time:= 20ns;
signal rst, clk	: std_logic;
signal R0,R1,R2,R3,IR: std_logic_vector(15 downto 0);


begin

DUT: processor port map( rst, clk,
								 R0,R1,R2,R3,IR);

	clk_generation : process
	begin
		clk <= '1';
		wait for CLK_PERIOD / 2;
		clk <= '0';
		wait for CLK_PERIOD / 2;
	end process clk_generation;


	simulation: process
	begin

		rst	<= '0';
		wait for 1ns;
		
		rst	<= '1';
		wait for 1000000000ns;
		wait for 1000000000ns;
		wait for 1000000000ns;
	end process simulation;


end behave;


