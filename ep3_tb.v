`timescale 1ns / 1ps

module bcd_divider_tb;

    // Inputs
    reg clk;
    reg rst;
    reg start;
    reg [15:0] dividend;
    reg [15:0] divisor;

    // Outputs
    wire [15:0] quotient;
    wire [15:0] remainder;
    wire end_division;

    // Instantiate the DUT (Device Under Test)
    bcd_divider uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .dividend(dividend),
        .divisor(divisor),
        .quotient(quotient),
        .remainder(remainder),
        .end_division(end_division)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Geração de arquivo VCD para GTKWave
    initial begin
        $dumpfile("bcd_divider_tb.vcd"); // Nome do arquivo VCD gerado
        $dumpvars(0, bcd_divider_tb);    // Registra todas as variáveis do testbench
    end

    // Stimulus
    initial begin
        // Initialize inputs
        rst = 1;
        start = 0;
        dividend = 0;
        divisor = 0;

        // Reset sequence
        #10;
        rst = 0;

        // Test case 1: Simple division
        #10;
        start = 1;
        dividend = 16'd25;   // 25 BCD
        divisor = 16'd4;     // 4 BCD

        #10;
        start = 0;

        // Wait for division to complete
        wait(end_division);
        #10;

        // Check results
        $display("Test Case 1:");
        $display("Dividend: %d, Divisor: %d", dividend, divisor);
        $display("Quotient: %d, Remainder: %d", quotient, remainder);
        $display("");

        // Test case 2: Division by zero
        #10;
        rst = 1; #10; rst = 0; // Reset
        start = 1;
        dividend = 16'd30;   // 30 BCD
        divisor = 16'd0;     // Division by zero

        #10;
        start = 0;

        // Wait for division to complete
        wait(end_division);
        #10;

        // Check results
        $display("Test Case 2:");
        $display("Dividend: %d, Divisor: %d", dividend, divisor);
        $display("Quotient: %d, Remainder: %d", quotient, remainder);
        $display("");

        // Test case 3: Large numbers
        #10;
        rst = 1; #10; rst = 0; // Reset
        start = 1;
        dividend = 16'd1234;  // 1234 BCD
        divisor = 16'd12;     // 12 BCD

        #10;
        start = 0;

        // Wait for division to complete
        wait(end_division);
        #10;

        // Check results
        $display("Test Case 3:");
        $display("Dividend: %d, Divisor: %d", dividend, divisor);
        $display("Quotient: %d, Remainder: %d", quotient, remainder);
        $display("");

        // End of simulation
        $finish;
    end
endmodule
