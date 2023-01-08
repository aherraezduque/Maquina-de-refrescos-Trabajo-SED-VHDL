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

entity monedero is
    Generic (
        valor_p10C: integer:= 10;               --valor de la moneda asociada al botón p10C
        valor_p20C: integer:= 20;               --valor de la moneda asociada al botón p20C
        valor_p50C: integer:= 50;               --valor de la moneda asociada al botón p50C
        valor_p1_euro: integer:= 100;           --valor de la moneda asociada al botón p1_euro
        valor_productos: integer:= 100;         --valor de cada unidad de producto
        valor_inicio: integer:= 0               --valor de inicio tras reset o devolución
    );
    Port (
        CLK: in std_logic;                      --CLK
        RESET: in std_logic;                    --reset asíncrono activo a nivel bajo
        p10C: in std_logic;                     --botón de 10cent
        p20C: in std_logic;                     --botón de 20cent
        p50C: in std_logic;                     --botón de 50cent
        p1_euro: in std_logic;                  --botón de 1 euro
        producto_adquirido: in std_logic:='0';  --Entrada que activa la máquina de estados, si se ha comprado un producto 
        saldo_monedero: out integer:=0;         --saldo acumulado en el monedero
        aviso_devolucion: out std_logic:='0'    --aviso en caso de sobrepasar los 100 cent == 1 euro
    );
end monedero;

architecture Behavioral of monedero is

begin
   
    coins: PROCESS (CLK, RESET)
    
        variable mi_monedero: integer :=0;                  --Saldo del monedero

    begin

        if RESET = '0' then                                 --Si se pulsa el reset
            mi_monedero := valor_inicio;                    --El monedero toma el valor de inicio, se vacía
            aviso_devolucion<='0';                          --La salida aviso_devolucion no está activa            
        elsif rising_edge(CLK) then                         --Si no ha habido reset, con cada flanco de subida del CLK
            if (p10C = '1') then                            --y si se pulsa el bóton p10c 
                mi_monedero := mi_monedero + valor_p10C ;   --el saldo del monedero aumenta el valor_p10c, 10cent por defecto 
            end if;
            if (p20C = '1') then                            --y si se pulsa el bóton p20c 
                mi_monedero := mi_monedero +valor_p20C;     --el saldo del monedero aumenta el valor_p20c, 20cent por defecto 
            end if;
            if (p50C = '1') then                            --y si se pulsa el bóton p50c 
                mi_monedero := mi_monedero +valor_p50C;     --el saldo del monedero aumenta el valor_p50c, 50cent por defecto 
            end if;
            if (p1_euro = '1') then                         --y si se pulsa el bóton p1_euro
                mi_monedero := mi_monedero +valor_p1_euro;  --el saldo del monedero aumenta el valor_p1_euro, 100cent por defecto 
            end if;
            if(producto_adquirido = '1')then                --si se ha comprado un producto, la entrada de producto_adquirido estará activa
                mi_monedero := valor_inicio;                --el saldo del monedero toma el valor de inicio, se vacía
            end if;
            if (mi_monedero > valor_productos) then          --Si te pasas de 1 euro                      
                aviso_devolucion <= '1';                     --Se activa la salida de aviso_devolución
                mi_monedero := valor_inicio;                 --y el saldo del monedero toma el valor de inicio, se vacía 
            else                                             --Si el saldo del monedero es inferior al valor_productos 
                aviso_devolucion <= '0';                     --La salida aviso_devolucion se encuentra desactiva                      
            end if;
        end if;

        saldo_monedero <= mi_monedero;                       --Se pasa el valor de la variable mi_monedero a la salida saldo_monedero

    END PROCESS;


end Behavioral;



















