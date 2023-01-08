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
      CLK: in std_logic; --clk
      digito3, digito2, digito1, digito0: in std_logic_vector(6 downto 0); --Cada uno de los 4 d�gitos que reflejan el saldo actual, expresados con el formato del display de 7segmentos
      digselector: out std_logic_vector(3 downto 0);                       --Selector del display que est� encendido en cada instante
      segmentos_ilum: out std_logic_vector(6 downto 0)                     --D�gito expresado en el formato del display de 7segmento que se encontrar� activo en el display seleccionado por 
     );                                                                    --digselector 
end MUXED_DISPLAY;

architecture Behavioral of MUXED_DISPLAY is
    constant N: integer:= 18;                                              --Genero la tasa de refresco, en caso de un reloj de 10MHz == 10ns *2^16 = 655,36 us = 1525,88 Hz
                                                                           --cada 655,36 us cambiar� el valor de digslector y por tanto el display activo
    signal q_reg: unsigned(N-1 downto 0):=('0', others=>'0');              --"000000000000000000"  ; Para contar el tiempo utilizo un registro inicializado a 0
    signal sel: std_logic_vector(1 downto 0):= "00";                       --Dependiendo del valor de sel se activar� un display u otro
begin

registr:   process(clk)                                                     --Process destinado a incrementar el valor del registro en cada ciclo de reloj  
   begin                                    
      if (rising_edge(clk)) then                                            --Cada flanco positivo de reloj
        q_reg <= q_reg+1;                                                   --El registro suma 1
      end if;
   end process;

    sel <= std_logic_vector(q_reg(N-1 downto N-2));                         --La se�al sel toma el valor de la posici�n 17 y 16 del registro, al ser un contador de 18 "bits"
                                                                            --que incrementa su valor cada ciclo de reloj, el valor del "bit" en la posici�n 16 se actualiza 
                                                                            --cada periodo del reloj * 2^16; en el caso de la posici�n 17 cada periodo de reloj * 2^17 
                                                                            
seleccion:    process(clk, sel)                                             --Process destinado a cambiar el valor de digselector en funci�n del valor de sel, y a pasar a 
                                                                            --segmentos_ilum el valor del d�gito que debe mostrar    
   begin
      if rising_edge(clk) then                                              --Cada flanco positivo del reloj 
          case sel is                                                       --Dependiendo del valor de sel, digselector tomar� un valor, la secuencia ser� 
                                                                            --digito3 -> digito2 -> digito1 -> digito0 ->digito3 ...
                                                                            
             when "00" =>                                                   --Si sel tiene como valor "00"
                digselector  <= "0111";                                     --El display activo es el display3, millares, por ello en digselector la posici�n 3 toma valor 0
                                                                            --debido a la configuraci�n de las l�neas de control en la nexys 4 DDR                 
                segmentos_ilum <= digito3;                                  --El d�gito que se debe mostrar, por ello segmentos_ilum debe tomar su valor, es el del d�gito3
                
             when "01" =>                                                   --Si sel tiene como valor "01"
                digselector  <= "1011"; --display2 centenas                 --El display activo es el display2, centenas, por ello en digselector la posici�n 2 toma valor 0
                                                                            --debido a la configuraci�n de las l�neas de control en la nexys 4 DDR
                segmentos_ilum <= digito2;                                  --El d�gito que se debe mostrar, por ello segmentos_ilum debe tomar su valor, es el del d�gito2
                
             when "10" =>                                                   --Si sel tiene como valor "10"
                digselector <= "1101"; --display1 decenas                   --El display activo es el display1, decenas, por ello en digselector la posici�n 1 toma valor 0
                                                                            --debido a la configuraci�n de las l�neas de control en la nexys 4 DDR
                segmentos_ilum <= digito1;                                  --El d�gito que se debe mostrar, por ello segmentos_ilum debe tomar su valor, es el del d�gito1   
                     
             when others =>                                                 --Si sel toma el valor "11" o cualquier otro
                digselector <= "1110"; --display0 unidades                  --El display activo es el display0, unidades, por ello en digselector la posici�n 0 toma valor 0
                                                                            --debido a la configuraci�n de las l�neas de control en la nexys 4 DDR             
                segmentos_ilum <= digito0;                                  --El d�gito que se debe mostrar, por ello segmentos_ilum debe tomar su valor, es el del d�gito0   
          end case;
      end if;
   end process;
       
end Behavioral;
