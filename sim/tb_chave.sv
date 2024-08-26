module tb_chave;

    logic clk = 1'b0;
    always #10 clk = ~clk;

    logic rst_n = 1'b0;
    initial begin
        #100 rst_n = 1'b1;
    end

    logic [63:0] kj;

    esquema_chave chave (
        .clk  (clk                                  ),
        .rst_n(rst_n                                ),
        .k0_i (128'h1b1a1918131211100b0a090803020100),
        .kj_o (kj                                   )
    );

    int i;
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            i <= 0;
        end
        else begin
            if (i < 68) begin
                $display("k%02d = %h", i, kj);
                i <= i + 1;
            end
            else begin 
                $finish();
            end
        end
    end

endmodule
