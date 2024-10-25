module esquema_chave (
    input  logic         clk,      // Sinal de clock para sincronização das operações sequenciais
    input  logic         rst_n,    // Sinal de reset ativo em nível baixo para inicializar o módulo
    input  logic         enable_i, // Sinal de habilitação
    input  logic [127:0] k0_i,     // Entrada da chave de 128 bits (inicial)
    
    output logic [ 63:0] kj_o  // Saída da nova chave gerada de 64 bits para ser usada em cada rodada de criptografia
);

////////////////////////////////////////////////////////////////////////////////
// Geração da constante de geração de chave
////////////////////////////////////////////////////////////////////////////////

    // Constante c utilizada na geração de chave
    localparam logic [63:0] c = 64'hFFFFFFFFFFFFFFFC; // Define uma constante de 64 bits para o algoritmo de geração de chave

    // Constante z2 utilizada na geração de chave
    localparam logic [61:0] z2 = 62'b11001101101001111110001000010100011001001011000000111011110101;  // Constante usada para o cálculo da constante de rodada
    logic [61:0] z;            // Variável para armazenar o valor atual da constante de rodada


    /* Round constant */
    logic [63:0] rc;          // Variável para armazenar a constante de rodada atualizada

    always_ff @(posedge clk or negedge rst_n) begin   // Bloco sempre sensível à borda de subida do clock ou borda de descida do reset
        if (!rst_n) begin                             // Se o reset estiver ativo (baixo)
            z <= z2;                                  // Inicializa z com o valor da constante z2
        end
        else begin                                    // Caso contrário, quando o reset não estiver ativo
            // Rotação circular à direita
            z[60:0] <= z[61:1];                       // Desloca os bits de z para a direita
            z[61]   <= z[0];                          // O bit mais significativo recebe o bit menos significativo, completando a rotação
        end
    end

    assign rc = {c[63:1], z[0]};

////////////////////////////////////////////////////////////////////////////////
// Geração da chave
////////////////////////////////////////////////////////////////////////////////

    // Dividir a chave de 128 bits em dois blocos de 64 bits
    logic [63:0] k1;                                  // Variável para armazenar a primeira metade da chave de 64 bits
    logic [63:0] k2;                                  // Variável para armazenar a segunda metade da chave de 64 bits
    logic [63:0] k2_proximo;                          // Variável para armazenar o próximo valor calculado para k2

    // Separando as partes da chave atual
    always_ff @(posedge clk or negedge rst_n) begin   // Bloco sempre sensível à borda de subida do clock ou borda de descida do reset
        if (!rst_n) begin                             // Se o reset estiver ativo (baixo)
            k1 <= k0_i[63:0];                         // Inicializa k1 com os 64 bits mais significativos da chave inicial k0_i
            k2 <= k0_i[ 127: 64];                       // Inicializa k2 com os 64 bits menos significativos da chave inicial k0_i
        end
    //
    always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // Inicializa os valores no reset
        k1 <= k0_i[127:64];  // Inicializa k1 com os 64 bits mais significativos da chave inicial k0_i
        k2 <= k0_i[ 63: 0];  // Inicializa k2 com os 64 bits menos significativos da chave inicial k0_i
    end else if (!enable) begin
        // Sem o enable ativo, mantém os valores de entrada como no reset
        k1 <= k0_i[127:64];  // Mantém k1 com os 64 bits mais significativos da chave inicial k0_i
        k2 <= k0_i[ 63: 0];  // Mantém k2 com os 64 bits menos significativos da chave inicial k0_i
    end else begin
        // Com enable ativo, atualiza os valores
        k1 <= k2;            // Atualiza k1 com o valor de k2
        k2 <= k2_proximo;     // Atualiza k2 com o próximo valor calculado (k2_proximo)
    end
end

        // No reset deve inicializar em 0
        // Sem enable, grava valores de entrada (como está no reset hoje)

        // Com enable, grava os próximos valores:
        else begin                                    // Caso contrário, quando o reset não estiver ativo
            k1 <= k2;                                 // Atualiza k1 com o valor atual de k2
            k2 <= k2_proximo;                         // Atualiza k2 com o valor calculado para k2_proximo
        end
    end

    // Implementação da rodada de geração de chave
    logic [63:0] k2_r3;                              // Variável para armazenar o valor de k2 após uma rotação à direita de 3 bits
    assign k2_r3 = {k2[2:0], k2[63:3]};              // Realiza uma rotação circular à direita de 3 bits em k2

    logic [63:0] tmp1;                               // Variável temporária para armazenar um valor intermediário
    assign tmp1 = k2_r3 ^ k1;                        // Executa uma operação XOR entre k2 rotacionado e k1

    logic [63:0] k2_r3_r1;                           // Variável para armazenar o valor de k2_r3 após uma rotação à direita de 1 bit
    assign k2_r3_r1 = {k2_r3[0], k2_r3[63:1]};       // Realiza uma rotação circular à direita de 1 bit em k2_r3

    logic [63:0] tmp2;                               // Variável temporária para armazenar um segundo valor intermediário
    assign tmp2 = tmp1 ^ k2_r3_r1;                   // Executa uma operação XOR entre tmp1 e k2_r3 rotacionado de 1 bit

    assign k2_proximo = tmp2 ^ rc;                   // Calcula o próximo valor de k2 aplicando XOR entre tmp2 e a constante de rodada

    assign kj_o = k1;                                // A saída kj_o é atribuída o valor de k1, que é a chave para a próxima rodada

endmodule
