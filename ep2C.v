module bcd_comparator_4digits (
    input [15:0] a, // A: número BCD de 4 dígitos
    input [15:0] b, // B: número BCD de 4 dígitos
    output a_ge_b   // Saída: se A >= B então 1, senão 0
);

    wire t0, t1, t2, t3; 
    wire i0, i1, i2;   
    assign t0 = a[15:12] > b[15:12];
    assign t1 = a[11:8] > b[11:8];
    assign t2 = a[7:4] > b[7:4];
    assign t3 = a[3:0] > b[3:0];
    assign i0 = a[15:12] == b[15:12];
    assign i1 = (i0 && (a[11:8] == b[11:8]));
    assign i2 = (i1 && (a[7:4] == b[7:4]));

    assign a_ge_b = t0 || (i0 && t1) || (i1 && t2) || (i2 && (t3 || (a[3:0] == b[3:0])));

endmodule
