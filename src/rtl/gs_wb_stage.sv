module GS_WB_STAGE
    import gs_pkg::*
#(
    ADDR_SIZE       = 32,
    WORD_SIZE       = 32,
    BYTES           = 4
)
(

    input   logic           clk,
    input   logic           rst,

    //* from lsu
    input   logic           lsu_rvalid_i,
    input   logic           lsu_busy_i,
    input   logic [31:0]    lsu_rdata_i,

    //* from ex stage
    input   logic           ex_RegWrite_i,
    input   logic           ex_MemRead_i,
    input   logic           ex_rd_addr_i,


    output  logic           wb_RegWrite_o,
    output  logic [31:0]    wb_rdata_o,
    output  logic [4:0]     wb_rd_addr_o,

    input   logic           halt_wb_i,
    input   logic           flush_wb_i,
    input   logic           ex_valid_i,    

    output  logic           wb_ready_o,

);

    logic  [4:0]        rd_addr_reg;
    logic               RegWrite_reg;


    always_ff@(posedge clk or negedge rst) begin
        if(~rst) begin
            rd_addr_reg <= 0;
            RegWrite_reg <= 0;
        end else begin
            if(ex_valid_i && ~halt_wb_i && ~flush_wb_i) begin
                rd_addr_reg <= ex_rd_addr_o;
                RegWrite_reg <= ex_RegWrite_i && ex_MemRead_i;
            end else if(flush_wb_i) begin
                rd_addr_reg <= 0;
                RegWrite_reg <= 0;
            end
        end
    end 


    assign wb_RegWrite_o = RegWrite_reg && lsu_rvalid_i;
    assign wb_rdata_o    = lsu_rdata_i;
    assign wb_rd_addr_o  = rd_addr_reg;

    assign wb_ready_o    = lsu_rvalid_i || ~lsu_busy_i;











endmodule