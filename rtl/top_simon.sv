module top_simon (
  input  logic         clk,       // Entrada de clock
  input  logic         rst_n,     // Entrada de reset ativo em nível baixo

  input  logic         start_i,   // start_i: sinal de início
  input  logic [127:0] pt_i,  // Entrada de plaintext de 128 bits
  input  logic [127:0] k0_i,  // Entrada de chave inicial de 128 bits

  output logic         valid_o,   // valid_o: sinal de saída válido
  output logic [127:0] ct_o   // Saída de ciphertext de 128 bits
);

  // Definição dos estados
  typedef enum logic [2:0] {
    IDLE    = 3'b001,   // Estado inicial, aguardando entrada de dados
    ENCRYPT = 3'b010,    // Estado de encriptação, onde ocorre o processamento
    FINISH  = 3'b100
  } state_t;

  // Registros de estado
  state_t current_state, next_state;  // Registradores para armazenar o estado atual e o próximo
  logic [6:0] round_cnt;  // Contador de 7 bits para contar os 68 ciclos de encriptação

  // Lógica para definir o próximo estado
  always_comb begin
    case (current_state)
      IDLE:    next_state = start_i             ? ENCRYPT : IDLE;
      ENCRYPT: next_state = (round_cnt == 7'd0) ? FINISH  : ENCRYPT;
      default: next_state = IDLE; /* FINISH */
    endcase
  end

  // Transição do estado
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      current_state <= IDLE;     // Se reset for ativo, volta ao estado IDLE
    else
      current_state <= next_state;  // Atualiza o estado atual para o próximo estado
  end

  // Definir o sinal de habilitação (enable)
  logic enable;  // enable: sinal de habilitação
  assign enable = (current_state == ENCRYPT);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      round_cnt <= 7'd67;        // Inicializa o contador com 67 (total de 68 ciclos)
    else if (current_state == IDLE)
      round_cnt <= 7'd67;
    else if (current_state == ENCRYPT)
      round_cnt <= round_cnt - 1'b1;  // Decrementa o contador a cada ciclo
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      valid_o <= 1'b0;
    end
    else begin
      if (current_state == IDLE && start_i)
        valid_o <= 1'b0;
      else if (current_state == FINISH)
        valid_o <= 1'b1;
    end
  end

  logic [127:0] ct;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      ct_o <= '0;
    else if (current_state == FINISH)
      ct_o <= ct;
  end

  // **Sinais internos**
  logic  [63:0] kj;  // Sinal para a saída do esquema de chave
  // **Instanciação do esquema de chave**
  esquema_chave key_sched (
    .clk(clk),       // Conecta o clock
    .rst_n(rst_n),   // Conecta o reset
    .enable_i(enable),// Sinal de habiltação
    .k0_i(k0_i),   // Recebe a chave inicial
    .kj_o(kj)  // Fornece a chave expandida
  );

  // **Instanciação da rodada do Simon**
  rodada_simon round_sim (
    .clk(clk),        // Conecta o clock
    .rst_n(rst_n),    // Conecta o reset
    .enable_i(enable),//Adiciona sinal de habilitação
    .pt_i(pt_i),      // Recebe o plaintext
    .kj_i(kj),        // Recebe a chave expandida do esquema de chave
    .ct_o(ct)         // Fornece o ciphertext resultante
  );

  // always_ff @(posedge clk or negedge rst_n) begin   // Bloco sempre sensível à borda de subida do clock ou borda de descida do reset
  //   if (!rst_n) begin                             // Se o reset estiver ativo (baixo)
  //     ;                                  // Inicializa z com o valor da constante z2
  //   end
  //   else begin                                    // Caso contrário, quando o reset não estiver ativo
  //     $display("X=%x, Y=%x, K=%x", ct[127:64], ct[63:0], kj);
  //   end
  // end

endmodule  // Fim do módulo top_simon
