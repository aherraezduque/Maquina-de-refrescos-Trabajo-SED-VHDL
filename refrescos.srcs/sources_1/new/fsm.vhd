library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY fsm is
    PORT (
        CLK : in std_logic;
        RESET: in std_logic;            --asynchronous active low reset
        p10C: in std_logic;             --boton de 10cent
        p20C: in std_logic;             --boton de 20cent
        p50C: in std_logic;             --boton de 50cent
        p1_euro: in std_logic;          --boton de 1 euro 
        p_rearme: in std_logic; 
        SELECTOR: in std_logic_vector (0 TO 3);  --switch selector product
        
        LIGHT : out std_logic_vector(0 TO 3);    --Leds activos cuando se pueden comprar productos
        SALDO : out integer ;                    --Saldo que va a leer el conversor a BCD
        AVISO_DEVOLUCION: out std_logic;          --Aviso de devolucion al pasarse de 100cent
        LED_SALIDA_PRODUCTO: out std_logic;       --Se enciende cuando sale el producto
        LED_ERROR: out std_logic);               --Se enciende cuando se produce el error (ha entrado a estado devolucion)   
        
END fsm;

ARCHITECTURE behavioral of fsm is

    COMPONENT monedero is 
        PORT (
            CLK: in std_logic;              --CLK
            RESET: in std_logic;            --asynchronous active low reset
            p10C: in std_logic;             --boton de 10cent
            p20C: in std_logic;             --boton de 20cent
            p50C: in std_logic;             --boton de 50cent
            p1_euro: in std_logic;          --boton de 1 name  
            producto_adquirido: in std_logic; 
            saldo_monedero: out integer;    --saldo acumulado en el monedero
            aviso_devolucion: out std_logic --aviso en caso de sobrepasar los 100 cent == 1 euro  
        );
    END COMPONENT;        
    
    type STATES is (Inicio, Dinero, Un_euro, Devolucion, Producto);
    signal current_state: STATES := Inicio;
    signal next_state: STATES;
    signal s_saldo: integer:= 0;
    signal s_aviso: std_logic;
    signal producto_adquirido: std_logic;
begin

    Inst_monedero: monedero PORT MAP(
            CLK=>CLK,
            RESET=>RESET,
            p10C => p10c, 
            p20C => p20c,
            p50C => p50c,
            p1_euro => p1_euro,
            producto_adquirido=> producto_adquirido,
            saldo_monedero =>  s_saldo,
            aviso_devolucion => s_aviso
        );

state_register: PROCESS (RESET, CLK)
 begin
      if RESET = '0' then
      current_state <= Inicio;
    elsif rising_edge(CLK) then
      current_state <= next_state;
    end if;      
 END PROCESS;
 
nextstate_decod: PROCESS (CLK, SELECTOR, current_state)
        begin
            next_state <= current_state;
            case current_state is
                                                            --INICIO TO DINERO
            when Inicio =>
            producto_adquirido <='0';
            if ((s_saldo =0) AND ((p10C OR p20C OR p50C OR p1_euro) ='1')) then 
                next_state <= Dinero;
            end if;
                                                            --DINERO TO DINERO OR DINERO TO UN_EURO
            when Dinero =>                            
            if (s_saldo < 100) then                         --Saldo menor que 100
                next_state <= Dinero;
                if (s_aviso ='1')then 
                next_state <= Devolucion;
                end if;                                       --sigue ingresando monedas
            elsif (s_saldo = 100)then                          --Saldo = 100                                                       
                next_state <= Un_euro;                      --Va a alcanzar 1 euro en este ciclo
            end if;
            
            when Un_euro =>                                 --UN-EURO TO DEVOLUCION OR UN_EURO TO PRODUCTO
            --if ((p10C OR p20C OR p50C OR p1_euro) ='1') then --Si se pasa de 1 euro, DEVOLUCION
            if (s_aviso ='1')then 
                next_state <= Devolucion;
            end if;                                       
            if (SELECTOR(0)= '1' OR SELECTOR(1)= '1' OR      --Si escoge un producto, recibe PRODUCTO   
               SELECTOR(2)= '1' OR SELECTOR(3)= '1') then
                producto_adquirido<= '1';
                --linea para poner a cero                                         
                next_state <= Producto;
            end if;
                
            when Producto =>                                 --PRODUCTO TO INICIO   
            if(SELECTOR = "0000") then                       --Si se bajan los selectores vuelve a INICIO  
                producto_adquirido<= '1';
                next_state <= Inicio;
            end if;
            when Devolucion =>
            if ((p10C OR p20C OR p50C OR p1_euro OR p_rearme ) ='1') then
                producto_adquirido<= '1';
                next_state <= Inicio;
            end if;
            when others =>
                next_state <= Inicio;
            end case;
 END PROCESS;
 
output_decod: PROCESS (current_state,SELECTOR)
            begin
            if current_state = Un_euro  then
                LIGHT <= "1111";
            end if;
            
            if current_state = Producto then 
                LED_SALIDA_PRODUCTO<= '1';
                LIGHT <= "0000";
            else 
                LED_SALIDA_PRODUCTO<= '0';
            end if; 
            if current_state = Inicio then 
                LED_SALIDA_PRODUCTO<= '0';
                LED_ERROR <= '0';
                LIGHT <= "0000"; 
            end if;  
             if current_state = Devolucion then 
                LED_SALIDA_PRODUCTO<= '0';
                LED_ERROR <= '1';
                LIGHT <= "0000"; 
            end if;   
END PROCESS;
            
            
      SALDO <= s_saldo ;     
      AVISO_DEVOLUCION<= s_aviso;   
end behavioral;




