module testbench;
    logic [127:0] texto; // Definição da variável para o texto de 128 bits
    logic [127:0] chave;       // Definição da variável para a chave de 128 bits
    logic [127:0] criptografia; // Definição da variável para o texto cifrado de 128 bits

    logic clk = 0;
    always #10 clk = ~clk;

    logic rst_n = 0;

    top_simon simon(
        .clk(clk),
        .rst_n(rst_n),
        .pt_i(texto),
        .k0_i(chave),
        .ct_o(criptografia)
    );

    initial begin
        // Definir valores iniciais para texto e chave
        texto = 128'h74636364616e69656c31322f32303234; // "tccdaniel12/2024" em hexadecimal
        chave = 128'h74636364616e69656c31322f32303234; // Definindo uma chave inicial para o teste
        #100 rst_n = 1;

        // Loop para testar cada rodada de criptografia e geração de chave
        for (int i = 0; i < 68; i++) begin
            @(negedge clk);
            // Exibir resultados de cada rodada
        end
        
        $display("Criptografia = %h", criptografia); // Imprime o número da rodada e o texto cifrado gerado

        $finish(); // Termina a simulação após todas as rodadas serem testadas
    end
endmodule
