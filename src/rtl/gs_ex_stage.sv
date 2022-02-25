module GS_EX_STAGE
    import gs_pkg::*
#(
    ADDR_SIZE       = 32,
    WORD_SIZE       = 32,
    BYTES           = 4
)
(
    input   logic           clk,
    input   logic           rst,

    
    //* from id stage
    input   logic [3:0]     id_ALUType_i,
    input   logic           id_BType_i,
    input   logic [1:0]     id_PCSrc_i,
    input   logic           id_MemWrite_i,
    input   logic           id_MemRead_i,
    input   logic           id_RDSrc_i,
    input   logic           id_ALUSrc_i,
    input   logic           id_RegWrite_i,
    input   logic [2:0]     id_DataSize_i,
    input   logic [31:0]    id_imm_i,
    input   logic [4:0]     id_rs1_addr_i,
    input   logic [4:0]     id_rs2_addr_i,
    input   logic [4:0]     id_rd_addr_i,

    input   logic [31:0]    id_pc_4_i,
    input   logic [31:0]    id_pc_imm_i,
    input   logic [31:0]    id_pc_to_reg_i,

    input   logic [31:0]    id_rs1_data_i,
    input   logic [31:0]    id_rs2_data_i,

    //* to load store unit
    output  logic           lsu_MemWrite_o,
    output  logic           lsu_MemRead_o,
    output  logic [2:0]     lsu_DataSize_o,
    output  logic [31:0]    lsu_rs2_data_o,
    output  logic [31:0]    lsu_data_addr_o,

    
    //* to register file
    output  logic           rf_RegWrite_o,
    output  logic [4:0]     rf_rd_addr_o,
    output  logic [31:0]    rf_rd_data_o,

    //* to controller
    output  logic [1:0]     ex_PCSrc_o,

    //* control status signal
    input   logic           id_valid_i,
    input   logic           halt_ex_i,
    input   logic           flush_ex_i,

    output  logic           ex_valid_o,

    output  logic [31:0]    ex_br_addr_o,
    output  logic           ex_br_taken_o,
    output  logic [31:0]    ex_uncod_jump_addr_o

);

    //* status
    logic           ex_valid;


    logic [3:0]     ALUType_reg;
    logic           BType_reg;
    logic [1:0]     PCSrc_reg;
    logic           MemWrite_reg;
    logic           MemRead_reg;
    logic           RDSrc_reg; //* The rd_data is pc or alu_ou_reg;
    logic           ALUSrc_reg;
    logic           RegWrite_reg;
    logic           DataSize_reg;
    logic [31:0]    imm_reg;
    logic [4:0]     rs1_addr_reg;
    logic [4:0]     rs2_addr_reg;
    logic [4:0]     rd_addr_reg;

    logic [31:0]    pc_4_reg;
    logic [31:0]    pc_imm_reg;
    logic [31:0]    pc_to_reg_reg;

    logic [31:0]    rs1_data_reg;
    logic [31:0]    rs2_data_reg; 

    //* rs2_data_mux_port
    logic [31:0]    rs2_mux_rs2_data;
    logic [31:0]    rs2_mux_imm;
    logic           rs2_mux_sel;
    logic [31:0]    rs2_mux_out;

    //* pc_or_alu_mux port
    logic [31:0]    pc_or_alu_mux_pc_to_reg;
    logic [31:0]    pc_or_alu_mux_alu_data;
    logic           pc_or_alu_mux_sel;
    logic [31:0]    pc_or_alu_mux_out;

    //* alu port
    logic [31:0]    alu_rs1_data;
    logic [31:0]    alu_imm_rs2_data;
    logic [3:0]     alu_ALUCtrl;
    logic [31:0]    alu_alu_data;
    logic           alu_br_flag;


    always_ff@(posedge clk or negedge rst) begin
        if(!rst) begin
            ALUType_reg     <= 0;
            BType_reg       <= 0;
            PCSrc_reg       <= 0;
            MemWrite_reg    <= 0;
            MemRead_reg     <= 0;
            RDSrc_reg       <= 0;
            ALUSrc_reg      <= 0;
            RegWrite_reg    <= 0;
            DataSize_reg    <= 0;
            imm_reg         <= 0;
            rs1_addr_reg    <= 0;
            rs2_addr_reg    <= 0;
            rd_addr_reg     <= 0;
            rs1_data_reg    <= 0;
            rs2_data_reg    <= 0;
            pc_4_reg        <= 0;
            pc_imm_reg      <= 0;
            pc_to_reg_reg   <= 0;
        end else begin
            if(id_valid_i && ~flush_ex_i && ~halt_ex_i) begin
                ALUType_reg     <= id_ALUType_i;
                BType_reg       <= id_BType_i;
                PCSrc_reg       <= id_PCSrc_i;
                MemWrite_reg    <= id_MemWrite_i;
                MemRead_reg     <= id_MemRead_i;
                RDSrc_reg       <= id_RDSrc_i;
                ALUSrc_reg      <= id_ALUSrc_i;
                RegWrite_reg    <= id_RegWrite_i;
                DataSize_reg    <= id_DataSize_i;
                imm_reg         <= id_imm_i;
                rs1_addr_reg    <= id_rs1_addr_i;
                rs2_addr_reg    <= id_rs2_addr_i;
                rd_addr_reg     <= id_rd_addr_i;
                rs1_data_reg    <= id_rs1_data_i;
                rs2_data_reg    <= id_rs2_data_i;
                pc_4_reg        <= id_pc_4_i;
                pc_imm_reg      <= id_pc_imm_i;
                pc_to_reg_reg   <= id_pc_to_reg_i;
            end else if(flush_ex_i) begin
                pc_4_reg        <= 0;
                pc_imm_reg      <= 0;
                pc_to_reg_reg   <= 0;
                ALUType_reg     <= 0;
                BType_reg       <= 0;
                PCSrc_reg       <= 0;
                MemWrite_reg    <= 0;
                MemRead_reg     <= 0;
                RDSrc_reg       <= 0;
                ALUSrc_reg      <= 0;
                RegWrite_reg    <= 0;
                DataSize_reg    <= 0;
                imm_reg         <= 0;
                rs1_addr_reg    <= 0;
                rs2_addr_reg    <= 0;
                rd_addr_reg     <= 0;
                rs1_data_reg    <= 0;
                rs2_data_reg    <= 0;
            end
        end
    end

    always_ff@(posedge clk or negedge rst) begin
        if(~rst) begin
            ex_valid <= 1'b0;
        end else begin
            ex_valid <= ~halt_ex_i && ~flush_ex_i;
        end
    end


    GS_MUX_2 #(
        .SEL_WIDTH(1),
        .SRC_WIDTH(32),
        .INPUT_0(1'b0),
        .INPUT_1(1'b1)
    ) rs2_mux_i(
        .a0             (rs2_mux_rs2_data       ),
        .a1             (rs2_mux_imm            ),
        .sel            (rs2_mux_sel            ),
        .out            (rs2_mux_out            )
    );

    GS_MUX_2 #(
        .SEL_WIDTH(1),
        .SRC_WIDTH(32),
        .INPUT_0(1'b0),
        .INPUT_1(1'b1)
    ) pc_or_alu_mux_i(
        .a0             (pc_or_alu_mux_pc_to_reg       ),
        .a1             (pc_or_alu_mux_alu_data        ),
        .sel            (pc_or_alu_mux_sel             ),
        .out            (pc_or_alu_mux_out             )
    );


    GS_ALU alu_i(
        .rst            (rst                            ),
        .rs1_data       (alu_rs1_data                   ),
        .imm_rs2_data   (alu_imm_rs2_data               ),
        .ALUCtrl        (alu_ALUCtrl                    ),
        .alu_data       (alu_alu_data                   ),
        .br_flag        (alu_br_flag                    )
    );


assign rs2_mux_rs2_data = rs2_data_reg;
assign rs2_mux_imm      = imm_reg;
assign rs2_mux_sel      = ALUSrc_reg;

assign pc_or_alu_mux_pc_to_reg  = pc_to_reg_reg;
assign pc_or_alu_mux_alu_data   = alu_alu_data;
assign pc_or_alu_mux_sel        = RDSrc_reg;

assign alu_rs1_data             = rs1_data_reg;
assign alu_imm_rs2_data         = rs2_mux_out;
assign alu_ALUCtrl              = ALUTyp_reg;

assign lsu_MemWrite_o           = MemWrite_reg;
assign lsu_MemRead_o            = MemRead_reg;
assign lsu_RegWrite_o           = RegWrite_reg;
assign lsu_rd_addr_o            = rd_addr_reg;
assign lsu_DataSize_o           = DataSize_reg;
assign lsu_rs2_data_o           = rs2_data_reg;
assign lsu_data_addr_o          = alu_alu_data;

assign rf_RegWrite_o            = RegWrite_reg;
assign rf_rd_addr_o             = rd_addr_reg;
assign rf_rd_data_o             = alu_alu_data;

assign ex_PCSrc_o               = PCSrc_reg;

assign ex_valid_o               = ex_valid;
assign ex_br_addr_o             = (alu_br_flag) ? pc_imm_reg : pc_4_reg;
assign ex_br_taken_o            = alu_br_flag;
assign ex_uncod_jump_addr_o     = alu_alu_data;



endmodule