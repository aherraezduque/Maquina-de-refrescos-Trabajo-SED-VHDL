----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.12.2022 12:27:44
-- Design Name: 
-- Module Name: top - Behavioral
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



entity top is
    Port (
        CLK : in std_logic;                                 --CLK   
        RESET: in std_logic;                                --RESET asíncrono activo a nivel bajo
        p10C: in std_logic;                                 --boton de 10cent
        p20C: in std_logic;                                 --boton de 20cent
        p50C: in std_logic;                                 --boton de 50cent
        p1_euro: in std_logic;                              --boton de 1 euro
        p_rearme: in std_logic;                             --boton de rearme  
        SELECTOR: in std_logic_vector (0 TO 3);             --Switch destinado a la elección del producto que se quiere adquirir

        LIGHT : out std_logic_vector(0 TO 3);               --Leds activos cuando se pueden comprar productos
        LED_SALIDA_PRODUCTO: out std_logic;                 --Se enciende cuando sale el producto
        LED_ERROR: out std_logic;                           --Se enciende cuando se ha producido el error
        digselector: out std_logic_vector(3 downto 0);      --Selector del display que está encendido en cada instante
        segmentos_ilum: out std_logic_vector(6 downto 0)    --Dígito expresado en el formato del display de 7segmento que se encontrará activo en el display seleccionado por 
    );                                                     --digselector    
end top;

architecture Estructural of top is

    COMPONENT debounce IS
        GENERIC(
            clk_freq    : INTEGER := 100_000_000;  --system clock frequency in Hz
            stable_time : INTEGER := 10);         --time button must remain stable in ms
        PORT(
            clk     : IN  STD_LOGIC;  --input clock
            reset_n : IN  STD_LOGIC;  --asynchronous active low reset
            button  : IN  STD_LOGIC;  --input signal to be debounced
            result  : OUT STD_LOGIC); --debounced signal
    END COMPONENT;

    COMPONENT SYNCHRNZR is
        PORT (
            CLK : in std_logic;
            ASYNC_IN : in std_logic;
            SYNC_OUT : out std_logic);
    END COMPONENT;

    COMPONENT EDGEDTCTR is
        PORT (
            CLK : in std_logic;
            SYNC_IN : in std_logic;
            EDGE : out std_logic);
    END COMPONENT;

    COMPONENT fsm is
        GENERIC(
            valor_p10C_fsm: integer:= 10;           --valor de la moneda asociada al botón p10C
            valor_p20C_fsm: integer:= 20;           --valor de la moneda asociada al botón p20C
            valor_p50C_fsm: integer:= 50;           --valor de la moneda asociada al botón p50C
            valor_p1_euro_fsm: integer:= 100;       --valor de la moneda asociada al botón p1_euro
            valor_productos_fsm: integer:= 100;     --valor de cada unidad de producto
            valor_inicio_fsm: integer:= 0;          --valor de inicio tras reset o devolución
            numero_de_productos_fsm: natural := 4   --número de opciones de productos que se pueden compar
        );
        PORT (
            CLK : in std_logic;                 --CLK
            RESET: in std_logic;                --reset asíncrono activo a nivel bajo
            p10C: in std_logic;                 --botÓn de 10cent
            p20C: in std_logic;                 --botÓn de 20cent
            p50C: in std_logic;                 --botón de 50cent
            p1_euro: in std_logic;              --botón de 1 euro 
            p_rearme: in std_logic;             --botón de rearme en caso de entrar al estado de devolución
            SELECTOR: in std_logic_vector (0 TO (numero_de_productos_fsm -1));  --Switch destinado a la elección del producto que se quiere adquirir

            LIGHT : out std_logic_vector(0 TO (numero_de_productos_fsm -1));    --Leds activos cuando se pueden comprar productos
            SALDO : out integer ;                                               --Saldo que va a leer el conversor a BCD (saldo acumulado)
            LED_SALIDA_PRODUCTO: out std_logic;                                 --Se enciende cuando sale el producto
            LED_ERROR: out std_logic);                                          --Se enciende cuando se produce el error (ha entrado al estado devolucion)   

    END COMPONENT;

    COMPONENT BCD_DECODER is
        Port (
            CLK: in std_logic;                              --CLK
            RESET: in std_logic;                            --Reset asíncrono activo a nivel bajo
            SALDO_NUM: in integer;                          --Saldo (en el monedero) que debe codificarse
            digito3: out std_logic_vector (6 downto 0);     --Unidades de millar    10 ^3
            digito2: out std_logic_vector (6 downto 0);     --Centenas              10 ^2   
            digito1: out std_logic_vector (6 downto 0);     --Decenas               10 ^1
            digito0: out std_logic_vector (6 downto 0));    --Unidades              10 ^0    
    END COMPONENT;

    COMPONENT MUXED_DISPLAY is
        Port (
            CLK: in std_logic; --clk
            digito3, digito2, digito1, digito0: in std_logic_vector(6 downto 0); --Cada uno de los 4 dígitos que reflejan el saldo actual, expresados con el formato del display de 7segmentos
            digselector: out std_logic_vector(3 downto 0);                       --Selector del display que está encendido en cada instante
            segmentos_ilum: out std_logic_vector(6 downto 0)                     --Dígito expresado en el formato del display de 7segmento que se encontrará activo en el display seleccionado por 
        );                                                                       --digselector 
    END COMPONENT;




    --signals   salida debouncer 
    signal s_result_p10c: std_logic;
    signal s_result_p20c: std_logic;
    signal s_result_p50c: std_logic;
    signal s_result_p1_euro: std_logic;
    signal s_result_p_rearme: std_logic;
    --signals salida synchr
    signal s_sync_out_p10c: std_logic;
    signal s_sync_out_p20c: std_logic;
    signal s_sync_out_p50c: std_logic;
    signal s_sync_out_p1_euro: std_logic;
    signal s_sync_out_p_rearme: std_logic;
    --signals salida edgedetctr
    signal s_edge_out_p10c: std_logic;
    signal s_edge_out_p20c: std_logic;
    signal s_edge_out_p50c: std_logic;
    signal s_edge_out_p1_euro: std_logic;
    signal s_edge_out_p_rearme: std_logic;
    --signals salida fsm
    signal s_fsm_saldo: integer;

    --signals salida BCD DECODER
    signal s_digito3: std_logic_vector (6 downto 0);
    signal s_digito2: std_logic_vector (6 downto 0);
    signal s_digito1: std_logic_vector (6 downto 0);
    signal s_digito0: std_logic_vector (6 downto 0);
begin
    --DEBOUNCERS PARA LOS BOTONES
    Inst_debouncer_p10c: debounce PORT MAP (
            clk => CLK,
            reset_n =>RESET,
            button => p10C,
            result =>s_result_p10c
        );
    Inst_debouncer_p20c: debounce PORT MAP (
            clk => CLK,
            reset_n =>RESET,
            button => p20C,
            result => s_result_p20c
        );
    Inst_debouncer_p50c: debounce PORT MAP (
            clk => CLK,
            reset_n => RESET,
            button => p50C,
            result =>s_result_p50c
        );
    Inst_debouncer_p1_euro: debounce PORT MAP (
            clk => CLK,
            reset_n =>  RESET,
            button =>   p1_euro,
            result =>   s_result_p1_euro
        );
    Inst_debouncer_p_rearme: debounce PORT MAP (
            clk => CLK,
            reset_n =>  RESET,
            button =>   p_rearme ,
            result =>   s_result_p_rearme
        );
    
    --SYNCHRNZR PARA LOS BOTONES
    Inst_synch_p10c: SYNCHRNZR PORT MAP(
            CLK => CLK,
            ASYNC_IN => s_result_p10c,
            SYNC_OUT => s_sync_out_p10c
        );
    Inst_synch_p20c: SYNCHRNZR PORT MAP(
            CLK => CLK,
            ASYNC_IN => s_result_p20c,
            SYNC_OUT => s_sync_out_p20c
        );
    Inst_synch_p50c: SYNCHRNZR PORT MAP(
            CLK => CLK,
            ASYNC_IN => s_result_p50c,
            SYNC_OUT => s_sync_out_p50c
        );
    Inst_synch_p1_euro: SYNCHRNZR PORT MAP(
            CLK => CLK,
            ASYNC_IN => s_result_p1_euro,
            SYNC_OUT => s_sync_out_p1_euro
        );
    Inst_synch_prearme: SYNCHRNZR PORT MAP(
            CLK => CLK,
            ASYNC_IN => s_result_p_rearme ,
            SYNC_OUT => s_sync_out_p_rearme
        );
    
    --EDGEDETCTR PARA LOS BOTONES
    Inst_edge_p10c: EDGEDTCTR PORT MAP(
            CLK => CLK,
            SYNC_IN => s_sync_out_p10c,
            EDGE => s_edge_out_p10c
        );
    Inst_edge_p20c: EDGEDTCTR PORT MAP(
            CLK => CLK,
            SYNC_IN => s_sync_out_p20c,
            EDGE => s_edge_out_p20c
        );
    Inst_edge_p50c: EDGEDTCTR PORT MAP(
            CLK => CLK,
            SYNC_IN => s_sync_out_p50c,
            EDGE => s_edge_out_p50c
        );
    Inst_edge_p1_euro: EDGEDTCTR PORT MAP(
            CLK => CLK,
            SYNC_IN => s_sync_out_p1_euro,
            EDGE => s_edge_out_p1_euro
        );
    Inst_edge_p_rearme: EDGEDTCTR PORT MAP(
            CLK => CLK,
            SYNC_IN => s_sync_out_p_rearme,
            EDGE => s_edge_out_p_rearme
        );

    --FSM
    Inst_fsm : fsm
        GENERIC MAP(
            valor_p10C_fsm => 10,                   --valor de la moneda asociada al botón p10C
            valor_p20C_fsm => 20,                   --valor de la moneda asociada al botón p20C
            valor_p50C_fsm => 50,                   --valor de la moneda asociada al botón p50C
            valor_p1_euro_fsm => 100,               --valor de la moneda asociada al botón p1_euro
            valor_productos_fsm => 100,             --valor de cada unidad de producto
            valor_inicio_fsm => 0,                  --valor de inicio tras reset o devolución
            numero_de_productos_fsm => 4)           --número de opciones de productos que se pueden compar
        PORT MAP(
            CLK => CLK,                                 --CLK
            RESET => RESET,                             --reset asíncrono activo a nivel bajo
            p10C => s_edge_out_p10c,                    --botÓn de 10cent
            p20C => s_edge_out_p20c,                    --botÓn de 20cent
            p50C => s_edge_out_p50c,                    --botón de 50cent
            p1_euro => s_edge_out_p1_euro,              --botón de 1 euro 
            p_rearme => s_edge_out_p_rearme,            --botón de rearme en caso de entrar al estado de devolución
            SELECTOR => SELECTOR,                       --Switch destinado a la elección del producto que se quiere adquirir

            LIGHT => LIGHT,                             --Leds activos cuando se pueden comprar productos
            SALDO => s_fsm_saldo,                       --Saldo que va a leer el conversor a BCD (saldo acumulado)
            LED_SALIDA_PRODUCTO => LED_SALIDA_PRODUCTO, --Se enciende cuando sale el producto
            LED_ERROR => LED_ERROR);                    --Se enciende cuando se produce el error (ha entrado al estado devolucion)                  

    --BCD DECODER
    Inst_bcd_decoder: BCD_DECODER PORT MAP(
            CLK => CLK,                              --CLK
            RESET => RESET,                          --Reset asíncrono activo a nivel bajo
            SALDO_NUM => s_fsm_saldo,                --Saldo (en el monedero) que debe codificarse
            digito3 => s_digito3,                    --Unidades de millar    10 ^3
            digito2 => s_digito2,                    --Centenas              10 ^2   
            digito1 => s_digito1,                    --Decenas               10 ^1
            digito0 => s_digito0 );                  --Unidades              10 ^0               

    -- MUXED DISPLAY    
    Inst_muxed_display: MUXED_DISPLAY PORT MAP (
            CLK => CLK,
            digito3 => s_digito3,
            digito2 => s_digito2,
            digito1 => s_digito1,
            digito0 => s_digito0,
            digselector => digselector,
            segmentos_ilum => segmentos_ilum
        );
        
   
end Estructural;














