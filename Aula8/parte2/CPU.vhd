library ieee;
use ieee.std_logic_1164.all;

entity CPU is
  -- Total de bits das entradas e saidas
  generic ( 
		  
        larguraEnderecosROM : natural := 9;
		  larguraDados : natural := 8;
		  		  
		  larguraPalavraControle : natural := 13;
        simulacao : boolean := TRUE                              -- para gravar na placa, altere de TRUE para FALSE
  );
  port   (
    
	 CLK: in std_logic;
	 Instruction_IN : in std_logic_vector(12 downto 0);
    Data_IN : in std_logic_vector(7 downto 0);
	 
	 Data_OUT : out std_logic_vector(7 downto 0);
    ROM_Address: out std_logic_vector(8 downto 0);
    Data_Address  : out std_logic_vector(8 downto 0);
	 Control : out std_logic_vector(1 downto 0)
	 
  );
end entity;


architecture arquitetura of CPU is

	-- PC:
	signal proxPC : std_logic_vector (larguraEnderecosROM-1 downto 0);
	signal out_endreco_inc : std_logic_vector (larguraEnderecosROM-1 downto 0);
	signal Endereco : std_logic_vector (larguraEnderecosROM-1  downto 0);
	
  -- Entrada ROM:
  signal opcode: 	std_logic_vector (3 downto 0);
  signal imediato_endereco: std_logic_vector (8 downto 0);
  signal imediato_valor: std_logic_vector (7 downto 0);
  
  -- Entrada RAM:
  signal RAM_IN : std_logic_vector(7 downto 0);
	
  -- MUX:
  signal MUX_saida : std_logic_vector (larguraDados-1 downto 0);
  signal Sel_Mux_PC: std_logic_vector(1 downto 0);
    
  -- Decoder:
  signal Sinais_Controle : std_logic_vector (larguraPalavraControle-2 downto 0);
	
  -- Pontos de Controle:
  signal SelMUX : std_logic;
  signal Habilita_A : std_logic;
  signal Operacao_ULA : std_logic_vector(1 downto 0);
  signal habLeitura : std_logic;
  signal habEscrita : std_logic;
  signal JMP: std_logic;
  signal JEQ: std_logic;
  signal hab_flag_igual :std_logic; 
  signal RET: std_logic;
  signal JSR: std_logic;
  signal habEscritaRetorno: std_logic;
	
  -- Registrador A:
  signal REG1_ULA_A : std_logic_vector (larguraDados-1 downto 0);
	
  -- Registrador de Comparaçao
  signal saida_REG_comp : std_logic;
  
  -- Registrador de Retorno
  signal endereco_Retorno : std_logic_vector (larguraEnderecosROM-1 downto 0);
  
  -- ULA:
  signal Saida_ULA : std_logic_vector (larguraDados-1 downto 0);
  signal flag_igual : std_logic;
  
  signal entrada_3_MUX : std_logic_vector(larguraEnderecosROM-1 downto 0);
  
begin

------------ Referenciando entradas RAM e ROM ------------

RAM_IN <= Data_IN;

opcode <= Instruction_IN(12 downto 9);
imediato_endereco <= Instruction_IN(8 downto 0);
imediato_valor <= Instruction_IN(7 downto 0);

------------ Program Counter ------------ 
			 
incrementaPC :  entity work.somaConstante  generic map (larguraDados => larguraEnderecosROM, constante => 1)
        port map( entrada => Endereco, saida => out_endreco_inc);

-- Registrador Endereço de Retorno
REG_RETORNO : entity work.registradorGenerico   generic map (larguraDados => larguraEnderecosROM)
          port map (DIN => out_endreco_inc, DOUT => endereco_Retorno, 
			           ENABLE => habEscritaRetorno, CLK => CLK, RST => '0');		  
		  
-- Instancia logica de Desvio :
LOGICA_DESVIO :  entity work.LogicaDesvio  port map(
                        jeq => JEQ , jmp => JMP , jsr => JSR , ret => RET,
                        flag_igual => saida_REG_comp, muxPC => Sel_Mux_PC);
		  
MUX_JMP :  entity work.muxGenerico4x1  generic map (larguraDados => larguraEnderecosROM)
           port map( 
					  entrada0_MUX => out_endreco_inc, entrada1_MUX => imediato_endereco, 
					  entrada2_MUX => endereco_Retorno, entrada3_MUX => entrada_3_MUX,
                 seletor_MUX => Sel_Mux_PC,
                 saida_MUX => proxPC);
					  
PC : entity work.registradorGenerico   generic map (larguraDados => larguraEnderecosROM)
          port map (DIN => proxPC, DOUT => Endereco, ENABLE => '1', CLK => CLK, RST => '0');
					  
			 
------------  MUX ------------
MUX1 :  entity work.muxGenerico2x1  generic map (larguraDados => larguraDados)
        port map( entradaA_MUX => RAM_IN,
                 entradaB_MUX => imediato_valor,
                 seletor_MUX => SelMUX,
                 saida_MUX => MUX_saida);
					  
------------ Decodificador ------------
DECODER :  entity work.decoderInstru port map( opcode => opcode, saida => Sinais_Controle);

habEscritaRetorno <= Sinais_Controle(11);
JMP               <= Sinais_Controle(10);
RET               <= Sinais_Controle(9);
JSR               <= Sinais_Controle(8);
JEQ               <= Sinais_Controle(7);
SelMUX            <= Sinais_Controle(6);
Habilita_A        <= Sinais_Controle(5);
Operacao_ULA      <= Sinais_Controle(4 downto 3);
hab_flag_igual    <= Sinais_Controle(2);
habLeitura        <= Sinais_Controle(1);
habEscrita        <= Sinais_Controle(0);

------------ Registrador A - Acumulador ------------
REGA : entity work.registradorGenerico   generic map (larguraDados => larguraDados)
          port map (DIN => Saida_ULA, DOUT => REG1_ULA_A, ENABLE => Habilita_A, CLK => CLK, RST => '0');

------------ ULA ------------
ULA : entity work.ULASomaSub  generic map(larguraDados => larguraDados)
          port map (entradaA => REG1_ULA_A, entradaB =>  MUX_saida, saida => Saida_ULA, 
			           seletor => Operacao_ULA , flag => flag_igual);			 

------------ FlipFlop de Comparaçao ------------
FLIPFLOP_COMP : entity work.FlipFlop port map (
	CLK => CLK, DIN=> flag_igual,
	RST => '0',
	DOUT => saida_REG_comp, ENABLE => hab_flag_igual
);
      						  					  

-- Retornos:
ROM_Address <= Endereco;
Data_OUT <= REG1_ULA_A;
Data_Address <= imediato_endereco;
Control <= habLeitura & habEscrita;
			 	
end architecture;