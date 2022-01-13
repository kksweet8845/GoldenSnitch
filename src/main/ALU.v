module ALU(
    rst,
    rs1_data,
    rs2_data,
    ALUCtrl,
    alu_data
);


input rst;

input [31:0]    rs1_data;
input [31:0]    rs2_data;
input [3:0]     ALUCtrl;
output reg [31:0]   alu_data;


wire [31:0]  sra_out;
wire [4:0]   sra_amt;
wire [31:0]  sra_in;


always@(*) begin
    if(!rst) begin
        alu_data = 0;
    end else begin
        case(ALUCtrl)
            4'b0000: alu_data = rs1_data + rs2_data;
            4'b1000: alu_data = rs1_data - rs2_data;
            4'b0001: alu_data = (rs1_data << rs2_data[4:0]);
            4'b0010: alu_data = ($signed(rs1_data) < $signed(rs2_data)) ? 1'b1 : 1'b0;
            4'b0011: alu_data = (rs1_data < rs2_data) ? 1'b1 : 1'b0;
            4'b0100: alu_data = rs1_data ^ rs2_data;
            4'b0101: alu_data = rs1_data >> rs2_data[4:0];
            4'b1101: alu_data = sra_out; //* >>>
            4'b0110: alu_data = rs1_data | rs2_data;
            4'b0111: alu_data = rs1_data & rs2_data;
            4'b1111: alu_data = rs2_data; //* forward imm;
        endcase
    end
end


assign sra_in = rs1_data;
assign sra_amt = rs2_data;


    ShiftRightArithmetic sra(
        .sh     (sra_out         ),
        .s0     (sra_in          ),
        .amt    (sra_amt         )
    );


endmodule