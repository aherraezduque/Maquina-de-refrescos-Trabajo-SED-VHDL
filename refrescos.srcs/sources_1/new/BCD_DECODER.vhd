----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.12.2022 22:43:57
-- Design Name: 
-- Module Name: BCD_DECODER - Behavioral
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
use IEEE.NUMERIC_STD.ALL;       --unsigned

--Tiene como finalidad calcular la secuencia de std_logic que se pasarán a cada 
--uno de los 4 displays de 7 segmentos con los que se va a trabajar

entity BCD_DECODER is


    Port (
        CLK: in std_logic;                              --CLK
        RESET: in std_logic;                            --Reset asíncrono activo a nivel bajo
        SALDO_NUM: in integer;                          --Saldo (en el monedero) que debe codificarse
        digito3: out std_logic_vector (6 downto 0);     --Unidades de millar    10 ^3
        digito2: out std_logic_vector (6 downto 0);     --Centenas              10 ^2   
        digito1: out std_logic_vector (6 downto 0);     --Decenas               10 ^1
        digito0: out std_logic_vector (6 downto 0));    --Unidades              10 ^0    
end BCD_DECODER;

architecture Behavioral of BCD_DECODER is

begin

    conversion: process  (CLK,RESET)

        variable  saldo: integer := SALDO_NUM;      --Variable a la que se le pasará el valor de la entrada SALDO_NUM

    begin   
        saldo:= SALDO_NUM;                          --Actualización del valor de la variable saldo, con el valor de la entrada SALDO_NUM          
        if RESET = '0' then                         --Si se pulsa el botón de reset, los digitos de los distintos displays no mostrarán nada
            digito3<= "1111111";                    
            digito2<= "1111111";
            digito1<= "1111111";
            digito0<= "1111111";

        elsif rising_edge(CLK) then                 --Si no se ha pulsado reset, con cada flanco positivo de reloj
        
            digito3<= "0000001";                    --Unidades de millar, el dígito3 mostrará un 0 
            digito0<= "0000001";                    --Unidades , el dígito0 mostrará un 0, ya que se ha diseñado pensando en incrementos de múltiplos de 10cent 

                                                    --Centenas
            if(saldo =100)then                      --En el caso de que el saldo tome el valor del precio del producto (pensado para 100 cent)
                digito2 <= "1001111";               --El dígito de las centenas valdrá 1 (pensado para 100 cent)
            else digito2 <= "0000001";              --En caso de que no se alcance el precio del producto el dígito de las centenas valdrá 0 (pensado para 100 cent)
            end if;

     
            case saldo is                           --Decenas, dependiendo del valor del saldo, el dígito de las decenas tomará un valor u otro
                when 100 => digito1 <= "0000001";   
                when 10 => digito1 <= "1001111";
                when 20 => digito1 <= "0010010";
                when 30 => digito1 <= "0000110";
                when 40 => digito1 <= "1001100";
                when 50 => digito1 <= "0100100";
                when 60 => digito1 <= "0100000";
                when 70 => digito1 <= "0001111";
                when 80 => digito1 <= "0000000";
                when 90 => digito1 <= "0000100";
                when others => digito1 <= "0000001";
            end case;

        end if;                                     

    end process;

end Behavioral;
