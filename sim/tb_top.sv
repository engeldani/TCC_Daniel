module tb_top;  // Início do módulo de testbench para o módulo top_simon

  // **Declaração dos sinais de teste**
  logic clk = 0;  // Sinal de clock
  logic rst_n;  // Sinal de reset ativo em nível baixo
  logic [127:0] pt_i;  // Entrada de plaintext de 128 bits
  logic [127:0] k0_i;  // Entrada de chave inicial de 128 bits
  logic [127:0] ct_o;  // Saída de ciphertext de 128 bits

  // **Contador de rodadas**
  integer round_count = 0;  // Inicializa o contador de rodadas em zero

  // **Instanciação do módulo top_simon**
  top_simon uut (  // 'uut' significa 'unidade sob teste'
    .clk(clk),      // Conecta o sinal de clock
    .rst_n(rst_n),  // Conecta o sinal de reset
    .pt_i(pt_i),    // Conecta a entrada de plaintext
    .k0_i(k0_i),    // Conecta a entrada de chave inicial
    .ct_o(ct_o)     // Recebe a saída de ciphertext
  );

  // **Geração do clock**
  always #10 clk = ~clk;  // Inverte o clock a cada 5 unidades de tempo (clock de 100 MHz)

  // **Bloco inicial para configurar o teste**
  initial begin
    rst_n = 0;  // Mantém o reset ativo inicialmente
    pt_i = 128'h0123456789abcdef0123456789abcdef;  // Define o plaintext de teste
    k0_i = 128'h0f0e0d0c0b0a09080706050403020100;  // Define a chave inicial de teste
    
    #100 rst_n = 1;  // Após 10 unidades de tempo, libera o reset

    // **Loop para contar 68 rodadas**
    while (round_count < 68) begin
      @(posedge clk);  // Aguarda a borda de subida do clock
      round_count = round_count + 1;  // Incrementa o contador de rodadas
    end
    
    // **Finalização do teste**
    $display("Teste finalizado após 68 rodadas.");  // Exibe uma mensagem na saída
    $finish;  // Encerra a simulação
  end

endmodule  // Fim do módulo de testbench
