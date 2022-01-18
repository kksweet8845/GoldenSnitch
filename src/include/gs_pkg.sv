package gs_pkg;



typedef enum logic [4:0] {
    RESET,
    BOOT_SET,
    FIRST_FETCH,
    DECODE,
    WAIT_FETCH,
    IF_ERR,
    ID_ERR
}ctrl_state_t;


typedef enum logic [3:0] {
    PC_BOOT = 4'b0000,
    PC_BRANCH = 4'b0001,
    PC_JUMP  = 4'b0010,
    PC_NORMAL = 4'b0011
} pc_sel_t;

typedef enum logic [2:0] {
    RS1_REG_NO_FORWARD,
    RS1_REG_WB_FORWARD,
    RS1_REG_EX_FORWARD,
    RS2_REG_NO_FORWARD,
    RS2_REG_WB_FORWARD,
    RS2_REG_EX_FORWARD
} forward_ctrl_t;


typedef enum logic [4:0] {
    OP          = 5'b01100,
    OP_IMM      = 5'b00100,
    LOAD        = 5'b00000,
    STORE       = 5'b01000,
    BRANCH      = 5'b11000,
    JALR        = 5'b11001,
    JAL         = 5'b11011,
    AUIPC       = 5'b00101,
    LUI         = 5'b01101
} instr_type_t;


typedef enum logic [4:0] {
    INITIAL,
    PENDING,
    FETCHING,
} pf_state_t;


typedef enum logic [3:0] {
    PLUS    = 4'b0000,
    MINUS   = 4'b1000,
    SLL     = 4'b0001,
    SLT     = 4'b0010,
    SLTU    = 4'b0011,
    XOR     = 4'b0100,
    SRL     = 4'b0101,
    SRA     = 4'b1101,
    OR      = 4'b0110,
    AND     = 4'b0111,
    FORWARD = 4'b1010,
    BEQ     = 4'b1000,
    BNE     = 4'b1001,
    BLT     = 4'b1100,
    BGE     = 4'b1101,
    BLTU    = 4'b1110,
    BGEU    = 4'b1111
} alu_type_t;





endpackage