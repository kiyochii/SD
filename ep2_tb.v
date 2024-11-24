module tb_bcd_adder_4digits;

    reg [15:0] a;        // Entrada A
    reg [15:0] b;        // Entrada B
    reg cin;             // Carry-in
    wire [15:0] sum;     // Saída da soma
    wire cout;           // Carry-out

    // Instanciando o módulo a ser testado
    bcd_adder_4digits dut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    // Procedimento inicial para os testes
    initial begin
        // Configuração do dumpfile e dumpvars
        $dumpfile("tb_bcd_adder_4digits.vcd");
        $dumpvars(0, tb_bcd_adder_4digits);

        // Início da simulação
        $display("Iniciando os testes...");
        $monitor("Time: %0d | A = %h | B = %h | Cin = %b || Sum = %h | Cout = %b", $time, a, b, cin, sum, cout);

        // Caso 1: Soma simples sem carry
        a = 16'h1234; b = 16'h2345; cin = 0;
        #10; // Esperado: Sum = 16'h3579, Cout = 0

        // Caso 2: Soma com carry-in
        a = 16'h5678; b = 16'h4321; cin = 1;
        #10; // Esperado: Sum = 16'h9999, Cout = 0

        // Caso 3: Soma que gera carry-out
        a = 16'h9999; b = 16'h0001; cin = 0;
        #10; // Esperado: Sum = 16'h0000, Cout = 1

        // Caso 4: Soma que envolve correção de BCD
        a = 16'h8976; b = 16'h7894; cin = 0;
        #10; // Esperado: Sum = 16'h6860, Cout = 1

        // Caso 5: Soma com entradas máximas
        a = 16'h9999; b = 16'h9999; cin = 1;
        #10; // Esperado: Sum = 16'h9999, Cout = 1

        // Fim da simulação
        $display("Testes concluídos.");
        $stop;
    end
endmodule
