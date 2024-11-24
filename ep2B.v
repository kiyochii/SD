module bcd_subtractor_4digits (
    input [15:0] a,         // Minuendo A de 4 dígitos BCD
    input [15:0] b,         // Subtraendo B de 4 dígitos BCD
    input bin,              // Borrow-in inicial
    output [15:0] diff,     // Diferença de 4 dígitos BCD
    output bout             // Borrow-out final
);

    wire bout0, bout1, bout2, bout3;

    bcd_subtractor primeiro (
        a[3:0],      
        b[3:0],      
        bin,         
        bout0,       
        diff[3:0]    
    );

    bcd_subtractor segundo (
        a[7:4],      
        b[7:4],      
        bout0,       
        bout1,       
        diff[7:4]
    );

    bcd_subtractor terceiro (
        a[11:8],     
        b[11:8],     
        bout1,       
        bout2,       
        diff[11:8]   
    );

    bcd_subtractor quarto (
        a[15:12],
        b[15:12],    
        bout2,       
        bout3,       
        diff[15:12]
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
        num1,         
        num2,         
        bin,          
        borrow_sub,   
        sub           
    );

    assign verificador = borrow_sub || (sub >= 4'b1010);

    subtrator4bits corrigido(
        sub,                  
        (verificador ? 4'b0110 : 4'b0000), 
        1'b0,                
        borrow_bcd,           
        res                   
    );

    assign bout = borrow_sub || borrow_bcd;

endmodule
