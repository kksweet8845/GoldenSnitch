module GS_Decoder
    import gs_pkg::*
(
    input   logic           rst
    input   logic [31:0]    instr_i,

    output  logic [2:0]     ImmType,
    output  logic           PCtoRegSrc,
    output  logic [3:0]     ALUType,
    output  logic           BType,
    output  logic [1:0]     PCSrc,
    output  logic           MemWrite,
    output  logic           MemRead,
    output  logic           RDSrc,
    output  logic           ALUSrc,
    output  logic           RegWrite,
    output  logic [2:0]     DataSize,
    output  logic [31:0]    imm,
    output  logic [4:0]     rs1_addr,
    output  logic [4:0]     rs2_addr,
    output  logic [4:0]     rd_addr
);



    logic [1:0] base;
    logic [4:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;




    assign base         = instr_i[1:0];
    assign opcode       = instr_i[6:2];
    assign rd           = instr_i[11:7];
    assign funct3       = instr_i[14:12];
    assign rs1_addr     = instr_i[19:15];
    assign rs2_addr     = instr_i[24:20];
    assign funct7       = instr_i[31:25];



    always_comb begin
        ImmType = 0; PCtoRegSrc = 0; ALUType = 0; BType = 0; PCSrc = 0;
        MemWrite = 0; MemRead = 0; RDSrc = 0;
        ALUSrc = 0; RegWrite = 0;

        if(!rst) begin
            ImmType = 0; PCtoRegSrc = 0; ALUType = 0; BType = 0; PCSrc = 0;
            MemWrite = 0; MemRead = 0;  RDSrc = 0;
            ALUSrc = 0; RegWrite = 0;
        end else begin
            unique case(base)
            2'b00: begin
                ImmType = 0; PCtoRegSrc = 0; ALUType = 0; BType = 3'b010; PCSrc = 0;
                MemWrite = 0; MemRead = 0;  RDSrc = 0;
                ALUSrc = 0; RegWrite = 0;
            end
            2'b01: begin
                ImmType = 0; PCtoRegSrc = 0; ALUType = 0; BType = 3'b010; PCSrc = 0;
                MemWrite = 0; MemRead = 0;  RDSrc = 0;
                ALUSrc = 0; RegWrite = 0;
            end
            2'b10: begin
                ImmType = 0; PCtoRegSrc = 0; ALUType = 0; BType = 3'b010; PCSrc = 0;
                MemWrite = 0; MemRead = 0;  RDSrc = 0;
                ALUSrc = 0; RegWrite = 0;
            end
            2'b11: begin
                unique case(opcode)
                OP: begin
                    ImmType = 3'd0; PCtoRegSrc = 0; 
                    ALUType = {funct7[5], funct3};
                    BType = 1'b0; RDSrc = 0;
                    PCSrc = 2'b00;
                    MemWrite = 0;
                    MemRead = 0;
                    ALUSrc = 1;
                    RegWrite = 1;
                    DataSize = 0; 
                end
                OP_IMM: begin
                    ImmType = 3'd1; PCtoRegSrc = 0;
                    ALUType = {funct7[5], funct3};
                    BType = 1'b0; RDSrc = 0;
                    PCSrc = 2'b00;
                    MemWrite = 0;
                    MemRead = 0;
                    ALUSrc = 0;
                    RegWrite = 1;
                    DataSize = 0;
                end
                LOAD: begin
                    ImmType = 3'd1; PCtoRegSrc = 0;
                    ALUType = PLUS; RDSrc = 0;
                    BType = 1'b0;
                    PCSrc = 2'b00;
                    MemWrite = 0;
                    MemRead = 1;
                    ALUSrc = 0;
                    RegWrite = 1;
                    DataSize = funct3;
                end
                STORE: begin
                    ImmType = 3'd2; PCtoRegSrc = 0; RDSrc = 0;
                    ALUType = PLUS; //* +
                    BType = 1'b0;
                    PCSrc = 2'b00;
                    MemWrite = 1;
                    MemRead = 0;
                    ALUSrc = 0;
                    RegWrite = 0;
                    DataSize = funct3;
                end
                BRANCH: begin
                    ImmType = 3'd3; PCtoRegSrc = 0; //* Don't care
                    RDSrc = 0;
                    ALUType = {1'b1, funct3};
                    BType = 1'b1;
                    PCSrc = 2'b11;
                    MemWrite = 0;
                    MemRead = 0;
                    ALUSrc = 0;
                    RegWrite = 0;
                    DataSize = 0;
                end
                JALR: begin //* pc = imm + rs1
                    ImmType = 3'd1; PCtoRegSrc = 0; //* rd = pc+4;
                    RDSrc = 1'b1;
                    ALUType = PLUS; //* +
                    BType = 1'b0;
                    PCSrc = 2'b10;
                    MemWrite = 0;
                    MemRead = 0;
                    ALUSrc = 0;
                    RegWrite = 1;
                    DataSize = 0;
                end
                JAL: begin //* pc = pc + imm
                    ImmType = 3'd5; PCtoRegSrc = 0;  //* rd = pc+4;
                    RDSrc = 1'b1;
                    ALUType = FORWARD; //* Don't care
                    BType = 1'b0;
                    PCSrc = 2'b01;
                    MemWrite = 0;
                    MemRead = 0;
                    ALUSrc = 0;
                    RegWrite = 1;
                    DataSize = 0;
                end
                AUIPC: begin
                    ImmType = 3'd4; PCtoRegSrc = 1; //* rd = pc+imm;
                    RDSrc = 1'b1;
                    ALUType = FORWARD; //* Don't Care
                    BType = 1'b0;
                    PCSrc = 2'b00;
                    MemWrite = 0;
                    MemRead = 0;
                    ALUSrc = 0;
                    RegWrite = 1;
                    DataSize = 0;
                end
                LUI: begin
                    ImmType = 3'd4; PCtoRegSrc = 0; //*Don't care
                    RDSrc = 1'b1;
                    ALUType = FORWARD; //* Don't care
                    BType = 1'b0;
                    PCSrc = 2'b00;
                    MemWrite = 0;
                    MemRead = 0;
                    ALUSrc = 0;
                    RegWrite = 1;
                    DataSize = 0;
                end
                endcase
            end
            endcase
        end
    end


    always_comb begin
        imm = 0;

        if(!rst) begin
            imm = 0;
        end else begin
            unique case(ImmType) 
            3'b000: begin
                imm = 0;
            end
            3'b001: begin
                imm = {{20{instr_i[31]}}, instr_i[31:20]};
            end
            3'b010: begin
                imm = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
            end
            3'b011: begin
                imm = {{20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0}; 
            end
            3'b100: begin
                imm = {imm[31:12], 12'b0};
            end
            3'b101: begin
                imm = {{12{instr_i[31]}}, instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};
            end
            default: begin
                imm = 0;
            end
            endcase
        end
    end


endmodule