module testbench;
    logic [127:0] texto; // Definição da variável para o texto de 128 bits
    logic [127:0] chave;       // Definição da variável para a chave de 128 bits
    logic [127:0] criptografia; // Definição da variável para o texto cifrado de 128 bits
    logic [63:0] z2;          // Definição da variável para a constante LFSR z2 de 64 bits

    // Instanciação dos módulos para testar
    rodada_simon simon_inst(
        .texto(texto), // Conectando a entrada de texto claro
        .chave(chave),             // Conectando a entrada de chave
        .criptografia(criptografia) // Conectando a saída de texto cifrado
    );

    esquema_chave chave_inst(
        .chave(chave),             // Conectando a entrada de chave
        .z2(z2),               // Conectando a entrada do LFSR z2
        .nova_chave(chave),         // Conectando a saída da nova chave gerada
        .nova_z2(z2)            // Conectando a saída do novo valor de LFSR z2
    );

    initial begin
        // Definir valores iniciais para texto e chave
        texto = 128'h74636364616e69656c31322f32303234; // "tccdaniel12/2024" em hexadecimal
        chave = 128'h0; // Definindo uma chave inicial para o teste
        z2 = 64'h0;   // Definindo um valor inicial para z2

        // Loop para testar cada rodada de criptografia e geração de chave
        for (int i = 0; i < 68; i++) begin
            #10; // Delay de 10 unidades de tempo para observar resultados
            // Exibir resultados de cada rodada
            $display("Rodada %0d: Criptografia = %h", i, criptografia); // Imprime o número da rodada e o texto cifrado gerado
        end

        $finish; // Termina a simulação após todas as rodadas serem testadas
    end
endmodule

