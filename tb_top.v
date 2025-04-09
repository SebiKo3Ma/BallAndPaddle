`timescale 1ns/1ns
module tb_top();
    reg clk, rst;
    wire [7:0] RED, GRN, BLU;
    wire HSYNC, VSYNC;

    top top(clk, rst, RED, GRN, BLU, HSYNC, VSYNC);

    initial begin
        clk = 0;
        forever #5 clk = !clk;
    end

    initial begin
        rst = 1'b1;

        #20 rst = 1'b0;      
    end
endmodule