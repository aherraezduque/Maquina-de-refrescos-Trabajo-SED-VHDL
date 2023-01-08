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
use IEEE.NUMERIC_STD.ALL;

entity tb_monedero is

end tb_monedero;

architecture Behavioral of tb_monedero is
    
    component monedero
        Generic (
        valor_p10C: integer:= 10;
        valor_p20C: integer:= 20;
        valor_p50C: integer:= 50;
        valor_p1_euro: integer:= 100;
        valor_productos: integer:= 100;
        valor_inicio: integer:= 0
        ); 
        Port (
        CLK: in std_logic;              --CLK
        RESET: in std_logic;            --asynchronous active low reset
        p10C: in std_logic;             --botón de 10cent
        p20C: in std_logic;             --botón de 20cent
        p50C: in std_logic;             --botón de 50cent
        p1_euro: in std_logic;          --botón de 1 euro
        saldo_monedero: out integer;    --saldo acumulado en el monedero
        aviso_devolucion: out std_logic --aviso en caso de sobrepasar los 100 cent == 1 euro
        );
        end component;
        
        --SIGNALS 
        signal clk_s: std_logic:= '1';
        constant tbPeriod: time :=10 ns;
        
        signal reset_s : std_logic:= '1';
        signal s_p10c: std_logic := '0';
        signal s_p20c: std_logic := '0';
        signal s_p50c: std_logic := '0';
        signal s_p1_euro: std_logic := '0';
        signal s_saldo_monedero: integer;
        signal s_aviso_devolucion: std_logic:= '0';
         
        TYPE vtest is record 
            reset_vt: std_logic;
            p10c_vt: std_logic;
            p20c_vt: std_logic;
            p50c_vt: std_logic;
            p1_euro_vt: std_logic;
            saldo_monedero_vt: integer;
            aviso_devolucion_vt: std_logic;
        END RECORD;
        
        TYPE vtest_vector IS ARRAY (natural RANGE<>) OF vtest;
        
    constant test: vtest_vector :=(
             (reset_vt=>'1', p10c_vt=>'1', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0', saldo_monedero_vt=>0, aviso_devolucion_vt=>'0'),    --10cent                            1                                                                                        
             (reset_vt=>'1', p10c_vt=>'0', p20c_vt=>'1', p50c_vt=>'0', p1_euro_vt=>'0', saldo_monedero_vt=>10, aviso_devolucion_vt=>'0'),   --30cent                            2
             (reset_vt=>'1', p10c_vt=>'0', p20c_vt=>'0', p50c_vt=>'1', p1_euro_vt=>'0', saldo_monedero_vt=>30, aviso_devolucion_vt=>'0'),   --80cent                            3
             (reset_vt=>'1', p10c_vt=>'1', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0', saldo_monedero_vt=>80, aviso_devolucion_vt=>'0'),   --90cent                            4
             (reset_vt=>'1', p10c_vt=>'1', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0', saldo_monedero_vt=>90, aviso_devolucion_vt=>'0'),   --100cent                           5
             (reset_vt=>'0', p10c_vt=>'0', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0', saldo_monedero_vt=>0, aviso_devolucion_vt=>'0'),    --reset asíncrono                   6
             
             (reset_vt=>'1', p10c_vt=>'1', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0', saldo_monedero_vt=>0, aviso_devolucion_vt=>'0'),    --10cent                            7
             (reset_vt=>'1', p10c_vt=>'0', p20c_vt=>'1', p50c_vt=>'0', p1_euro_vt=>'0', saldo_monedero_vt=>10, aviso_devolucion_vt=>'0'),   --30cent                            8
             (reset_vt=>'1', p10c_vt=>'0', p20c_vt=>'0', p50c_vt=>'1', p1_euro_vt=>'0', saldo_monedero_vt=>30, aviso_devolucion_vt=>'0'),   --80cent                            9
             (reset_vt=>'1', p10c_vt=>'1', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0', saldo_monedero_vt=>80, aviso_devolucion_vt=>'0'),   --90cent                            10
             (reset_vt=>'1', p10c_vt=>'1', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0', saldo_monedero_vt=>90, aviso_devolucion_vt=>'0'),   --100cent                           11
             (reset_vt=>'1', p10c_vt=>'0', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0', saldo_monedero_vt=>100, aviso_devolucion_vt=>'0'),  --100cent espera                    12
             
             (reset_vt=>'1', p10c_vt=>'1', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0', saldo_monedero_vt=>100, aviso_devolucion_vt=>'0'),  --100cent y me paso al pulsar p10c  13
             (reset_vt=>'1', p10c_vt=>'0', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0', saldo_monedero_vt=>0, aviso_devolucion_vt=>'1'),    --ha saltado el aviso               14
             (reset_vt=>'1', p10c_vt=>'0', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'1', saldo_monedero_vt=>0, aviso_devolucion_vt=>'0'),    --1euro                             15
             (reset_vt=>'1', p10c_vt=>'0', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0', saldo_monedero_vt=>100, aviso_devolucion_vt=>'0'),  --saldo 1euro y espero              16
             (reset_vt=>'0', p10c_vt=>'0', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0', saldo_monedero_vt=>0, aviso_devolucion_vt=>'0'),    --reset asíncrono                   17
             (reset_vt=>'1', p10c_vt=>'0', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0', saldo_monedero_vt=>0, aviso_devolucion_vt=>'0'),    --nada                              18
             (reset_vt=>'1', p10c_vt=>'0', p20c_vt=>'1', p50c_vt=>'0', p1_euro_vt=>'0', saldo_monedero_vt=>0, aviso_devolucion_vt=>'0'),    --nada 20cent                       19
             (reset_vt=>'1', p10c_vt=>'0', p20c_vt=>'0', p50c_vt=>'1', p1_euro_vt=>'0', saldo_monedero_vt=>20, aviso_devolucion_vt=>'0'),   --50cent                            20
             (reset_vt=>'1', p10c_vt=>'0', p20c_vt=>'0', p50c_vt=>'0', p1_euro_vt=>'0', saldo_monedero_vt=>70, aviso_devolucion_vt=>'0')    --saldo 70cent y espero             21
             );
             
begin
    uut: monedero
    generic map (
        valor_p10C => 10,
        valor_p20C => 20,
        valor_p50C => 50,
        valor_p1_euro => 100,
        valor_productos => 100,
        valor_inicio => 0 )
    port map (CLK => clk_s,
              RESET => reset_s,
              p10C => s_p10c,          
              p20C => s_p20c, 
              p50C => s_p50c,
              p1_euro => s_p1_euro,
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
        wait for tbPeriod;                                      --Comprobacion de salidas
        assert s_saldo_monedero = test(i).saldo_monedero_vt     --¿es correcto el saldo?
               report "Salida incorrecta -saldo"
               severity FAILURE ;
        assert s_aviso_devolucion = test(i).aviso_devolucion_vt --¿saltó el aviso de devolucion?      
               report "Salida incorrecta -aviso"
               severity FAILURE ;
    end loop;
    
    assert false 
            report "Simulacion finalizada. Test superado."
            severity FAILURE ;
    end process;
end Behavioral;
