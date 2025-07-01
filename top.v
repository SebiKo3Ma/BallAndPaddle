module top(input clk, rst, ball_speed, serve_type, angle, bat_size, restart, start, en_color, auto, hard_mode, input[3:0] mode, max_score, input[8:0] adc, output sel, size, output sound, output [9:0] RED, GRN, BLU, output HSYNC, VSYNC, px_clk, blank);
    wire [9:0] x, y, p1_y, p2_y, bx, by;
    reg [9:0] p2_y_ff;
    wire px_data_out;
    wire [29:0] px_data_in;
    wire [4:0] score1, score2;
    wire p1_win, p2_win, turn, start_state, hit, wall, goal;
    wire p2p, p2m, xh, yh;
    wire [1:0] game_mode;
    reg[1:0] mode_in, score_in;

    wire [9:0] ap2_y, pp2_y;

    assign blank = 1'b1;
    assign size = bat_size;
    assign p2_y = p2_y_ff;

    always @(posedge clk) begin
        if(auto) p2_y_ff <= ap2_y;
        else p2_y_ff <= pp2_y;

        if(mode[0]) mode_in <= 2'b00;
        if(mode[1]) mode_in <= 2'b01;
        if(mode[2]) mode_in <= 2'b10;
        if(mode[3]) mode_in <= 2'b11;

        if(max_score[0]) score_in <= 2'b00;
        if(max_score[1]) score_in <= 2'b01;
        if(max_score[2]) score_in <= 2'b10;
        if(max_score[3]) score_in <= 2'b11;
    end

    paddle_controller pctrl(clk, rst, p2p, p2m, bat_size, ap2_y);
    heading_detect heading_detect(clk, rst, bx, by, xh, yh);
    auto_player auto_player(clk, rst, auto, turn, hit, wall, start_state, hard_mode, xh, yh, game_mode, bx, by, ap2_y, p2p, p2m);

    adc_reader adc_reader(clk, rst, adc, sel, p1_y, pp2_y);
    clk_divider clk_divider(clk, rst, px_clk);
    sound_output sound_output(clk, rst, hit, wall, goal, sound);
    game_controller game_controller(clk, rst, p1_y, p2_y, mode_in, score_in, ball_speed, serve_type, angle, bat_size, restart, start, p1_win, p2_win, turn, start_state, hit, wall, goal, game_mode, score1, score2, bx, by);
    video_encoder video_encoder(clk, rst, bat_size, p1_win, p2_win, turn, start_state, game_mode, score1, score2, p1_y, p2_y, bx, by, x, y, px_data_out);
    color_module color_module(clk, rst, px_data_out, en_color, game_mode, x, y, px_data_in);
    vga_controller vga_controller(px_clk, rst, px_data_in, x, y, RED, GRN, BLU, HSYNC, VSYNC);
endmodule