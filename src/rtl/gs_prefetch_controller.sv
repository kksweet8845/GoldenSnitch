module GS_PrefetchController
    import gs_pkg::*
(
    input   logic           clk,
    input   logic           rst,
    input   logic [31:0]    instr_addr_i,

    output  logic [31:0]    instr_o,

    //* status control
    output  logic           pf_fetching_o,
    output  logic           pf_ready_o,

    output  logic [31:0]    im_addr_o
    output  logic [3:0]     im_web_o,
    input   logic [31:0]    im_instr_i
);


    pf_state_t pf_fsm_cs, pf_fsm_ns;
    
    logic [31:0]    nxt_instr_addr;
    logic           nxt_instr_valid;

    logic [31:0]    pf_instr;
    logic           pf_instr_valid;


    always_comb begin
        pf_fsm_ns = pf_fsm_cs;
        if(!rst) begin
            
        end else begin
            unique case(pf_fsm_cs)
            INITIAL: begin
                pf_fsm_ns = PENDING;
            end
            PENDING: begin
                if(instr_valid_i) begin
                    nxt_instr_addr = instr_addr_i;
                    nxt_instr_valid = instr_valid_i;
                end else begin
                    nxt_instr_addr = instr_addr_i;
                    nxt_instr_valid = instr_valid_i;
                end
                pf_fsm_ns = (instr_valid_i) ? FETCHING : PENDING;
            end
            FETCHING: begin




            end
            endcase
        end
    end



















endmodule