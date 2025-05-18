module video_encoder(input        clk, rst,
                                  bat_size,
                     input [1:0]  mode,
                     input [4:0]  p1_score,
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

    wire [13:0] scl, scr;

    //pixel data output registers
    reg px_data_ff, px_data_nxt;
    assign px_data = px_data_ff;

    segments_lut segl(p1_score, scl);
    segments_lut segr(p2_score, scr);

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
                P2S_nxt = 1'b0;
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
            if(x >= 317 && x <= 323) begin
                if(   (y >= 36 && y < 46) ||
                      (y >= 56 && y < 66) ||
                      (y >= 76 && y < 86) ||
                    (y >=  96 && y < 106) ||
                    (y >= 116 && y < 126) ||
                    (y >= 136 && y < 146) ||
                    (y >= 156 && y < 166) ||
                    (y >= 176 && y < 186) ||
                    (y >= 196 && y < 206) ||
                    (y >= 216 && y < 226) ||

                    (y >= 235 && y < 245) ||

                    (y >= 254 && y < 264) ||
                    (y >= 274 && y < 284) ||
                    (y >= 294 && y < 304) ||
                    (y >= 314 && y < 324) ||
                    (y >= 334 && y < 344) ||
                    (y >= 354 && y < 364) ||
                    (y >= 374 && y < 384) ||
                    (y >= 394 && y < 404) ||
                    (y >= 414 && y < 424) ||
                    (y >= 434 && y < 444)
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
            if(P1_ff && x >= 40 && x < 46) begin
                px_data_nxt = 1'b1;
            end

            //football forward / squash paddle
            if(P1F_ff && x >= 484 && x < 490) begin
                px_data_nxt = 1'b1;
            end
        end

        //draw player 2 paddles
        if(y >= p2_y - size_ff && y < p2_y + size_ff) begin
            //main paddle
            if(P2_ff && x >= 594 && x < 600) begin
                px_data_nxt = 1'b1;
            end

            //football forward
            if(P2F_ff && x >= 150 && x < 156) begin
                px_data_nxt = 1'b1;
            end

            //squash paddle
            if(P2S_ff && x >= 500 && x < 506) begin
                px_data_nxt = 1'b1;
            end
        end

        //draw ball
        if(x >= ball_x - 4 && x < ball_x + 4) begin
            if(y >= ball_y - 4 && y < ball_y + 4) begin
                px_data_nxt = 1'b1;
            end
        end

        //draw score left
        //second digit
        if(x >= 282 && x < 300) begin
            if(y >= 50 && y <= 56) begin
                if(scl[5]) begin
                    px_data_nxt = 1'b1;
                end
            end
            if(y >= 62 && y <= 68) begin
                if(scl[6]) begin
                    px_data_nxt = 1'b1;
                end
            end
            if(y >= 74 && y <= 80) begin
                if(scl[2]) begin
                    px_data_nxt = 1'b1;
                end
            end
        end

        if(x >= 282 && x < 288) begin
            if(y >= 50 && y < 68) begin
                if(scl[4]) begin
                    px_data_nxt = 1'b1;
                end
            end

            if(y >= 62 && y < 80) begin
                if(scl[3]) begin
                    px_data_nxt = 1'b1;
                end
            end
        end

        if(x >= 294 && x < 300) begin
            if(y >= 50 && y < 68) begin
                if(scl[0]) begin
                    px_data_nxt = 1'b1;
                end
            end

            if(y >= 62 && y < 80) begin
                if(scl[1]) begin
                    px_data_nxt = 1'b1;
                end
            end
        end

        //first digit
        if(x >= 258 && x < 276) begin
            if(y >= 50 && y <= 56) begin
                if(scl[12]) begin
                    px_data_nxt = 1'b1;
                end
            end
            if(y >= 62 && y <= 68) begin
                if(scl[13]) begin
                    px_data_nxt = 1'b1;
                end
            end
            if(y >= 74 && y <= 80) begin
                if(scl[9]) begin
                    px_data_nxt = 1'b1;
                end
            end
        end

        if(x >= 258 && x < 264) begin
            if(y >= 50 && y < 68) begin
                if(scl[11]) begin
                    px_data_nxt = 1'b1;
                end
            end

            if(y >= 62 && y < 80) begin
                if(scl[10]) begin
                    px_data_nxt = 1'b1;
                end
            end
        end

        if(x >= 270 && x < 276) begin
            if(y >= 50 && y < 68) begin
                if(scl[7]) begin
                    px_data_nxt = 1'b1;
                end
            end

            if(y >= 62 && y < 80) begin
                if(scl[8]) begin
                    px_data_nxt = 1'b1;
                end
            end
        end

        //draw score right
        if(mode != 2'b11) begin
            //first digit
            if(x >= 340 && x < 358) begin
                if(y >= 50 && y <= 56) begin
                    if(scr[12]) begin
                        px_data_nxt = 1'b1;
                    end
                end
                if(y >= 62 && y <= 68) begin
                    if(scr[13]) begin
                        px_data_nxt = 1'b1;
                    end
                end
                if(y >= 74 && y <= 80) begin
                    if(scr[9]) begin
                        px_data_nxt = 1'b1;
                    end
                end
            end

            if(x >= 340 && x < 346) begin
                if(y >= 50 && y < 68) begin
                    if(scr[11]) begin
                        px_data_nxt = 1'b1;
                    end
                end

                if(y >= 62 && y < 80) begin
                    if(scr[10]) begin
                        px_data_nxt = 1'b1;
                    end
                end
            end

            if(x >= 352 && x < 358) begin
                if(y >= 50 && y < 68) begin
                    if(scr[7]) begin
                        px_data_nxt = 1'b1;
                    end
                end

                if(y >= 62 && y < 80) begin
                    if(scr[8]) begin
                        px_data_nxt = 1'b1;
                    end
                end
            end

            //second digit
            if(x >= 364 && x < 382) begin
                if(y >= 50 && y <= 56) begin
                    if(scr[5]) begin
                        px_data_nxt = 1'b1;
                    end
                end
                if(y >= 62 && y <= 68) begin
                    if(scr[6]) begin
                        px_data_nxt = 1'b1;
                    end
                end
                if(y >= 74 && y <= 80) begin
                    if(scr[2]) begin
                        px_data_nxt = 1'b1;
                    end
                end
            end

            if(x >= 364 && x < 370) begin
                if(y >= 50 && y < 68) begin
                    if(scr[4]) begin
                        px_data_nxt = 1'b1;
                    end
                end

                if(y >= 62 && y < 80) begin
                    if(scr[3]) begin
                        px_data_nxt = 1'b1;
                    end
                end
            end

            if(x >= 376 && x < 382) begin
                if(y >= 50 && y < 68) begin
                    if(scr[0]) begin
                        px_data_nxt = 1'b1;
                    end
                end

                if(y >= 62 && y < 80) begin
                    if(scr[1]) begin
                        px_data_nxt = 1'b1;
                    end
                end
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