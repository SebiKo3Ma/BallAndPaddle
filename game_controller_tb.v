module game_controller_tb;
    reg clk, rst;
    reg[10:0] p1_y, p2_y;
    reg[1:0] mode, max_score;
    reg ball_speed, serve_type, angle, bat_size, serve, start;
    wire p1_win, p2_win, turn;
    wire start_state;
    wire hit, goal;
    wire [1:0] game_mode;
    wire [4:0] score1, score2;
    wire [10:0] p1_yo, p2_yo, bx, by;

    game_controller game_controller(clk, rst, p1_y, p2_y, mode, max_score, ball_speed, serve_type, angle, bat_size, serve, start, 
                                p1_win, p2_win, turn, start_state, hit, wall, goal, game_mode, score1, score2, p1_yo, p2_yo, bx, by);

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1'b1;
        p1_y = 11'd240;
        p2_y = 11'd240;
        mode = 2'b00;
        max_score = 2'b00;
        ball_speed = 1'b0;
        serve_type = 1'b0;
        angle = 1'b0;
        bat_size = 1'b0;
        serve = 1'b0;
        start = 1'b1;
        #100 rst = 1'b0;
    end

endmodule