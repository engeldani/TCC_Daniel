module rodada_simon(
    input logic [127:0] texto,        // Entrada de texto de 128 bits
    input logic [127:0] chave,        // Entrada da chave de 128 bits
    output logic [127:0] criptografia // Saída de texto cifrado de 128 bits
);
    // Dividir o bloco de 128 bits em dois blocos de 64 bits
    logic [63:0] PT1, PT2; // Partes 1 e 2 do texto claro de 64 bits cada
    logic [63:0] CT1, CT2; // Partes 1 e 2 do texto cifrado de 64 bits cada
    logic [63:0] K1, K2;   // Partes 1 e 2 da chave de 64 bits cada

    // Separando os dois blocos de 64 bits a partir dos 128 bits de texto e chave
    assign PT1 = texto[127:64]; // PT1 representa a primeira metade do texto
    assign PT2 = texto[63:0];   // PT2 representa a segunda metade do texto
    assign K1 = chave[127:64];  // K1 representa a primeira metade da chave
    assign K2 = chave[63:0];    // K2 representa a segunda metade da chave

    // Implementação da rodada de criptografia
    always_comb begin
        CT1 = PT2 ^ (((PT1 <<< 1) & (PT1 <<< 8)) ^ (PT1 <<< 2)) ^ K1; // Cálculo da primeira parte do texto cifrado (CT1)
        CT2 = PT1; // A segunda parte do texto cifrado (CT2) é apenas a primeira parte do texto claro (PT1)
    end

    // Concatenar os resultados para formar a saída de 128 bits do texto cifrado
    assign criptografia = {CT1, CT2}; // Combinação de CT1 e CT2 para formar o texto cifrado completo de 128 bits

endmodule

module esquema_chave(
    input logic [127:0] chave,  // Entrada da chave de 128 bits
    input logic [63:0] z2,    // Entrada da constante LFSR z2 de 64 bits
    output logic [127:0] nova_chave, // Saída da nova chave gerada de 128 bits
    output logic [63:0] nova_z2    // Saída da nova constante LFSR z2 de 64 bits
);
    // Dividir a chave de 128 bits em dois blocos de 64 bits
    logic [63:0] K1, K2, K1_proximo, K2_proximo; // Variáveis para a chave atual e próxima
    logic [63:0] c = 64'hFFFFFFFFFFFFFFFC; // Constante c utilizada na geração de chave

    // Separando as partes da chave atual
    assign K1 = chave[127:64]; // K1 representa a primeira metade da chave
    assign K2 = chave[63:0];   // K2 representa a segunda metade da chave

    // Implementação da rodada de geração de chave
    always_comb begin
        K1_proximo = K2; // Atualização de K1 para a próxima rodada, que é simplesmente K2
        K2_proximo = ((K1 ^ (K2 >> 3)) ^ ((K2 >> 3) >> 1)) ^ (c ^ z2); // Cálculo de K2 para a próxima rodada usando operações XOR e shift
    end

    // Combinação das partes para formar a nova chave de 128 bits
    assign nova_chave = {K1_proximo, K2_proximo}; // Combinação de K1_proximo e K2_proximo para formar a nova chave de 128 bits

    // Implementação do LFSR para atualizar z2
    always_comb begin
        nova_z2 = {z2[62:0], (z2[63] ^ z2[62] ^ z2[60] ^ z2[59])}; // Atualização do LFSR z2 para a próxima iteração
    end

endmodule

