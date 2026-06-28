module vendingmachine(clk,rst,x,y,R,Q,QB);
input clk,rst;
input [1:0] x;
output reg y,R;
output [1:0] Q,QB;
wire w0,w1,w2,w3;
assign w1 = ((Q[1] & (~x[1])) & (QB[0] | (~x[0]))) | (((~x[0]) & x[1]) & (QB[1] | Q[0])) | ((~x[1]) & x[0] & QB[1] & Q[0]);
assign w0 = (~x[1] & ~x[0] & Q[0]) | (QB[1] & Q[0] & ~x[0]) | (Q[1] & Q[0] & ~x[1]) | (Q[1] & QB[0] & x[0]) | ((~x[1] & x[0]) & (Q[1] | QB[0]));
assign  w2 = ((x[1] & (~x[0])) & (Q[1] ^ Q[0])) | ((Q[1] & QB[0]) & (x[1] ^ x[0]));
assign w3 = (x[1]) & ((Q[1] & QB[0]) | (x[0] & QB[1] & Q[0]));
initial begin
        y<= 1'b0;
        R<= 1'b0;
end
always @(posedge clk) begin
        if(rst)begin
                y <= 1'b0;
                R <= 1'b0;
        end else begin
                y <= w2;
                R <= w3;
        end
end
dflipflop d0(Q[0], QB[0], w0, clk, rst);
dflipflop d1(Q[1], QB[1], w1, clk, rst);
endmodule