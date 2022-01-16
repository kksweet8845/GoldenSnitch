module Mux_3(
    output  [31:0] res,
    input   [31:0] a_0,
    input   [31:0] a_1,
    input   [31:0] a_2,
    input   [1:0]  sel;
);


always@(*) begin
    case(sel)
    2'b00: res = a_0;
    2'b01: res = a_1;
    2'b10: res = a_2;
    default: res = 32'dx;
    endcase
end

endmodule