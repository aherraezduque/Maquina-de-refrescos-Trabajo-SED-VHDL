----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.12.2022 16:56:46
-- Design Name: 
-- Module Name: tb_monedero - Behavioral
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

entity tb_monedero is

end tb_monedero;

architecture Behavioral of tb_monedero is
    component monedero 
        Port (
        CLK: in std_logic;              --CLK
        RESET: in std_logic;            --asynchronous active low reset
        p10C: in std_logic;             --boton de 10cent
        p20C: in std_logic;             --boton de 20cent
        p50C: in std_logic;             --boton de 50cent
        p1_euro: in std_logic;          --boton de 1 euro
        producto_adquirido: in std_logic;
        saldo_monedero: out integer;    --saldo acumulado en el monedero
        aviso_devolucion: out std_logic --aviso en caso de sobrepasar los 100 cent == 1 euro
             );
        end component;
        --SIGNALS
        --signal mi_monedero: integer :=0;
        signal clk_s: std_logic:= '1';
        constant tbPeriod: time :=10 ns;
        
        signal reset_s : std_logic;
        signal s_p10c: std_logic := '0';
        signal s_p20c: std_logic := '0';
        signal s_p50c: std_logic := '0';
        signal s_p1_euro: std_logic := '0';
        signal s_producto_adquirido: std_logic := '0';
        signal s_saldo_monedero: integer;
        signal s_aviso_devolucion: std_logic:= '0';
        
    
        TYPE vtest is record 
            reset_vt: std_logic;
            p10c_vt: std_logic;
            p20c_vt: std_logic;
            p50c_vt: std_logic;
            p1_euro_vt: std_logic;
            producto_adquirido: std_logic;
            saldo_monedero_vt: integer;
            aviso_devolucion_vt: std_logic;
        END RECORD;
        
        TYPE vtest_vector IS ARRAY (natural RANGE<>) OF vtest;
        
    constant test: vtest_vector :=(
             (reset_vt=>'1', p10c_vt=>'1', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0',producto_adquirido =>'0', saldo_monedero_vt=>0, aviso_devolucion_vt=>'0'),--10cent        1
             (reset_vt=>'1', p10c_vt=>'0', p20c_vt=>'1', p50c_vt=>'0', p1_euro_vt=>'0',producto_adquirido =>'0', saldo_monedero_vt=>10, aviso_devolucion_vt=>'0'),--30cent       2
             (reset_vt=>'1', p10c_vt=>'0', p20c_vt=>'0', p50c_vt=>'1', p1_euro_vt=>'0',producto_adquirido =>'0', saldo_monedero_vt=>30, aviso_devolucion_vt=>'0'),--80cent       3
             (reset_vt=>'1', p10c_vt=>'1', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0',producto_adquirido =>'0', saldo_monedero_vt=>80, aviso_devolucion_vt=>'0'),--90cent       4
             (reset_vt=>'1', p10c_vt=>'1', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0',producto_adquirido =>'0', saldo_monedero_vt=>90, aviso_devolucion_vt=>'0'),--100cent      5
             (reset_vt=>'0', p10c_vt=>'0', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0',producto_adquirido =>'0', saldo_monedero_vt=>0, aviso_devolucion_vt=>'0'),--reset asincrono   6
             
             (reset_vt=>'1', p10c_vt=>'1', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0',producto_adquirido =>'0', saldo_monedero_vt=>0, aviso_devolucion_vt=>'0'),--10cent    7
             (reset_vt=>'1', p10c_vt=>'0', p20c_vt=>'1', p50c_vt=>'0', p1_euro_vt=>'0',producto_adquirido =>'0', saldo_monedero_vt=>10, aviso_devolucion_vt=>'0'),--30cent   8
             (reset_vt=>'1', p10c_vt=>'0', p20c_vt=>'0', p50c_vt=>'1', p1_euro_vt=>'0',producto_adquirido =>'0', saldo_monedero_vt=>30, aviso_devolucion_vt=>'0'),--80cent   9
             (reset_vt=>'1', p10c_vt=>'1', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0',producto_adquirido =>'0', saldo_monedero_vt=>80, aviso_devolucion_vt=>'0'),--90cent   10
             (reset_vt=>'1', p10c_vt=>'1', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0',producto_adquirido =>'0', saldo_monedero_vt=>90, aviso_devolucion_vt=>'0'),--100cent  11
             (reset_vt=>'1', p10c_vt=>'0', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0',producto_adquirido =>'0', saldo_monedero_vt=>100, aviso_devolucion_vt=>'0'),--100cent espera  12
             
             (reset_vt=>'1', p10c_vt=>'1', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0',producto_adquirido =>'0', saldo_monedero_vt=>100, aviso_devolucion_vt=>'0'),--100cent y me paso al pulsar p10c    13
             (reset_vt=>'1', p10c_vt=>'0', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0',producto_adquirido =>'0', saldo_monedero_vt=>0, aviso_devolucion_vt=>'1'),--ha saltado el aviso   14
             (reset_vt=>'1', p10c_vt=>'0', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0',producto_adquirido =>'0', saldo_monedero_vt=>0, aviso_devolucion_vt=>'0'),--nada   15
             (reset_vt=>'1', p10c_vt=>'0', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'1',producto_adquirido =>'0', saldo_monedero_vt=>0, aviso_devolucion_vt=>'0'), --1euro    16
             (reset_vt=>'1', p10c_vt=>'0', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0',producto_adquirido =>'0', saldo_monedero_vt=>100, aviso_devolucion_vt=>'0'),--nada   17
             (reset_vt=>'0', p10c_vt=>'0', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0',producto_adquirido =>'0', saldo_monedero_vt=>0, aviso_devolucion_vt=>'0'),--reset asincrono   18
             (reset_vt=>'1', p10c_vt=>'0', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0',producto_adquirido =>'0', saldo_monedero_vt=>0, aviso_devolucion_vt=>'0'),--nada  19
             (reset_vt=>'1', p10c_vt=>'0', p20c_vt=>'1', p50c_vt=>'0', p1_euro_vt=>'0',producto_adquirido =>'0', saldo_monedero_vt=>0, aviso_devolucion_vt=>'0'),--nada 20cent   20
             (reset_vt=>'1', p10c_vt=>'0', p20c_vt=>'0', p50c_vt=>'1', p1_euro_vt=>'0',producto_adquirido =>'0', saldo_monedero_vt=>20, aviso_devolucion_vt=>'0'),-- +50cent      21
             (reset_vt=>'1', p10c_vt=>'0', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0',producto_adquirido =>'0', saldo_monedero_vt=>70, aviso_devolucion_vt=>'0'),--nada 70cent  22
             (reset_vt=>'1', p10c_vt=>'0', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0',producto_adquirido =>'1', saldo_monedero_vt=>70, aviso_devolucion_vt=>'0'),--como le llega prod. adquirido=1 el saldo pasa a ser 0 en el sig 23
             (reset_vt=>'1', p10c_vt=>'0', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0',producto_adquirido =>'0', saldo_monedero_vt=>0, aviso_devolucion_vt=>'0')--nada 24
             );
             
begin
    uut: monedero 
    port map (CLK => clk_s,
              RESET => reset_s,
              p10C => s_p10c,          
              p20C => s_p20c, 
              p50C => s_p50c,
              p1_euro => s_p1_euro,
              producto_adquirido => s_producto_adquirido,
              saldo_monedero => s_saldo_monedero,
              aviso_devolucion => s_aviso_devolucion);
              
    --Señal de reloj 
    clk_s <= not clk_s after tbPeriod/2;
    
    stimuli: process
    begin
    
    for i in 0 to (test'high) loop 
        reset_s <= test(i).reset_vt;
        s_p10c <= test(i).p10c_vt;          
        s_p20c <= test(i).p20c_vt;
        s_p50c <= test(i).p50c_vt;
        s_p1_euro <= test(i).p1_euro_vt;
        s_producto_adquirido <= test(i).producto_adquirido;
        wait for tbPeriod;                                  --Comprobacion de salidas
        assert s_saldo_monedero = test(i).saldo_monedero_vt --¿es correcto el saldo?
               report "Salida incorrecta -saldo"
               severity FAILURE ;
        assert s_aviso_devolucion = test(i).aviso_devolucion_vt--¿saltó el aviso de devolucion?      
               report "Salida incorrecta -aviso"
               severity FAILURE ;
    end loop;
    
    assert false 
            report "Simulacion finalizada. Test superado."
            severity FAILURE ;
    end process;
end Behavioral;
