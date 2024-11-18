module bcd_subtractor_4digits (
    input [15:0] a,         // Minuendo A de 4 dígitos BCD
    input [15:0] b,         // Subtraendo B de 4 dígitos BCD
    input bin,              // Borrow-in inicial
    output [15:0] diff,     // Diferença de 4 dígitos BCD
    output bout             // Borrow-out final
);

    wire bout0, bout1, bout2, bout3;

    bcd_subtractor primeiro (
        .num1(a[3:0]),
        .num2(b[3:0]),
        .bin(bin),
        .res(diff[3:0]),
        .bout(bout0)
    );

        bcd_subtractor segundo (
        .num1(a[7:4]),
        .num2(b[7:4]),
        .bin(bout0),
        .res(diff[7:4]),
        .bout(bout1)
    );

    bcd_subtractor terceiro (
        .num1(a[11:8]),
        .num2(b[11:8]),
        .bin(bout1),
        .res(diff[11:8]),
        .bout(bout2)
    );

    bcd_subtractor quarto (
        .num1(a[15:12]),
        .num2(b[15:12]),
        .bin(bout2),
        .res(diff[15:12]),
        .bout(bout3)
    );

    assign bout = bout3;
endmodule

module subtrator4bits (
    input [3:0] n1,  
    input [3:0] n2,        
    input bin,           
    output bout,          
    output [3:0] res       
);
    wire [4:0] full_res;

    assign full_res = {1'b0, n1} - {1'b0, n2} - bin;

    assign res = full_res[3:0];

    assign bout = full_res[4];

endmodule

module bcd_subtractor(
    input [3:0] num1,    
    input [3:0] num2,    
    input bin,          
    output bout,        
    output [3:0] res    
);

    wire [3:0] sub;       
    wire borrow_sub;      
    wire borrow_bcd;      
    wire verificador;     

    subtrator4bits inicial(
        .n1(num1),
        .n2(num2),
        .bin(bin),
        .res(sub),
        .bout(borrow_sub)  
    );

    assign verificador = borrow_sub || (sub >= 4'b1010);

    subtrator4bits corrigido(
        .n1(sub),
        .n2(verificador ? 4'b0110 : 4'b0000),
        .bin(1'b0),
        .res(res),
        .bout(borrow_bcd)  
    );

    assign bout = borrow_sub || borrow_bcd;

endmodule
