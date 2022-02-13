module GS_ID_STAGE
    import gs_pkg::*
#(
    ADDR_SIZE       = 32,
    WORD_SIZE       = 32,
    BYTES           = 4 
)
(
    input   logic           clk,
    input   logic           rst,


    //* from if stage
    input   logic [31:0]    pc_4_i,
    input   logic [31:0]    pc_i,
    input   logic [31:0]    instr_i,

    //* to ex stage
    output  logic [3:0]     ALUType_o,
    output  logic           BType_o,
    output  logic [1:0]     PCSrc_o,
    output  logic           MemWrite_o,
    output  logic           MemRead_o,
    output  logic           RDSrc_o,
    output  logic           ALUSrc_o,
    output  logic           RegWrite_o,
    output  logic [2:0]     DataSize_o,
    output  logic [31:0]    imm_o,
    output  logic [4:0]     rs1_addr_o,
    output  logic [4:0]     rs2_addr_o,
    output  logic [4:0]     rd_addr_o,
    output  logic [31:0]    pc_to_reg_data_o;


    //* read data
    input   logic [31:0]    rs1_wb_data_i,
    input   logic [31:0]    rs1_ex_data_i,
    input   logic [1:0]     rs1_forward_sel_i,
    output  logic [31:0]    rs1_data_o,

    input   logic [31:0]    rs2_wb_data_i,
    input   logic [31:0]    rs2_ex_data_i,
    input   logic [1:0]     rs2_forward_sel_i,
    output  logic [31:0]    rs2_data_o,

    //* from ex stage
    input   logic           ex_RegWrite_i;
    input   logic [4:0]     ex_rd_addr_i;
    input   logic [31:0]    ex_rd_data_i;

    //* from LSU, from wb stage
    input   logic           lsu_MemRead_i;
    input   logic [4:0]     lsu_rd_addr_i;
    input   logic [31:0]    lsu_rd_data_i;

    //* control status signal
    input   logic           halt_id_i,
    input   logic           flush_id_i,
    input   logic           if_valid_i,

    output  logic           id_valid_o,
); 






    logic [3:0]     id_fsm_ns, id_fsm_cs;
    logic [31:0]    instr;
    logic           id_valid;


/*=============================================================================+
/                                 DECODER PORT                                 /
 +=============================================================================*/
    logic [31:0]    decoder_instr_i;
    logic [2:0]     decoder_ImmType_o;
    logic [2:0]     decoder_ImmType_o;
    logic           decoder_PCtoRegSrc_o;
    logic [3:0]     decoder_ALUType_o;
    logic           decoder_BType_o;
    logic [1:0]     decoder_PCSrc_o;
    logic           decoder_MemWrite_o;
    logic           decoder_MemRead_o;
    logic           decoder_RDSrc_o;
    logic           decoder_ALUSrc_o;
    logic           decoder_RegWrite_o;
    logic [2:0]     decoder_DataSize_o;
    logic [31:0]    decoder_imm_o;
    logic [4:0]     decoder_rs1_addr_o;
    logic [4:0]     decoder_rs2_addr_o;
    logic [4:0]     decoder_rd_addr_o;


    //* REGISTER FILE PORT
    logic [4:0]     rf_rs1_addr_i;
    logic [4:0]     rf_rs2_addr_i;
    logic           rf_ex_rd_wen_i;
    logic [4:0]     rf_ex_rd_addr_i;
    logic [31:0]    rf_ex_rd_data_i;
    logic           rf_lsu_rd_wen_i;
    logic [4:0]     rf_lsu_rd_addr_i;
    logic [31:0]    rf_lsu_rd_data_i;
    logic [31:0]    rf_rs1_data_o;
    logic [31:0]    rf_rs2_data_o;

    //* pc_out_imm
    logic [31:0]    pc_out_imm

    //* pc_4 or pc_out_imm src
    logic           pc_src_mux_sel;
    logic [31:0]    pc_to_reg_data;

    always_ff@(posedge clk or negedge rst) begin
        if(!rst) begin
            instr <= 32'd0;
            id_valid <= 1'b0;
        end else begin
            if(if_valid_i &&  ~halt_id_i && ~flush_id_i) begin
                instr <= instr_i;
            end else if(flush_id_i) begin
                instr <= 32'd0;
            end
            id_valid <= ~halt_id_i && ~flush_id_i;
        end
    end

    //* Decoder_i
    GS_Decoder decoder_i(
        .rst            (rst                        ),
        .instr          (decoder_instr_i            ),
        .ImmType        (decoder_ImmType_o          ),
        .PCtoRegSrc     (decoder_PCtoRegSrc_o       ),
        .ALUType        (decoder_ALUType_o          ),
        .BType          (decoder_BType_o            ),
        .PCSrc          (decoder_PCSrc_o            ),
        .MemWrite       (decoder_MemWrite_o         ),
        .MemRead        (decoder_MemRead_o          ),
        .RDSrc          (decoder_RDSrc_o            ),
        .ALUSrc         (decoder_ALUSrc_o           ),
        .RegWrite       (decoder_RegWrite_o         ),
        .DataSize       (decoder_DataSize_o         ),
        .imm            (decoder_imm_o              ),
        .rs1_addr       (decoder_rs1_addr_o         ),
        .rs2_addr       (decoder_rs2_addr_o         ),
        .rd_addr        (decoder_rd_addr_o          )
    );


    //* Register File
    GS_RegisterFile register_file_i(
        .clk                (clk                            ),
        .rst                (rst                            ),
        .rs1_addr           (rf_rs1_addr_i                  ),
        .rs2_addr           (rf_rs2_addr_i                  ),
        .ex_rd_wen          (rf_ex_rd_wen_i                 ),
        .ex_rd_addr         (rf_ex_rd_addr_i                ),
        .ex_rd_data         (rf_ex_rd_data_i                ),
        .lsu_rd_wen         (rf_lsu_rd_wen_i                ),
        .lsu_rd_addr        (rf_lsu_rd_addr_i               ),
        .lsu_rd_data        (rf_lsu_rd_data_i               ),
        .rs1_data           (rf_rs1_data_o                  ),
        .rs2_data           (rf_rs2_data_o                  )
    );


    //* MUX 3

    GS_MUX_3 
    #(
        .SEL_WIDTH              (2),
        .SRC_WIDTH              (32),
        .INPUT_0                (REG_NO_FORWARD),
        .INPUT_1                (REG_EX_FORWARD),
        .INPUT_2                (REG_WB_FORWARD)
    ) rs1_src_mux_i(
        .a0                     (rf_rs1_data_o      ),
        .a1                     (rs1_ex_data_i      ),
        .a2                     (rs1_wb_data_i      ),
        .sel                    (rs1_forward_sel_i  ),
        .out                    (rs1_data_o         )
    );
    

    GS_MUX_3 
    #(
        .SEL_WIDTH              (2),
        .SRC_WIDTH              (32),
        .INPUT_0                (REG_NO_FORWARD),
        .INPUT_1                (REG_EX_FORWARD),
        .INPUT_2                (REG_WB_FORWARD)
    ) rs2_src_mux_i(
        .a0                     (rf_rs2_data_o      ),
        .a1                     (rs2_ex_data_i      ),
        .a2                     (rs2_wb_data_i      ),
        .sel                    (rs2_forward_sel_i  ),
        .out                    (rs2_data_o         )
    );

    //* pc_out + imm    
    assign pc_out_imm = pc_i + decoder_imm_o;

    //* pc_4 or pc_out_imm
    GS_MUX_2 #(
        .SEL_WIDTH(1),
        .SRC_WIDTH(32),
        .INPUT_0(1'b0),
        .INPUT_1(1'b1)
    ) pc_src_mux(
        .a0                     (pc_4_i             ),
        .a1                     (pc_out_imm         ),
        .sel                    (pc_src_mux_sel     ),
        .out                    (pc_to_reg_data     )
    );



//* connection
assign  pc_src_mux_sel      = decoder_PCtoRegSrc_o;

assign  ALUType_o           = decoder_ALUType_o;
assign  BType_o             = decoder_BType_o;
assign  PCSrc_o             = decoder_PCSrc_o; // to controller
assign  MemWrite_o          = decoder_MemWrite_o;
assign  MemRead_o           = decoder_MemRead_o;
assign  RDSrc_o             = decoder_RDSrc_o;
assign  ALUSrc_o            = decoder_ALUSrc_o;
assign  RegWrite_o          = decoder_RegWrite_o;
assign  DataSize_o          = decoder_DataSize_o;
assign  imm_o               = decoder_imm_o;
assign  rs1_addr_o          = decoder_rs1_addr_o;
assign  rs2_addr_o          = decoder_rs2_addr_o;
assign  rd_addr_o           = decoder_rd_addr_o;

assign  rf_rs1_addr_i       = decoder_rs1_addr_o;
assign  rf_rs2_addr_i       = decoder_rs2_addr_o;

assign  rf_ex_rd_wen_i      = ex_RegWrite_i;
assign  rf_ex_rd_addr_i     = ex_rd_addr_i;
assign  rf_ex_rd_data_i     = ex_rd_data_i;

assign  rf_lsu_rd_wen_i     = lsu_MemRead_i;
assign  rf_lsu_rd_addr_i    = lsu_rd_addr_i;
assign  rf_lsu_rd_data_i    = lsu_rd_data_i;
assign  pc_to_reg_data_o    = pc_to_reg_data;
assign  id_valid_o          = id_valid;




endmodule