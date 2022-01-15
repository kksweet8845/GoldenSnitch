module ForwardCtrl(
    rst,
    //* E Stage
    E_MemRead,
    E_RegWrite,
    E_rd_addr,
    //* M Stage,
    M_MemRead,
    M_RegWrite,
    M_rd_addr,
    //* D Stage
    D_ImmType,
    D_rs1_addr,
    D_rs2_addr,
    E_rs1_forward,
    E_rs2_forward,
    M_rs1_forward,
    M_rs2_forward,
    stall_ifid_flush_idex,
);


input           clk;
input           rst;

input           E_MemRead;
input           E_RegWrite;
input [4:0]     E_rd_addr;
input           M_MemRead;
input           M_RegWrite;
input [4:0]     M_rd_addr;

input [2:0]     D_ImmType;

input [4:0]     D_rs1_addr;
input [4:0]     D_rs2_addr;

output  reg     E_rs1_forward;
output  reg     E_rs2_forward;
output  reg     M_rs1_forward;
output  reg     M_rs2_forward;


reg             stall_ifid_flush_idex;
wire            D_use_rs1;
wire            D_use_rs2;

wire            E_rs1_forward_normal;
wire            M_rs1_forward_normal;
wire            E_rs1_forward_lw;
wire            M_rs1_forward_lw;

wire            E_rs2_forward_normal;
wire            M_rs2_forward_normal;
wire            E_rs2_forward_lw;
wire            M_rs2_forward_lw;

assign D_use_rs1 = (D_ImmType[2] != 1'b1) ?                         1'b1 : 1'b0;
assign D_use_rs2 = (D_ImmType == 3'd0 | D_ImmType[2:1] == 2'b01) ?  1'b1 : 1'b0;


//* check logic
//* rs1, check for prev normal instr in E
assign E_rs1_forward_normal = (((E_RegWrite & !E_MemRead) & (D_use_rs1)) & (E_rd_addr == D_rs1_addr)) ? 1'b1 : 1'b0;

//* rs1, check for prev normal instr in M
assign M_rs1_forward_normal = (((M_RegWrite & !M_MemRead) & (D_use_rs1)) & (M_rd_addr == D_rs1_addr)) ? 1'b1 : 1'b0;


//* rs1, check for prev instr == lw, the F/D Stall, D/E Flush
assign E_rs1_forward_lw     = (((E_RegWrite &  E_MemRead) & (D_use_rs1)) & (E_rd_addr == D_rs1_addr)) ? 1'b1 : 1'b0;

//* check logic
//* rs2, check for prev normal instr in E
assign E_rs2_forward_normal = (((E_RegWrite & !E_MemRead) & (D_use_rs2)) & (E_rd_addr == D_rs2_addr)) ? 1'b1 : 1'b0;

//* rs2, check for prev normal instr in M
assign M_rs2_forward_normal = (((M_RegWrite & !M_MemRead) & (D_use_rs2)) & (M_rd_addr == D_rs2_addr)) ? 1'b1 : 1'b0;

//* rs2, check for prev instr == lw, then F/D Stall, D/E Flush
assign E_rs2_forward_lw     = (((E_RegWrite & E_MemRead) & (D_use_rs2)) & (E_rd_addr == D_rs2_addr)) ? 1'b1 : 1'b0;


always@(rst) begin
    if(!rst) begin
        E_rs1_forward = 0;
        E_rs2_forward = 0;
        M_rs1_forward = 0;
        M_rs2_forward = 0;
    end else begin
        //* rs1
        if(E_rs1_forward_normal) begin
            E_rs1_forward = 1;
            M_rs1_forward = 0;
            stall_ifid_flush_idex = 0;
        end else if(M_rs1_forward_normal) begin
            M_rs1_forward = 1;
            E_rs1_forward = 0;
            stall_ifid_flush_idex = 0;
        end else if(E_rs1_forward_lw) begin
            stall_ifid_flush_idex = 1;
            M_rs1_forward = 1;
            E_rs1_forward = 0;
        end else begin
            stall_ifid_flush_idex = 0;
            M_rs1_forward = 0;
            E_rs1_forward = 0;
        end

        //* rs2
        if(E_rs2_forward_normal) begin
            E_rs2_forward = 1;
            M_rs2_forward = 0;
            stall_ifid_flush_idex = 0;
        end else if(M_rs2_forward_normal) begin
            M_rs2_forward = 1;
            E_rs2_forward = 0;
            stall_ifid_flush_idex = 0;
        end else if(E_rs2_forward_lw) begin
            stall_ifid_flush_idex = 1;
            M_rs2_forward = 1;
            E_rs2_forward = 0;
        end else begin
            stall_ifid_flush_idex = 0;
            M_rs2_forward = 0;
            E_rs2_forward = 0;
        end
    end
end









endmodule