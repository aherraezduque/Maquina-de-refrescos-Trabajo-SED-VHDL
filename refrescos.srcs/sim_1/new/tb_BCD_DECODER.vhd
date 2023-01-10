----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.01.2023 18:28:51
-- Design Name: 
-- Module Name: tb_BCD_DECODER - Behavioral
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

entity tb_BCD_DECODER is

end tb_BCD_DECODER;

architecture Behavioral of tb_BCD_DECODER is
    component BCD_DECODER is
        --GENERIC(
        --clk_freq    : INTEGER := 100_000_000;   --system clock frequency in Hz
        --stable_time : INTEGER := 5000);         --holding time for aviso_devolucion in ms

        Port (
            CLK: in std_logic;              --CLK
            RESET: in std_logic;            --asynchronous active low reset 
            SALDO_NUM: in integer;          --saldo en el monedero
            AVISO_DEVOLUCION: in std_logic; --aviso en caso de que se pase de 1 euro == 100 cent

            digito3: out std_logic_vector (6 downto 0);--unidades de millar  10 ^3
            digito2: out std_logic_vector (6 downto 0);--centenas            10 ^2   
            digito1: out std_logic_vector (6 downto 0);--decenas             10 ^1
            digito0: out std_logic_vector (6 downto 0)); --unidades          10 ^0    
    end component ;

    --SIGNALS
    signal clk_s: std_logic:= '1';
    constant tbPeriod: time :=1000 ns;
    signal reset_s : std_logic:= '1';
    signal s_saldo_num : integer:=0;
    signal s_aviso_devolucion: std_logic:= '0';
    signal s_digito3: std_logic_vector (6 downto 0);
    signal s_digito2: std_logic_vector (6 downto 0);
    signal s_digito1: std_logic_vector (6 downto 0);
    signal s_digito0: std_logic_vector (6 downto 0);
    
    
    TYPE vtest is record
        reset_vt: std_logic;
        saldo_num_vt: integer;
        aviso_devolucion_vt: std_logic ;
        digito3_vt: std_logic_vector (6 downto 0);
        digito2_vt: std_logic_vector (6 downto 0);
        digito1_vt: std_logic_vector (6 downto 0);
        digito0_vt: std_logic_vector (6 downto 0);
    END RECORD;
    
    TYPE vtest_vector IS ARRAY (natural RANGE<>) OF vtest;
    
     constant test: vtest_vector :=(  
              (reset_vt=>'0', saldo_num_vt=>0, aviso_devolucion_vt=>'0', digito3_vt=>"1111111", digito2_vt=>"1111111", digito1_vt=>"1111111", digito0_vt=>"1111111"),     --RESET, no hace reset del saldo                                                                                                                                      --SALDO
              (reset_vt=>'1', saldo_num_vt=>0,  aviso_devolucion_vt=>'0', digito3_vt=>"0000001", digito2_vt=>"0000001", digito1_vt=>"0000001", digito0_vt=>"0000001"),      --0
              (reset_vt=>'1', saldo_num_vt=>10, aviso_devolucion_vt=>'0', digito3_vt=>"0000001", digito2_vt=>"0000001", digito1_vt=>"1001111", digito0_vt=>"0000001"),      --10
              (reset_vt=>'1', saldo_num_vt=>20, aviso_devolucion_vt=>'0', digito3_vt=>"0000001", digito2_vt=>"0000001", digito1_vt=>"0010010", digito0_vt=>"0000001"),      --20
              (reset_vt=>'1', saldo_num_vt=>30, aviso_devolucion_vt=>'0', digito3_vt=>"0000001", digito2_vt=>"0000001", digito1_vt=>"0000110", digito0_vt=>"0000001"),      --30  
              (reset_vt=>'1', saldo_num_vt=>40, aviso_devolucion_vt=>'0', digito3_vt=>"0000001", digito2_vt=>"0000001", digito1_vt=>"1001100", digito0_vt=>"0000001"),      --40
              (reset_vt=>'1', saldo_num_vt=>50, aviso_devolucion_vt=>'0', digito3_vt=>"0000001", digito2_vt=>"0000001", digito1_vt=>"0100100", digito0_vt=>"0000001"),      --50    
              (reset_vt=>'1', saldo_num_vt=>60, aviso_devolucion_vt=>'0', digito3_vt=>"0000001", digito2_vt=>"0000001", digito1_vt=>"0100000", digito0_vt=>"0000001"),      --60
              (reset_vt=>'1', saldo_num_vt=>70, aviso_devolucion_vt=>'0', digito3_vt=>"0000001", digito2_vt=>"0000001", digito1_vt=>"0001111", digito0_vt=>"0000001"),      --70
              (reset_vt=>'1', saldo_num_vt=>80, aviso_devolucion_vt=>'0', digito3_vt=>"0000001", digito2_vt=>"0000001", digito1_vt=>"0000000", digito0_vt=>"0000001"),      --80
              (reset_vt=>'1', saldo_num_vt=>90, aviso_devolucion_vt=>'0', digito3_vt=>"0000001", digito2_vt=>"0000001", digito1_vt=>"0000100", digito0_vt=>"0000001"),      --90
              (reset_vt=>'1', saldo_num_vt=>100, aviso_devolucion_vt=>'0', digito3_vt=>"0000001", digito2_vt=>"1001111", digito1_vt=>"0000001", digito0_vt=>"0000001"),     --100
              
              (reset_vt=>'0', saldo_num_vt=>100, aviso_devolucion_vt=>'0', digito3_vt=>"1111111", digito2_vt=>"1111111", digito1_vt=>"1111111", digito0_vt=>"1111111"),     --RESET, no hace reset del saldo
              (reset_vt=>'1', saldo_num_vt=>0,  aviso_devolucion_vt=>'0', digito3_vt=>"0000001", digito2_vt=>"0000001", digito1_vt=>"0000001", digito0_vt=>"0000001"),      --0
              (reset_vt=>'1', saldo_num_vt=>20, aviso_devolucion_vt=>'0', digito3_vt=>"0000001", digito2_vt=>"0000001", digito1_vt=>"0010010", digito0_vt=>"0000001"),      --20
              (reset_vt=>'1', saldo_num_vt=>70, aviso_devolucion_vt=>'0', digito3_vt=>"0000001", digito2_vt=>"0000001", digito1_vt=>"0001111", digito0_vt=>"0000001"),      --70
              (reset_vt=>'1', saldo_num_vt=>0,  aviso_devolucion_vt=>'0', digito3_vt=>"0000001", digito2_vt=>"0000001", digito1_vt=>"0000001", digito0_vt=>"0000001"),      --0
              (reset_vt=>'1', saldo_num_vt=>100, aviso_devolucion_vt=>'0', digito3_vt=>"0000001", digito2_vt=>"1001111", digito1_vt=>"0000001", digito0_vt=>"0000001")      --100
              );
begin
    uut: BCD_DECODER 
    port map(CLK => clk_s,
             RESET => reset_s,
             SALDO_NUM => s_saldo_num,
             AVISO_DEVOLUCION => s_aviso_devolucion,

             digito3 => s_digito3,
             digito2 => s_digito2,
             digito1 => s_digito1,
             digito0 => s_digito0);

    --Señal de reloj 
    clk_s <= not clk_s after tbPeriod/2;
    
    stimuli: process
    begin
    
    for i in 0 to (test'high) loop 
        --reset_s <= test(i).reset_vt;
        reset_s <= test(i).reset_vt;
        s_saldo_num  <= test(i).saldo_num_vt;
        s_aviso_devolucion <= test(i).aviso_devolucion_vt;
       
        wait for tbPeriod;                               --Comprobacion de salidas
        
--        assert s_digito3= test(i).digito3_vt --¿es correcto el digito 3?
--               report "Salida incorrecta -Digito 3"
--               severity FAILURE ;
--        assert s_digito2= test(i).digito2_vt --¿es correcto el digito 2?
--               report "Salida incorrecta -Digito 2"
--               severity FAILURE ;      
--       assert s_digito1= test(i).digito1_vt --¿es correcto el digito 1?
--               report "Salida incorrecta -Digito 1"
--               severity FAILURE ;
--        assert s_digito0= test(i).digito0_vt --¿es correcto el digito 0?
--               report "Salida incorrecta -Digito 0"
--               severity FAILURE ;                    
        end loop;  
    
    assert false 
            report "Simulacion finalizada. Test superado."
            severity FAILURE ;
    end process;      
end Behavioral;













