module GS_RegisterFile
    import gs_pkg::*
(
    input   logic           clk,
    input   logic           rst,
    input   logic [4:0]     rs1_addr,
    input   logic [4:0]     rs2_addr,
    input   logic           rd_wen,
    input   logic [4:0]     rd_addr,
    input   logic [31:0]    rd_data,
    output  logic [31:0]    rs1_data,
    output  logic [31:0]    rs2_data
);

    logic [31:0]  rf [0:31];
    integer i;

    assign rs1_data = (rd_wen && rs1_addr == rd_addr) ? rd_data : rf[rs1_addr];
    assign rs2_data = (rd_wen && rs2_addr == rd_addr) ? rd_data : rf[rs2_addr];


    always_ff@(posedge clk or negedge rst) begin
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