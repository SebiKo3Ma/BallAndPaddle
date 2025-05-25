module top(input clk, rst, ball_speed, serve_type, angle, bat_size, serve, start, p1p, p1m, p2p, p2m, input[1:0] mode, max_score, output [9:0] RED, GRN, BLU, output HSYNC, VSYNC, px_clk, blank);
    wire [10:0] x, y, p1_y, p2_y, bx, by;
    wire px_data_out;
    wire [29:0] px_data_in;
    wire [4:0] score1, score2;
    wire wp1p, wp1m, wp2p, wp2m, p1_win, p2_win;
    wire [1:0] game_mode;

    assign px_data_in = {30{px_data_out}};
    assign blank = 1'b1;

    // demo_players demo_players(clk, rst, 1'b1, p1_y, p2_y);
    // demo_ball demo_ball(clk, rst, en, bx, by);
    // demo_score demo_score(clk, rst, en2, score1, score2);
    debouncer d1(px_clk, rst, p1p, wp1p);
    debouncer d2(px_clk, rst, p1m, wp1m);
    debouncer d3(px_clk, rst, p2p, wp2p);
    debouncer d4(px_clk, rst, p2m, wp2m);
    paddle_controller_btn pctrl(clk, rst, wp1p, wp1m, wp2p, wp2m, bat_size, p1_y, p2_y);
    clk_divider clk_divider(clk, rst, px_clk);
    game_controller game_controller(clk, rst, p1_y, p2_y, mode, max_score, ball_speed, serve_type, angle, bat_size, !serve, !start, p1_win, p2_win, game_mode, score1, score2, p1_y, p2_y, bx, by);
    video_encoder video_encoder(clk, rst, bat_size, p1_win, p2_win, game_mode, score1, score2, p1_y, p2_y, bx, by, x, y, px_data_out);
    vga_controller vga_controller(px_clk, rst, px_data_in, x, y, RED, GRN, BLU, HSYNC, VSYNC);
endmodule