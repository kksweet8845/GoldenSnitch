module BranchCtrl(
    rst,
    D_PCSrc,
    D_BSrc,
    br_sel
);

input [1:0]     ID_PCSrc;
input           ID_BSrc;
output [1:0]    br_sel;

always@(*) begin
    if(!rst) begin
        br_sel = 2'b00;
    end else begin
        if(D_PCSrc == 2'b11) begin
            br_sel = (D_BSrc == 1'b1) ? 2'b01 : 2'b00;
        end else begin
            br_sel = D_PCSrc;
        end
    end
end


endmodule