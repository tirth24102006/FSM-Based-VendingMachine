`timescale 1ns / 1ps
module vendingmachine_tb;
reg clk;
reg rst;
reg [1:0]x;
wire[1:0] Q,Qb;
wire y,R;
vendingmachine A1(clk,rst,x,y,R,Q,Qb);
initial begin
clk = 1'b0;
end 
always #5 clk=~clk;
initial begin
$dumpfile("dump.vcd");
$dumpvars(0, vendingmachine_tb);
$monitor("at time %t: clk=%b rst=%b x=%b Q=%b Qb=%b y=%b R=%b",$time,clk,rst,x,Q,Qb,y,R);
                rst = 1 ; x = 2'b00 ; #10;
                rst = 1 ; x = 2'b01 ; #10;
                rst = 1 ; x = 2'b10 ; #10;
                rst = 1 ; x = 2'b11 ; #10;
                rst = 0 ; x = 2'b01 ; #10;
                rst = 0 ; x = 2'b00 ; #10;
                rst = 0 ; x = 2'b01 ; #10;
                rst = 0 ; x = 2'b01 ; #10;
                rst = 0 ; x = 2'b11 ; #10;
                rst = 0 ; x = 2'b10 ; #10;
                rst = 0 ; x = 2'b01 ; #10;
                rst = 0 ; x = 2'b01 ; #10;
                rst = 0 ; x = 2'b10 ; #10;
                rst = 0 ; x = 2'b10 ; #10;
                rst = 0 ; x = 2'b11 ; #10;
                rst = 0 ; x = 2'b11 ; #10;
                rst = 0 ; x = 2'b10 ; #10;
                rst = 0 ; x = 2'b10 ; #10;
                rst = 0 ; x = 2'b00 ; #5;
        $finish;
end
endmodule