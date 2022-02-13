module GS_RegisterFile
    import gs_pkg::*
(
    input   logic           clk,
    input   logic           rst,
    input   logic [4:0]     rs1_addr,
    input   logic [4:0]     rs2_addr,
    //* from wb stage
    input   logic           ex_rd_wen,
    input   logic [4:0]     ex_rd_addr,
    input   logic [31:0]    ex_rd_data,
    //* from lsu stage
    input   logic           lsu_rd_wen,
    input   logic [4:0]     lsu_rd_addr,
    input   logic [31:0]    lsu_rd_data,

    output  logic [31:0]    rs1_data,
    output  logic [31:0]    rs2_data
);

    logic [31:0]  rf [0:31];
    integer i;

    assign rs1_data = (rs1_addr == rd_addr) ? rd_data : rf[rs1_addr];
    assign rs2_data = (rs2_addr == rd_addr) ? rd_data : rf[rs2_addr];


    always_ff@(posedge clk or negedge rst) begin
       if(!rst) begin
        for(i=0;i<32;i=i+1)
            rf[i] <= 0;
        end else begin
            if(ex_rd_wen && ex_rd_addr != 0) begin
                rf[ex_rd_addr] <= ex_rd_data; 
            end

            if(lsu_rd_wen && lsu_rd_addr != 0) begin
                rf[lsu_rd_addr] <= lsu_rd_data;
            end
        end   
    end


endmodule