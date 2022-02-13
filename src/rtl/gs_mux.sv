module GS_MUX_3
    import gs_pkg::*
#(
    SEL_WIDTH = 2,
    SRC_WIDTH = 32,
    INPUT_0   = 2'b00,
    INPUT_1   = 2'b01,
    INPUT_2   = 2'b10,
)
(
    input  logic [SRC_WIDTH-1:0] a0,
    input  logic [SRC_WIDTH-1:0] a1,
    input  logic [SRC_WIDTH-1:0] a2,
    input  logic [SEL_WIDTH-1:0] sel,
    output logic [SRC_WIDTH-1:0] out
);


    always_comb begin
        unique case
        INPUT_0: out = a0;
        INPUT_1: out = a1;
        INPUT_2: out = a2;
        default: out = 0;
        endcase
    end

endmodule


module GS_MUX_2
    import gs_pkg::*
#(
    SEL_WIDTH = 1,
    SRC_WIDTH = 32,
    INPUT_0   = 1'b0,
    INPUT_1   = 1'b1,
)
(
    input  logic [SRC_WIDTH-1:0] a0,
    input  logic [SRC_WIDTH-1:0] a1,
    input  logic [SEL_WIDTH-1:0] sel,
    output logic [SRC_WIDTH-1:0] out
);


    always_comb begin
        unique case
        INPUT_0: out = a0;
        INPUT_1: out = a1;
        default: out = 0;
        endcase
    end

endmodule

