
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity tb_fsm is
end tb_fsm;

architecture tb of tb_fsm is

    component fsm
        generic(
            valor_p10C_fsm          : integer:= 10;
            valor_p20C_fsm          : integer:= 20;
            valor_p50C_fsm          : integer:= 50;
            valor_p1_euro_fsm       : integer:= 100;
            valor_productos_fsm     : integer:= 100;
            valor_inicio_fsm        : integer:= 0;
            numero_de_productos_fsm : natural := 4);            
        port (CLK                 : in std_logic;
              RESET               : in std_logic;
              p10C                : in std_logic;
              p20C                : in std_logic;
              p50C                : in std_logic;
              p1_euro             : in std_logic;
              p_rearme            : in std_logic;
              SELECTOR            : in std_logic_vector (0 to (numero_de_productos_fsm -1));
              LIGHT               : out std_logic_vector (0 to (numero_de_productos_fsm -1));
              SALDO               : out integer;
              LED_SALIDA_PRODUCTO : out std_logic;
              LED_ERROR           : out std_logic);
    end component;
    
    constant TbPeriod : time := 10 ns; 
    --Constant necesaria para el testbench de entities que usan generic
    --a la hora de generar las señales
    constant numero_de_productos_fsm_const : natural :=4;               --Necesario para signal de SELECTOR y LIGHT
    
    --SIGNALS
    signal CLK                 : std_logic:= '0';
    signal RESET               : std_logic:='1';
    signal p10C                : std_logic:= '0';
    signal p20C                : std_logic:= '0';
    signal p50C                : std_logic:= '0';
    signal p1_euro             : std_logic:= '0';
    signal p_rearme            : std_logic:= '0';
    signal SELECTOR            : std_logic_vector (0 to (numero_de_productos_fsm_const -1)):= (others=>'0');
    signal LIGHT               : std_logic_vector (0 to (numero_de_productos_fsm_const -1)):= (others=>'0');
    signal SALDO               : integer:= 0;
    signal LED_SALIDA_PRODUCTO : std_logic:= '0';
    signal LED_ERROR           : std_logic:= '0';
    
    TYPE vtest is record
        reset_vt               : std_logic;     
        p10C_vt                : std_logic ;
        p20C_vt                : std_logic ;
        p50C_vt                : std_logic ;
        p1_euro_vt             : std_logic ;
        p_rearme_vt            : std_logic ;
        SELECTOR_vt            : std_logic_vector (0 to (numero_de_productos_fsm_const -1));
        LIGHT_vt               : std_logic_vector (0 to (numero_de_productos_fsm_const -1));
        SALDO_vt               : integer ;
        LED_SALIDA_PRODUCTO_vt : std_logic ;
        LED_ERROR_vt           : std_logic ;
    END RECORD;

    TYPE vtest_vector1 IS ARRAY (natural RANGE<>) OF vtest;
    
    constant test: vtest_vector1 := (
        (reset_vt => '1', p10C_vt => '0', p20C_vt => '0', p50C_vt => '0', p1_euro_vt => '0', p_rearme_vt => '0',
            SELECTOR_vt => "0000", LIGHT_vt => "0000", SALDO_vt => 0,  LED_SALIDA_PRODUCTO_vt => '0', LED_ERROR_vt => '0'), 
            
        (reset_vt => '1', p10C_vt => '1', p20C_vt => '0', p50C_vt => '0', p1_euro_vt => '0', p_rearme_vt => '0',                    --10 
             SELECTOR_vt => "0000", LIGHT_vt => "0000", SALDO_vt => 10,  LED_SALIDA_PRODUCTO_vt => '0', LED_ERROR_vt => '0'),
        (reset_vt => '1', p10C_vt => '0', p20C_vt => '1', p50C_vt => '0', p1_euro_vt => '0', p_rearme_vt => '0',                    --30 <Dinero>
             SELECTOR_vt => "0000", LIGHT_vt => "0000", SALDO_vt => 30,  LED_SALIDA_PRODUCTO_vt => '0', LED_ERROR_vt => '0'),
        (reset_vt => '1', p10C_vt => '0', p20C_vt => '0', p50C_vt => '1', p1_euro_vt => '0', p_rearme_vt => '0',                    --80  <Dinero>  
             SELECTOR_vt => "0000", LIGHT_vt => "0000", SALDO_vt => 80,  LED_SALIDA_PRODUCTO_vt => '0', LED_ERROR_vt => '0'),
        (reset_vt => '1', p10C_vt => '0', p20C_vt => '1', p50C_vt => '0', p1_euro_vt => '0', p_rearme_vt => '0',                    --100 <Dinero>
             SELECTOR_vt => "0000", LIGHT_vt => "0000", SALDO_vt => 100,  LED_SALIDA_PRODUCTO_vt => '0', LED_ERROR_vt => '0'),
              
        (reset_vt => '1', p10C_vt => '0', p20C_vt => '0', p50C_vt => '0', p1_euro_vt => '0', p_rearme_vt => '0',                    --100 <Un_euro>
             SELECTOR_vt => "0000", LIGHT_vt => "1111", SALDO_vt => 100,  LED_SALIDA_PRODUCTO_vt => '0', LED_ERROR_vt => '0'), 
        (reset_vt => '1', p10C_vt => '0', p20C_vt => '0', p50C_vt => '0', p1_euro_vt => '0', p_rearme_vt => '0',                    -- al mover switch paso a <Producto>
             SELECTOR_vt => "0100", LIGHT_vt => "0000", SALDO_vt => 0,  LED_SALIDA_PRODUCTO_vt => '1', LED_ERROR_vt => '0'),
        (reset_vt => '1', p10C_vt => '0', p20C_vt => '0', p50C_vt => '0', p1_euro_vt => '0', p_rearme_vt => '0',                    --<Producto>
            SELECTOR_vt => "0100", LIGHT_vt => "0000", SALDO_vt => 0,  LED_SALIDA_PRODUCTO_vt => '1', LED_ERROR_vt => '0'), 
        (reset_vt => '1', p10C_vt => '0', p20C_vt => '0', p50C_vt => '0', p1_euro_vt => '0', p_rearme_vt => '0',                    --como bajo el switch regreso a <Inicio>
            SELECTOR_vt => "0000", LIGHT_vt => "0000", SALDO_vt => 0,  LED_SALIDA_PRODUCTO_vt => '0', LED_ERROR_vt => '0'),
        (reset_vt => '1', p10C_vt => '0', p20C_vt => '0', p50C_vt => '0', p1_euro_vt => '1', p_rearme_vt => '0',                    --Paso de <Inicio> a <Dinero> metiendo 1 euro
            SELECTOR_vt => "0000", LIGHT_vt => "0000", SALDO_vt => 100,  LED_SALIDA_PRODUCTO_vt => '0', LED_ERROR_vt => '0'), 
        (reset_vt => '1', p10C_vt => '0', p20C_vt => '0', p50C_vt => '0', p1_euro_vt => '0', p_rearme_vt => '0',                    --De <Dinero> paso a <Un_euro> 
            SELECTOR_vt => "0000", LIGHT_vt => "0000", SALDO_vt => 100,  LED_SALIDA_PRODUCTO_vt => '0', LED_ERROR_vt => '0'),
        (reset_vt => '1', p10C_vt => '0', p20C_vt => '0', p50C_vt => '0', p1_euro_vt => '1', p_rearme_vt => '0',             --Como estando en <Un_euro> me paso al meter otro euro, el saldo se hace 0
            SELECTOR_vt => "0000", LIGHT_vt => "1111", SALDO_vt => 0,  LED_SALIDA_PRODUCTO_vt => '0', LED_ERROR_vt => '0'),         --Como estoy en <Un_euro> LIGHT se enciende   
        (reset_vt => '1', p10C_vt => '0', p20C_vt => '0', p50C_vt => '0', p1_euro_vt => '0', p_rearme_vt => '0',                    --He entrado en <Devolucion>
            SELECTOR_vt => "0000", LIGHT_vt => "0000", SALDO_vt => 0,  LED_SALIDA_PRODUCTO_vt => '0', LED_ERROR_vt => '1'),         --Se me enciende led error 
        (reset_vt => '1', p10C_vt => '0', p20C_vt => '0', p50C_vt => '0', p1_euro_vt => '0', p_rearme_vt => '0',                    --Sigo en <Devolucion> 
            SELECTOR_vt => "0000", LIGHT_vt => "0000", SALDO_vt => 0,  LED_SALIDA_PRODUCTO_vt => '0', LED_ERROR_vt => '1'),
        (reset_vt => '1', p10C_vt => '0', p20C_vt => '0', p50C_vt => '0', p1_euro_vt => '0', p_rearme_vt => '1',                    --Sigo en <Devolucion y pulso rearme
            SELECTOR_vt => "0000", LIGHT_vt => "0000", SALDO_vt => 0,  LED_SALIDA_PRODUCTO_vt => '0', LED_ERROR_vt => '1'),         --el led de error sigue
        (reset_vt => '1', p10C_vt => '0', p20C_vt => '0', p50C_vt => '0', p1_euro_vt => '0', p_rearme_vt => '0',                    --He regresado a <Inicio> 
            SELECTOR_vt => "0000", LIGHT_vt => "0000", SALDO_vt => 0,  LED_SALIDA_PRODUCTO_vt => '0', LED_ERROR_vt => '0'),         --Led error apagado
        (reset_vt => '1', p10C_vt => '0', p20C_vt => '0', p50C_vt => '1', p1_euro_vt => '0', p_rearme_vt => '0',                    --Paso de <Inicio> a dinero metiendo 50cent
            SELECTOR_vt => "0000", LIGHT_vt => "0000", SALDO_vt => 50,  LED_SALIDA_PRODUCTO_vt => '0', LED_ERROR_vt => '0'),
        (reset_vt => '1', p10C_vt => '0', p20C_vt => '0', p50C_vt => '1', p1_euro_vt => '0', p_rearme_vt => '0',                    --Paso de <Dinero> a <Un_euro> ya que vuelvo a meter 50cent
            SELECTOR_vt => "0000", LIGHT_vt => "0000", SALDO_vt => 100,  LED_SALIDA_PRODUCTO_vt => '0', LED_ERROR_vt => '0'),          
        (reset_vt => '1', p10C_vt => '0', p20C_vt => '0', p50C_vt => '0', p1_euro_vt => '0', p_rearme_vt => '0',                    --Sigo en <Un_euro>
            SELECTOR_vt => "0000", LIGHT_vt => "1111", SALDO_vt => 100,  LED_SALIDA_PRODUCTO_vt => '0', LED_ERROR_vt => '0'),       --y Se encienden LIGHT
        (reset_vt => '1', p10C_vt => '0', p20C_vt => '0', p50C_vt => '0', p1_euro_vt => '0', p_rearme_vt => '0',                    --Paso de <Un_euro> a <Producto>
            SELECTOR_vt => "0001", LIGHT_vt => "0000", SALDO_vt => 0,  LED_SALIDA_PRODUCTO_vt => '1', LED_ERROR_vt => '0'),         --al subir un switch, LIGHT apagadas , LED SALIDA PRODUCTO on 
        (reset_vt => '1', p10C_vt => '0', p20C_vt => '0', p50C_vt => '0', p1_euro_vt => '0', p_rearme_vt => '0',                    --Sigo en <Producto> 
            SELECTOR_vt => "0001", LIGHT_vt => "0000", SALDO_vt => 0,  LED_SALIDA_PRODUCTO_vt => '1', LED_ERROR_vt => '0'),
        (reset_vt => '1', p10C_vt => '0', p20C_vt => '0', p50C_vt => '0', p1_euro_vt => '0', p_rearme_vt => '0',                    --Paso de <Producto> a <Inicio>
            SELECTOR_vt => "0000", LIGHT_vt => "0000", SALDO_vt => 0,  LED_SALIDA_PRODUCTO_vt => '0', LED_ERROR_vt => '0'),         --Al bajar selector, se apaga LED SALIDA PRODUCTO
        (reset_vt => '1', p10C_vt => '0', p20C_vt => '0', p50C_vt => '0', p1_euro_vt => '0', p_rearme_vt => '0',                    --Sigo en <Inicio>
            SELECTOR_vt => "0000", LIGHT_vt => "0000", SALDO_vt => 0,  LED_SALIDA_PRODUCTO_vt => '0', LED_ERROR_vt => '0'), 
        (reset_vt => '1', p10C_vt => '0', p20C_vt => '0', p50C_vt => '1', p1_euro_vt => '0', p_rearme_vt => '0',                    --Paso de <Inicio> a <Dinero> al meter 50cent
            SELECTOR_vt => "0000", LIGHT_vt => "0000", SALDO_vt => 50,  LED_SALIDA_PRODUCTO_vt => '0', LED_ERROR_vt => '0'),        --El saldo pasa a ser 50cent
        (reset_vt => '1', p10C_vt => '0', p20C_vt => '0', p50C_vt => '1', p1_euro_vt => '0', p_rearme_vt => '0',                    --Pasa de <Dinero> a <Un_euro>
            SELECTOR_vt => "0000", LIGHT_vt => "0000", SALDO_vt => 100,  LED_SALIDA_PRODUCTO_vt => '0', LED_ERROR_vt => '0'),       --saldo 100cent
        (reset_vt => '1', p10C_vt => '0', p20C_vt => '0', p50C_vt => '0', p1_euro_vt => '0', p_rearme_vt => '0',                    --Está en <Un_euro>
            SELECTOR_vt => "0000", LIGHT_vt => "1111", SALDO_vt => 100,  LED_SALIDA_PRODUCTO_vt => '0', LED_ERROR_vt => '0'),       --LIGHT se encienden
        (reset_vt => '0', p10C_vt => '0', p20C_vt => '0', p50C_vt => '0', p1_euro_vt => '0', p_rearme_vt => '0',                    --Se pulsa el botón de reset
            SELECTOR_vt => "0000", LIGHT_vt => "0000", SALDO_vt => 0,  LED_SALIDA_PRODUCTO_vt => '0', LED_ERROR_vt => '0'),         --El saldo pasa a ser 0 y regresa a <Inicio>
        (reset_vt => '1', p10C_vt => '0', p20C_vt => '1', p50C_vt => '0', p1_euro_vt => '0', p_rearme_vt => '0',                    --Estando en <Inicio> se pulsa 20cent y pasa a <Dinero>
            SELECTOR_vt => "0000", LIGHT_vt => "0000", SALDO_vt => 20,  LED_SALIDA_PRODUCTO_vt => '0', LED_ERROR_vt => '0')         --saldo 20 cent
                                                       
    );
    
begin
    
    
    uut : fsm
    generic map (
            valor_p10C_fsm =>10,
            valor_p20C_fsm =>20,
            valor_p50C_fsm =>50,
            valor_p1_euro_fsm => 100,
            valor_productos_fsm => 100,
            valor_inicio_fsm => 0,
            numero_de_productos_fsm => 4)
    port map (CLK                 => CLK,
              RESET               => RESET,
              p10C                => p10C,
              p20C                => p20C,
              p50C                => p50C,
              p1_euro             => p1_euro,
              p_rearme            => p_rearme,
              SELECTOR            => SELECTOR,
              LIGHT               => LIGHT,
              SALDO               => SALDO,
              LED_SALIDA_PRODUCTO => LED_SALIDA_PRODUCTO,
              LED_ERROR           => LED_ERROR);

    -- Clock generation
    CLK <= not CLK after TbPeriod/2;

    stimuli : process
    begin
    
    for i in 0 to (test'high) loop 
        --reset_s <= test(i).reset_vt;
        RESET<= test(i).reset_vt;
        p10C<= test(i).p10C_vt;
        p20C<= test(i).p20C_vt;
        p50C<= test(i).p50C_vt;
        p1_euro<= test(i).p1_euro_vt;
        p_rearme<= test(i).p_rearme_vt;
        SELECTOR<= test(i).SELECTOR_vt;
       
        wait for (TbPeriod);                               --Comprobacion de salidas
        
        assert LIGHT = test(i).LIGHT_vt  --¿es correcto LUGHT?
            report "Salida incorrecta -LIGHT"
            severity FAILURE ;
        assert SALDO= test(i).SALDO_vt  --¿es correcto el SALDO?
            report "Salida incorrecta -SALDO"
            severity FAILURE ;    
        assert LED_SALIDA_PRODUCTO= test(i).LED_SALIDA_PRODUCTO_vt --¿es correcto el LED_SALIDA_PRODUCTO?
            report "Salida incorrecta -LED_SALIDA_PRODUCTO"
            severity FAILURE ;
        assert LED_ERROR= test(i).LED_ERROR_vt --¿es correcto el LED_ERROR?
            report "Salida incorrecta -LED_ERROR"
            severity FAILURE ;         
        end loop;  
         
    assert false 
            report "Simulacion finalizada. Test superado."
            severity FAILURE ;    

    end process;

end tb;