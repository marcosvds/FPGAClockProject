library ieee;
use ieee.std_logic_1164.all;

entity Aula7 is
  -- Total de bits das entradas e saidas
  generic ( 
		  
		  larguraDadosROM : natural := 13;
		  larguraEnderecosROM : natural := 9;
		  
		  larguraDadosRAM : natural := 8;
        larguraEnderecosRAM : natural := 6;
		  
        simulacao : boolean := FALSE                              -- para gravar na placa, altere de TRUE para FALSE
  );
  port(
	 CLOCK_50 : in std_logic;
    KEY: in std_logic_vector(3 downto 0);
	 LEDR: out std_logic_vector(9 downto 0);
	 --INSTRUCTION: out std_logic_vector(larguraDadosROM-1 downto 0);
	 --BLOCO_DECODER: out std_logic_vector(7 downto 0);
	 --ENDERECO_DECODER: out std_logic_vector(7 downto 0);
	 -- DATA_ADDR : out std_logic_vector(8 downto 0);
	 -- BLOCO1 :  out std_logic;
	 -- BLOCO4 :  out std_logic;
	 PC_OUT: out std_logic_vector(larguraEnderecosROM-1 downto 0)
  );
  
end entity;


architecture arquitetura of Aula7 is

	-- I/O RAM e ROM , I/O CPU
	signal data_RAM_OUT: std_logic_vector(larguraDadosRAM-1 downto 0);
	signal instrucao_ROM : std_logic_vector(larguraDadosROM-1 downto 0);
	
	signal CLK: std_logic;
	signal data_out: std_logic_vector(larguraDadosRAM-1 downto 0);
	signal prox_ROM_address: std_logic_vector(larguraEnderecosROM-1 downto 0);
	signal data_Address: std_logic_vector(8 downto 0);
	signal control: std_logic_vector(1 downto 0);
	
	-- Decodificador de Blocos e Endereços
	signal decoder_bloco_out : std_logic_vector(7 downto 0);
	signal decoder_endereco_out : std_logic_vector(7 downto 0);
	signal hab_bloco_0 : std_logic; 
	signal hab_bloco_4 : std_logic; 
	
	-- Regstradores dos LEDS:
	signal hab_reg_LEDR : std_logic; 
	signal hab_ff_LED8 : std_logic; 
	signal hab_ff_LED9 : std_logic; 
	
	signal leds: std_logic_vector(7 downto 0);
	signal led8: std_logic;
	signal led9: std_logic;
	
begin
	
------------ Edge Detector  ------------
gravar:  if simulacao generate
CLK <= KEY(0);
else generate
detectorSub0: work.edgeDetector(bordaSubida)
        port map (clk => CLOCK_50, entrada => (not KEY(0)), saida => CLK);
end generate;
	
------------ Unidade de Processamento ------------ 
CPU : entity work.CPU port map (CLK=>CLK , Instruction_IN => instrucao_ROM, Data_IN => data_RAM_OUT,  
											Data_OUT => data_out , ROM_Address => prox_ROM_address, 
											Data_Address=> data_Address, Control=>control);
											
------------ Memoria de Instrucoes - ROM ------------
ROM : entity work.memoriaROM   generic map (dataWidth => larguraDadosROM, addrWidth => larguraEnderecosROM)
          port map (endereco => prox_ROM_address, Dado => instrucao_ROM);
			 
------------ Memoria RAM  ------------
RAM : entity work.memoriaRAM   generic map (dataWidth => larguraDadosRAM, addrWidth => larguraEnderecosRAM)
          port map (addr => data_Address(5 downto 0), we => control(0) , re => control(1), 
			 habilita  => hab_bloco_0, dado_in => data_out , dado_out => data_RAM_OUT, 
			 clk => CLK);

------------ DECODERs  ------------
DECODER_BLOCO :  entity work.decoder3x8 port map( entrada => data_Address(8 downto 6), saida => decoder_bloco_out);								  

DECODER_ENDERECO :  entity work.decoder3x8 port map( entrada => data_Address(2 downto 0), saida => decoder_endereco_out);	

-- Habilita blocos:
hab_bloco_0 <= decoder_bloco_out(0);
hab_bloco_4 <= decoder_bloco_out(4);

------------ LEDS ------------

-- LEDR0 até LEDR7 

hab_reg_LEDR <= hab_bloco_4 AND control(0) AND decoder_endereco_out(0);

REG_LEDR : entity work.registradorGenerico   generic map (larguraDados => 8)
          port map (DIN => data_out , DOUT => leds, ENABLE => hab_reg_LEDR , CLK => CLK, RST => '0');

--LEDR8 

hab_ff_LED8 <= hab_bloco_4 AND control(0) AND decoder_endereco_out(1);

FF_8 : entity work.FlipFlop port map (
	CLK => CLK, DIN => data_out(0),
	RST => '0' , 
	DOUT => led8, ENABLE => hab_ff_LED8
);

-- LEDR9 
hab_ff_LED9 <= hab_bloco_4 AND control(0) AND decoder_endereco_out(2);

FF_9 : entity work.FlipFlop port map (
	CLK => CLK, DIN=> data_out(0),
	RST => '0' , 
	DOUT => led9, ENABLE => hab_ff_LED9
);

------------ RETORNO ------------
LEDR(7 downto 0) <= leds;
LEDR(8) <= led8;
LEDR(9) <= led9;

-- Saida do decoder bloco
--BLOCO_DECODER <= decoder_bloco_out;
-- Saida do decoder endereço
--ENDERECO_DECODER <= decoder_endereco_out;
-- Instruçao da ROM
--INSTRUCTION <= instrucao_ROM;
-- Retorna dataAddress
-- DATA_ADDR <= data_Address;
-- BLOCO1 <= hab_bloco_0;
-- BLOCO4 <= hab_bloco_4;

PC_OUT <= prox_ROM_address;
end architecture;