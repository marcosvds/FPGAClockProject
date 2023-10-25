library ieee;
use ieee.std_logic_1164.all;

entity Aula8_3 is
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
	 FPGA_RESET_N : in std_logic;
    KEY: in std_logic_vector(3 downto 0);
	 SW:  in std_logic_vector(9 downto 0);
	 LEDR: out std_logic_vector(9 downto 0);
	 HEX0: out std_logic_vector(6 downto 0);
	 HEX1: out std_logic_vector(6 downto 0);
	 HEX2: out std_logic_vector(6 downto 0);
	 HEX3: out std_logic_vector(6 downto 0);
	 HEX4: out std_logic_vector(6 downto 0);
	 HEX5: out std_logic_vector(6 downto 0);
	 PC_OUT: out std_logic_vector(larguraEnderecosROM-1 downto 0)
  );
  
end entity;


architecture arquitetura of Aula8_3 is

	-- I/O RAM e ROM , I/O CPU
	signal data_RAM_OUT: std_logic_vector(larguraDadosRAM-1 downto 0);
	signal instrucao_ROM : std_logic_vector(larguraDadosROM-1 downto 0);
	signal data_in : std_logic_vector(larguraDadosRAM-1 downto 0);
	
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
	signal hab_bloco_5 : std_logic; 
	
	-- Regstradores dos LEDS:
	signal hab_reg_LEDR : std_logic; 
	signal hab_ff_LED8 : std_logic; 
	signal hab_ff_LED9 : std_logic; 
	
	signal leds: std_logic_vector(7 downto 0);
	signal led8: std_logic;
	signal led9: std_logic;
		
	-- Controle entre LEDS e Display
	alias A5:std_logic is data_Address(5);
	
	-- Registradores do Display
	signal hab_reg_HEX0: std_logic;
	signal hab_reg_HEX1: std_logic;
	signal hab_reg_HEX2: std_logic;
	signal hab_reg_HEX3: std_logic;
	signal hab_reg_HEX4: std_logic;
	signal hab_reg_HEX5: std_logic;
	
	signal reg_hex0_out : std_logic_vector(3 downto 0);
	signal reg_hex1_out : std_logic_vector(3 downto 0);
	signal reg_hex2_out : std_logic_vector(3 downto 0);
	signal reg_hex3_out : std_logic_vector(3 downto 0);
	signal reg_hex4_out : std_logic_vector(3 downto 0);
	signal reg_hex5_out : std_logic_vector(3 downto 0);
	
	-- Buffers chaves e botoes:
	signal hab_sw_07 : std_logic;
	signal hab_sw_8 : std_logic;
	signal hab_sw_9 : std_logic;
	
	signal hab_key_0 : std_logic;
	signal hab_key_1 : std_logic;
	signal hab_key_2 : std_logic;
	signal hab_key_3 : std_logic;
	signal hab_fpga_reset : std_logic;
	
	-- FlipFlop Contador
	signal clk_contador_key0 : std_logic;
	signal limpa_leitura : std_logic;
	signal ff_key0_out : std_logic;
	
	
begin
	
------------------------------------------------------------------
----------------------- Edge Detector  ---------------------------
------------------------------------------------------------------

-- FPGA_RESET_N como CLOCK Manual
--gravar:  if simulacao generate
--CLK <= FPGA_RESET_N;
--else generate
--detectorSub0: work.edgeDetector(bordaSubida)
--        port map (clk => CLOCK_50, entrada => (not FPGA_RESET_N), saida => CLK);
--end generate;


CLK <= CLOCK_50;

------------------------------------------------------------------
--------------------- Unidade de Processamento -------------------
------------------------------------------------------------------

CPU : entity work.CPU port map (CLK=>CLK , Instruction_IN => instrucao_ROM, Data_IN => data_in,  
											Data_OUT => data_out , ROM_Address => prox_ROM_address, 
											Data_Address=> data_Address, Control=>control);
											
------------------------------------------------------------------									
-------------------- Memoria de Instrucoes - ROM -----------------
------------------------------------------------------------------	

ROM : entity work.memoriaROM   generic map (dataWidth => larguraDadosROM, addrWidth => larguraEnderecosROM)
          port map (endereco => prox_ROM_address, Dado => instrucao_ROM);

------------------------------------------------------------------			 
-------------------------- Memoria RAM  --------------------------
------------------------------------------------------------------

RAM : entity work.memoriaRAM   generic map (dataWidth => larguraDadosRAM, addrWidth => larguraEnderecosRAM)
          port map (addr => data_Address(5 downto 0), we => control(0) , re => control(1), 
			 habilita  => hab_bloco_0, dado_in => data_out , dado_out => data_in, 
			 clk => CLK);

------------------------------------------------------------------
----------------------------- DECODERs  --------------------------
------------------------------------------------------------------

DECODER_BLOCO :  entity work.decoder3x8 port map( entrada => data_Address(8 downto 6), saida => decoder_bloco_out);								  

DECODER_ENDERECO :  entity work.decoder3x8 port map( entrada => data_Address(2 downto 0), saida => decoder_endereco_out);	

-- Habilita blocos:
hab_bloco_0 <= decoder_bloco_out(0);
hab_bloco_4 <= decoder_bloco_out(4);
hab_bloco_5 <= decoder_bloco_out(5);


------------------------------------------------------------------
------------------------------- LEDS -----------------------------
------------------------------------------------------------------

-- LEDR0 até LEDR7 

hab_reg_LEDR <= hab_bloco_4 AND control(0) AND decoder_endereco_out(0) AND not(A5);

REG_LEDR : entity work.registradorGenerico   generic map (larguraDados => 8)
          port map (DIN => data_out , DOUT => leds, ENABLE => hab_reg_LEDR , CLK => CLK, RST => '0');

--LEDR8 

hab_ff_LED8 <= hab_bloco_4 AND control(0) AND decoder_endereco_out(1) AND not(A5);

FF_8 : entity work.FlipFlop port map (
	CLK => CLK, DIN => data_out(0),
	RST => '0' , 
	DOUT => led8, ENABLE => hab_ff_LED8
);

-- LEDR9 
hab_ff_LED9 <= hab_bloco_4 AND control(0) AND decoder_endereco_out(2) AND not(A5);

FF_9 : entity work.FlipFlop port map (
	CLK => CLK, DIN=> data_out(0),
	RST => '0' , 
	DOUT => led9, ENABLE => hab_ff_LED9
);

------------------------------------------------------------------
---------------------------- DISPLAY -----------------------------
------------------------------------------------------------------

-- HEX0
hab_reg_HEX0 <=  hab_bloco_4 AND control(0) AND decoder_endereco_out(0) AND A5;

REG_HEX_0 : entity work.registradorGenerico   generic map (larguraDados => 4)
		  port map (DIN => data_out(3 downto 0) , DOUT => reg_hex0_out, ENABLE => hab_reg_HEX0, CLK => CLK, RST => '0');

HEX_0 :  entity work.conversorHex7Seg
        port map(dadoHex => reg_hex0_out,
                 saida7seg => HEX0);
	  
-- HEX1
hab_reg_HEX1 <=  hab_bloco_4 AND control(0) AND decoder_endereco_out(1) AND A5;

REG_HEX_1 : entity work.registradorGenerico   generic map (larguraDados => 4)
        port map (DIN => data_out(3 downto 0) , DOUT => reg_hex1_out, ENABLE => hab_reg_HEX1 , CLK => CLK, RST => '0');

HEX_1 :  entity work.conversorHex7Seg
        port map(dadoHex => reg_hex1_out,
                 saida7seg => HEX1);
		  
-- HEX2
hab_reg_HEX2 <=  hab_bloco_4 AND control(0) AND decoder_endereco_out(2) AND A5;

REG_HEX_2 : entity work.registradorGenerico   generic map (larguraDados => 4)
		  port map (DIN => data_out(3 downto 0) , DOUT => reg_hex2_out, ENABLE => hab_reg_HEX2 , CLK => CLK, RST => '0');

HEX_2 :  entity work.conversorHex7Seg
        port map(dadoHex => reg_hex2_out,
                 saida7seg => HEX2);
		  
-- HEX3
hab_reg_HEX3 <=  hab_bloco_4 AND control(0) AND decoder_endereco_out(3) AND A5;

REG_HEX_3 : entity work.registradorGenerico   generic map (larguraDados => 4)
		  port map (DIN => data_out(3 downto 0) , DOUT => reg_hex3_out, ENABLE => hab_reg_HEX3 , CLK => CLK, RST => '0');

HEX_3 :  entity work.conversorHex7Seg
        port map(dadoHex => reg_hex3_out,
                 saida7seg => HEX3);
		  
-- HEX4
hab_reg_HEX4 <=  hab_bloco_4 AND control(0) AND decoder_endereco_out(4) AND A5;

REG_HEX_4 : entity work.registradorGenerico   generic map (larguraDados => 4)
		  port map (DIN => data_out(3 downto 0) , DOUT => reg_hex4_out, ENABLE => hab_reg_HEX4 , CLK => CLK, RST => '0');

HEX_4 :  entity work.conversorHex7Seg
        port map(dadoHex => reg_hex4_out,
                 saida7seg => HEX4);
		  
-- HEX5
hab_reg_HEX5 <=  hab_bloco_4 AND control(0) AND decoder_endereco_out(5) AND A5;

REG_HEX_5 : entity work.registradorGenerico   generic map (larguraDados => 4)
		  port map (DIN => data_out(3 downto 0) , DOUT => reg_hex5_out, ENABLE => hab_reg_HEX5 , CLK => CLK, RST => '0');

HEX_5 :  entity work.conversorHex7Seg
        port map(dadoHex => reg_hex5_out,
                 saida7seg => HEX5);

-- Controlar PC:
--HEX_4 :  entity work.conversorHex7Seg
--        port map(dadoHex => prox_ROM_address(3 downto 0),
--                 saida7seg => HEX4);
		  
------------------------------------------------------------------
---------------------------- CHAVES ------------------------------
------------------------------------------------------------------

-- SW(7 -> 0)
hab_sw_07 <= control(1) AND NOT(A5) AND decoder_endereco_out(0) AND hab_bloco_5;

BUFFER_SW_07 : entity work.buffer_3_state_8portas
        port map(entrada => SW(7 downto 0), habilita => hab_sw_07 , saida => data_in);			
			
-- SW(8)	
hab_sw_8 <= control(1) AND NOT(A5) AND decoder_endereco_out(1) AND hab_bloco_5;
			
BUFFER_SW_8 : entity work.buffer_3_state
        port map(entrada => SW(8), habilita => hab_sw_8 , saida => data_in(0));
			
-- SW(9)	
hab_sw_9 <= control(1) AND NOT(A5) AND decoder_endereco_out(2) AND hab_bloco_5;

BUFFER_SW_9 : entity work.buffer_3_state
        port map(entrada => SW(9), habilita => hab_sw_9 , saida => data_in(0));

------------------------------------------------------------------
----------------------------- BOTOES -----------------------------
------------------------------------------------------------------

-- ----- Fazendo KEY(0) ser o contador -----
-- KEY(0)

hab_key_0 <= control(1) AND A5 AND decoder_endereco_out(0) AND hab_bloco_5;
limpa_leitura <= data_Address(8) AND data_Address(7) AND data_Address(6) AND data_Address(5) AND data_Address(4) AND data_Address(3) AND
					  data_Address(2) AND data_Address(1) AND data_Address(0) AND control(0);

detectorContador: work.edgeDetector(bordaSubida)
						port map (clk => CLK, entrada => NOT(KEY(0)), saida => clk_contador_key0);

FLIPFLOP_KEY0 : entity work.FlipFlop port map (
	CLK => clk_contador_key0 , DIN => '1',
	RST => limpa_leitura , 
	DOUT => ff_key0_out, ENABLE => '1'
);

BUFFER_KEY_0 : entity work.buffer_3_state
        port map(entrada => ff_key0_out , habilita => hab_key_0 , saida => data_in(0));
		  
-- KEY(1)

hab_key_1 <= control(1) AND A5 AND decoder_endereco_out(1) AND hab_bloco_5;
			
BUFFER_KEY_1 : entity work.buffer_3_state
        port map(entrada => KEY(1), habilita => hab_key_1 , saida => data_in(0));

-- KEY(2)

hab_key_2 <= control(1) AND A5 AND decoder_endereco_out(2) AND hab_bloco_5;
			
BUFFER_KEY_2 : entity work.buffer_3_state
        port map(entrada => KEY(2), habilita => hab_key_2 , saida => data_in(0));

-- KEY(3)

hab_key_3 <= control(1) AND A5 AND decoder_endereco_out(3) AND hab_bloco_5;
			
BUFFER_KEY_3 : entity work.buffer_3_state
        port map(entrada => KEY(3), habilita => hab_key_3 , saida => data_in(0));
		  
-- FPGA_RESET_N
hab_fpga_reset <= control(1) AND A5 AND decoder_endereco_out(4) AND hab_bloco_5;
 
BUFFER_FPGA_RESET_N : entity work.buffer_3_state
        port map(entrada => FPGA_RESET_N , habilita => hab_fpga_reset , saida => data_in(0));
 
 
------------------------------------------------------------------
------------------------------- RETORNO --------------------------
------------------------------------------------------------------

LEDR(7 downto 0) <= leds;
LEDR(8) <= led8;
LEDR(9) <= led9;
-- LEDR(8) <= ff_key0_out;

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