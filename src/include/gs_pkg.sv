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






endpackage