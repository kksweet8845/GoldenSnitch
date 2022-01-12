module Top(
    clk,
    rst,
);


input clk;
input rst;


parameter ADDR_SIZE         =   32;
parameter WORD_SIZE         =   32;
parameter BYTES             =   4;

//* CoreIPDesign Port
wire                    topDesign_im_oe;
wire [BYTES-1:0]        topDesign_im_web;
wire [ADDR_SIZE-1:0]    topDesign_im_addr;
wire [WORD_SIZE-1:0]    topDesign_im_DI;
wire [WORD_SIZE-1:0]    topDesign_im_DO;
wire                    topDesign_dm_oe;
wire [BYTES-1:0]        topDesign_dm_web;
wire [ADDR_SIZE-1:0]    topDesign_dm_addr;
wire [WORD_SIZE-1:0]    topDesign_dm_DI;
wire [WORD_SIZE-1:0]    topDesign_dm_DO;



//* IM Port
wire                    instr_mem_oe;
wire [BYTES-1:0]        instr_mem_web;
wire [ADDR_SIZE-1:0]    instr_mem_addr;
wire [WORD_SIZE-1:0]    instr_mem_DI;
wire [WORD_SIZE-1:0]    instr_mem_DO;

//* DM Port

wire                    data_mem_oe;
wire [BYTES-1:0]        data_mem_web;
wire [ADDR_SIZE-1:0]    data_mem_addr;
wire [WORD_SIZE-1:0]    data_mem_DI;
wire [WORD_SIZE-1:0]    data_mem_DO;


    //* CoreIP Design
    CoreIPDesignWrapper CoreIPDesignWrapper_i(
        .clk                (clk                    ),
        .rst                (rst                    ),
        .im_oe              (topDesign_im_oe        ),
        .im_web             (topDesign_im_web       ),
        .im_addr            (topDesign_im_addr      ),
        .im_DI              (topDesign_im_DI        ),
        .im_DO              (topDesign_im_DO        ),
        .dm_oe              (topDesign_dm_oe        ),
        .dm_web             (topDesign_dm_web       ),
        .dm_addr            (topDesign_dm_addr      ),
        .dm_DI              (topDesign_dm_DI        ),
        .dm_DO              (topDesign_dm_DO        )
    );


    //* SRAM IM
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