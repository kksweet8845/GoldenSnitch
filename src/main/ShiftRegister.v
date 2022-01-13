module ShiftRightArithmetic 
    #(parameter BITS = 5)
(
    amt,
    s0,
    sh
);

    input [31:0]    s0;
    input [4:0]     amt;
    output [31:0]   sh;

    wire [31:0] s [0:5];

    assign s[0] = s0;
    assign sh = s[5];

    // Mux2 mux2_0_i(s[1], amt[0], s[0], {s[0][31], s[0][31:1]});
    // Mux2 mux2_1_i(s[2], amt[1], s[1], { {2{s[1][31]}},  s[1][31:2]} );
    // Mux2 mux2_0_i(s[3], amt[2], s[2], { {4{s[2][31]}},  s[2][31:4]} );
    // Mux2 mux2_0_i(s[4], amt[3], s[3], { {8{s[3][31]}},  s[3][31:8]} );
    // Mux2 mux2_0_i(s[5], amt[4], s[4], { {16{s[0][31]}}, s[4][31:16]});

    genvar i, j;
    generate
        for(i=0;i<BITS;i=i+1) begin : gen_mux2
            j = 1<<i;
            Mux2 mux2_i( s[i+1], amt[i], s[i], {j{s[i][31:j]}} );
        end
    endgenerate


endmodule



module Mux2(
    output [31:0] out
    input        sel,
    input [31:0] a0,
    input [31:0] a1,
);


assign out = (sel) ? a1 : a0;

endmodule