module GS_Core
    import gs_pkg::*
#(
    BOOT_ADDR       = 0,
    ADDR_SIZE       = 32,
    WORD_SIZE       = 32,
    BYTES           = 4 
)
(
    input   logic           clk,
    input   logic           rst,
    //* Instr memory
    output  logic   [ADDR_SIZE-1:0] im_addr_o,
    input   logic   [WORD_SIZE-1:0] im_data_i,

    //* Data memory
    output  logic   [ADDR_SIZE-1:0] dm_addr_o,
    input   logic   [WORD_SIZE-1:0] dm_data_i,
    output  logic   [WORD_SIZE-1:0] dm_data_o,
    output  logic   [BYTES-1:0]     dm_web
);


//* if stage port
logic [3:0]         if_pc_mux_sel;
logic [31:0]        if_br_addr;
logic [31:0]        if_jump_addr;

logic [31:0]        if_instr_addr;
logic [31:0]        if_instr_data_i;
logic [31:0]        if_instr_data_o;
logic [31:0]        if_pc_out;

logic               if_halt_if;
logic               if_flush_if;
logic               if_id_ready;
logic               if_valid;

//* id stage port
logic [31:0]        id_pc_4;
logic [31:0]        id_pc;
logic [31:0]        id_instr;
logic [3:0]         id_ALUType;
logic               id_BType;
logic [1:0]         id_PCSrc;
logic               id_MemWrite;
logic               id_MemRead;
logic               id_RDSrc;
logic               id_ALUSrc;
logic               id_RegWrite;
logic               id_DataSize;
logic [31:0]        id_imm;
logic [4:0]         id_rs1_addr;
logic [4:0]         id_rs2_addr;
logic [4:0]         id_rd_addr;
logic [31:0]        id_pc_to_reg_data;
logic [31:0]        id_rs1_wb_data;
logic [31:0]        id_rs1_ex_data;
logic [1:0]         id_rs1_forward_sel;
logic [31:0]        id_rs1_data;
logic [31:0]        id_rs2_wb_data;
logic [31:0]        id_rs2_ex_data;
logic [1:0]         id_rs2_forward_sel;
logic [31:0]        id_rs2_data;

logic               id_ex_RegWrite;
logic [4:0]         id_ex_rd_addr;
logic [31:0]        id_ex_rd_data;

logic               id_lsu_MemRead;
logic [4:0]         id_lsu_rd_addr;
logic [31:0]        id_lsu_rd_data;

logic               id_halt_id;
logic               id_flush_id;
logic               id_if_valid;
logic               id_id_valid;

//* ex stage port 
logic [3:0]         ex_id_ALUType;
logic               ex_id_BType;
logic [1:0]         ex_id_PCSrc;
logic               ex_id_MemWrite;
logic               ex_id_MemRead;
logic               ex_id_RDSrc;
logic               ex_id_ALUSrc;
logic               ex_id_RegWrite;
logic [2:0]         ex_id_DataSize;
logic [31:0]        ex_id_imm;
logic [4:0]         ex_id_rs1_addr;
logic [4:0]         ex_id_rs2_addr;
logic [4:0]         ex_id_rd_addr;
logic [31:0]        ex_id_pc_to_reg;
logic [31:0]        ex_id_rs1_data;
logic [31:0]        ex_id_rs2_data;
logic               ex_lsu_MemWrite;
logic               ex_lsu_MemRead;
logic [2:0]         ex_lsu_DataSize;
logic [31:0]        ex_lsu_rs2_data;
logic [31:0]        ex_lsu_data_addr;
logic               ex_rf_RegWrite;
logic [4:0]         ex_rf_rd_addr;
logic [31:0]        ex_rf_data;
logic [1:0]         ex_ex_PCSrc;
logic               ex_id_valid;
logic               ex_halt_ex;
logic               ex_flush_ex;
logic               ex_ex_valid;
logic               ex_ex_br_taken;

//* wb stage
logic               wb_lsu_rvalid;
logic               wb_lsu_busy;
logic [31:0]        wb_lsu_rdata;
logic               wb_ex_RegWrite;
logic               wb_ex_MemRead;
logic               wb_ex_rd_addr;
logic               wb_wb_RegWrite;
logic [31:0]        wb_wb_rdata;
logic [4:0]         wb_wb_rd_addr;
logic               wb_halt_wb;
logic               wb_flush_wb;
logic               wb_ex_valid;
logic               wb_wb_ready;

//* lsu
logic               lsu_ex_MemRead;
logic               lsu_ex_MemWrite;
logic [2:0]         lsu_ex_DataSize;
logic [31:0]        lsu_ex_rs2_data;
logic [31:0]        lsu_ex_data_addr;

logic               lsu_mem_oe;
logic [2:0]         lsu_mem_web;
logic [31:0]        lsu_mem_waddr;
logic [31:0]        lsu_mem_data_o;
logic [31:0]        lsu_mem_data_i;
logic               lsu_rvalid;
logic               lsu_rdata;
logic               lsu_ex_valid;
logic               lsu_lsu_busy;

//* controller
logic               ctrl_if_fetch_valid;
logic               ctrl_id_ready;
logic               ctrl_id_uncod_jumps;
logic               ctrl_ex_br_taken;
logic               ctrl_ex_ready;
logic               ctrl_reg_rs1_wb;
logic               ctrl_reg_rs2_wb;
logic               ctrl_reg_rs1_ex;
logic               ctrl_reg_rs2_ex;

logic               ctrl_load_to_use;
logic [1:0]         ctrl_rs1_forward_sel;
logic [1:0]         ctrl_rs2_forward_sel;
logic               ctrl_is_decoding;
logic [3:0]         ctrl_pc_mux_sel;
logic               ctrl_instr_fetch;
logic               ctrl_flush_id;
logic               ctrl_flush_if;
logic               ctrl_flush_ex;
logic               ctrl_halt_if;
logic               ctrl_halt_id;
logic               ctrl_halt_ex;

/*=============================================================================+
/        // ██╗███████╗    ░██████╗████████╗░█████╗░░██████╗░███████╗        /
/        // ██║██╔════╝    ██╔════╝╚══██╔══╝██╔══██╗██╔════╝░██╔════╝        /
/        // ██║█████╗░░    ╚█████╗░░░░██║░░░███████║██║░░██╗░█████╗░░        /
/        // ██║██╔══╝░░    ░╚═══██╗░░░██║░░░██╔══██║██║░░╚██╗██╔══╝░░        /
/        // ██║██║░░░░░    ██████╔╝░░░██║░░░██║░░██║╚██████╔╝███████╗        /
/        // ╚═╝╚═╝░░░░░    ╚═════╝░░░░╚═╝░░░╚═╝░░╚═╝░╚═════╝░╚══════╝        /
 +=============================================================================*/

GS_IF_STAGE #(
    .BOOT_ADDR(BOOT_ADDR),
    .ADDR_SIZE(ADDR_SIZE),
    .WORD_SIZE(WORD_SIZE),
    .BYTES    (BYTES)
) gs_if_stage_i(
    .clk            (clk                ),
    .rst            (rst                ),
    .pc_mux_sel_i   (if_pc_mux_sel      ),
    .br_addr_i      (if_br_addr         ),
    .jump_addr_i    (if_jump_addr       ),
    .instr_addr_o   (if_instr_addr      ),
    .instr_data_i   (if_instr_data_i    ),
    .instr_data_o   (if_instr_data_o    ),
    .pc_out_o       (if_pc_out          )
);



/*=============================================================================+
/          ██╗██████╗░    ░██████╗████████╗░█████╗░░██████╗░███████╗           /
/          ██║██╔══██╗    ██╔════╝╚══██╔══╝██╔══██╗██╔════╝░██╔════╝           /
/          ██║██║░░██║    ╚█████╗░░░░██║░░░███████║██║░░██╗░█████╗░░           /
/          ██║██║░░██║    ░╚═══██╗░░░██║░░░██╔══██║██║░░╚██╗██╔══╝░░           /
/          ██║██████╔╝    ██████╔╝░░░██║░░░██║░░██║╚██████╔╝███████╗           /
/          ╚═╝╚═════╝░    ╚═════╝░░░░╚═╝░░░╚═╝░░╚═╝░╚═════╝░╚══════╝           /
 +=============================================================================*/
GS_ID_STAGE #(
    .ADDR_SIZE(ADDR_SIZE),
    .WORD_SIZE(WORD_SIZE),
    .BYTES    (BYTES)
) gs_id_stage_i(
    .clk                (clk                        ),
    .rst                (rst                        ),
    .pc_4_i             (id_pc_4                    ),
    .pc_i               (id_pc                      ),
    .instr_i            (id_instr                   ),
    .ALUType_o          (id_ALUType                 ),
    .BType_o            (id_BType                   ),
    .PCSrc_o            (id_PCSrc                   ),
    .MemWrite_o         (id_MemWrite                ),
    .MemRead_o          (id_MemRead                 ),
    .RDSrc_o            (id_RDSrc                   ),
    .ALUSrc_o           (id_ALUSrc                  ),
    .RegWrite_o         (id_RegWrite                ),
    .DataSize_o         (id_DataSize                ),
    .imm_o              (id_imm                     ),
    .rs1_addr_o         (id_rs1_addr                ),
    .rs2_addr_o         (id_rs2_addr                ),
    .rd_addr_o          (id_rd_addr                 ),
    .pc_to_reg_data_o   (id_pc_to_reg_data          ),
    .rs1_wb_data_i      (id_rs1_wb_data             ),
    .rs1_ex_data_i      (id_rs1_ex_data             ),
    .rs1_forward_sel_i  (id_rs1_forward_sel         ),
    .rs1_data_o         (id_rs1_data                ),
    .rs2_wb_data_i      (id_rs2_wb_data             ),
    .rs2_ex_data_i      (id_rs2_ex_data             ),
    .rs2_forward_sel_i  (id_rs2_forward_sel         ),
    .rs2_data_o         (id_rs2_data                ),
    .ex_RegWrite_i      (id_ex_RegWrite             ),
    .ex_rd_addr_i       (id_ex_rd_addr              ),
    .ex_rd_data_i       (id_ex_rd_data              ),
    .lsu_MemRead_i      (id_lsu_MemRead             ),
    .lsu_rd_addr_i      (id_lsu_rd_addr             ),
    .halt_id_i          (id_halt_id                 ),
    .flush_id_i         (id_flush_id                ),
    .if_valid_i         (id_if_valid                ),
    .id_valid_o         (id_id_valid                )
);



/*=============================================================================+
/        ███████╗██╗░░██╗    ░██████╗████████╗░█████╗░░██████╗░███████╗        /
/        ██╔════╝╚██╗██╔╝    ██╔════╝╚══██╔══╝██╔══██╗██╔════╝░██╔════╝        /
/        █████╗░░░╚███╔╝░    ╚█████╗░░░░██║░░░███████║██║░░██╗░█████╗░░        /
/        ██╔══╝░░░██╔██╗░    ░╚═══██╗░░░██║░░░██╔══██║██║░░╚██╗██╔══╝░░        /
/        ███████╗██╔╝╚██╗    ██████╔╝░░░██║░░░██║░░██║╚██████╔╝███████╗        /
/        ╚══════╝╚═╝░░╚═╝    ╚═════╝░░░░╚═╝░░░╚═╝░░╚═╝░╚═════╝░╚══════╝        /
 +=============================================================================*/


GS_EX_STAGE #(
    .ADDR_SIZE(ADDR_SIZE),
    .WORD_SIZE(WORD_SIZE),
    .BYTES    (BYTES)
) gs_ex_stage_i(
    .clk                (clk                    ),
    .rst                (rst                    ),
    .id_ALUType_i       (ex_id_ALUType          ),
    .id_BType_i         (ex_id_BType            ),
    .id_PCSrc_i         (ex_id_PCSrc            ),
    .id_MemWrite_i      (ex_id_MemWrite         ),
    .id_MemRead_i       (ex_id_MemRead          ),
    .id_RDSrc_i         (ex_id_RDSrc            ),
    .id_ALUSrc_i        (ex_id_ALUSrc           ),
    .id_RegWrite_i      (ex_id_RegWrite         ),
    .id_DataSize_i      (ex_id_DataSize         ),
    .id_imm_i           (ex_id_imm              ),
    .id_rs1_addr_i      (ex_id_rs1_addr         ),
    .id_rs2_addr_i      (ex_id_rs2_addr         ),
    .id_rd_addr_i       (ex_id_rd_addr          ),
    .id_pc_to_reg_i     (ex_id_pc_to_reg        ),
    .id_rs1_data_i      (ex_id_rs1_data         ),
    .id_rs2_data_i      (ex_id_rs2_data         ),
    .lsu_MemWrite_o     (ex_lsu_MemWrite        ),
    .lsu_MemRead_o      (ex_lsu_MemRead         ),
    .lsu_DataSize_o     (ex_lsu_DataSize        ),
    .lsu_rs2_data_o     (ex_lsu_rs2_data        ),
    .lsu_data_addr_o    (ex_lsu_data_addr       ),
    .rf_RegWrite_o      (ex_rf_RegWrite         ),
    .rf_rd_addr_o       (ex_rf_rd_addr          ),
    .rf_rd_data_o       (ex_rf_rd_data          ),
    .ex_PCSrc_o         (ex_ex_PCSrc            ),
    .id_valid_i         (ex_id_valid            ),
    .halt_ex_i          (ex_halt_ex             ),
    .flush_ex_i         (ex_flush_ex            ),
    .ex_valid_o         (ex_ex_valid            ),
    .ex_br_taken_o      (ex_ex_br_taken         )
);



/*=============================================================================+
/     ░██╗░░░░░░░██╗██████╗░    ░██████╗████████╗░█████╗░░██████╗░███████╗     /
/     ░██║░░██╗░░██║██╔══██╗    ██╔════╝╚══██╔══╝██╔══██╗██╔════╝░██╔════╝     /
/     ░╚██╗████╗██╔╝██████╦╝    ╚█████╗░░░░██║░░░███████║██║░░██╗░█████╗░░     /
/     ░░████╔═████║░██╔══██╗    ░╚═══██╗░░░██║░░░██╔══██║██║░░╚██╗██╔══╝░░     /
/     ░░╚██╔╝░╚██╔╝░██████╦╝    ██████╔╝░░░██║░░░██║░░██║╚██████╔╝███████╗     /
/     ░░░╚═╝░░░╚═╝░░╚═════╝░    ╚═════╝░░░░╚═╝░░░╚═╝░░╚═╝░╚═════╝░╚══════╝     /
 +=============================================================================*/

GS_WB_STAGE #(
    .ADDR_SIZE(ADDR_SIZE),
    .WORD_SIZE(WORD_SIZE),
    .BYTES    (BYTES)
) gs_wb_stage_i(
    .clk                (clk                ),
    .rst                (rst                ),
    .lsu_rvalid_i       (wb_lsu_rvalid      ),
    .lsu_busy_i         (wb_lsu_busy        ),
    .lsu_rdata_i        (wb_lsu_rdata       ),
    .ex_RegWrite_i      (wb_ex_RegWrite     ),
    .ex_MemRead_i       (wb_ex_MemRead      ),
    .ex_rd_addr_i       (wb_ex_rd_addr      ),
    .wb_RegWrite_o      (wb_wb_RegWrite     ),
    .wb_rdata_o         (wb_wb_rdata        ),
    .wb_rd_addr_o       (wb_wb_rd_addr      ),
    .halt_wb_i          (wb_halt_wb         ),
    .flush_wb_i         (wb_flush_wb        ),
    .ex_valid_i         (wb_ex_valid        ),
    .wb_ready_o         (wb_wb_ready        )
);

/*=============================================================================+
/          ██╗░░░░░░██████╗██╗░░░██╗  ██╗░░░██╗███╗░░██╗██╗████████╗           /
/          ██║░░░░░██╔════╝██║░░░██║  ██║░░░██║████╗░██║██║╚══██╔══╝           /
/          ██║░░░░░╚█████╗░██║░░░██║  ██║░░░██║██╔██╗██║██║░░░██║░░░           /
/          ██║░░░░░░╚═══██╗██║░░░██║  ██║░░░██║██║╚████║██║░░░██║░░░           /
/          ███████╗██████╔╝╚██████╔╝  ╚██████╔╝██║░╚███║██║░░░██║░░░           /
/          ╚══════╝╚═════╝░░╚═════╝░  ░╚═════╝░╚═╝░░╚══╝╚═╝░░░╚═╝░░░           /
 +=============================================================================*/


GS_LSU #(
    .ADDR_SIZE(ADDR_SIZE),
    .WORD_SIZE(WORD_SIZE),
    .BYTES    (BYTES)
) gs_lsu_i(
    .clk                (clk                ),
    .rst                (rst                ),
    .ex_MemRead_i       (lsu_ex_MemRead     ),
    .ex_MemWrite_i      (lsu_ex_MemWrite    ),
    .ex_DataSize_i      (lsu_ex_DataSize    ),
    .ex_rs2_data_i      (lsu_ex_rs2_data    ),
    .ex_data_addr_i     (lsu_ex_data_addr   ),
    .mem_oe_o           (lsu_mem_oe         ),
    .mem_web_o          (lsu_mem_web        ),
    .mem_addr_o         (lsu_mem_addr       ),
    .mem_data_o         (lsu_mem_data_o     ),
    .mem_data_i         (lsu_mem_data_i     ),
    .rvalid_o           (lsu_rvalid         ),
    .rdata_o            (lsu_rdata          ),
    .ex_valid_i         (lsu_ex_valid       ),
    .lsu_busy_o         (lsu_lsu_busy       )
);



/*=============================================================================+
/░█████╗░░█████╗░███╗░░██╗████████╗██████╗░░█████╗░██╗░░░░░██╗░░░░░███████╗██████╗░/
/██╔══██╗██╔══██╗████╗░██║╚══██╔══╝██╔══██╗██╔══██╗██║░░░░░██║░░░░░██╔════╝██╔══██╗/
/██║░░╚═╝██║░░██║██╔██╗██║░░░██║░░░██████╔╝██║░░██║██║░░░░░██║░░░░░█████╗░░██████╔╝/
/██║░░██╗██║░░██║██║╚████║░░░██║░░░██╔══██╗██║░░██║██║░░░░░██║░░░░░██╔══╝░░██╔══██╗/
/╚█████╔╝╚█████╔╝██║░╚███║░░░██║░░░██║░░██║╚█████╔╝███████╗███████╗███████╗██║░░██║/
/░╚════╝░░╚════╝░╚═╝░░╚══╝░░░╚═╝░░░╚═╝░░╚═╝░╚════╝░╚══════╝╚══════╝╚══════╝╚═╝░░╚═╝/
 +=============================================================================*/

GS_CtrlUnit gs_ctrlunit_i(
    .clk                (clk                    ),
    .rst                (rst                    ),
    .if_fetch_valid_i   (ctrl_if_fetch_valid    ),
    .id_ready_i         (ctrl_id_ready          ),
    .id_uncod_jumps_i   (ctrl_id_uncod_jumps    ),
    .ex_br_taken_i      (ctrl_ex_br_taken       ),
    .ex_ready_i         (ctrl_ex_ready          ),
    .reg_rs1_wb_i       (ctrl_reg_rs1_wb        ),
    .reg_rs2_wb_i       (ctrl_reg_rs2_wb        ),
    .reg_rs1_ex_i       (ctrl_reg_rs1_ex        ),
    .reg_rs2_ex_i       (ctrl_reg_rs2_ex        ),
    .load_to_use_i      (ctrl_load_to_use       ),
    .rs1_forward_sel_o  (ctrl_rs1_forward_sel   ),
    .rs2_forward_sel_o  (ctrl_rs2_forward_sel   ),
    .is_decoding_o      (ctrl_is_decoding       ),
    .pc_mux_sel_o       (ctrl_pc_mux_sel        ),
    .instr_fetch_o      (ctrl_instr_fetch       ),
    .flush_id_o         (ctrl_flush_id          ),
    .flush_if_o         (ctrl_flush_if          ),
    .flush_ex_o         (ctrl_flush_ex          ),
    .halt_if_o          (ctrl_halt_if           ),
    .halt_id_o          (ctrl_halt_id           ),
    .halt_ex_o          (ctrl_halt_ex           )
);





endmodule