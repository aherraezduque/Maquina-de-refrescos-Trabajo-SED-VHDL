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

--Tiene como finalidad calcular la secuencia de std_logic que se pasar�n a cada 
--uno de los 4 displays de 7 segmentos con los que se va a trabajar

entity BCD_DECODER is
    --GENERIC(
    --clk_freq    : INTEGER := 100_000_000;   --system clock frequency in Hz
    --stable_time : INTEGER := 5000);         --holding time for aviso_devolucion in ms
    
    Port (
    CLK: in std_logic;              --CLK
    RESET: in std_logic;            --asynchronous active low reset 
    SALDO_NUM: in integer;          --saldo en el monedero
    AVISO_DEVOLUCION: in std_logic; --aviso en caso de que se pase de 1 euro == 100 cent
    
    digito3: out std_logic_vector (6 downto 0);--unidades de millar  10 ^3
    digito2: out std_logic_vector (6 downto 0);--centenas            10 ^2   
    digito1: out std_logic_vector (6 downto 0);--decenas             10 ^1
    digito0: out std_logic_vector (6 downto 0)); --unidades            10 ^0    
end BCD_DECODER;

architecture Behavioral of BCD_DECODER is
    --signal aviso_holder: std_logic;
begin    

conversion: process  (CLK,RESET)
       
        variable saldo: integer := SALDO_NUM;
        --Se pueden eliminar estas 4 variables
        variable millares: integer:=0;
        variable centenas: integer:=0;
        variable decenas: integer:=0;
        variable unidades: integer:=0;
        
        --variable count :  INTEGER RANGE 0 TO clk_freq*stable_time/1000;  --counter for timing
        
        begin 
                  --C�lculo de los valores de los distintos pesos                                              
        --millares:= saldo /1000; saldo:= saldo - (millares *1000);
        --centenas:= saldo /100;  saldo := saldo -(centenas *100);
        --decenas:= saldo /10;    saldo := saldo -(decenas *10);
        --unidades:= saldo;
        
        if RESET = '0' then 
            digito3<= "1111111";
            digito2<= "1111111";
            digito1<= "1111111";
            digito0<= "1111111";
            --count := 0;                             --reset del contador
            --aviso_holder<= '0';                     --reset del holder
        elsif rising_edge(CLK) then
             digito3<= "0000001";                     --millares
             digito0<= "0000001";                     --unidades
             
            --if(centenas =1) then                    --centenas
            if(saldo =100)then
                digito2 <= "1001111";
            else digito2 <= "0000001";
            end if;
            
            --case decenas  is
            case saldo is                        --decenas
            --when 0 => digito1 <= "0000001";
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
            --when others => digito1 <= "1111010";
            when others => digito1 <= "0000001";
            end case;
            
--            if AVISO_DEVOLUCION = '1' then          --se�al de aviso devolucion   
--                --aviso_holder <= '1';                --ACTIVACI�N DEL TOKEN
--                digito3<= "1111111";
--                digito2<= "0110000";
--                digito1<= "1111010";
--                digito0<= "1111010";
--            end if;                                 --fin aviso
--            if (aviso_holder ='1') then
--                count := count +1;
--            end if;
            
            
--            if ( aviso_holder ='1' AND (count = clk_freq*stable_time/1000)) then
--                aviso_holder<= '0';                 --se apaga el holder porque ha alcanzado el tiempo que quer�amos mantener las luces de aviso
--                count:=0;  
--            elsif  (aviso_holder ='1' AND (count <clk_freq*stable_time/1000)) then 
--                digito3<= "1111111";
--                digito2<= "0110000";
--                digito1<= "1111010";
--                digito0<= "1111010";
--            end if;                                                                      
        end if;                                     --fin if clk
  
        end process;
        
end Behavioral;
