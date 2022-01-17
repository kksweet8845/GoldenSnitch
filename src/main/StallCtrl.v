module StallCtrl(
    clk,
    rst,
    stall_D,
    M_MemRead,
    fd_flush,
    fd_en,
    de_flush,
    de_en,
    em_flush,
    em_en,
    mw_flush,
    mw_en,
    pc_en
);

input           rst;
input [1:0]     stall_D;
input           M_MemRead;


output          fd_flush;
output          fd_en;
output          de_flush;
output          de_en;
output          em_flush;
output          em_en;
output          mw_flush;
output          mw_en;
output          pc_en;

reg             stalling;
reg  [2:0]      stall_cnt;

reg [4:0]       cur_st;



always@(negedge clk or negedge rst) begin
    if(!rst) begin
        pc_en    <= 1;
        fd_flush <= 0; fd_en <= 1;
        de_flush <= 0; de_en <= 1;
        em_flush <= 0; em_en <= 1;
        mw_flush <= 0; mw_en <= 1;
        stall_cnt <= 0;
        cur_st <= 5'd0;
    end else begin
        case(cur_st)
        5'd0: begin //* initial state
            if(M_MemRead & stall_D != 0) begin
                //* stall M
                pc_en    <= 0;
                fd_flush <= 0; fd_en <= 0;
                de_flush <= 0; de_en <= 0;
                em_flush <= 0; em_en <= 0;
                mw_flush <= 1; mw_en <= 0;
                cur_st <= 5'd1;
            end else if(M_MemRead) begin
                pc_en    <= 0;
                fd_flush <= 0; fd_en <= 0;
                de_flush <= 0; de_en <= 0;
                em_flush <= 0; em_en <= 0;
                mw_flush <= 1; mw_en <= 0;
                cur_st <= 5'd3;
            end else if(stall_D != 0) begin
                pc_en    <= 0;
                fd_flush <= 0; fd_en <= 0;
                de_flush <= 1; de_en <= 0;
                em_flush <= 0; em_en <= 1;
                mw_flush <= 0; mw_en <= 1;
                stall_cnt <= stall_D;
                cur_st <= 5'd2;
            end
        end
        5'd1: begin //* stall M & handle stall_D
            pc_en    <= 0;
            fd_flush <= 0; fd_en <= 0;
            de_flush <= 1; de_en <= 0;
            em_flush <= 0; em_en <= 1;
            mw_flush <= 0; mw_en <= 1;
            stall_cnt <= stall_D;
            cur_st <= 5'd2;
        end
        5'd2: begin //* handle stall_D
            stall_cnt <= stall_cnt - 1;
            cur_st <= (stall_cnt - 1 == 0) ? 5'd0 : cur_st;
            if(stall_cnt - 1 == 0) begin
                pc_en    <= 1;
                fd_flush <= 0; fd_en <= 1;
                de_flush <= 0; de_en <= 1;
                em_flush <= 0; em_en <= 1;
                mw_flush <= 0; mw_en <= 1;
            end
        end
        5'd3: begin //* stall M
            pc_en    <= 1;
            fd_flush <= 0; fd_en <= 1;
            de_flush <= 0; de_en <= 1;
            em_flush <= 0; em_en <= 1;
            mw_flush <= 0; mw_en <= 1;
            cur_st <= 5'd0;
        end
        endcase
    end
end

endmodule
