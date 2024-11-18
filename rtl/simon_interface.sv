module simon_interface (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        en_i,       // Habilitação
    input  logic [ 3:0] we_i,       // Sinal de escrita
    input  logic [ 7:0] addr_i,     // Endereço de memória
    input  logic [31:0] data_i,     // Dados de entrada
    
    output logic [31:0] data_o      // Dados de saída
);

    // Registradores para texto plano (PT), chave (KEY), e texto cifrado (CT)
    logic [127:0] pt, key, ct;
    logic         start, valid;

    // Leitura de dados
    logic [31:0] r_data;
    always_comb begin
        case (addr_i)
            8'h00:   r_data = pt [ 31: 0];
            8'h04:   r_data = pt [ 63:32];
            8'h08:   r_data = pt [ 95:64];
            8'h0C:   r_data = pt [127:96];
            8'h10:   r_data = key[ 31: 0];
            8'h14:   r_data = key[ 63:32];
            8'h18:   r_data = key[ 95:64];
            8'h1C:   r_data = key[127:96];
            8'h20:   r_data = ct [ 31: 0];
            8'h24:   r_data = ct [ 63:32];
            8'h28:   r_data = ct [ 95:64];
            8'h2C:   r_data = ct [127:96];  // Leitura do ciphertext
            8'h30:   r_data = {30'b0, valid, start};   // "CSR"
            default: r_data = '0;
        endcase
    end

    // Configuração de dado da escrita
    // Escreve dado de entrada somente no byte correspondente ao seu bit do we_i
    // Nos outros bytes, escreve o próprio valor já presente na memória
    logic [31:0] w_data;
    always_comb begin
        w_data[31:24] = we_i[3] ? data_i[31:24] : r_data[31:24];
        w_data[23:16] = we_i[2] ? data_i[23:16] : r_data[23:16];
        w_data[15: 8] = we_i[1] ? data_i[15: 8] : r_data[15: 8];
        w_data[ 7: 0] = we_i[0] ? data_i[ 7: 0] : r_data[ 7: 0];
    end

    // Decodificação de endereços
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pt    <= 128'b0;
            key   <= 128'b0;
            start <= 1'b0;
        end
        else begin
            if (en_i) begin
                if (we_i != '0) begin  // Escrita nos registradores
                    case (addr_i)
                        8'h00:   pt [ 31: 0] <= w_data;
                        8'h04:   pt [ 63:32] <= w_data;
                        8'h08:   pt [ 95:64] <= w_data;
                        8'h0C:   pt [127:96] <= w_data;
                        8'h10:   key[ 31: 0] <= w_data;
                        8'h14:   key[ 63:32] <= w_data;
                        8'h18:   key[ 95:64] <= w_data;
                        8'h1C:   key[127:96] <= w_data;
                        8'h30:   start       <= w_data[0];    // "CSR"
                        default: ;
                    endcase
                end
            end
            if (!en_i || (we_i == '0) || addr_i != 8'h30)
                start <= 1'b0;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_o <= '0;
        end
        else begin
            if (en_i && (we_i == '0))
                data_o <= r_data;
            else
                data_o <= '0;
        end
    end

    top_simon simon(
        .clk(clk),
        .rst_n(rst_n),
        .start_i(start),
        .pt_i(pt),
        .k0_i(key),
        .valid_o(valid),
        .ct_o(ct)
    );

endmodule
