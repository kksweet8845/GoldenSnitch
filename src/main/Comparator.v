module Comparator(
    rst,
    BType,
    rs1_data,
    rs2_data,
    BSrc
);

input           rst;
input [2:0]     BType;
input [31:0]    rs1_data;
input [31:0]    rs2_data;

output          BSrc;



always@(*) begin
    if(!rst) begin
        BSrc = 0;
    end else begin
        case(BType)
        3'b000: BSrc = (rs1_data == rs2_data) ? 1'b1 : 1'b0;
        3'b001: BSrc = (rs1_data != rs2_data) ? 1'b1 : 1'b0;
        3'b100: BSrc = ($signed(rs1_data) < $signed(rs2_data)) ? 1'b1 : 1'b0;
        3'b101: BSrc = ($signed(rs1_data) >= $signed(rs2_data)) ? 1'b1 : 1'b0;
        3'b110: BSrc = (rs1_data < rs2_data) ? 1'b1 : 1'b0;
        3'b111: BSrc = (rs1_data >= rs2_data) ? 1'b1 : 1'b0;
        default: BSrc = 0;
        endcase 
    end
end












endmodule