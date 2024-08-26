module esquema_chave (
    input  logic         clk,
    input  logic         rst_n,

    input  logic [127:0] k0_i, // Entrada da chave de 128 bits (inicial)
    output logic [ 63:0] kj_o  // Saída da nova chave gerada de 64 bits
);

////////////////////////////////////////////////////////////////////////////////
// Geração da constante de geração de chave
////////////////////////////////////////////////////////////////////////////////

    // Constante c utilizada na geração de chave
    localparam logic [63:0] c = 64'hFFFFFFFFFFFFFFFC;

    // Constante z2 utilizada na geração de chave
    localparam logic [61:0] z2 = 62'b10101111011100000011010010011000101000010001111110010110110011;
    logic [61:0] z;

    /* Round constant */
    logic [63:0] rc;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            z <= z2;
        end
        else begin
            // Rotação circular à direita
            z[60:0] <= z[61:1];
            z[61]   <= z[0];
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rc <= '0;
        end
        else begin
            rc <= {c[63:1], z[0]};
        end
    end

////////////////////////////////////////////////////////////////////////////////
// Geração da chave
////////////////////////////////////////////////////////////////////////////////

    // Dividir a chave de 128 bits em dois blocos de 64 bits
    logic [63:0] k1;
    logic [63:0] k2;
    logic [63:0] k2_proximo;

    // Separando as partes da chave atual
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            k1 <= k0_i[63:0];
            k2 <= k0_i[127:64];
        end
        else begin
            k1 <= k2;
            k2 <= k2_proximo;
        end
    end

    // Implementação da rodada de geração de chave
    logic [63:0] k2_r3;
    assign k2_r3 = {k2[2:0], k2[63:3]};

    logic [63:0] tmp1;
    assign tmp1 = k2_r3 ^ k1;

    logic [63:0] k2_r3_r1;
    assign k2_r3_r1 = {k2_r3[0], k2_r3[63:1]};

    logic [63:0] tmp2;
    assign tmp2 = tmp1 ^ k2_r3_r1;

    assign k2_proximo = tmp2 ^ rc;

    assign kj_o = k1;

endmodule
