`timescale 1ns/1ns
module tb_top();
    reg clk, rst;
    reg bat_size, en, en2;
    reg [1:0] mode;
    wire [7:0] RED, GRN, BLU;
    wire HSYNC, VSYNC, px_clk, blank;

    top top(clk, rst, bat_size, en, en2, mode, RED, GRN, BLU, HSYNC, VSYNC, px_clk, blank);

    initial begin
        clk = 0;
        forever #5 clk = !clk;
    end

    initial begin
        rst = 1'b1;

        #20 rst = 1'b0;
        #100 bat_size = 1'b0;
        en = 1'b1;
        en2 = 1'b1;
        mode = 2'b00;      
    end
endmodule