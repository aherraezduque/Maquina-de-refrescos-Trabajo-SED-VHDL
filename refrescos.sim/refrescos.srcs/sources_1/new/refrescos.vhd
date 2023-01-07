----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.12.2022 13:12:58
-- Design Name: 
-- Module Name: refrescos - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity refrescos is
      Port (
        CLK : in std_logic;
        RESET: in std_logic;            --asynchronous active low reset
        p10C: in std_logic;             --boton de 10cent
        p20C: in std_logic;             --boton de 20cent
        p50C: in std_logic;             --boton de 50cent
        p1_euro: in std_logic;          --boton de 1 euro  
        SELECTOR: in std_logic_vector (0 TO 3);  --switch selector product
        
        LIGHT : out std_logic_vector(0 TO 3);    --Leds activos cuando se pueden comprar productos
        SALDO : out integer ;                    --Saldo que va a leer el conversor a BCD
        AVISO_DEVOLUCION: out std_logic;          --Aviso de devolucion al pasarse de 100cent
        LED_SALIDA_PRODUCTO: out std_logic       --Se enciende cuando sale el producto     
      );
end refrescos;

architecture Estructural of refrescos is

begin


end Estructural;
