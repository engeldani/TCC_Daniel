module tb_simon_interface;
    timeunit 1ns; timeprecision 1ns;
    // Sinais do testbench
    logic clk;
    logic rst_n;
    logic en_i;
    logic [ 3:0] we_i;
    logic [ 7:0] addr_i;
    logic [31:0] data_i;
    logic [31:0] data_o;

    // Instância do módulo simon_interface
    simon_interface uut (
        .clk(clk),
        .rst_n(rst_n),
        .en_i(en_i),
        .we_i(we_i),
        .addr_i(addr_i),
        .data_i(data_i),
        .data_o(data_o)
    );

    // Clock de 10 unidades de tempo
    always #5 clk = ~clk;

    // Procedimento inicial de teste
    initial begin
        // Inicialização
        clk = 0;
        rst_n = 0;
        en_i = 0;
        we_i = 4'b0;
        addr_i = 32'b0;
        data_i = 32'b0;

        // Libera o reset após 10 unidades de tempo
        #100 rst_n = 1;
        @(negedge clk);

        // Teste: Escrever plaintext nos registradores PT_0~3
        en_i = 1;
        we_i = 4'b1111;  // Ativa escrita para tods os bytes

        addr_i = 32'h0000_0000;
        data_i = 32'h0123_4567;  // Parte mais alta do plaintext
        @(negedge clk);
        addr_i = 32'h0000_0004;
        data_i = 32'h89AB_CDEF;  // Parte seguinte
        @(negedge clk);
        addr_i = 32'h0000_0008;
        data_i = 32'h0123_4567;
        @(negedge clk);
        addr_i = 32'h0000_000C;
        data_i = 32'h89AB_CDEF;  // Parte mais baixa
        @(negedge clk);

        // Teste: Escrever chave nos registradores KEY_0~3
        @(negedge clk); 
        addr_i = 32'h0000_0010;
        data_i = 32'h0F0E_0D0C;  // Parte mais alta da chave
        @(negedge clk);
        addr_i = 32'h0000_0014;
        data_i = 32'h0B0A_0908;  // Parte seguinte
        @(negedge clk); 
        addr_i = 32'h0000_0018;
        data_i = 32'h0706_0504;
        @(negedge clk);
        addr_i = 32'h0000_001C;
        data_i = 32'h0302_0100;  // Parte mais baixa
        @(negedge clk);

        // Teste: Iniciar a operação de criptografia (escrever no CSR)
        addr_i = 32'h0000_0030;
        data_i = 32'h00000001;  // Bit 0 é o "start"
        @(negedge clk);
        
        we_i = 4'b0000;  // Desativa a escrita

        // Aguardar o sinal valid ser ativado
        addr_i = 32'h0000_0030;  // Endereço do CSR para verificar o "valid"
        @(negedge clk);

        wait(data_o[1] == 1);    // Espera até o bit 1 (valid) ser 1
        // Leitura do ciphertext (CT_0~3)
        @(negedge clk); 

        addr_i = 32'h0000_0020;  // Parte mais alta do ciphertext
        @(negedge clk); 
        $display("Ciphertext part 0: %h", data_o);
        
        addr_i = 32'h0000_0024;  // Parte seguinte
        @(negedge clk);
        $display("Ciphertext part 1: %h", data_o);

        addr_i = 32'h0000_0028;  // Parte seguinte
        @(negedge clk); 
        $display("Ciphertext part 2: %h", data_o);

        addr_i = 32'h0000_002C;  // Parte mais baixa
        @(negedge clk); 
        $display("Ciphertext part 3: %h", data_o);
        
        //

        // Teste 2: Escrever plaintext nos registradores PT_0~3
        en_i = 1;
        we_i = 4'b1111;  // Ativa escrita para tods os bytes

        addr_i = 32'h0000_0000;
        data_i = 32'h7463_6364;  // Parte mais alta do plaintext
        @(negedge clk);
        addr_i = 32'h0000_0004;
        data_i = 32'h616E_6965;  // Parte seguinte
        @(negedge clk);
        addr_i = 32'h0000_0008;
        data_i = 32'h6C31_322F;
        @(negedge clk);
        addr_i = 32'h0000_000C;
        data_i = 32'h3230_3234;  // Parte mais baixa
        @(negedge clk);

        // Teste: Escrever chave nos registradores KEY_0~3
        @(negedge clk); 
        addr_i = 32'h0000_0010;
        data_i = 32'h7463_6364;  // Parte mais alta da chave
        @(negedge clk);
        addr_i = 32'h0000_0014;
        data_i = 32'h616E_6965;  // Parte seguinte
        @(negedge clk); 
        addr_i = 32'h0000_0018;
        data_i = 32'h6C31_322F;
        @(negedge clk);
        addr_i = 32'h0000_001C;
        data_i = 32'h3230_3234;  // Parte mais baixa
        @(negedge clk);

        // Teste: Iniciar a operação de criptografia (escrever no CSR)
        addr_i = 32'h0000_0030;
        data_i = 32'h00000001;  // Bit 0 é o "start"
        @(negedge clk);
        
        we_i = 4'b0000;  // Desativa a escrita

        // Aguardar o sinal valid ser ativado
        addr_i = 32'h0000_0030;  // Endereço do CSR para verificar o "valid"
        @(negedge clk);

        wait(data_o[1] == 1);    // Espera até o bit 1 (valid) ser 1
        // Leitura do ciphertext (CT_0~3)
        @(negedge clk); 

        addr_i = 32'h0000_0020;  // Parte mais alta do ciphertext
        @(negedge clk); 
        $display("Ciphertext part 0: %h", data_o);
        
        addr_i = 32'h0000_0024;  // Parte seguinte
        @(negedge clk);
        $display("Ciphertext part 1: %h", data_o);

        addr_i = 32'h0000_0028;  // Parte seguinte
        @(negedge clk); 
        $display("Ciphertext part 2: %h", data_o);

        addr_i = 32'h0000_002C;  // Parte mais baixa
        @(negedge clk); 
        $display("Ciphertext part 3: %h", data_o);

        // Fazer outro teste em sequência!!!!!
        // Chave = 0x74636364616e69656c31322f32303234
        // Pt    = 0x74636364616e69656c31322f32303234

        // Finaliza a simulação
        $finish();
    end
endmodule
