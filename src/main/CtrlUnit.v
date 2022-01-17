//* Main CPU Controller of Processor
`include "define.v"
module CtrlUnit
(
    clk,
    rst,
    pc_mux_sel,
);


input               clk;
input               rst;

output  [3:0]       pc_mux_sel;    



reg [4:0]   ctrl_fsm_cs;
reg [4:0]   ctrl_fsm_ns;




always@(posedge clk or negedge rst) begin
    if(!rst) begin
        cur_st <= 0;
    end else begin
        case(cur_st)
        RESET: begin //* reset

        end
        5'd1: begin //* copy boot address
            
        end
        5'd2: begin //* start to fetch instr
            
        end
        5'd3: begin //* start to decode
            
        end
        5'd4: begin 
            
        end


        endcase
    end
end




















endmodule