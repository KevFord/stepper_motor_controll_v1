-- Stepper motor using a ULN2003 driver IC
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	
entity top_level is
generic(
        g_rotation_speed    : integer range 50000 to 270000 := 50000); -- 50000 is the fastest.
port(
		clk					: in std_logic;
		btn					: in std_logic_vector(1 downto 0);
		
		motor_controll_pins	: out std_logic_vector(3 downto 0)); -- 4 controll pins, used to determine which coil to energize
		-- Pins 70 - 73
end entity top_level;

architecture rtl of top_level is

signal s_btn_1r				: std_logic_vector(1 downto 0);
signal s_btn_2r				: std_logic_vector(1 downto 0);
signal timer 				: integer range 0 to 270000 := 270000;

type t_motor_controll is(
						stop,
						step_one,
						step_two,
						step_three,
						step_four);
signal s_motor_controll	: t_motor_controll := step_one; -- The sequence of energized coils.

type t_rotation_direction is(
							stop,
							clockwise,
							counter_clockwise);
signal s_rotation_direction	: t_rotation_direction; -- Clockwise, counter clockwise or full stop.
begin

	p_user_input		: process(clk) is
	begin
		if rising_edge(clk) then
			s_btn_1r	<= btn;
			s_btn_2r	<= s_btn_1r;
		end if;
	end process p_user_input;
	
	p_set_rotation		: process(clk, s_btn_2r) is
	begin
		if rising_edge(clk) then
			if s_btn_2r(1) = '1' then
				s_rotation_direction <= clockwise;
			elsif s_btn_2r(0) = '1' then
				s_rotation_direction <= counter_clockwise;
			else s_rotation_direction <= stop;
            end if;
        end if;
	end process p_set_rotation;
	
	p_motor_controll	: process(clk) is
	begin
		if rising_edge(clk) then
			if timer = 0 then
                case s_rotation_direction is
                    when clockwise  =>
						case s_motor_controll is
							when step_one	=>
								motor_controll_pins <= "1100";
								s_motor_controll <= step_two;
								timer <= g_rotation_speed;
							when step_two	=>
								motor_controll_pins <= "0110";
								s_motor_controll <= step_three;
								timer <= g_rotation_speed;
							when step_three	=>						
								motor_controll_pins <= "0011";
								s_motor_controll <= step_four;
								timer <= g_rotation_speed;
							when step_four	=>					
								motor_controll_pins <= "1001";
								s_motor_controll <= step_one;
								timer <= g_rotation_speed;
							when others		=>
								motor_controll_pins	<= "0000";
								timer <= g_rotation_speed;
						end case;

					when counter_clockwise =>
						case s_motor_controll is
							when step_one	=>
								motor_controll_pins <= "1100";
								s_motor_controll <= step_two;
								timer <= g_rotation_speed;
							when step_two	=>
								motor_controll_pins <= "1001";
								s_motor_controll <= step_three;
								timer <= g_rotation_speed;
							when step_three	=>						
								motor_controll_pins <= "0011";
								s_motor_controll <= step_four;
								timer <= g_rotation_speed;
							when step_four	=>					
								motor_controll_pins <= "0110";
								s_motor_controll <= step_one;
								timer <= g_rotation_speed;
							when others		=>
								motor_controll_pins	<= "0000";
								timer <= g_rotation_speed;
						end case;
						
					when stop =>
						motor_controll_pins <= "0000";
						timer <= g_rotation_speed;
					end case;
			else timer <= timer - 1;
			end if;
		end if;	
	end process p_motor_controll;
end architecture rtl;