module rodada_simon(
    input logic clk,
    input logic rst_n,
    input  logic [127:0] texto,  // Entrada de texto de 128 bits
    input  logic [ 63:0] kj_i,   // Entrada da chave de rodada de 64 bits
    output logic [127:0] cifrado // Saída de texto cifrado de 128 bits
);
    // Dividir o bloco de 128 bits em dois blocos de 64 bits
    logic [63:0] pt1, pt2; // Partes 1 e 2 do texto claro de 64 bits cada
    logic [63:0] ct1, ct2; // Partes 1 e 2 do texto cifrado de 64 bits cada

    always_ff @(posedge clk or negedge rst_n) begin   // Bloco sempre sensível à borda de subida do clock ou borda de descida do reset
        if (!rst_n) begin                             // Se o reset estiver ativo (baixo)
            // Separando os dois blocos de 64 bits a partir dos 128 bits de texto e chave
            pt1 <= texto[63:0];
            pt2 <= texto[127:64];
        end
        else begin                                    // Caso contrário, quando o reset não estiver ativo
            pt1 <= ct1;
            pt2 <= ct2;
        end
    end

    // Implementação da rodada de criptografia Simon
    always_comb begin
        // Operações de rotação e XOR para o algoritmo Simon
        logic [63:0] rot1, rot8, rot2;

        // Realizando as rotações
        rot1 = {pt1[62:0], pt1[63]};          // Rotação para a esquerda em 1 bit
        rot8 = {pt1[55:0], pt1[63:56]};       // Rotação para a esquerda em 8 bits
        rot2 = {pt1[61:0], pt1[63:62]};       // Rotação para a esquerda em 2 bits

        // Cálculo de CT1 usando as operações Simon
        ct1 = pt2 ^ (rot1 & rot8) ^ rot2 ^ kj_i; 

        // A segunda parte do texto cifrado (CT2) é apenas a primeira parte do texto claro (PT1)
        ct2 = pt1;
    end

    // Concatenar os resultados para formar a saída de 128 bits do texto cifrado
    assign cifrado = {pt1, pt2}; // Combinação de CT1 e CT2 para formar o texto cifrado completo de 128 bits

endmodule
