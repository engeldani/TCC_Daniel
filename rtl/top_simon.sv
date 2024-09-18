module top_simon (
  input wire clk,       // Entrada de clock
  input wire rst_n,     // Entrada de reset ativo em nível baixo
  input wire [127:0] pt_i,  // Entrada de plaintext de 128 bits
  input wire [127:0] k0_i,  // Entrada de chave inicial de 128 bits
  output wire [127:0] ct_o  // Saída de ciphertext de 128 bits
);

  // **Sinais internos**
  wire [127:0] key_out;  // Sinal para a saída do esquema de chave

  // **Instanciação do esquema de chave**
  esquema_chave key_sched (
    .clk(clk),       // Conecta o clock
    .rst_n(rst_n),   // Conecta o reset
    .key_in(k0_i),   // Recebe a chave inicial
    .key_out(key_out)  // Fornece a chave expandida
  );

  // **Instanciação da rodada do Simon**
  rodada_simon round_sim (
    .clk(clk),        // Conecta o clock
    .rst_n(rst_n),    // Conecta o reset
    .pt_i(pt_i),      // Recebe o plaintext
    .k0_i(key_out),   // Recebe a chave expandida do esquema de chave
    .ct_o(ct_o)       // Fornece o ciphertext resultante
  );

endmodule  // Fim do módulo top_simon
