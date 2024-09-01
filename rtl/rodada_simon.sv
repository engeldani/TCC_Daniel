module rodada_simon(
    input  logic [127:0] texto,  // Entrada de texto de 128 bits
    input  logic [ 63:0] kj_i,   // Entrada da chave de rodada de 64 bits
    output logic [127:0] cifrado // Saída de texto cifrado de 128 bits
);
    // Dividir o bloco de 128 bits em dois blocos de 64 bits
    logic [63:0] PT1, PT2; // Partes 1 e 2 do texto claro de 64 bits cada
    logic [63:0] CT1, CT2; // Partes 1 e 2 do texto cifrado de 64 bits cada

    // Separando os dois blocos de 64 bits a partir dos 128 bits de texto e chave
    assign PT1 = texto[127:64]; // PT1 representa a primeira metade do texto
    assign PT2 = texto[63:0];   // PT2 representa a segunda metade do texto

    // Implementação da rodada de criptografia Simon
    always_comb begin
        // Operações de rotação e XOR para o algoritmo Simon
        logic [63:0] rot1, rot8, rot2;

        // Realizando as rotações
        rot1 = {PT1[62:0], PT1[63]};          // Rotação para a esquerda em 1 bit
        rot8 = {PT1[55:0], PT1[63:56]};       // Rotação para a esquerda em 8 bits
        rot2 = {PT1[61:0], PT1[63:62]};       // Rotação para a esquerda em 2 bits

        // Cálculo de CT1 usando as operações Simon
        CT1 = PT2 ^ (rot1 & rot8) ^ rot2 ^ kj_i; 

        // A segunda parte do texto cifrado (CT2) é apenas a primeira parte do texto claro (PT1)
        CT2 = PT1;
    end

    // Concatenar os resultados para formar a saída de 128 bits do texto cifrado
    assign cifrado = {CT1, CT2}; // Combinação de CT1 e CT2 para formar o texto cifrado completo de 128 bits

endmodule
