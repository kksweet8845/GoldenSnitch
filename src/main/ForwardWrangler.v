module ForwardWrangler(
    rst,
    E_ALUSrc
    E_rs1_forward,
    E_rs2_forward,
    M_rs1_forward,
    M_rs2_forward,
    rs2_sel,
    rs1_sel,
    rs2_sw_sel
);


input rst;
input E_ALUSrc;
input E_rs1_forward,
input E_rs2_forward,
input M_rs1_forward,
input M_rs2_forward,

output reg [1:0]    rs2_sel;
output reg [1:0]    rs1_sel;
output reg [1:0]    rs2_sw_sel;


always@(*) begin 
    if(!rst) begin
        rs2_sel = 0;
        rs1_sel = 0;
        rs2_sw_sel = 0;
    end else begin
        case({E_ALUSrc, E_rs2_forward, M_rs2_forward})
        3'b100: rs2_sel = 2'b01; rs2_sw_sel = 0;
        3'b11x: rs2_sel = 2'b11; rs2_sw_sel = 0;
        3'b101: rs2_sel = 2'b10; rs2_sw_sel = 0;
        3'b01x: rs2_sel = 2'b00; rs2_sw_sel = 2'b10;
        3'b001: rs2_sel = 2'b00; rs2_sw_sel = 2'b01;
        default: rs2_sel = 2'b00; rs2_sel_sel = 2'b00;
        endcase
        case({E_rs1_forward, M_rs1_forward})
        2'b1x: rs1_sel = 2'b10;
        2'b01: rs1_sel = 2'b01;
        default: rs1_sel = 2'b00;
        endcase
    end
end





endmodule