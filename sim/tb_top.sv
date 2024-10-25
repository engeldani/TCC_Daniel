module tb_top;  // Início do módulo de testbench para o módulo top_simon

  // **Declaração dos sinais de teste**
  logic clk = 0;  // Sinal de clock
  logic rst_n;  // Sinal de reset ativo em nível baixo
  logic [127:0] pt_i;  // Entrada de plaintext de 128 bits
  logic [127:0] k0_i;  // Entrada de chave inicial de 128 bits
  logic [127:0] ct_o;  // Saída de ciphertext de 128 bits

  // **Instanciação do módulo top_simon**
  top_simon uut (  // 'uut' significa 'unidade sob teste'
    .clk(clk),      // Conecta o sinal de clock
    .rst_n(rst_n),  // Conecta o sinal de reset
    .start_i(start), // Sinal de início da operação
    .valid_o(valid), // Sinal que indica quando a saída (ciphertext) é válida
    .pt_i(pt_i),    // Conecta a entrada de plaintext
    .k0_i(k0_i),    // Conecta a entrada de chave inicial
    .ct_o(ct_o)     // Recebe a saída de ciphertext
  );

  // **Geração do clock**
  always #10 clk = ~clk;  // Inverte o clock a cada 5 unidades de tempo (clock de 100 MHz)

  // **Bloco inicial para configurar o teste**
  initial begin
    rst_n = 0;  // Mantém o reset ativo inicialmente
    
    #100 rst_n = 1;  // Após 100 unidades de tempo, libera o reset

    pt_i = 128'h0123456789abcdef0123456789abcdef;  // Define o plaintext de teste
    k0_i = 128'h0f0e0d0c0b0a09080706050403020100;  // Define a chave inicial de teste

    // Aguarda ao menos 1 ciclo para garantir que o reset foi corretamente aplicado
    #10;

    // Ativa o start para iniciar a operação
    start_i = 1;
    
    // Aguarda 1 ciclo de clock
    #10 start_i = 0;  // Baixa o sinal start após 1 ciclo

    // Aguarda até que o valid_o fique ativo (indica que o resultado está pronto)
    wait (valid_o == 1);

    // Quando valid_o for 1, imprimir o valor de ct_o na tela
    $display("Ciphertext: %h", ct_o);

    // Encerra a simulação
    $finish;
end
    // Aguardar ao menos 1 ciclo para teste
    // Escrever start_i=1
    // Aguardar 1 ciclo
    // Baixar start_i
    // Aguardar pelo valid_o ficar em 1
    // Quando valid_o for 1, imprimir na tela o ct_o
    // Encerra a simulação
  

endmodule  // Fim do módulo de testbench
