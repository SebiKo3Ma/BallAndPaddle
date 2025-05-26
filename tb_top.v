`timescale 1ns/1ns
module tb_top();
    reg clk, rst;
    reg bat_size, ball_speed, angle, serve_type, serve, start, p1p, p1m, p2p, p2m;
    reg [1:0] mode, max_score;
    wire [9:0] RED, GRN, BLU;
    wire HSYNC, VSYNC, px_clk, blank;
    wire hit_out, hit_wall, hit_goal;

    top top(clk, rst, ball_speed, serve_type, angle, bat_size, serve, start, p1p, p1m, p2p, p2m, mode, max_score, hit_out, wall_out, goal_out,  RED, GRN, BLU, HSYNC, VSYNC, px_clk, blank);

    initial begin
        clk = 0;
        forever #5 clk = !clk;
    end

    initial begin
        rst = 1'b1;

        #20 rst = 1'b0;
        #100 bat_size = 1'b0;
        ball_speed = 1'b0;
        serve_type = 1'b0;
        angle = 1'b0;
        serve = 1'b0;
        p1p = 1'b0;
        p1m = 1'b0;
        p2p = 1'b0;
        p2m = 1'b0;
        max_score = 2'b00;
        mode = 2'b00; 
        start = 1'b1;     
    end
endmodule