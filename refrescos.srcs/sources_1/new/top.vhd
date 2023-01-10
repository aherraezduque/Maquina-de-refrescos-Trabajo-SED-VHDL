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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    Port (
        CLK : in std_logic;
        RESET: in std_logic;                     --asynchronous active low reset
        p10C: in std_logic;                      --boton de 10cent
        p20C: in std_logic;                      --boton de 20cent
        p50C: in std_logic;                      --boton de 50cent
        p1_euro: in std_logic;                   --boton de 1 euro
        p_rearme: in std_logic;                  --boton de rearme  
        SELECTOR: in std_logic_vector (0 TO 3);  --switch selector product
        
        LIGHT : out std_logic_vector(0 TO 3);     --Leds activos cuando se pueden comprar productos
        LED_SALIDA_PRODUCTO: out std_logic;        --Se enciende cuando sale el producto
        LED_ERROR: out std_logic;                   --SE enciende cuando se ha producido el error
        digselector: out std_logic_vector(3 downto 0); --digit selector 
        segmentos_ilum: out std_logic_vector(6 downto 0) --7 segments output, to show in the digit selected by "an"
     );
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
        LED_SALIDA_PRODUCTO: out std_logic;      --Se enciende cuando sale el producto
        LED_ERROR: out std_logic);               --Se enciende cuando se produce el error (ha entrado a estado devolucion)        
    END COMPONENT;
    
    COMPONENT BCD_DECODER is
    --GENERIC(
    --clk_freq    : INTEGER := 100_000_000;   --system clock frequency in Hz
    --stable_time : INTEGER := 2000);         --holding time for aviso_devolucion in ms
    
    PORT (
        CLK: in std_logic;              --CLK
        RESET: in std_logic;            --asynchronous active low reset 
        SALDO_NUM: in integer;          --saldo en el monedero
        AVISO_DEVOLUCION: in std_logic; --aviso en caso de que se pase de 1 euro == 100 cent
    
        digito3: out std_logic_vector (6 downto 0);--unidades de millar  10 ^3
        digito2: out std_logic_vector (6 downto 0);--centenas            10 ^2   
        digito1: out std_logic_vector (6 downto 0);--decenas             10 ^1
        digito0: out std_logic_vector (6 downto 0)); --unidades            10 ^0    
    end COMPONENT;

    COMPONENT MUXED_DISPLAY is
    PORT (
      CLK: in std_logic; --clk, needed for synchronization
      --in3, in2, in1, in0: in std_logic_vector(6 downto 0); --7 segment inputs for each digit
      digito3, digito2, digito1, digito0: in std_logic_vector(6 downto 0); --7 segment inputs for each digit
      --an: out std_logic_vector(3 downto 0); --digit selector
      digselector: out std_logic_vector(3 downto 0); --digit selector
      segmentos_ilum: out std_logic_vector(6 downto 0)); --7 segments output, to show in the digit selected by "an"    
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
    signal s_aviso_devolucion: std_logic;
    
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
Inst_fsm: fsm PORT MAP (
        CLK => CLK,
        RESET => RESET,
        p10C => s_edge_out_p10c,
        p20C => s_edge_out_p20c,
        p50C => s_edge_out_p50c,
        p1_euro => s_edge_out_p1_euro,
        p_rearme => s_edge_out_p_rearme,
        SELECTOR => SELECTOR,
        
        LIGHT => LIGHT,
        SALDO => s_fsm_saldo,
        AVISO_DEVOLUCION => s_aviso_devolucion,
        LED_SALIDA_PRODUCTO => LED_SALIDA_PRODUCTO,
        LED_ERROR => LED_ERROR        
    );
            
            --BCD DECODER
Inst_bcd_decoder:  BCD_DECODER PORT MAP(
    CLK => CLK,
    RESET => RESET,
    SALDO_NUM => s_fsm_saldo,
    AVISO_DEVOLUCION => s_aviso_devolucion,
    
    digito3 => s_digito3,
    digito2 => s_digito2,
    digito1 => s_digito1,
    digito0 => s_digito0
    ); 
    
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














