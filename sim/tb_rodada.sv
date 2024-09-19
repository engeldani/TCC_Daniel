module tb_rodada;  // Início do módulo de testbench para o módulo rodada_simon

  // **Declaração dos sinais de teste**
  logic clk = 0;  // Sinal de clock
  logic rst_n;  // Sinal de reset ativo em nível baixo
  logic [127:0] pt_i;  // Entrada de plaintext de 128 bits
  logic [ 63:0] k0_i;  // Entrada de chave inicial de 128 bits
  logic [127:0] ct_o;  // Saída de ciphertext de 128 bits

  // **Contador de rodadas**
  integer round_count = 0;  // Inicializa o contador de rodadas em zero

  // **Instanciação do módulo a ser testado**
  rodada_simon uut (  // 'uut' significa 'unidade sob teste'
    .clk(clk),       // Conecta o sinal de clock
    .rst_n(rst_n),   // Conecta o sinal de reset
    .pt_i(pt_i),     // Conecta a entrada de plaintext
    .kj_i(k0_i),     // Conecta a entrada de chave de rodada
    .ct_o(ct_o)      // Recebe a saída de ciphertext
  );

  // **Geração do clock**
  always #10 clk = ~clk;  // Inverte o clock a cada 5 unidades de tempo (clock de 100 MHz)

  // **Bloco inicial para configurar o teste**
  initial begin
    rst_n = 0;  // Mantém o reset ativo inicialmente
    pt_i = 128'h0123456789abcdef0123456789abcdef;  // Define o plaintext de teste
    k0_i =  64'h0706050403020100;  // Define a chave inicial de teste
    
    #100 rst_n = 1;  // Após 10 unidades de tempo, libera o reset
  end

  int i;
  always_ff @(posedge clk) begin
        if (!rst_n) begin
            i <= 0;
        end
        else begin
            if (i < 68) begin
                $display("ct%02d = %h", i, ct_o);
                i <= i + 1;
            end
            else begin 
                $finish();
            end
        end
    end

endmodule  // Fim do módulo de testbench
