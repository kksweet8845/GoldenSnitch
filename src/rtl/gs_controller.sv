module GS_CtrlUnit
    importt gs_pkg::*;
(
    input   logic         clk,
    input   logic         rst,

    //* instr fetch signals
    // input   logic       if_fetch_failed_i,
    input   logic       if_fetch_valid_i,

    //* instr decode signals
    input   logic       id_ready_i,
    input   logic       id_uncod_jumps_i,

    //* execution signals
    input   logic       ex_uncod_jumps_i,
    input   logic       ex_br_taken_i,
    input   logic       ex_ready_i,

    //* forward detection signals
    input   logic       reg_rs1_wb_i,
    input   logic       reg_rs2_wb_i,
    input   logic       reg_rs1_ex_i,
    input   logic       reg_rs2_ex_i,

    //* stall logic
    input   logic       load_to_use_i,
    // input   logic       is_loading_i,

    output  logic [1:0] rs1_forward_sel_o,
    output  logic [1:0] rs2_forward_sel_o,

    output  logic       is_decoding_o,
    output  logic [3:0] pc_mux_sel_o,
    output  logic       instr_fetch_o,
    output  logic       flush_id_o,
    output  logic       flush_if_o,
    output  logic       flush_ex_o,
    // output  logic       flush_wb,
    output  logic       halt_if_o,
    output  logic       halt_id_o,
    output  logic       halt_ex_o
);


    ctrl_state_t ctrl_fsm_cs, ctrl_fsm_ns;


    always_comb begin : main_logic
        ctrl_fsm_ns = ctrl_fsm_cs;
        is_decoding_o = 1'b0;
        instr_fetch_o = 1'b0;

        unique case(ctrl_fsm_cs)
        RESET: begin
            pc_mux_sel_o = PC_BOOT;
            instr_fetch_o = 1'b0;
            ctrl_fsm_ns = BOOT_SET;
        end
        BOOT_SET: begin
            instr_fetch_o = 1'b1;
            ctrl_fsm_ns = FIRST_FETCH;
        end
        FIRST_FETCH: begin
            is_decoding_o = 1'b0;
            ctrl_fsm_ns = (if_fetch_valid_i && id_ready_i) ? DECODE : FIRST_FETCH;
        end
        DECODE: begin
            if(ex_br_taken_i) begin
                is_decoding_o = 1'b0;
                pc_mux_sel_o = PC_BRANCH;
                //* Need to flush if id stage
                flush_if_o = 1'b1;
                flush_id_o = 1'b1;
                ctrl_fsm_ns = WAIT_FETCH;
            end else if(id_uncod_jumps_i || ex_uncod_jumps_i) begin
                is_decoding_o = 1'b0;
                pc_mux_sel_o = PC_JUMP;
                flush_if_o = 1'b1;
                flush_id_o = 1'b1;
                ctrl_fsm_ns = WAIT_FETCH;
            end else begin
                is_decoding_o = 1'b1;
                pc_mux_sel_o = PC_NORMAL;
                ctrl_fsm_ns = DECODE;
            end
        end
        WAIT_FETCH: begin
            ctrl_fsm_ns = (if_fetch_valid_i && id_ready_i) ? DECODE : WAIT_FETCH;
            flush_if_o = (if_fetch_valid_i && id_ready_i) ? 1'b0 : 1'b1;
            flush_id_o = (if_fetch_valid_i && id_ready_i) ? 1'b0 : 1'b1;
        end
        endcase
    end


    always_comb begin : stall_logic
        if(!rst) begin
            halt_if_o = 1'b0;
            halt_id_o = 1'b0;
        end else begin
            //* if load to use, need to stall until get data
            // if(load_to_use_i == 1'b1 && is_loading_i == 1'b1) begin
            //     halt_if_o = 1'b1;
            //     halt_id_o = 1'b1;
            //     halt_ex_o = 1'b1;
            // end else if(load_to_use_i == 1'b1) begin
            //     halt_if_o = 1'b1;
            //     halt_id_o = 1'b1;
            //     halt_ex_o = 1'b0;
            // end else if(is_loading_i == 1'b1) begin
            //     halt_if_o = 1'b1;
            //     halt_id_o = 1'b1;
            //     halt_ex_o = 1'b1;
            // end else begin
            //     halt_if_o = 1'b0;
            //     halt_id_o = 1'b0;
            //     halt_ex_o = 1'b0;
            // end

            if(load_to_use_i == 1'b1) begin
                halt_if_o = 1'b1;
                halt_id_o = 1'b1;
            end else begin
                halt_if_o = 1'b0;
                halt_id_o = 1'b0;
            end
        end
    end


    always_ff@(posedge clk or negedge rst) begin
        if(!rst) begin
            ctrl_fsm_cs <= RESET;
        end else begin
            ctrl_fsm_cs <= ctrl_fsm_ns;
        end
    end



    always_comb begin : forward_logic
        rs1_forward_sel_o = REG_NO_FORWARD;
        rs2_forward_sel_o = REG_NO_FORWARD;

        if(reg_rs1_ex_i == 1'b1) begin
            rs1_forward_sel_o = REG_EX_FORWARD;
        end else if(reg_rs1_wb_i == 1'b1) begin
            rs1_forward_sel_o = REG_WB_FORWARD;
        end
        if(reg_rs2_ex_i == 1'b1) begin
            rs2_forward_sel_o = REG_EX_FORWARD;
        end else if(reg_rs2_wb_i == 1'b1) begin
            rs2_forward_sel_o = REG_WB_FORWARD;
        end
    end





endmodule