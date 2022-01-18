module GS_ALU
    import gs_pkg::*
(
    input   logic         rst,
    input   logic [31:0]  rs1_data,
    input   logic [31:0]  imm_rs2_data,
    input   logic [3:0]   ALUCtrl,
    output  logic [31:0]  alu_data,
    output  logic         br_flag
);


    always_comb begin
        alu_data = 32'd0;
        br_flag  = 1'b0;
        if(!rst) begin
            alu_data = 0;
        end else begin
            unique case(ALUCtrl)
                PLUS    :   alu_data = rs1_data + imm_rs2_data;
                MINUS   :   alu_data = rs1_data - imm_rs2_data;
                SLL     :   alu_data = (rs1_data << imm_rs2_data[4:0]);
                SLT     :   alu_data = ($signed(rs1_data) < $signed(imm_rs2_data)) ? 1'b1 : 1'b0;
                SLTU    :   alu_data = (rs1_data < imm_rs2_data) ? 1'b1 : 1'b0;
                XOR     :   alu_data = rs1_data ^ imm_rs2_data;
                SRL     :   alu_data = rs1_data >> imm_rs2_data[4:0];
                SRA     :   alu_data = rs1_data >>> imm_rs2_data[4:0];
                OR      :   alu_data = rs1_data | imm_rs2_data;
                AND     :   alu_data = rs1_data & imm_rs2_data;
                FORWARD :   alu_data = imm_rs2_data;
                BEQ     :   br_flag  = (rs1_data == rs2_imm_data) ? 1'b1 : 1'b0;
                BNE     :   br_flag  = (rs1_data != rs2_imm_data) ? 1'b1 : 1'b0;
                BLT     :   br_flag  = ($signed(rs1_data) < $signed(rs2_imm_data)) ? 1'b1 : 1'b0;
                BGE     :   br_flag  = ($signed(rs1_data >= $signed(rs2_imm_data))) ? 1'b1 : 1'b0;
                BLTU    :   br_flag  = (rs1_data < rs2_imm_data) ? 1'b1 : 1'b0;
                BGEU    :   br_flag  = (rs1_data >= rs2_imm_data) ? 1'b1 : 1'b0;
            endcase
        end
    end



endmodule