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
        addr_i = '0;
        data_i = '0;

        // Libera o reset após 10 unidades de tempo
        #100 rst_n = 1;
        @(negedge clk);

        // Teste: Escrever plaintext nos registradores PT_0~3
        en_i = 1;
        we_i = 4'b1111;  // Ativa escrita para tods os bytes

        addr_i = 8'h34;
        data_i = 32'h0000_0001;  // Modo encrypt
        @(negedge clk);

        addr_i = 8'h00;
        data_i = 32'h89AB_CDEF;  // Parte mais baixa
        @(negedge clk);
        addr_i = 8'h04;
        data_i = 32'h0123_4567;
        @(negedge clk);
        addr_i = 8'h08;
        data_i = 32'h89AB_CDEF;  // Parte seguinte
        @(negedge clk);
        addr_i = 8'h0C;
        data_i = 32'h0123_4567;  // Parte mais alta do plaintext
        @(negedge clk);

        // Teste: Escrever chave nos registradores KEY_0~3
        @(negedge clk); 
        addr_i = 8'h10;
        data_i = 32'h0302_0100;  // Parte mais baixa
        @(negedge clk);
        addr_i = 8'h14;
        data_i = 32'h0706_0504;
        @(negedge clk); 
        addr_i = 8'h18;
        data_i = 32'h0B0A_0908;  // Parte seguinte
        @(negedge clk);
        addr_i = 8'h1C;
        data_i = 32'h0F0E_0D0C;  // Parte mais alta da chave
        @(negedge clk);

        // Teste: Iniciar a operação de criptografia (escrever no CSR)
        addr_i = 8'h30;
        data_i = 32'h00000001;  // Bit 0 é o "start"
        @(negedge clk);
        
        we_i = 4'b0000;  // Desativa a escrita

        // Aguardar o sinal valid ser ativado
        addr_i = 8'h30;  // Endereço do CSR para verificar o "valid"
        @(negedge clk);

        wait(data_o[1] == 1);    // Espera até o bit 1 (valid) ser 1
        // Leitura do ciphertext (CT_0~3)
        @(negedge clk); 

        addr_i = 8'h20;  // Parte mais alta do ciphertext
        @(negedge clk); 
        $display("Ciphertext part LL: %h", data_o);
        
        addr_i = 8'h24;  // Parte seguinte
        @(negedge clk);
        $display("Ciphertext part LH: %h", data_o);

        addr_i = 8'h28;  // Parte seguinte
        @(negedge clk); 
        $display("Ciphertext part HL: %h", data_o);

        addr_i = 8'h2C;  // Parte mais baixa
        @(negedge clk); 
        $display("Ciphertext part HH: %h", data_o);
        
        //

        // Teste 2: Escrever plaintext nos registradores PT_0~3
        en_i = 1;
        we_i = 4'b1111;  // Ativa escrita para tods os bytes

        addr_i = 8'h00;
        data_i = 32'h3230_3234;  // Parte mais baixa
        @(negedge clk);
        addr_i = 8'h04;
        data_i = 32'h6C31_322F;
        @(negedge clk);
        addr_i = 8'h08;
        data_i = 32'h616E_6965;  // Parte seguinte
        @(negedge clk);
        addr_i = 8'h0C;
        data_i = 32'h7463_6364;  // Parte mais alta do plaintext
        @(negedge clk);

        // Teste: Escrever chave nos registradores KEY_0~3
        @(negedge clk); 
        addr_i = 8'h10;
        data_i = 32'h3230_3234;  // Parte mais baixa
        @(negedge clk);
        addr_i = 8'h14;
        data_i = 32'h6C31_322F;
        @(negedge clk); 
        addr_i = 8'h18;
        data_i = 32'h616E_6965;  // Parte seguinte
        @(negedge clk);
        addr_i = 8'h1C;
        data_i = 32'h7463_6364;  // Parte mais alta da chave
        @(negedge clk);

        // Teste: Iniciar a operação de criptografia (escrever no CSR)
        addr_i = 8'h30;
        data_i = 32'h00000001;  // Bit 0 é o "start"
        @(negedge clk);
        
        // Teste: Iniciar a operação de criptografia (escrever no CSR)
        addr_i = 8'h30;
        data_i = 32'h00000001;  // Bit 0 é o "start"
        @(negedge clk);
        
        we_i = 4'b0000;  // Desativa a escrita

        // Aguardar o sinal valid ser ativado
        addr_i = 8'h30;  // Endereço do CSR para verificar o "valid"
        @(negedge clk);

        wait(data_o[1] == 1);    // Espera até o bit 1 (valid) ser 1
        // Leitura do ciphertext (CT_0~3)
        @(negedge clk); 

        addr_i = 8'h20;  // Parte mais alta do ciphertext
        @(negedge clk); 
        $display("Ciphertext part LL: %h", data_o);
        
        addr_i = 8'h24;  // Parte seguinte
        @(negedge clk);
        $display("Ciphertext part LH: %h", data_o);

        addr_i = 8'h28;  // Parte seguinte
        @(negedge clk); 
        $display("Ciphertext part HL: %h", data_o);

        addr_i = 8'h2C;  // Parte mais baixa
        @(negedge clk); 
        $display("Ciphertext part HH: %h", data_o);


        //



        // Teste 3: decrypt
        en_i = 1;
        we_i = 4'b1111;  // Ativa escrita para tods os bytes

        addr_i = 8'h34;
        data_i = 32'h0000_0000;  // Modo decrypt
        @(negedge clk);

        addr_i = 8'h00;
        data_i = 32'h34BA_84F6;  // Parte mais baixa
        @(negedge clk);
        addr_i = 8'h04;
        data_i = 32'h4DB7_7887;
        @(negedge clk);
        addr_i = 8'h08;
        data_i = 32'h3F3E_BAC3;  // Parte seguinte
        @(negedge clk);
        addr_i = 8'h0C;
        data_i = 32'h7094_CBB0;  // Parte mais alta do plaintext
        @(negedge clk);
        
        // Teste: Iniciar a operação de criptografia (escrever no CSR)
        addr_i = 8'h30;
        data_i = 32'h00000001;  // Bit 0 é o "start"
        @(negedge clk);
        
        we_i = 4'b0000;  // Desativa a escrita

        // Aguardar o sinal valid ser ativado
        addr_i = 8'h30;  // Endereço do CSR para verificar o "valid"
        @(negedge clk);

        wait(data_o[1] == 1);    // Espera até o bit 1 (valid) ser 1
        // Leitura do ciphertext (CT_0~3)
        @(negedge clk); 

        addr_i = 8'h20;  // Parte mais alta do ciphertext
        @(negedge clk); 
        $display("Plaintext part LL: %h", data_o);
        
        addr_i = 8'h24;  // Parte seguinte
        @(negedge clk);
        $display("Plaintext part LH: %h", data_o);

        addr_i = 8'h28;  // Parte seguinte
        @(negedge clk); 
        $display("Plaintext part HL: %h", data_o);

        addr_i = 8'h2C;  // Parte mais baixa
        @(negedge clk); 
        $display("Plaintext part HH: %h", data_o);

        // Finaliza a simulação
        $finish();
    end
endmodule
