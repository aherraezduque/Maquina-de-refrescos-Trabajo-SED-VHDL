----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.12.2022 15:52:02
-- Design Name: 
-- Module Name: monedero - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity monedero is
    Port (
    CLK: in std_logic;              --CLK
    RESET: in std_logic;            --asynchronous active low reset
    p10C: in std_logic;             --boton de 10cent
    p20C: in std_logic;             --boton de 20cent
    p50C: in std_logic;             --boton de 50cent
    p1_euro: in std_logic;          --boton de 1 euro
    producto_adquirido: in std_logic;
    saldo_monedero: out integer:=0;    --saldo acumulado en el monedero
    aviso_devolucion: out std_logic:='0' --aviso en caso de sobrepasar los 100 cent == 1 euro
    );
end monedero;

architecture Behavioral of monedero is
    --signal mi_monedero: integer :=0;
    
begin
    
coins: PROCESS (CLK, RESET)
    variable mi_monedero: integer :=0;
    
    begin
        --aviso_devolucion <= '0';
        
        if RESET = '0' then
            --mi_monedero <= 0;
            mi_monedero := 0;
        elsif rising_edge(CLK) then 
            if (p10C = '1') then 
                --mi_monedero <= mi_monedero +10;
                mi_monedero := mi_monedero +10;
            end if;
            if (p20C = '1') then
                --mi_monedero <= mi_monedero +20;
                mi_monedero := mi_monedero +20;
            end if;
            if (p50C = '1') then 
                --mi_monedero <= mi_monedero +50;
                mi_monedero := mi_monedero +50;
            end if;
            if (p1_euro = '1') then 
                --mi_monedero <= mi_monedero +100;
                mi_monedero := mi_monedero +100;
            end if;
            if(producto_adquirido = '1')then
                mi_monedero := 0;
            end if;
            if (mi_monedero > 100) then          --Si te pasas de 1 euro
                    --mi_monedero <= 0;               --Se vacia mi_monedero
                     aviso_devolucion <= '1';
                     mi_monedero := 0;
                     
            else        
                    aviso_devolucion <= '0';
            end if;
        end if;

       saldo_monedero <= mi_monedero;
       
END PROCESS;
               
            
end Behavioral;


















