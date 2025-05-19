module top(input clk, rst, ball_speed, angle, bat_size, input[1:0] mode, output [9:0] RED, GRN, BLU, output HSYNC, VSYNC, px_clk, blank);
    wire [10:0] x, y, p1_y, p2_y, bx, by;
    wire px_data_out;
    wire [29:0] px_data_in;
    wire [4:0] score1, score2;

    assign px_data_in = {30{px_data_out}};
    assign blank = 1'b1;

    // demo_players demo_players(clk, rst, en, p1_y, p2_y);
    // demo_ball demo_ball(clk, rst, en, bx, by);
    // demo_score demo_score(clk, rst, en2, score1, score2);
    clk_divider clk_divider(clk, rst, px_clk);
    game_controller game_controller(clk, rst, 11'd62, 11'd418, mode, ball_speed, 1'b0, angle, bat_size, 1'b0, score1, score2, p1_y, p2_y, bx, by);
    video_encoder video_encoder(clk, rst, bat_size, mode, score1, score2, p1_y, p2_y, bx, by, x, y, px_data_out);
    vga_controller vga_controller(px_clk, rst, px_data_in, x, y, RED, GRN, BLU, HSYNC, VSYNC);
endmodule