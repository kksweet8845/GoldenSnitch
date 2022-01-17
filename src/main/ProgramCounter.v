module ProgramCounter(
    input clk,
    input rst,
    input [31:0] pc_in,
    input [31:0] pc_en,
    output [31:0] pc_out,
);


reg pc;

always@(negedge clk or negedge rst) begin
    if(!rst) begin
        pc <= 0;
    end else begin
        pc <= (pc_en) ? pc_in : pc;
    end
end

assign pc_out = pc;




endmodule