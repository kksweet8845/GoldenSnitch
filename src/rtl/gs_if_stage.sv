module GS_IF_STAGE
    import gs_pkg::*
#(
    ADDR_SIZE       = 32,
    WORD_SIZE       = 32,
    BYTES           = 4
)
(
    input   logic       clk,
    input   logic       rst,


    output  logic [ADDR_SIZE-1:0]   instr_addr_o,
    input   logic [WORD_SIZE-1:0]   instr_data_i,
    
    output  logic [ADDR_SIZE-1:0]   


);


