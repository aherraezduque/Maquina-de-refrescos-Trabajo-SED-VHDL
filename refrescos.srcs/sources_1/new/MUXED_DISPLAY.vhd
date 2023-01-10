----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.12.2022 00:42:47
-- Design Name: 
-- Module Name: MUXED_DISPLAY - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;   --unsigned


entity MUXED_DISPLAY is
    Port (
      CLK: in std_logic; --clk, needed for synchronization
      digito3, digito2, digito1, digito0: in std_logic_vector(6 downto 0); --7 segment inputs for each digit
      digselector: out std_logic_vector(3 downto 0); --digit selector
      segmentos_ilum: out std_logic_vector(6 downto 0) --7 segments output, to show in the digit selected by "an"
     );
end MUXED_DISPLAY;

architecture Behavioral of MUXED_DISPLAY is
    constant N: integer:= 18;           --con esto genero la tasa de refresco 
    signal q_reg: unsigned(N-1 downto 0):=('0', others=>'0');
    signal sel: std_logic_vector(1 downto 0):= "00"; --signal to select the digit to enable
begin

registr:   process(clk)
   begin
      if (rising_edge(clk)) then
        q_reg <= q_reg+1;
      end if;
   end process;

    sel <= std_logic_vector(q_reg(N-1 downto N-2));
    
seleccion:    process(clk, sel)
   begin
      if rising_edge(clk) then
          case sel is
             when "00" =>
                digselector  <= "0111"; --display3 millares
                segmentos_ilum <= digito3;
             when "01" =>
                digselector  <= "1011"; --display2 centenas
                segmentos_ilum <= digito2;
             when "10" =>
                digselector <= "1101"; --display1 decenas
                segmentos_ilum <= digito1;
             when others =>
                digselector <= "1110"; --display0 unidades
                segmentos_ilum <= digito0;
          end case;
      end if;
   end process;
       
end Behavioral;
