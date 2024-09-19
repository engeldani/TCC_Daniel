module top_simon (
  input  logic clk,       // Entrada de clock
  input  logic rst_n,     // Entrada de reset ativo em nível baixo
  input  logic [127:0] pt_i,  // Entrada de plaintext de 128 bits
  input  logic [127:0] k0_i,  // Entrada de chave inicial de 128 bits
  output logic [127:0] ct_o  // Saída de ciphertext de 128 bits
);

  // **Sinais internos**
  logic [63:0] kj;  // Sinal para a saída do esquema de chave

  // **Instanciação do esquema de chave**
  esquema_chave key_sched (
    .clk(clk),       // Conecta o clock
    .rst_n(rst_n),   // Conecta o reset
    .k0_i(k0_i),   // Recebe a chave inicial
    .kj_o(kj)  // Fornece a chave expandida
  );

  // **Instanciação da rodada do Simon**
  rodada_simon round_sim (
    .clk(clk),        // Conecta o clock
    .rst_n(rst_n),    // Conecta o reset
    .pt_i(pt_i),      // Recebe o plaintext
    .kj_i(kj),   // Recebe a chave expandida do esquema de chave
    .ct_o(ct_o)       // Fornece o ciphertext resultante
  );

endmodule  // Fim do módulo top_simon
