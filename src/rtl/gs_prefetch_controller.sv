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


    









endmodule