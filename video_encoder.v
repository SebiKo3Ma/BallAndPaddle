module video_encoder(input        clk, rst,
                                  bat_size,
                     input [1:0]  mode,
                     input [5:0]  p1_score,
                                  p2_score,
                     input [10:0] p1_y,
                                  p2_y,
                                  ball_x,
                                  ball_y,
                                  x,
                                  y,
                     output       px_data);

    localparam LB = 20,    //left boundry
               RB = 620,   //right boundry
               TB = 20,    //top boundry
               BB = 460,   //bottom boundry
               thick = 6; //line thickness

    reg ML_ff , ML_nxt ,  // middle line
        FBL_ff, FBL_nxt,  // football line left
        FBR_ff, FBR_nxt,  // football line right
        SQ_ff , SQ_nxt ,  // squash line
        P1_ff , P1_nxt ,  // P1 main paddle visibility
        P1F_ff, P1F_nxt,  // P1 football forward visibility
        P2_ff , P2_nxt ,  // P2 main paddle visibility
        P2F_ff, P2F_nxt,  // P2 football forward visibility
        P2S_ff, P2S_nxt;  // P2 squash paddle visibility

    reg [5:0] size_ff, size_nxt; //bat size

    //pixel data output registers
    reg px_data_ff, px_data_nxt;
    assign px_data = px_data_ff;

    always @* begin
        ML_nxt  = ML_ff ;
        FBL_nxt = FBL_ff;
        FBR_nxt = FBR_ff;
        SQ_nxt  = SQ_ff ;
        P1_nxt  = P1_ff ;
        P1F_nxt = P1F_ff;
        P2_nxt  = P2_ff ;
        P2F_nxt = P2F_ff;
        P2S_nxt = P2S_ff;
        size_nxt = size_ff;
        px_data_nxt = 1'b0;

        //enable components of the field based on the game mode
        case(mode)
            2'b00 : begin //tennis
                ML_nxt  = 1'b1;
                FBL_nxt = 1'b0;
                FBR_nxt = 1'b0;
                SQ_nxt  = 1'b0;
                P1_nxt  = 1'b1;
                P1F_nxt = 1'b0;
                P2_nxt  = 1'b1;
                P2F_nxt = 1'b0;
                P2S_nxt = 1'b0;
            end

            2'b01 : begin //football
                ML_nxt  = 1'b1;
                FBL_nxt = 1'b1;
                FBR_nxt = 1'b1;
                SQ_nxt  = 1'b0;
                P1_nxt  = 1'b1;
                P1F_nxt = 1'b1;
                P2_nxt  = 1'b1;
                P2F_nxt = 1'b1;
                P2S_nxt = 1'b0;
            end

            2'b10 : begin //squash
                ML_nxt  = 1'b0;
                FBL_nxt = 1'b1;
                FBR_nxt = 1'b0;
                SQ_nxt  = 1'b1;
                P1_nxt  = 1'b0;
                P1F_nxt = 1'b1;
                P2_nxt  = 1'b0;
                P2F_nxt = 1'b0;
                P2S_nxt = 1'b1;
            end

            2'b11 : begin //practice
                ML_nxt  = 1'b0;
                FBL_nxt = 1'b1;
                FBR_nxt = 1'b0;
                SQ_nxt  = 1'b1;
                P1_nxt  = 1'b0;
                P1F_nxt = 1'b1;
                P2_nxt  = 1'b0;
                P2F_nxt = 1'b0;
                P2S_nxt = 1'b1;
            end
        endcase

        //draw top and bottom boundries boundries
        if(x >= LB && x < RB) begin
            if((y >= TB && y < TB + thick) || (y < BB && y >= BB - thick)) begin
                px_data_nxt = 1'b1;
            end
        end

        //draw middle line
        if(ML_ff) begin
            if(x >= 327 && x <= 333) begin
                if(   (y >= 40 && y < 50) ||
                      (y >= 60 && y < 70) ||
                      (y >= 80 && y < 90) ||
                    (y >= 100 && y < 110) ||
                    (y >= 120 && y < 130) ||
                    (y >= 140 && y < 150) ||
                    (y >= 160 && y < 170) ||
                    (y >= 180 && y < 190) ||
                    (y >= 200 && y < 210) ||
                    (y >= 220 && y < 230) ||

                    (y >= 237 && y < 243) ||

                    (y >= 250 && y < 260) ||
                    (y >= 270 && y < 280) ||
                    (y >= 290 && y < 300) ||
                    (y >= 310 && y < 320) ||
                    (y >= 330 && y < 340) ||
                    (y >= 350 && y < 360) ||
                    (y >= 370 && y < 380) ||
                    (y >= 390 && y < 400) ||
                    (y >= 410 && y < 420) ||
                    (y >= 430 && y < 440)
                ) begin
                    px_data_nxt = 1'b1;
                end
            end
        end

        //draw left football lines
        if(FBL_ff) begin
            if(x >= LB && x < LB + thick) begin
                if((y >= TB && y < 130) || (y >= 350 && y < BB)) begin
                    px_data_nxt = 1'b1;
                end
            end
        end

        //draw right football lines
        if(FBR_ff) begin
            if(x >= RB - thick && x < RB) begin
                if((y >= TB && y < 130) || (y >= 350 && y < BB)) begin
                    px_data_nxt = 1'b1;
                end
            end
        end

        //draw squash line
        if(SQ_ff) begin
            if(x >= LB && x < LB + thick) begin
                if(y >= 130 && y < 350) begin
                    px_data_nxt = 1'b1;
                end
            end
        end

        //set paddle size
        if(bat_size) begin
            size_nxt = 6'd35;
        end else begin
            size_nxt = 6'd25;
        end

        //draw player 1 paddles
        if(y >= p1_y - size_ff && y < p1_y + size_ff) begin
            //main paddle
            if(P1_ff && x >= 40 && x < 50) begin
                px_data_nxt = 1'b1;
            end

            //football forward / squash paddle
            if(P1F_ff && x >= 480 && x < 490) begin
                px_data_nxt = 1'b1;
            end
        end

        //draw player 2 paddles
        if(y >= p2_y - size_ff && y < p2_y + size_ff) begin
            //main paddle
            if(P2_ff && x >= 590 && x < 600) begin
                px_data_nxt = 1'b1;
            end

            //football forward
            if(P2F_ff && x >= 150 && x < 160) begin
                px_data_nxt = 1'b1;
            end

            //squash paddle
            if(P2S_ff && x >= 500 && x < 510) begin
                px_data_nxt = 1'b1;
            end
        end

        //draw ball
        if(x >= ball_x - 4 && x < ball_x + 4) begin
            if(y >= ball_y - 4 && y < ball_y + 4) begin
                px_data_nxt = 1'b1;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            ML_ff      <= 1'b0;
            FBL_ff     <= 1'b0;
            FBR_ff     <= 1'b0;
            SQ_ff      <= 1'b0;
            P1_ff      <= 1'b0;
            P1F_ff     <= 1'b0;
            P2_ff      <= 1'b0;
            P2F_ff     <= 1'b0;
            P2S_ff     <= 1'b0;
            size_ff    <= 6'd0;
            px_data_ff <= 1'b0;
        end else begin
            ML_ff      <= ML_nxt;
            FBL_ff     <= FBL_nxt;
            FBR_ff     <= FBR_nxt;
            SQ_ff      <= SQ_nxt;
            P1_ff      <= P1_nxt;
            P1F_ff     <= P1F_nxt;
            P2_ff      <= P2_nxt;
            P2F_ff     <= P2F_nxt;
            P2S_ff     <= P2S_nxt;
            size_ff    <= size_nxt;
            px_data_ff <= px_data_nxt;
        end
    end
endmodule