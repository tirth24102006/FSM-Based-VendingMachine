module dflipflop(Q,Qb, D, clk, rst);
input D, clk, rst;
output reg Q, Qb;
always@(posedge clk) begin
        if (rst) begin
                Q <= 0;
                Qb <= 1;
        end else begin
                Q <= D;
                Qb <= ~D;
        end
end
endmodule 