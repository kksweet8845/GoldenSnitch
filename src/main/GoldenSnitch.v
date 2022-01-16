module GoldenSnitch(
    clk,
    rst,
    im_addr,
    im_DI,
    dm_web,
    dm_addr,
    dm_DI,
    dm_DO
);


input clk;
input rst;
output [31:0]   im_addr;
input  [31:0]   im_DI;

output [3:0]        dm_web;
output [31:0]       dm_addr;
input  [31:0]       dm_DI;
output [31:0]       dm_DO;


//* pc
wire [31:0]   pc_in;
wire [31:0]   pc_out;
wire          pc_en;

//* pc src mux








    Mux_3 mux_32_pc_i(
        .res            (pc_in),
        .a_0            ()

    );


    ProgramCounter pc_i(
        .clk            (clk            )
        .rst            (rst            ),
        .pc_in          (pc_in          ),
        .pc_en          (pc_en          ),
        .pc_out         (pc_out         )
    );




























endmodule

