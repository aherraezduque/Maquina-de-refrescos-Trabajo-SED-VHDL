
library ieee;
use ieee.std_logic_1164.all;

entity tb_MUXED_DISPLAY is
end tb_MUXED_DISPLAY;

architecture tb of tb_MUXED_DISPLAY is

    component MUXED_DISPLAY
        port (CLK            : in  std_logic;
              digito3        : in  std_logic_vector (6 downto 0);
              digito2        : in  std_logic_vector (6 downto 0);
              digito1        : in  std_logic_vector (6 downto 0);
              digito0        : in  std_logic_vector (6 downto 0);
              digselector    : out std_logic_vector (3 downto 0);
              segmentos_ilum : out std_logic_vector (6 downto 0));
    end component;

    signal CLK            : std_logic:= '0';
    signal s_digito3        : std_logic_vector (6 downto 0);
    signal s_digito2        : std_logic_vector (6 downto 0);
    signal s_digito1        : std_logic_vector (6 downto 0);
    signal s_digito0        : std_logic_vector (6 downto 0);
    signal s_digselector    : std_logic_vector (3 downto 0);
    signal s_segmentos_ilum : std_logic_vector (6 downto 0);

    constant TbPeriod : time := 10 ns; -- EDIT Put right period here
    
    TYPE vtest is record
        digito3_vt        : std_logic_vector (6 downto 0);
        digito2_vt        : std_logic_vector (6 downto 0);
        digito1_vt        : std_logic_vector (6 downto 0);
        digito0_vt        : std_logic_vector (6 downto 0);
        digselector_vt    : std_logic_vector (3 downto 0);
        segmentos_ilum_vt : std_logic_vector (6 downto 0);
    END RECORD;

    TYPE vtest_vector IS ARRAY (natural RANGE<>) OF vtest;
    
    constant test: vtest_vector :=(                                                                                                                                        --SALDO   digito
              ( digito3_vt=>"0000001", digito2_vt=>"0000001", digito1_vt=>"1001111", digito0_vt=>"0000001", digselector_vt=>"0111", segmentos_ilum_vt =>"0000001" ),      --10      --3          
              ( digito3_vt=>"0000001", digito2_vt=>"0000001", digito1_vt=>"1001111", digito0_vt=>"0000001", digselector_vt=>"1011", segmentos_ilum_vt =>"0000001" ),      --10      --2
              ( digito3_vt=>"0000001", digito2_vt=>"0000001", digito1_vt=>"1001111", digito0_vt=>"0000001", digselector_vt=>"1101", segmentos_ilum_vt =>"1001111" ),      --10      --1   
              ( digito3_vt=>"0000001", digito2_vt=>"0000001", digito1_vt=>"1001111", digito0_vt=>"0000001", digselector_vt=>"1110", segmentos_ilum_vt =>"0000001" ),      --10      --0
              ( digito3_vt=>"0000001", digito2_vt=>"1001111", digito1_vt=>"0000001", digito0_vt=>"0000001", digselector_vt=>"0111", segmentos_ilum_vt =>"0000001" ),      --100     --3 
              ( digito3_vt=>"0000001", digito2_vt=>"1001111", digito1_vt=>"0000001", digito0_vt=>"0000001", digselector_vt=>"1011", segmentos_ilum_vt =>"1001111" ),      --100     --2
              ( digito3_vt=>"0000001", digito2_vt=>"1001111", digito1_vt=>"0000001", digito0_vt=>"0000001", digselector_vt=>"1101", segmentos_ilum_vt =>"0000001" ),      --100     --1 
              ( digito3_vt=>"0000001", digito2_vt=>"1001111", digito1_vt=>"0000001", digito0_vt=>"0000001", digselector_vt=>"1110", segmentos_ilum_vt =>"0000001" )       --100     --0
              );
    constant tasa_refresco: time := 10ns * 2**16;        --Cuando se producirán cambios
begin

    dut : MUXED_DISPLAY
    port map (CLK            => CLK,
              digito3        => s_digito3,
              digito2        => s_digito2,
              digito1        => s_digito1,
              digito0        => s_digito0,
              digselector    => s_digselector,
              segmentos_ilum => s_segmentos_ilum);


   CLK <= not CLK after tbPeriod/2;
    

stimuli: process
    begin
    
    for i in 0 to (test'high) loop 
        --reset_s <= test(i).reset_vt;
        s_digito0<= test(i).digito0_vt;
        s_digito1<= test(i).digito1_vt;
        s_digito2<= test(i).digito2_vt;
        s_digito3<= test(i).digito3_vt;
       --wait for (TbPeriod);
       
        wait for (tasa_refresco );                               --Comprobacion de salidas
        
--        assert s_digselector= test(i).digselector_vt --¿es correcto el digselector?
--            report "Salida incorrecta -Digselector"
--            severity FAILURE ;
                 
        end loop;  
    
    assert false 
            report "Simulacion finalizada. Test superado."
            severity FAILURE ;
    end process;      

end tb;