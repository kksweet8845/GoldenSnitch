module Deconstructor(
    instr,
    funct7,
    rs2,
    rs1,
    funct3,
    rd,
    opcode,
    base
);

parameter ADDR_SIZE         =   32;
parameter WORD_SIZE         =   32;
parameter BYTES             =   4;

input [WORD_SIZE-1:0]   instr;
output [6:0]            funct7;
output [4:0]            rs2;
output [4:0]            rs1;
output [2:0]            funct3;
output [4:0]            rd;
output [4:0]            opcode;
output [1:0]            base;

wire   [4:2]            category;
wire   [6:5]            detail;

assign base         = instr[1:0];
assign category     = instr[4:2];
assign detail       = instr[6:5];
assign opcode = {detail, category};

assign rd     = instr[11:7];
assign funct3 = instr[14:12];
assign rs1    = instr[19:15];
assign rs2    = instr[24:20];
assign funct7 = instr[31:25];


endmodule