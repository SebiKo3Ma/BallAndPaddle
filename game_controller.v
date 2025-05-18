module game_controller( input clk, rst,     
                        input  [10:0] p1_in,      // y input for player 1
                                      p2_in,      // y input for player 2
                        input  [1:0]  mode,       // game mode: 00-tennis, 01-soccer, 10-squash, 11-practice
                        input         ball_speed, // slow / fast
                                      serve_type, // auto / manual
                                      angle,      // narrow / wide
                                      bat_size,   // small / large
                                      serve,      // serve trigger
                        output [4:0]  p1_score,   // score for player 1
                                      p2_score,   // score for player 2
                        output [10:0] p1_y,       // vertical position of player 1
                                      p2_y,       // vertical position of player 2
                                      ball_x,     // horizontal position of ball
                                      ball_y);    // vertical position of ball

    //ball registers
    reg [10:0] x_ff, x_nxt, y_ff, y_nxt; //ball position flip-flops
    reg xh_ff, xh_nxt, yh_ff, yh_nxt;    //ball heading flip-flops
    reg [17:0] counter_ff, counter_nxt;  //counter for ball movement speed

    //score registers
    reg [4:0] p1_score_ff, p1_score_nxt, p2_score_ff, p2_score_nxt; //player scores flip-flops

    //player paddle registers
    reg [10:0] p1_ff, p1_nxt, p2_ff, p2_nxt;

    //output assignments
    assign p1_score = p1_score_ff;
    assign p2_score = p2_score_ff;
    assign p1_y = p1_in;
    assign p2_y = p2_in;
    assign ball_x = x_ff;
    assign ball_y = y_ff;


    always @* begin
        p1_score_nxt = p1_score_ff;
        p2_score_nxt = p2_score_ff;

        counter_nxt = counter_ff + 1;
        x_nxt = x_ff;
        y_nxt = y_ff;
        xh_nxt = xh_ff;
        yh_nxt = yh_ff;

        //ball movement and collisions
        if(!counter_ff || ball_speed) begin
            if(xh_ff) begin
                x_nxt = x_ff + 1;
            end else begin
                x_nxt = x_ff - 1;
            end

            if(yh_ff) begin
                y_nxt = y_ff + 1;
            end else begin
                y_nxt = y_ff - 1;
            end

            if(x_ff <= 11'd30) begin
                xh_nxt = 1'b1;
                x_nxt = 11'd31;
                p2_score_nxt = p2_score_ff + 1;
            end

            if(x_ff >= 11'd610) begin
                xh_nxt = 1'b0;
                x_nxt = 11'd609;
                p1_score_nxt = p1_score_ff + 1;
            end

            if(y_ff <= 11'd30) begin
                yh_nxt = 1'b1;
                y_nxt = 11'd31;
            end

            if(y_ff >= 11'd450) begin
                yh_nxt = 1'b0;
                y_nxt = 11'd445;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin 
            p1_score_ff <= 5'd0;
            p2_score_ff <= 5'd0;

            counter_ff <= 18'd1;
            x_ff <= 11'd60;
            y_ff <= 11'd60;
            xh_ff <= 1'b1;
            yh_ff <= 1'b1;
        end else begin
            p1_score_ff <= p1_score_nxt;
            p2_score_ff <= p2_score_nxt;

            counter_ff <= counter_nxt;
            x_ff <= x_nxt;
            y_ff <= y_nxt;
            xh_ff <= xh_nxt;
            yh_ff <= yh_nxt;
        end
    end

endmodule