module GS_IF_STAGE
    import gs_pkg::*
#(
    BOOT_ADDR       = 0,
    ADDR_SIZE       = 32,
    WORD_SIZE       = 32,
    BYTES           = 4
)
(
    input   logic       clk,
    input   logic       rst,

    input   logic [3:0]             pc_mux_sel_i,
    input   logic [31:0]            br_addr_i,
    input   logic [31:0]            jump_addr_i,

    output  logic [ADDR_SIZE-1:0]   instr_addr_o,
    input   logic [WORD_SIZE-1:0]   instr_data_i,
    
    output  logic [WORD_SIZE-1:0]   instr_data_o,
    output  logic [31:0]            pc_out_o,


    //* control and status signals
    input   logic                   halt_if_i,
    input   logic                   flush_if_i,
    input   logic                   id_ready_i,
    output  logic                   if_valid_o
);



    //* Program counter

    logic [31:0]        pc_out;
    logic               if_valid_ns, if_valid;

    logic [2:0]             if_fsm_cs, if_fsm_ns;
    logic [WORD_SIZE-1:0]   instr_data;

    assign pc_out_o = pc_out;
    assign if_valid_o = if_valid;
    assign instr_data_o = instr_data;
    /*
        pc logic
    */
    always_comb begin : program_counter_logic
        instr_addr_o = 0;
        if(!rst) begin
            instr_addr_o = 0;
        end else begin
           unique case(pc_mux_sel_i)
            PC_BOOT: instr_addr_o = BOOT_ADDR;
            PC_BRNACH: instr_addr_o = (halt_if_i) ? br_addr_i : pc_out;
            PC_JUMP: instr_addr_o = (halt_if_i) ? jump_addr_i : pc_out;
            PC_NORMAL: instr_addr_o = (halt_if_i) ?  pc_out + 32'd4 : pc_out;
           endcase
        end
    end

    always_comb begin : fsm_logic
        if_fsm_ns = if_fsm_cs;
        if(!rst) begin
        end else begin
            unique case(if_fsm_cs)
                3'd0: begin //* initial state
                    if_fsm_ns = (pc_mux_sel_i == PC_BOOT) ? 3'd1 : 3'd0;
                    if_valid_ns = 0;
                end
                3'd1: begin //* stall one cycle
                    if_fsm_ns = 3'd2; //* wait for one cycle
                    if_valid_ns = 1'b1;
                end
                3'd2: begin //* the instr comes
                    if_fsm_ns = (flush_if_i) ? 3'd1 : 3'd2;
                    if_valid_ns = (flush_if_i) ? 1'b0 : 1'b1;
                end
            endcase
        end
    end

    always_ff@(posedge clk or negedge rst) begin
        if(!rst) begin
            pc_out <= 0;
        end else begin
            pc_out <= instr_addr_o; 
            if_fsm_cs <= if_fsm_ns;
            if_valid    <= if_valid_ns;
            if( ~flush_if_i  && ~halt_if_i) begin
                instr_data <= instr_data_i;
            end else if(flush_if_i) begin
                instr_data <= 32'd0;
            end
        end
    end

endmodule




