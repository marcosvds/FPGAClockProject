<h1>Projeto 1: Relógio Utilizando um Processador Personalizado</h1>

<h2>Informações Gerais</h2>

<h3>Engenharia de Computação Insper - Design de Computadores 2023.2</h3>

<h3>Alunos:</h3>
<ul>
  <li><a href=https://www.linkedin.com/in/caio-ribeiro-de-paula-8b5999193/>Caio Ribeiro de Paula</a></li>
  <li><a href=https://www.linkedin.com/in/marcosvinis/>Marcos Vinícius da Silva</a></li>
</ul>

<h3>Professores:</h3> 
<ul>
  <li><a href=https://www.insper.edu.br/pesquisa-e-conhecimento/docentes-pesquisadores/paulo-carlos-ferreira-dos-santos/>Paulo Carlos Ferreira dos Santos</a></li>
</ul>

<h2>Acompanhamento de Tarefas: https://docs.google.com/document/d/1tQu284zb4H75BPVvmHYvKxLIM0q2ro0aXAdbX-oSKcw/edit?usp=sharing</h2>

<h2>Descrição</h2>
<p>O projeto visa a implementação de um processador personalizado que será utilizado em um relógio com as seguintes características:</p>
<ul>
    <li>Indicação de horas, minutos e segundos.</li>
    <li>Exibição do horário através de um display de sete segmentos.</li>
    <li>Sistema para ajuste do horário exibido.</li>
    <li>Seleção da base de tempo para mostrar a passagem das 24 horas em tempo reduzido, utilizado para verificação do funcionamento correto do projeto.</li>
    <li>Avaliação final realizada na placa FPGA.</li>
</ul>

<h2>Características do Processador</h2>
<ul>
    <li>Arquitetura Harvard.</li>
    <li>Trabalha com dados de 8 bits.</li>
    <li>Componente com interface externa contendo:</li>
    <ul>
        <li>Barramento de dados: 8 bits.</li>
        <li>Barramento da memória de instruções: até 16 bits.</li>
        <li>Barramento de endereços: até 16 bits.</li>
        <li>Barramento de controle com sinais comuns (ex: R/~W).</li>
    </ul>
    <li>Topologia permitida: Registrador-Memória.</li>
    <li>Uso obrigatório de sub-rotinas.</li>
    <li>Decodificação de endereços realizada fora do processador.</li>
</ul>

<h2>Opcionais para o Relógio</h2>
<h3>Adicionam meio conceito ao limite da nota:</h3>
<ul>
    <li>Novas instruções úteis (ex: AND, CLT, JLT, ADDI, SUBI, LDADDR, STAIND, LDAIND).</li>
    <li>Ajuste de horário que não seja por aumento da frequência da base de tempo.</li>
    <li>Montador (assembler) para o processador em Python.</li>
    <li>Indicação do horário selecionável (12h ou 24h).</li>
    <li>Sistema de despertador.</li>
    <li>Temporizador com contagem regressiva.</li>
</ul>

<h3>Adicionam um conceito ao limite da nota:</h3>
<ul>
    <li>Chamada de sub-rotina aninhada (até 8 chamadas).</li>
    <li>Pilha controlada por hardware.</li>
    <li>Interrupção por hardware (uma única interrupção).</li>
</ul>

</body>
</html>

