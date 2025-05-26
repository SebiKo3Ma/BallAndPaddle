module game_controller( input clk, rst,     
                        input  [10:0] p1_in,      // y input for player 1
                                      p2_in,      // y input for player 2
                        input  [1:0]  mode,       // game mode: 00-tennis, 01-soccer, 10-squash, 11-practice
                                      max_score,  // score needed to win: 00-10, 01-15, 10-20, 11-30
                        input         ball_speed, // slow / fast
                                      serve_type, // auto / manual
                                      angle,      // narrow / wide
                                      bat_size,   // small / large
                                      serve,      // serve trigger
                                      start,
                        output        p1_win,
                                      p2_win,
                                      turn,
                                      start_state,
                                      hit,
                                      wall,
                                      goal,
                        output [1:0]  mode_out,
                        output [4:0]  p1_score,   // score for player 1
                                      p2_score,   // score for player 2
                        output [10:0] p1_y,       // vertical position of player 1
                                      p2_y,       // vertical position of player 2
                                      ball_x,     // horizontal position of ball
                                      ball_y);    // vertical position of ball

    localparam[1:0] START = 2'b00,
                    GAME  = 2'b01,
                    SERVE = 2'b10,
                    ENDG  = 2'b11;

    reg [1:0] state_ff, state_nxt;
    reg [1:0] mode_ff, mode_nxt;
    reg start_state_ff;
    reg hit_ff, hit_nxt, wall_ff, wall_nxt, goal_ff, goal_nxt;

    //ball registers
    reg [10:0] x_ff, x_nxt, y_ff, y_nxt; //ball position flip-flops
    reg xh_ff, xh_nxt, yh_ff, yh_nxt;    //ball heading flip-flops
    reg [16:0] counter_ff, counter_nxt;  //counter for ball movement speed
    reg mini_counter_ff, mini_counter_nxt;
    reg ball_en_ff, ball_en_nxt;
    reg [4:0] rand_pos_ff, rand_pos_nxt;
    reg [1:0] move_counter_ff, move_counter_nxt;

    //score registers
    reg [4:0] p1_score_ff, p1_score_nxt, p2_score_ff, p2_score_nxt; //player scores flip-flops
    reg turn_ff, turn_nxt; //squash player turn flip-flop
    reg [4:0] win_score;
    reg win1_ff, win1_nxt, win2_ff, win2_nxt;

    //player paddle registers
    reg [4:0] bat;

    //output assignments
    assign mode_out = mode_ff;
    assign start_state = start_state_ff;
    assign hit = hit_ff;
    assign wall = wall_ff;
    assign goal = goal_ff;
    assign p1_win = win1_ff;
    assign p2_win = win2_ff;
    assign turn = turn_ff;
    assign p1_score = p1_score_ff;
    assign p2_score = p2_score_ff;
    assign p1_y = p1_in;
    assign p2_y = p2_in;
    assign ball_x = x_ff;
    assign ball_y = y_ff;

    function [1:0] angles;
        input [4:0] pos;

        case(pos)
            5'd0  : angles = 2'd0;
            5'd1  : angles = 2'd1;
            5'd2  : angles = 2'd2;
            5'd3  : angles = 2'd1;
            5'd4  : angles = 2'd2;
            5'd5  : angles = 2'd0;
            5'd6  : angles = 2'd0;
            5'd7  : angles = 2'd2;
            5'd8  : angles = 2'd1;
            5'd9  : angles = 2'd0;
            5'd10 : angles = 2'd1;
            5'd11 : angles = 2'd0;
            5'd12 : angles = 2'd1;
            5'd13 : angles = 2'd2;
            5'd14 : angles = 2'd2;
            5'd15 : angles = 2'd0;
            5'd16 : angles = 2'd2;
            5'd17 : angles = 2'd1;
            5'd18 : angles = 2'd2;
            5'd19 : angles = 2'd0;
            5'd20 : angles = 2'd0;
            5'd21 : angles = 2'd2;
            5'd22 : angles = 2'd1;
            5'd23 : angles = 2'd0;
            5'd24 : angles = 2'd1;
            5'd25 : angles = 2'd0;
            5'd26 : angles = 2'd2;
            5'd27 : angles = 2'd1;
            5'd28 : angles = 2'd1;
            5'd29 : angles = 2'd0;
            5'd30 : angles = 2'd0;
            5'd31 : angles = 2'd2;

            default : angles = 2'd0;
        endcase
    endfunction


    always @* begin
        state_nxt = state_ff;
        mode_nxt = mode_ff;
        hit_nxt = 1'b0;
        wall_nxt = 1'b0;
        goal_nxt = 1'b0;

        p1_score_nxt = p1_score_ff;
        p2_score_nxt = p2_score_ff;
        turn_nxt = turn_ff;
        win1_nxt = win1_ff;
        win2_nxt = win2_ff;

        counter_nxt = counter_ff + 17'd1;
        mini_counter_nxt = mini_counter_ff;
        move_counter_nxt = move_counter_ff;
        rand_pos_nxt = rand_pos_ff;

        x_nxt = x_ff;
        y_nxt = y_ff;
        xh_nxt = xh_ff;
        yh_nxt = yh_ff;
        ball_en_nxt = ball_en_ff;

        //game state machine
        case(state_ff)
            START : begin
                mode_nxt = mode;
                p1_score_nxt = 5'b0;
                p2_score_nxt = 5'b0;
                win1_nxt = 1'b0;
                win2_nxt = 1'b0;
                x_nxt = 11'd60;
                y_nxt = 11'd60;
                xh_nxt = 1'b1;
                yh_nxt = 1'b1;
                ball_en_nxt = 1'b0;
                turn_nxt = 1'b0;

                if(start) state_nxt = GAME;
            end

            GAME  : begin
                ball_en_nxt = 1'b1;
            end

            SERVE : begin
                ball_en_nxt = 1'b0;

                if(p1_score_ff >= win_score || p2_score_ff >= win_score) begin
                    state_nxt = ENDG;
                    if(p1_score_ff > p2_score_ff)
                        win1_nxt = 1'b1;
                    else win2_nxt = 1'b1;
                end else if(serve || !serve_type) state_nxt = GAME;
            end

            ENDG  : begin
                ball_en_nxt = 1'b1;
                if(serve) state_nxt = START;
            end
        endcase

        if(!counter_ff) begin
            mini_counter_nxt = mini_counter_ff + 1'b1;
        end

        //ball movement
        if((!mini_counter_ff || ball_speed) && !counter_ff && ball_en_ff) begin
            move_counter_nxt = move_counter_ff + 1'b1;

            if(xh_ff) begin
                x_nxt = x_ff + 11'd1;
            end else begin
                x_nxt = x_ff - 11'd1;
            end
            
            if(!angle || move_counter_ff == angles(rand_pos_ff)) begin
                move_counter_nxt = 2'b00;
                if(yh_ff) begin
                    y_nxt = y_ff + 11'd1;
                end else begin
                    y_nxt = y_ff - 11'd1;
                end
            end
        end

        case(mode_ff)
            2'b00 : begin //tennis collisions and score
                //horizontal collisions
                if(x_ff <= 11'd15) begin
                    xh_nxt = 1'b1;
                    x_nxt = 11'd160;
                    p2_score_nxt = p2_score_ff + 5'd1;
                    if(state_ff == GAME) state_nxt = SERVE;
                    goal_nxt = 1'b1;
                end

                if(x_ff >= 11'd625) begin
                    xh_nxt = 1'b0;
                    x_nxt = 11'd480;
                    p1_score_nxt = p1_score_ff + 5'd1;
                    if(state_ff == GAME) state_nxt = SERVE;
                    goal_nxt = 1'b1;
                end
            end

            2'b01 : begin //football collisions and score
                //side border collisions
                if(x_ff <= 11'd30) begin
                    if(!(y_ff >= 11'd134 && y_ff <= 11'd344)) begin
                        xh_nxt = 1'b1;
                        x_nxt = 11'd31;
                        wall_nxt = 1'b1;
                    end else if(x_ff <= 11'd15) begin
                        xh_nxt = 1'b1;
                        x_nxt = 11'd160;
                        p2_score_nxt = p2_score_ff + 5'd1;
                        if(state_ff == GAME) state_nxt = SERVE;
                        goal_nxt = 1'b1;
                    end
                end

                if(x_ff >= 11'd610) begin
                    if(!(y_ff >= 11'd134 && y_ff <= 11'd344)) begin
                        xh_nxt = 1'b0;
                        x_nxt = 11'd609;
                        wall_nxt = 1'b1;
                    end else if(x_ff >= 11'd625) begin
                        xh_nxt = 1'b0;
                        x_nxt = 11'd480;
                        p1_score_nxt = p1_score_ff + 5'd1;
                        if(state_ff == GAME) state_nxt = SERVE;
                        goal_nxt = 1'b1;
                    end
                end

            end

            2'b10 : begin //squash collision and scoring
                if(x_ff <= 11'd30) begin
                    xh_nxt = 1'b1;
                    x_nxt = 11'd31;
                    rand_pos_nxt = rand_pos_ff + 2'd1;
                    wall_nxt = 1'b1;
                end

                if(x_ff >= 625) begin
                    x_nxt = 11'd100;
                    goal_nxt = 1'b1;
                    if(turn_ff) begin
                        p1_score_nxt = p1_score_ff + 5'd1;
                        if(state_ff == GAME) state_nxt = SERVE;
                    end else begin
                        p2_score_nxt = p2_score_ff + 5'd1;
                        if(state_ff == GAME) state_nxt = SERVE;
                    end
                end
            end

            2'b11 : begin //squash practice collision and scoring
                if(x_ff <= 11'd30) begin
                    xh_nxt = 1'b1;
                    x_nxt = 11'd31;
                    rand_pos_nxt = rand_pos_ff + 2'd1;
                    wall_nxt = 1'b1;
                end

                if(x_ff >= 11'd625) begin
                    x_nxt = 11'd100;
                    p2_score_nxt = p2_score_ff + 5'd1;
                    if(state_ff == GAME) state_nxt = SERVE;
                    goal_nxt = 1'b1;
                end

                //p1 score with paddle
            end
        endcase

        //paddle collisions
        //player main paddles
        if(mode_ff== 2'b00 || mode_ff== 2'b01) begin //active in tennis and football
            if(x_ff == 11'd45 && y_ff >= p1_in - 4 - bat && y_ff <= p1_in + 4 + bat) begin
                xh_nxt = 1'b1;
                x_nxt = 11'd46;
                rand_pos_nxt = rand_pos_ff + 2'd1;
                hit_nxt = 1'b1;
            end

            if(x_ff == 11'd595 && y_ff >= p2_in - 4 - bat && y_ff <= p2_in + 4 + bat) begin
                xh_nxt = 1'b0;
                x_nxt = 11'd594;
                rand_pos_nxt = rand_pos_ff + 2'd1;
                hit_nxt = 1'b1;
            end
        end

        //player football forwards
        if(mode_ff== 2'b01) begin //active in football mode
            if(x_ff == 11'd489 && y_ff >= p1_in - 4 - bat && y_ff <= p1_in + 4 + bat) begin
                xh_nxt = 1'b1;
                x_nxt = 11'd490;
                rand_pos_nxt = rand_pos_ff + 2'd1;
                hit_nxt = 1'b1;

                if(y_ff < 11'd240) begin
                    yh_nxt = 1'b1;
                end else begin
                    yh_nxt = 1'b0;
                end
            end

            if(x_ff == 11'd155 && y_ff >= p2_in - 4 - bat && y_ff <= p2_in + 4 + bat) begin
                xh_nxt = 1'b0;
                x_nxt = 11'd154;
                rand_pos_nxt = rand_pos_ff + 2'd1;
                hit_nxt = 1'b1;

                if(y_ff < 11'd240) begin
                    yh_nxt = 1'b1;
                end else begin
                    yh_nxt = 1'b0;
                end
            end
        end

        //player 2 squash paddle
        if(mode_ff== 2'b10) begin //active in squash mode
            if(x_ff == 11'd505 && y_ff >= p2_in - 4 - bat && y_ff <= p2_in + 4 + bat && turn_ff) begin
                xh_nxt = 1'b0;
                x_nxt = 11'd504;
                rand_pos_nxt = rand_pos_ff + 2'd1;
                turn_nxt = turn_ff + 1'b1;
                hit_nxt = 1'b1;
            end
        end

        //player 1 squash paddle
        if(mode_ff== 2'b10 || mode_ff== 2'b11) begin //active in squash and practice mode
            if(x_ff == 11'd489 && y_ff >= p1_in - 4 - bat && y_ff <= p1_in + 4 + bat && !turn_ff) begin
                xh_nxt = 1'b0;
                x_nxt = 11'd488;
                rand_pos_nxt = rand_pos_ff + 2'd1;
                turn_nxt = turn_ff + 1'b1;
                if(mode_ff== 2'b11) begin
                    p1_score_nxt = p1_score_ff + 5'd1;
                    if(p1_score_ff >= max_score) state_nxt = SERVE;
                end
                hit_nxt = 1'b1;
            end
        end

        //vertical collisions
        if(y_ff <= 11'd30) begin
            yh_nxt = 1'b1;
            y_nxt = 11'd31;
            wall_nxt = 1'b1;
        end

        if(y_ff >= 11'd450) begin
            yh_nxt = 1'b0;
            y_nxt = 11'd445;
            wall_nxt = 1'b1;
        end
        
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin 
            state_ff <= START;
            mode_ff <= 2'b00;
            start_state_ff <= 1'b0;

            hit_ff <= 1'b0;
            wall_ff <= 1'b0;
            goal_ff <= 1'b0;

            p1_score_ff <= 5'd0;
            p2_score_ff <= 5'd0;
            turn_ff <= 1'b0;
            win_score <= 5'd10;
            win1_ff <= 1'b0;
            win2_ff <= 1'b0;

            counter_ff <= 17'd1;
            mini_counter_ff <= 1'b1;
            move_counter_ff <= 1'b1;
            rand_pos_ff <= 5'd0;
            x_ff <= 11'd60;
            y_ff <= 11'd60;
            xh_ff <= 1'b1;
            yh_ff <= 1'b1;
            ball_en_ff <= 1'b0;

            bat <= 5'd25;
        end else begin
            state_ff <= state_nxt;
            mode_ff <= mode_nxt;

            if(state_ff != ENDG) begin
                p1_score_ff <= p1_score_nxt;
                p2_score_ff <= p2_score_nxt;
            end

            if(state_ff == START)
                start_state_ff <= 1'b1;
            else start_state_ff <= 1'b0;

            hit_ff <= hit_nxt;
            wall_ff <= wall_nxt;
            goal_ff <= goal_nxt;

            win1_ff <= win1_nxt;
            win2_ff <= win2_nxt;

            turn_ff <= turn_nxt;

            counter_ff <= counter_nxt;
            mini_counter_ff <= mini_counter_nxt;
            move_counter_ff <= move_counter_nxt;
            rand_pos_ff <= rand_pos_nxt;
            x_ff <= x_nxt;
            y_ff <= y_nxt;
            xh_ff <= xh_nxt;
            yh_ff <= yh_nxt;
            ball_en_ff <= ball_en_nxt;

            if(bat_size) begin
                bat <= 5'd15;
            end else begin
                bat <= 5'd25;
            end

            case(max_score)
            2'b00 : win_score <= 5'd10;
            2'b01 : win_score <= 5'd15;
            2'b10 : win_score <= 5'd20;
            2'b11 : win_score <= 5'd30;
        endcase
        end
    end

endmodule