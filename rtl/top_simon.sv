module top_simon (

// Definição dos estados
typedef enum logic [1:0] {
    IDLE = 2'b00,      // Estado inicial, aguardando entrada de dados
    ENCRYPT = 2'b01    // Estado de encriptação, onde ocorre o processamento
} state_t;

// Registros de estado
state_t current_state, next_state;  // Registradores para armazenar o estado atual e o próximo
logic [6:0] round_cnt;  // Contador de 7 bits para contar os 68 ciclos de encriptação

// Sinais para a máquina de estados
logic start_i, valid_o, enable_i;  // start_i: sinal de início; valid_o: sinal de saída válido; enable_i: sinal de habilitação

// Lógica de inicialização do estado e transição
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;     // Se reset for ativo, volta ao estado IDLE
        round_cnt <= 7'd67;        // Inicializa o contador com 67 (total de 68 ciclos)
        valid_o <= 1'b0;           // Inicializa o sinal de saída como inválido
    end else begin
        current_state <= next_state;  // Atualiza o estado atual para o próximo estado

        // Decrementa o contador de ciclos no estado ENCRYPT
        if (current_state == ENCRYPT) begin
            round_cnt <= round_cnt - 1'b1;  // Decrementa o contador a cada ciclo
        end
    end
end

// Lógica para definir o próximo estado
always_comb begin
    next_state = current_state;  // Atribuição padrão: mantém o estado atual
    start_i = 1'b0;              // Inicializa o sinal start como 0 (padrão)
    enable_i = 1'b0;             // Inicializa o sinal enable como 0 (padrão)

    case (current_state)
        IDLE: begin
            valid_o = 1'b0;  // No estado IDLE, o sinal valid_o é 0
            if (start_i == 1'b1) begin
                next_state = ENCRYPT;  // Se start_i for 1, muda para o estado ENCRYPT
            end
        end
        ENCRYPT: begin
            enable_i = 1'b1;  // Ativa o sinal enable para iniciar a encriptação
            if (round_cnt == 7'd0) begin
                next_state = IDLE;  // Quando o contador chega a 0, retorna ao estado IDLE
                valid_o = 1'b1;  // Sinaliza que a saída é válida
            end
        end
    endcase
end
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

  always_ff @(posedge clk or negedge rst_n) begin   // Bloco sempre sensível à borda de subida do clock ou borda de descida do reset
    if (!rst_n) begin                             // Se o reset estiver ativo (baixo)
      ;                                  // Inicializa z com o valor da constante z2
    end
    else begin                                    // Caso contrário, quando o reset não estiver ativo
      $display("X=%x, Y=%x, K=%x", ct_o[127:64], ct_o[63:0], kj);
    end
  end
  

endmodule  // Fim do módulo top_simon
