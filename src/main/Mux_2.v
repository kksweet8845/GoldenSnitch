module Mux_3(
    output  [31:0] res,
    input   [31:0] a_0,
    input   [31:0] a_1,
    input          sel;
);


always@(*) begin
    case(sel)
    1'b0: res = a_0;
    1'b1: res = a_1;
    endcase
end

endmodule