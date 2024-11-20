module rodada_simon(
    input  logic         clk,
    input  logic         rst_n,
    input  logic         enable_i,
    input  logic         encrypt_i,
    input  logic [127:0] pt_i,  // Entrada de texto de 128 bits
    input  logic [ 63:0] kj_i,   // Entrada da chave de rodada de 64 bits
    output logic [127:0] ct_o // Saída de texto cifrado de 128 bits
);
    // Dividir o bloco de 128 bits em dois blocos de 64 bits
    logic [63:0] pt1, pt2; // Partes 1 e 2 do texto claro de 64 bits cada
    logic [63:0] ct1, ct2; // Partes 1 e 2 do texto cifrado de 64 bits cada

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Inicializa pt1 e pt2 com 0 no reset
            pt1 <= 64'b0;
            pt2 <= 64'b0;
        end 
        else if (!enable_i) begin
            // Sem enable, grava os valores de entrada em pt1 e pt2
            if (encrypt_i) begin // modo criptografia
                pt1 <= pt_i[127:64];  // Parte mais significativa do texto de entrada
                pt2 <= pt_i[ 63: 0];  // Parte menos significativa do texto de entrada
            end
            else begin  // Para descriptografar a inicialização é invertida
                pt1 <= pt_i[ 63: 0];
                pt2 <= pt_i[127:64];
            end
        end 
        else begin
            // Com enable ativo, atualiza os valores conforme a computação
            pt1 <= ct1;  // Atualiza com os valores cifrados
            pt2 <= ct2;  // Atualiza com os valores cifrados
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
        ct1 = (pt2 ^ ((rot1 & rot8) ^ rot2)) ^ kj_i; 

        // A segunda parte do texto cifrado (CT2) é apenas a primeira parte do texto claro (PT1)
        ct2 = pt1;
    end

    // Concatenar os resultados para formar a saída de 128 bits do texto cifrado
    assign ct_o = {pt1, pt2}; // Combinação de CT1 e CT2 para formar o texto cifrado completo de 128 bits

endmodule
