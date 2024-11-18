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