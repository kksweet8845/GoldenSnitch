module Decoder(
    rst,
    base,
    opcode,
    funct3,
    funct7,
    ImmType,
    PCtoRegSrc,
    ALUType,
    BType,
    PCSrc,
    MemWrite,
    MemRead,
    RDSrc,
    MemtoRegSrc,
    ALUSrc,
    RegWrite
);

input [1:0]             base;
input [4:0]             opcode;
input [2:0]             funct3;
input [6:0]             funct7;

output reg [2:0]            ImmType;   //* 0: Not Imm, 1: imm[11:0], 2: {imm[11:5], imm[4:0]}, 3: {imm[12|10:5], imm[4:1|11]}, 4: imm[31:12], 5: imm[20|10:1|11|19:12]
output reg                  PCtoRegSrc;
output reg [3:0]            ALUType;
output reg [2:0]            BType;
output reg [1:0]            PCSrc;
output reg                  MemWrite;
output reg                  MemRead;
output reg                  RDSrc;
output reg                  MemtoRegSrc;
output reg                  ALUSrc;
output reg                  RegWrite;
output reg [2:0]            DataSize;



always@(*) begin
    if(!rst) begin


    end else begin
        case(base)
            2'b00: begin
                ImmType = 0; PCtoRegSrc = 0; ALUType = 0; BType = 3'b010; PCSrc = 0;
                MemWrite = 0; MemRead = 0; RDSrc = 0; MemtoRegSrc = 0;
                ALUSrc = 0; RegWrite = 0;
            end
            2'b01: begin
                ImmType = 0; PCtoRegSrc = 0; ALUType = 0; BType = 3'b010; PCSrc = 0;
                MemWrite = 0; MemRead = 0; RDSrc = 0; MemtoRegSrc = 0;
                ALUSrc = 0; RegWrite = 0;
            end
            2'b10: begin
                ImmType = 0; PCtoRegSrc = 0; ALUType = 0; BType = 3'b010; PCSrc = 0;
                MemWrite = 0; MemRead = 0; RDSrc = 0; MemtoRegSrc = 0;
                ALUSrc = 0; RegWrite = 0;
            end
            2'b11: begin
                case(opcode)
                    5'b01100: begin //* R-type
                        ImmType = 3'd0; PCtoRegSrc = 0; 
                        ALUType = {funct7[5], funct3};
                        BType = 3'b010;
                        PCSrc = 2'b00;
                        MemWrite = 0;
                        MemRead = 0;
                        RDSrc = 0;
                        MemtoRegSrc = 0;
                        ALUSrc = 1;
                        RegWrite = 1;
                        DataSize = 0;
                    end
                    5'b00100: begin //* I-Type
                        ImmType = 3'd1; PCtoRegSrc = 0;
                        ALUType = {funct7[5], funct3};
                        BType = 3'b010;
                        PCSrc = 2'b00;
                        MemWrite = 0;
                        MemRead = 0;
                        RDSrc = 0;
                        MemtoRegSrc = 0;
                        ALUSrc = 0;
                        RegWrite = 1;
                        DataSize = 0;
                    end
                    5'b00000: begin //* Load Type
                        ImmType = 3'd1; PCtoRegSrc = 0;
                        ALUType = 4'b0000;
                        BType = 3'b010;
                        PCSrc = 2'b00;
                        MemWrite = 0;
                        MemRead = 1;
                        RDSrc = 0; //* Dont' care
                        MemtoRegSrc = 1;
                        ALUSrc = 0;
                        RegWrite = 1;
                        DataSize = funct3;
                    end
                    5'b01000: begin //* Store Type
                        ImmType = 3'd2; PCtoRegSrc = 0;
                        ALUType = 4'b0000; //* +
                        BType = 3'b010;
                        PCSrc = 2'b00;
                        MemWrite = 1;
                        MemRead = 0;
                        RDSrc = 0; //* Dont' care
                        MemtoRegSrc = 0;
                        ALUSrc = 0;
                        RegWrite = 0;
                        DataSize = funct3;
                    end
                    5'b11000: begin //* Branch Type
                        ImmType = 3'd3; PCtoRegSrc = 0; //* Don't care
                        ALUType = {1'b0, funct3};
                        BType = funct3;
                        PCSrc = 2'b11;
                        MemWrite = 0;
                        MemRead = 0;
                        RDSrc = 0;
                        MemtoRegSrc = 0;
                        ALUSrc = 0;
                        RegWrite = 0;
                        DataSize = 0;
                    end
                    5'b11001: begin //* JALR
                        ImmType = 3'd1; PCtoRegSrc = 0; //* rd = pc+4;
                        ALUType = 4'b0000; //* +
                        BType = 0;
                        PCSrc = 2'b10;
                        MemWrite = 0;
                        MemRead = 0;
                        RDSrc = 1;
                        MemtoRegSrc = 0;
                        ALUSrc = 0;
                        RegWrite = 1;
                        DataSize = 0;
                    end
                    5'b11011: begin //* JAL
                        ImmType = 3'd5; PCtoRegSrc = 0;  //* rd = pc+4;
                        ALUType = 4'hf; //* Don't care
                        BType = 3'b010;
                        PCSrc = 2'b01;
                        MemWrite = 0;
                        MemRead = 0;
                        RDSrc = 1;
                        MemtoRegSrc = 0;
                        ALUSrc = 0;
                        RegWrite = 1;
                        DataSize = 0;
                    end
                    5'b00101: begin //* AUIPC
                        ImmType = 3'd4; PCtoRegSrc = 1; //* rd = pc+imm;
                        ALUType = 4'hf; //* Don't Care
                        BType = 3'b010;
                        PCSrc = 2'b00;
                        MemWrite = 0;
                        MemRead = 0;
                        RDSrc = 1;
                        MemtoRegSrc = 0;
                        ALUSrc = 0;
                        RegWrite = 1;
                        DataSize = 0;
                    end
                    5'b01101: begin //* LUI
                        ImmType = 3'd4; PCtoRegSrc = 0; //*Don't care
                        ALUType = 4'hf; //* Don't care
                        BType = 3'b010;
                        PCSrc = 2'b00;
                        MemWrite = 0;
                        MemRead = 0;
                        RDSrc = 0;
                        MemtoRegSrc = 0;
                        ALUSrc = 0;
                        RegWrite = 1;
                        DataSize = 0;
                    end
                endcase
            end
        endcase
    end
end















endmodule