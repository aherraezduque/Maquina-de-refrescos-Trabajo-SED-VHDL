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
use IEEE.NUMERIC_STD.ALL;
--Máquina de estados que rige el funcionamiento de la máquina de refrescos.

--La máquina parte del estado <Inicio> donde el saldo es 0. Permanece en dicho estado hasta que se pulsa 
--uno de los botones que incrementan el saldo, pasando al estado <Dinero>.

-- En el estado <Dinero>, el usuario sigue pulsando los distintos botones que incrementan el saldo
-- (el saldo se irá mostrando en los displays de 7 segmentos)
-- hasta que el saldo alcanza el valor del producto,pasando al estado <Un_euro>.

--En el estado <Un_euro> se iluminan los LEDS que identifican los distintos productos que se pueden 
--adquirir. Si el usuario selecciona uno de estos productos (subiendo uno de los switches), pasa al estado 
--<Producto>.
--En el estado <Producto> se apagan los LEDS de los distintos productos y se activa el led de salida de producto.
-- Cuando todos los switches vuelven a estar bajados, se regresa al estado <Inicio>, apagando el led de salida de 
--producto.

--Si se encuentra en el estado <Dinero> o en el estado <Un_euro> y el saldo sobrepasa el valor del producto,
--pasa al estado <Devolucion>, activando el led de error por devolución, y apagándo los LEDs de los productos 
--en el caso de que estuviera en <Un_euro> al producirse la devolución. Se produce la devolución del saldo (saldo =0)
--La máquina de estados permanece en el estado <Devolución> hasta que se pulsa el boton de rearme , o cualquiera
--de los botones asociados a las monedas, regresando al estado <Inicio>
ENTITY fsm is
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
        
END fsm;

ARCHITECTURE behavioral of fsm is

    COMPONENT monedero is 
        Generic (
        valor_p10C: integer:= 10;               --valor de la moneda asociada al botón p10C                
        valor_p20C: integer:= 20;               --valor de la moneda asociada al botón p20C
        valor_p50C: integer:= 50;               --valor de la moneda asociada al botón p50C
        valor_p1_euro: integer:= 100;           --valor de la moneda asociada al botón p1_euro
        valor_productos: integer:= 100;         --valor de cada unidad de producto
        valor_inicio: integer:= 0               --valor de inicio tras reset o devolución
        );
        PORT (
            CLK: in std_logic;                  --CLK
            RESET: in std_logic;                --reset asíncrono activo a nivel bajo
            p10C: in std_logic;                 --botón de 10cent
            p20C: in std_logic;                 --botón de 20cent
            p50C: in std_logic;                 --botón de 50cent
            p1_euro: in std_logic;              --botón de 1 euro
            producto_adquirido: in std_logic;   --Entrada que activa la máquina de estados, si se ha comprado un producto 
            saldo_monedero: out integer;        --saldo acumulado en el monedero
            aviso_devolucion: out std_logic     --aviso en caso de sobrepasar los 100 cent == 1 euro  
        );
    END COMPONENT;        
    
    type STATES is (Inicio, Dinero, Un_euro, Devolucion, Producto); --Cada uno de los distintos estados en los que puede encontrarse la máquina de estados
                                                                    
    constant valor_productos_fsm1 :integer :=valor_productos_fsm;   --Toman los valores que han sido configurados en generic
    constant valor_inicio_fsm1: integer:= valor_inicio_fsm;         --Son necesarias para utilizar estos valores dentro de la condición de sentencias if
    
    signal current_state: STATES := Inicio;                         --Estado actual del fsm, parte del estado <Inicio>        
    signal next_state: STATES:= Inicio;                             --Estado al que va a pasar el fsm, parte del estado <Inicio>     
    signal s_saldo: integer:= valor_inicio_fsm ;                    --Saldo calculado por el componente monedero
    signal s_aviso: std_logic:= '0';                                --Aviso en caso de que el monedero detecte que el saldo ha sobrepasado el valor del producto
    signal producto_adquirido: std_logic:= '0';                     --Aviso que se pasa al monedero, en caso de que se compre un producto
                        
begin
    
    Inst_monedero: monedero
        GENERIC MAP(                                                --Se configura el monedero y sus parámetros generic, con los seleccionados en la entidad fsm
        valor_p10C => valor_p10C_fsm,
        valor_p20C => valor_p20C_fsm,
        valor_p50C => valor_p50C_fsm,
        valor_p1_euro => valor_p1_euro_fsm,
        valor_productos => valor_productos_fsm,
        valor_inicio => valor_inicio_fsm
        )
        PORT MAP(                                                   --Se conectan las respectivas entradas del componente monedero con los de la entidad fsm                                                
            CLK=>CLK,                                              
            RESET=>RESET,
            p10C => p10c, 
            p20C => p20c,
            p50C => p50c,
            p1_euro => p1_euro,
            producto_adquirido=> producto_adquirido,                --Se conecta la entrada del componente monedero con la señal producto_adquirido
            saldo_monedero =>  s_saldo,                             --Se conecta la salida del componenete monedero con la señal s_saldo de la fsm
            aviso_devolucion => s_aviso                             --Se conecta la salida del componente monedero con la señal s_aviso de la fsm
        );

state_register: PROCESS (RESET, CLK)                                --Process destinado a actualizar el estado actual en el que se encuentra la fsm
 begin
      if RESET = '0' then                                           --Si se pulsa reset
      current_state <= Inicio;                                      --El estado actual pasa a ser el estado <Inicio>
    elsif rising_edge(CLK) then                                     --Si no se ha pulsado reset, en cada flanco positivo del reloj
      current_state <= next_state;                                  --El estado actual pasa a tomar el valor del siguiente estado (next_state) determinado por la fsm
    end if;      
 END PROCESS;
 
nextstate_decod: PROCESS (CLK, current_state, SELECTOR )             --Process destinado a actualizar el valor 
        begin
            next_state <= current_state;                    --Por defecto se pasa el valor del estado actual al 
                                                            --siguiente estado en caso de que no se produzcan cambios
            case current_state is                           --DEPENDIENDO DEL ESTADO ACTUAL, el siguiente estado tomar� un valor
                                                            
            when Inicio =>                                  --INICIO TO DINERO
            producto_adquirido <='0';                       --al entrar en inicio producto_adquirido debe tomar el valor 0
            if ((p10C OR p20C OR p50C OR p1_euro) ='1') then --Si se pulsa uno de los botones estanto en Inicio
                next_state <= Dinero;                        --el siguiente estado pasa a ser Dinero
            end if;
            
                                                            --DINERO TO DINERO OR DINERO TO DEVOLUCION OR DINERO TO UN_EURO
            when Dinero =>                            
            if (s_saldo < valor_productos_fsm1) then        --Saldo menor que valor maximo de producto que produce devolucion
                next_state <= Dinero;                       --permanece en Dinero
                
               if (s_aviso ='1')then                        --Si ha saltado el aviso de devolucion conectado al monedero
                next_state <= Devolucion;                   --el siguiente estado pasa a ser Devolucion
                end if;  
                                                            --sigue ingresando monedas
            elsif (s_saldo = valor_productos_fsm1)then      --Si el Saldo = valor maximo de los productos       100                                                       
                next_state <= Un_euro;                      --Va a alcanzar 1 euro en este ciclo, pasa al estado Un_euro
                
            end if;
            
            when Un_euro =>                                 --UN-EURO TO DEVOLUCION OR UN_EURO TO PRODUCTO
            if (s_aviso ='1')then                           --si ha seguido metiendo monedas y se pasa del valor, salta el aviso    
                next_state <= Devolucion;                   --el siguiente estado ser� Devolucion
            elsif( (to_integer(unsigned(SELECTOR)) > 0)) then --Si escoge un producto, recibe PRODUCTO (SELECTOR /= "0000")     
                producto_adquirido<= '1';                     --producto adquirido toma el valor 1                                   
                next_state <= Producto;                     --el siguiente estado pasa a ser Producto
            end if;
                
            when Producto =>                                 --PRODUCTO TO INICIO   
            if( (to_integer(unsigned(SELECTOR)) = 0)) then   --Si se bajan los selectores vuelve a INICIO (SELECTOR = "0000")   
                producto_adquirido<= '1';                    --Se ha adquirido un producto    
                next_state <= Inicio;                        --Regresa a Inicio
            end if;
            
            when Devolucion =>                               --DEVOLUCION TO INICIO
            if ((p10C OR p20C OR p50C OR p1_euro OR p_rearme ) ='1') then-- al pulsar cualquiera de los botones 
                producto_adquirido<= '1';                    --garantiza  0 en el monedero
                next_state <= Inicio;                        -- el proximo estado pasa a ser Inicio
            end if;
            
            when others =>                                   --Se pone por defecto el estado de Inicio   
                next_state <= Inicio;
            end case;
 END PROCESS;
 
output_decod: PROCESS (current_state)                       --Process destinado a actualizar los distintos LEDS que son salidas de la fsm,
                                                            --en función del estado actual, o de si se sube alguno de los switches      
            begin
            if current_state = Un_euro  then                --Si el estado actual es <Un_euro>
                LIGHT <= (others=>'1');                     --Los leds que avisan que los productos pueden ser adquiridos se encienden
                LED_SALIDA_PRODUCTO<= '0';                  --El led que identifica que se ha comprado un producto está apagado
                LED_ERROR <= '0';                           --El led que identifica que se ha producido una devolución está apagado
            end if;
                                                            
            if current_state = Dinero  then                 --Si el estado actual es <Dinero>
                LIGHT <= (others=>'0');                     --Los leds que avisan que los productos pueden ser adquiridos están apagados
                LED_SALIDA_PRODUCTO<= '0';                  --El led que identifica que se ha comprado un producto está apagado
                LED_ERROR <= '0';                           --El led que identifica que se ha producido una devolución está apagado   
            end if;
            
            if current_state = Producto then                --Si estado actual es <Producto>
                LIGHT <= (others=>'0');                     --Los leds que avisan que los productos pueden ser adquiridos están apagados
                LED_SALIDA_PRODUCTO<= '1';                  --El led que identifica que se ha comprado un producto se enciende
                LED_ERROR <= '0';                           --El led que identifica que se ha producido una devolución está apagado          
            end if; 
            
            if current_state = Inicio then                  --Si el estado actual es <Inicio>
                LIGHT <= (others=>'0');                     --Los leds que avisan que los productos pueden ser adquiridos están apagados
                LED_SALIDA_PRODUCTO<= '0';                  --El led que identifica que se ha comprado un producto está apagado
                LED_ERROR <= '0';                           --El led que identifica que se ha producido una devolución está apagado
            end if;  
            
            if current_state = Devolucion then 
                LIGHT <= (others=>'0');                     --Los leds que avisan que los productos pueden ser adquiridos están apagados
                LED_SALIDA_PRODUCTO<= '0';                  --El led que identifica que se ha comprado un producto está apagado
                LED_ERROR <= '1';                           --El led que identifica que se ha producido una devolución se enciende
            end if;   
END PROCESS;
                  
      SALDO <= s_saldo ;                                    --Se pasa el valor de la señal s_saldo a la salida de la fsm SALDO
 
end behavioral;



