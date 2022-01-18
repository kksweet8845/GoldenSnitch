module GS_Top
    import gs_pkg::*
#(
    BOOT_ADDR       = 32'h0,
    ADDR_SIZE       = 32,
    WORD_SIZE       = 32,
    BYTES           = 4 
)
(
    input       clk,
    input       rst
);


//* core Port
logic 



//* IM Port
logic                    instr_mem_oe;
logic [BYTES-1:0]        instr_mem_web;
logic [ADDR_SIZE-1:0]    instr_mem_addr;
logic [WORD_SIZE-1:0]    instr_mem_DI;
logic [WORD_SIZE-1:0]    instr_mem_DO;

//* DM Port
logic                    data_mem_oe;
logic [BYTES-1:0]        data_mem_web;
logic [ADDR_SIZE-1:0]    data_mem_addr;
logic [WORD_SIZE-1:0]    data_mem_DI;
logic [WORD_SIZE-1:0]    data_mem_DO;
    

    





    //* IM
    SRAM_wrapper instr_mem_i(
        .CK                 (clk                    ),
        .CS                 (rst                    ),
        .OE                 (instr_mem_oe           ),
        .WEB                (instr_mem_web          ),
        .A                  (instr_mem_addr[13:0]   ),
        .DI                 (instr_mem_DI           ),
        .DO                 (instr_mem_DO           )
    );



    //* SRAM DM
    SRAM_wrapper data_mem_i(
        .CK                 (data_mem_clk           ),
        .CS                 (data_mem_rst           ),
        .OE                 (data_mem_oe            ),
        .WEB                (data_mem_web           ),
        .A                  (data_mem_addr[13:0]    ),
        .DI                 (data_mem_DI            ),
        .DO                 (data_mem_DO            )
    );

























endmodule