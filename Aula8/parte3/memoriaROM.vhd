library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity memoriaROM is
   generic (
          dataWidth: natural := 12;
          addrWidth: natural := 3
    );
   port (
          Endereco : in std_logic_vector (addrWidth-1 DOWNTO 0);
          Dado : out std_logic_vector (dataWidth-1 DOWNTO 0)
    );
end entity;

architecture assincrona of memoriaROM is

  type blocoMemoria is array(0 TO 2**addrWidth - 1) of std_logic_vector(dataWidth-1 DOWNTO 0);

  function initMemory
        return blocoMemoria is variable tmp : blocoMemoria := (others => (others => '0'));
		  
		  constant NOP  : std_logic_vector(3 downto 0) := "0000";
		  constant LDA  : std_logic_vector(3 downto 0) := "0001";
		  constant SOMA : std_logic_vector(3 downto 0) := "0010";
		  constant SUB  : std_logic_vector(3 downto 0) := "0011";
		  constant LDI  : std_logic_vector(3 downto 0) := "0100";
		  constant STA  : std_logic_vector(3 downto 0) := "0101";
		  constant JMP  : std_logic_vector(3 downto 0) := "0110";
		  constant JEQ  : std_logic_vector(3 downto 0) := "0111";
		  constant CEQ  : std_logic_vector(3 downto 0) := "1000";
		  constant JSR  : std_logic_vector(3 downto 0) := "1001";
		  constant RET  : std_logic_vector(3 downto 0) := "1010";

  begin		  
			
		  -- SetUp	
		  tmp(0)    := LDI  & '0' & x"00";      
		  tmp(1)    := STA  & '0' & x"00";      -- MEN[0] = 0
		  tmp(2)    := STA  & '0' & x"02";      -- MEN[2] = contador
		  tmp(3)    := LDI & '0' & x"01"; 
		  tmp(4)    := STA  & '0' & x"01";      -- MEN[1] = 1 (constante)
		  tmp(5)    := NOP  & '0' & x"00";
		  
		  -- Verifica estado de KEY0
        tmp(6)    := LDA  & '1' & x"60"; 
		  tmp(7)    := STA  & '1' & x"20";      -- Le botao e armazena em HEX0
		  tmp(8)    := CEQ  & '0' & x"00";      -- Verifica se botao foi apertado (Compara com MEM[0])
		  tmp(9)    := JEQ  & '0' & x"0B";      -- Reinicia leitura caso NAO APERTADO
		  tmp(10)   := JSR  & '0' & x"20";      -- Incrementa contadora PRESSIONADO
		  tmp(11)   := NOP  & '0' & x"00";
		  tmp(12)   := JMP  & '0' & x"05";
		  
		  -- ...
		  -- Limpa leitura do botao e incrementa contador
		  tmp(32)   := STA  & '1' & x"FF";      -- Limpa flipflop botao
		  tmp(33)   := LDA  & '0' & x"02";      
		  tmp(34)   := SOMA  & '0' & x"01";
		  tmp(35)   := STA  & '0' & x"02";      -- Incrementa contador
		  tmp(36)   := STA  & '1' & x"02";      -- Armazena bit0 do contador no LEDR9
		  tmp(37)   := STA  & '1' & x"25";      -- Valor do contador em HEX5
		  tmp(38)   := RET  & '0' & x"00";
		  
		return tmp;
    end initMemory;

    signal memROM : blocoMemoria := initMemory;

begin
    Dado <= memROM (to_integer(unsigned(Endereco)));
end architecture;