module CoreIPDesignWrapper(
    clk,
    rst,
    im_oe,
    im_web,
    im_addr,
    im_DI,
    im_DO,
    dm_oe,
    dm_web,
    dm_addr,
    dm_DI,
    dm_DO
);

parameter ADDR_SIZE         =   32;
parameter WORD_SIZE         =   32;
parameter BYTES             =   4;


input clk;
input rst;
output                      im_oe;
output [BYTES-1:0]          im_web;
output [ADDR_SIZE-1:0]      im_addr;
input  [WORD_SIZE-1:0]      im_DI;
output [WORD_SIZE-1:0]      im_DO;


input clk;
input rst;
output                      dm_oe;
output [BYTES-1:0]          dm_web;
output [ADDR_SIZE-1:0]      dm_addr;
input  [WORD_SIZE-1:0]      dm_DI;
output [WORD_SIZE-1:0]      dm_DO;


//* CoreIPDesign Port
wire                    topMod_im_oe;
wire [BYTES-1:0]        topMod_im_web;
wire [ADDR_SIZE-1:0]    topMod_im_addr;
wire [WORD_SIZE-1:0]    topMod_im_DI;
wire [WORD_SIZE-1:0]    topMod_im_DO;
wire                    topMod_dm_oe;
wire [BYTES-1:0]        topMod_dm_web;
wire [ADDR_SIZE-1:0]    topMod_dm_addr;
wire [WORD_SIZE-1:0]    topMod_dm_DI;
wire [WORD_SIZE-1:0]    topMod_dm_DO;


    CoreIPDesign topMod_i(
        .clk                (clk                    ),
        .rst                (rst                    ),
        .im_oe              (topMod_im_oe           ),
        .im_web             (topMod_im_web          ),
        .im_addr            (topMod_im_addr         ),
        .im_DI              (topMod_im_DI           ),
        .im_DO              (topMod_im_DO           ),
        .dm_oe              (topMod_dm_oe           ),
        .dm_web             (topMod_dm_web          ),
        .dm_addr            (topMod_dm_addr         ),
        .dm_DI              (topMod_dm_DI           ),
        .dm_DO              (topMod_dm_DO           )
    );

endmodule