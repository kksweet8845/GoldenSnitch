module CoreIPDesign(
    clk,
    rst,
    im_oe
    im_web
    im_addr
    im_DI
    im_DO
    dm_oe
    dm_web
    dm_addr
    dm_DI
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














endmodule