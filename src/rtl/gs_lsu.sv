module GS_LSU
    import gs_pkg::*
#(
    ADDR_SIZE       = 32,
    WORD_SIZE       = 32,
    BYTES           = 4
)
(
    input   logic           clk,
    input   logic           rst,

    //* from ex stage
    input   logic           ex_MemRead_i,
    input   logic           ex_MemWrite_i,
    input   logic [2:0]     ex_DataSize_i,
    input   logic [31:0]    ex_rs2_data_i,
    input   logic [31:0]    ex_data_addr_i,


    output  logic           mem_oe_o,
    output  logic [3:0]     mem_web_o,
    output  logic [31:0]    mem_addr_o,
    output  logic [31:0]    mem_data_o,
    input   logic [31:0]    mem_data_i,


    output  logic           rvalid_o,
    output  logic           rdata_o,

    input   logic           ex_valid_i,
    output  logic           lsu_busy_o,

);


    logic           rvalid;
    logic           MemRead_reg;
    logic           MemWrite_reg;
    logic [2:0]     DataSize_reg;
    logic [31:0]    rs2_data_reg;
    logic [31:0]    data_addr_reg;


    logic [2:0]     lsu_fsm_ns, lsu_fsm_cs;


    assign lsu_busy_o = (lsu_fsm_ns != 3'd0);

    always_comb begin
        if(~rst) begin
            lsu_fsm_ns = 0;
        end else begin
            unique case(lsu_fsm_cs)
                3'd0: begin //* start to load/store
                    lsu_fsm_ns = (ex_MemRead_i || ex_MemWrite_i) ? 3'd1 : 3'd0;
                end
                3'd1: begin //* wait 1 cycle
                    lsu_fsm_ns = 3'd2;
                end
                3'd2: begin
                    lsu_fsm_ns = 3'd0;
                end
            endcase
        end
    end

    always_ff@(posedge clk or negedge rst) begin
        if(~rst) begin
            MemRead_reg <= 0;
            MemWrite_reg <= 0;
            DataSize_reg <= 0;
            rs2_data_reg <= 0;
            data_addr_reg <= 0;
        end else begin
            if(ex_valid_i && (lsu_fsm_ns == 3'd0)) begin
                MemRead_reg <= ex_MemRead_i;
                MemWrite_reg <= ex_MemWrite_i;
                DataSize_reg <= ex_DataSize_i;
                rs2_data_reg <= ex_rs2_data_i;
                data_addr_reg <= ex_data_addr_i;
            end
        end
    end


    always_ff@(posedge clk or negedge rst) begin
        if(~rst) begin
            mem_oe_o <= 0;
            mem_addr_o <= 0;
            rvalid_o <= 1'b0;
            rdata_o <= 32'd0;
        end else begin
            unique case(lsu_fsm_cs)
            3'd0: begin
                mem_oe_o <= ~ex_MemWrite_i || ex_MemRead_i;
                mem_addr_o <= ex_data_addr_i;
                if(ex_MemWrite_i) begin
                    unique case(ex_DataSize_i)
                        3'b000: mem_data_o <= {24'd0, ex_rs2_data_i[7:0]}; mem_web_o <= 4'h1;
                        3'b001: mem_data_o <= {16'd0, ex_rs2_data_i[15:0]}; mem_web_o <= 4'h3;
                        3'b010: mem_data_o <= ex_rs2_data_i;    mem_web_o <= 4'hf;
                        default: mem_data_o <= 0; mem_web_o <= 4'h0;
                    endcase
                end else begin
                    mem_data_o <= 0;
                    mem_web_o <= 4'h0;
                end
                rvalid_o <= 1'b0;
                rdata <= 32'd0;
            end
            3'd1: begin
                rvalid_o <= 1'b0;
            end
            3'd2: begin
                rvalid_o <= 1'b1;
                unique case(DataSize_reg)
                    3'b000: begin
                        rdata_o <= {{8{mem_data_i[7]}}, mem_data_i[7:0]};
                    end
                    3'b001: begin //* LH
                        rdata_o <= {{16{mem_data_i[15]}}, mem_data_i[15:0]};
                    end
                    3'b010: begin //* LW
                        rdata_o <= mem_data_i;
                    end
                    3'b101: begin //* LHU
                        rdata_o <= {16'd0, mem_data_i[15:0]};
                    end
                    3'b100: begin //* LBU
                        rdata_o <= {24'd0, mem_data_i[7:0]};
                    end
                    default: begin
                        rdata_o <= 0;
                    end
                endcase
            end
            endcase
        end
    end















endmodule