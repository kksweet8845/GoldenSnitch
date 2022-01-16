module ForwardCtrl(
    rst,
    //* E Stage
    E_MemRead,
    E_RegWrite,
    E_ImmType,
    E_rs1_addr,
    E_rs2_addr,
    E_rd_addr,
    //* M Stage,
    M_MemRead,
    M_RegWrite,
    M_ImmType,
    M_rs1_addr,
    M_rs2_addr,
    M_rd_addr,
    //* D Stage
    D_MemRead,
    D_RegWrite,
    D_ImmType,
    D_rs1_addr,
    D_rs2_addr,
    //* Output
    forward_rs1,
    forward_rs2,
    br_forward_rs1,
    br_forward_rs2,
    stall_D
);


input           clk;
input           rst;


//* D Stage
input           D_MemRead;
input           D_RegWrite;
input [2:0]     D_ImmType;
input [4:0]     D_rs1_addr;
input [4:0]     D_rs2_addr;
input [4:0]     D_rd_addr;

//* E Stage
input           E_MemRead;
input           E_RegWrite;
input [2:0]     E_ImmType;
input [4:0]     E_rs1_addr;
input [4:0]     E_rs2_addr;
input [4:0]     E_rd_addr;

//* M Stage
input           M_MemRead;
input           M_RegWrite;
input [2:0]     M_ImmType;
input [4:0]     M_rs1_addr;
input [4:0]     M_rs2_addr;
input [4:0]     M_rd_addr;

output reg [1:0]    forward_rs1;
output reg [1:0]    forward_rs2;
output reg [1:0]    br_forward_rs1;
output reg [1:0]    br_forward_rs2;
output reg [1:0]    stall_D;

reg             stall_ifid_flush_idex;
wire            D_use_rs1;
wire            D_use_rs2;

//* normal forward
wire            M2E_rs1_forward_logic;
wire            M2E_rs2_forward_logic;
wire            W2E_rs1_forward_logic;
wire            W2E_rs2_forward_logic;

//* load to use
wire            l2u_normal_logic; //* Need to stall one cycle

//* br, (lw, nop, beq)
wire            l2u_1_ahead_br_logic;

//* br, (add, beq)
wire            imm_use_br_logic;

//* br, (lw, beq)
wire            l2u_imm_br_logic;

//* br, (add, add, beq)
wire            W2D_rs1_forward_logic;
wire            W2D_rs2_forward_logic;
wire            M2D_rs1_forward_logic;
wire            M2D_rs2_forward_logic;


assign D_use_rs1 = (D_ImmType[2] != 1'b1) ?                         1'b1 : 1'b0;
assign D_use_rs2 = (D_ImmType == 3'd0 | D_ImmType[2:1] == 2'b01) ?  1'b1 : 1'b0;
assign D_br      = (D_ImmType == 3'd011) ? 1'b1 : 1'b0;

assign E_use_rs1 = (E_ImmType[2] != 1'b1) ?                         1'b1 : 1'b0;
assign E_use_rs2 = (E_ImmType == 3'd0 | D_ImmType[2:1] == 2'b01) ?  1'b1 : 1'b0;
assign E_br      = (E_ImmType == 3'd011) ? 1'b1 : 1'b0;

//* forward logic
//* rs1, W, E forward
assign W2E_rs1_forward_logic    = (((W_RegWrite) & (E_use_rs1)) & (W_rd_addr == E_rs1_addr)) ? 1'b1 : 1'b0;
//* rs1, M, E forward
assign M2E_rs1_forward_logic    = (((M_RegWrite) & (E_use_rs1)) & (M_rd_addr == E_rs1_addr)) ? 1'b1 : 1'b0;
//* rs2, W, E forward
assign W2E_rs2_forward_logic    = (((W_RegWrite) & (E_use_rs1)) & (W_rd_addr == E_rs2_addr)) ? 1'b1 : 1'b0;
//* rs2, M, E forward
assign M2E_rs2_forward_logic    = (((M_RegWrite) & (E_use_rs1)) & (M_rd_addr == E_rs2_addr)) ? 1'b1 : 1'b0;
//*load to use
assign l2u_normal_logic         = ((E_MemRead) & (D_use_rs1 || D_use_rs2) & (E_rd_addr == D_rs1_addr || E_rd_addr == D_rs2_addr)) ? 1'b1 : 1'b0;
//* br (lw, nop, br)
assign l2u_1_ahead_br_logic        = ((M_MemRead) & (D_br) & (M_rd_addr == D_rs1_addr || M_rd_addr == D_rs2_addr)) ? 1'b1 : 1'b0;;
//* br (add, br)
assign imm_use_br_logic         = ((E_RegWrite) & (D_br) & (E_rd_addr == D_rs1_addr || E_rd_addr == D_rs2_addr)) ? 1'b1 : 1'b0;
//* br, (lw, beq)
assign l2u_imm_br_logic         = ((E_MemRead) & (D_br) & (E_rd_addr == D_rs1_addr || E_rd_addr == D_rs2_addr)) ? 1'b1 : 1'b0;


//* br, (add, add, beq)
assign W2D_rs1_forward_logic    = ((W_RegWrite) & (D_br) & (W_rd_addr == D_rs1_addr)) ? 1'b1 : 1'b0;
assign W2D_rs2_forward_logic    = ((W_RegWrite) & (D_br) & (W_rd_addr == D_rs2_addr)) ? 1'b1 : 1'b0;
assign M2D_rs1_forward_logic    = ((M_RegWrite) & (D_br) & (M_rd_addr == D_rs1_addr)) ? 1'b1 : 1'b0;
assign M2D_rs2_forward_logic    = ((M_RegWrite) & (D_br) & (M_rd_addr == D_rs2_addr)) ? 1'b1 : 1'b0;



always@(*) begin
    if(!rst) begin
        forward_rs1 = 2'b00;
        forward_rs2 = 2'b00;
        br_forward_rs1 = 2'b00;
        br_forward_rs2 = 2'b00;
        stall_D = 0;
    end else begin
        if(W2E_rs1_forward_logic & M2E_rs1_forward_logic) begin
            forward_rs1 = 2'b01;
        end else if(W2E_rs1_forward_logic) begin
            forward_rs1 = 2'b10;
        end else if(M2E_rs1_forward_logic) begin
            forward_rs1 = 2'b01;
        end else begin
            forward_rs1 = 2'b00;
        end

        if(W2E_rs2_forward_logic & M2E_rs2_forward_logic) begin
            forward_rs2 = 2'b01;
        end else if(W2E_rs2_forward_logic) begin
            forward_rs2 = 2'b10;
        end else if(M2E_rs2_forward_logic) begin
            forward_rs2 = 2'b01;
        end else begin
            forward_rs2 = 2'b00;
        end

        if(W2D_rs1_forward_logic & M2D_rs1_forward_logic) begin
            br_forward_rs1 = 2'b01;
        end else if(W2D_rs1_forward_logic) begin
            br_forward_rs1 = 2'b10;
        end else if(M2D_rs1_forward_logic) begin
            br_forward_rs1 = 2'b01;
        end else begin
            br_forward_rs1 = 2'b00;
        end

        if(W2D_rs2_forward_logic & M2D_rs2_forward_logic) begin
            br_forward_rs2 = 2'b01;
        end else if(W2D_rs2_forward_logic) begin
            br_forward_rs2 = 2'b10;
        end else if(M2D_rs2_forward_logic) begin
            br_forward_rs2 = 2'b01;
        end else begin
            br_forward_rs2 = 2'b00;
        end


        if(l2u_normal_logic || l2u_1_head_br_logic || imm_use_br_logic) begin
            stall_D = 2'b01;
        end else if(l2u_imm_br_logic) begin
            stall_D = 2'b10;
        end else begin
            stall_D = 2'b00;
        end
    end
end




endmodule

