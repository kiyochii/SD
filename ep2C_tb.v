`timescale 1ns / 1ps

module bcd_comparator_4digits_tb;

    // Entradas
    reg [15:0] a;
    reg [15:0] b;

    // Saída
    wire a_ge_b;

    // Instancia o módulo a ser testado
    bcd_comparator_4digits uut (
        .a(a),
        .b(b),
        .a_ge_b(a_ge_b)
    );

    // Procedimento de teste
    initial begin
        // Início da simulação
        $display("Início dos testes");
        $monitor("Tempo: %0t | a = %h | b = %h | a_ge_b = %b", $time, a, b, a_ge_b);

        // Teste 1: a > b
        a = 16'h1234; // 1234 em BCD
        b = 16'h1233; // 1233 em BCD
        #10;

        // Teste 2: a < b
        a = 16'h1232; // 1232 em BCD
        b = 16'h1233; // 1233 em BCD
        #10;

        // Teste 3: a == b
        a = 16'h5678; // 5678 em BCD
        b = 16'h5678; // 5678 em BCD
        #10;

        // Teste 4: Diferentes dígitos mais significativos
        a = 16'h9000; // 9000 em BCD
        b = 16'h8000; // 8000 em BCD
        #10;

        // Teste 5: Diferentes dígitos menos significativos
        a = 16'h1001; // 1001 em BCD
        b = 16'h1000; // 1000 em BCD
        #10;

        // Teste 6: Zero comparado a um número
        a = 16'h0000; // 0000 em BCD
        b = 16'h9999; // 9999 em BCD
        #10;
    

        // Final da simulação
        $display("Fim dos testes");
        $stop;
    end

endmodule
