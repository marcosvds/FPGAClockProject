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
		  tmp(0) := LDI & '0' & x"01";  -- REG_A = 1
		  tmp(1) := STA & '0' & x"00";  
		  tmp(2) := SOMA & '0' & x"00"; -- REG_A = 1
		  tmp(3) := STA & '0' & x"01";  -- MEM[0] = REG_A =  1
        tmp(4) := LDA & '0' & x"00";  -- REG_A = MEM[0] = 1
		  tmp(5) := STA & '1' & x"01";  -- LED[257] = 1          LED8
		  tmp(6) := STA & '1' & x"02";  -- LED[258] = 1          LED9
		  tmp(7) := LDI & '0' & x"55";
		  tmp(8) := STA & '1' & x"00";  -- LED[256] = x'55'      LED0-7
		  tmp(9) := LDI & '0' & x"AA";
		  tmp(10) := STA & '1' & x"00"; -- LED[256] = x'AA'      LED0-7
		  tmp(11) := JMP & '0' & x"0B";
		  
		return tmp;
    end initMemory;

    signal memROM : blocoMemoria := initMemory;

begin
    Dado <= memROM (to_integer(unsigned(Endereco)));
end architecture;