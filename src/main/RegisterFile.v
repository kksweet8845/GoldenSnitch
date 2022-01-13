module RegisterFile(
    clk,
    rst,
    rs1_addr,
    rs2_addr,
    rd_wen,
    rd_addr,
    rd_data,
    rs1_data,
    rs2_data
);

input clk;
input rst;
input [4:0]     rs1_addr;
input [4:0]     rs2_addr;

input           rd_wen;
input [4:0]     rd_addr;
input [31:0]    rd_data;

output [31:0]   rs1_data;
output [31:0]   rs2_data;


reg [31:0] rf [0:31];
integer i;


assign rs1_data = (rd_wen && rs1_addr == rd_addr) ? rd_data : rf[rs1_addr]; 
assign rs2_data = (rd_wen && rs2_addr == rd_addr) ? rd_data : rf[rs2_addr];


always@(posedge clk or negedge rst) begin
    if(!rst) begin
        for(i=0;i<32;i=i+1)
            rf[i] <= 0;
    end else begin
        if(rd_wen && rd_addr != 0) begin
           rf[rd_addr] <= rd_data; 
        end
    end   
end













endmodule