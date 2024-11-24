module bcd_divider(
    input clk,             // Clock signal
    input rst,             // Reset signal
    input start,           // Start signal
    input [15:0] dividend, // Dividend
    input [15:0] divisor,  // Divisor
    output [15:0] quotient,// Quotient
    output [15:0] remainder,// Remainder
    output end_division    // Finish signal
);

    wire rged, muxr, muxq, loadq, loadr;
    //so inicializa
    bcd_divider_control uc (
        .start(start),
        .rged(rged),
        .clk(clk),
        .rst(rst),
        .muxr(muxr),
        .muxq(muxq),
        .loadq(loadq),
        .loadr(loadr),
        .end_division(end_division)
    );

    bcd_divider_df dataflow (
        .dividend(dividend),
        .divisor(divisor),
        .muxr(muxr),
        .muxq(muxq),
        .clk(clk),
        .rst(rst),
        .loadq(loadq),
        .loadr(loadr),
        .quotient(quotient),
        .remainder(remainder),
        .rged(rged)
    );


endmodule

module bcd_divider_df (
    input [15:0] dividend,  // Dividend
    input [15:0] divisor,   // Divisor
    input muxr,             // Mux select signal for remainder
    input muxq,             // Mux select signal for quotient
    input clk,              // Clock signal
    input rst,              // Reset signal
    input loadq,            // Load signal for quotient
    input loadr,            // Load signal for remainder
    output reg [15:0] quotient, // Quotient
    output reg [15:0] remainder,// Remainder
    output rged             // Greater or Equal signal
);

    wire [15:0] muxRresult;
    wire [15:0] muxQresult;
    wire [15:0] sumResult;
    wire [15:0] subtractorResult;
    wire [15:0] subA;
    wire [15:0] addA;
    wire bout;
    wire cout; //so para armazenar um valor n utilizado
   
    assign subA = remainder;
    assign addA = quotient;
    bcd_subtractor_4digits subtrator
    (
        .a(remainder),
        .b(divisor),
        .bin(1'b0),
        .diff(subtractorResult),
        .bout(bout)
    );
    bcd_adder_4digits somador
    (
        .a(quotient),
        .b(16'b0001),
        .cin(1'b0),
        .sum(sumResult),
        .cout(cout)

    );
    assign muxQresult = muxq ? sumResult : 16'b0;
    assign muxRresult = muxr ? subtractorResult : dividend;
    bcd_comparator_4digits comparador(
        .a(remainder),
        .b(divisor),
        .a_ge_b(rged)
    );
    always @(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            remainder <= 16'b0;
            quotient <= 16'b0;
        end
        else 
        begin
        if (loadr)
        remainder <= muxRresult;
         if (loadq)
        quotient <= muxQresult;
        end
    end
endmodule

module bcd_divider_control(
    input start,        // Start signal
    input rged,         // GE signal
    input clk,          // Clock signal
    input rst,          // Reset signal
    output reg muxr,    // Mux select signal for dividend
    output reg muxq,    // Mux select signal for quotient
    output reg loadq,   // Load signal for quotient
    output reg loadr,   // Load signal for remainder
    output reg end_division // Finish signal
);

localparam parado = 2'b00;
localparam processando = 2'b01;
localparam termino = 2'b10;

reg [1:0] atual, proximo;

always @(posedge clk or posedge rst) begin
    if (rst)
        atual <= parado;
    else
        atual <= proximo; // Atualiza o estado na borda de subida do clock
end

// Determinação do próximo estado
always @(atual, start, rged) begin
    case (atual)
        parado: proximo = start ? processando : parado;
        processando: proximo = rged ? processando : termino;
        termino: proximo = parado;
        default: proximo = parado;
    endcase
end

// Definição das saídas baseadas no estado atual
always @(*) begin
    // Resetando os sinais
    muxr = 0;
    muxq = 0;
    loadq = 0;
    loadr = 0;
    end_division = 0;

    case (atual)
        parado: begin
            muxr = 0;
            muxq = 0;
            loadr = 1; 
            loadq = 1;
        end
        processando: begin
            muxq = 1;
            if (rged) begin
                loadr = 1;
                loadq = 1;
            end else begin
                loadr = 0;
                loadq = 0;
            end
            muxr = rged;
        end
        termino: begin
            loadr = 0;
            loadq = 0;
         
            end_division = 1; // Sinaliza o término da divisão
        end
    endcase
end

endmodule


module bcd_adder_4digits (
input [15:0] a, // Adendo A de 4 d´ıgitos BCD
input [15:0] b, // Adendo B de 4 d´ıgitos BCD
input cin, // Carry-in BCD
output [15:0] sum, // Soma de 4 d´ıgitos BCD
output cout // Carry-out BCD
);

wire [3:0] sum_0, sum_1, sum_2, sum_3;
wire carry_0, carry_1, carry_2, carry_3;

bcd_adder primeiro (
    .num1(a[3:0]),
    .num2(b[3:0]),
    .cin(cin),
    .cout(carry_0),
    .res(sum_0)
);

bcd_adder segundo (
    .num1(a[7:4]),
    .num2(b[7:4]),
    .cin(carry_0),
    .cout(carry_1),
    .res(sum_1)
);

bcd_adder terceiro (
    .num1(a[11:8]),
    .num2(b[11:8]),
    .cin(carry_1),
    .cout(carry_2),
    .res(sum_2)
);

bcd_adder quarto (
    .num1(a[15:12]),
    .num2(b[15:12]),
    .cin(carry_2),
    .cout(carry_3),
    .res(sum_3)
);

assign sum = {sum_3, sum_2, sum_1, sum_0};
assign cout = carry_3;

endmodule


module somadorCompleto(
    input [0:0]a,
    input [0:0]b,
    input [0:0]cin,
    output cout,
    output res
);
assign cout = (a&b)|(a&cin)|(b&cin);
assign res = a ^ b ^ cin;

endmodule

module somador4bits(
    input [3:0]s1,
    input [3:0]s2,
    input [0:0]cin,
    output [0:0]cout,
    output [3:0]res
);

wire aux [3:0];
genvar i;
generate
    for(i = 0; i < 4; i = i+1) begin
        if(i == 0) begin
            somadorCompleto fa(
                s1[0],
                s2[0],
                cin[0],
                aux[0],
                res[0]
            );
        end
        else begin
            somadorCompleto fa(
                s1[i],
                s2[i],
                aux[i-1],
                aux[i],
                res[i]
            );
        end
    end
endgenerate
assign cout = aux[3];
endmodule


module bcd_adder(
input [3:0]num1,
input [3:0]num2,
input cin,
output cout,
output [3:0] res
);

wire [3:0] soma;
wire carrysum;
wire carrybcd;
wire verificador;

somador4bits antes(
    num1,
    num2,
    cin,
    carrysum,
    soma
);

assign verificador = ((soma > 4'b1001) || carrysum);

somador4bits corrigido(
    soma,
    verificador ? 4'b0110 : 4'b0000,
    1'b0,
    carrybcd,
    res
);
assign cout = carrysum || carrybcd;

endmodule

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
