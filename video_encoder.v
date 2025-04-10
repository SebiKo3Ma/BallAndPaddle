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

    reg [6:0] scl_ff, scl_nxt;

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
        scl_nxt = scl_ff;

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
        if(x >= 300 - (3 * thick) && x < 300) begin
            if(y >= 50 && y <= 50 + thick) begin
                if(scl_ff[5]) begin
                    px_data_nxt = 1'b1;
                end
            end
            if(y >= 50 + (2 * thick) && y <= 50 + (3 * thick)) begin
                if(scl_ff[6]) begin
                    px_data_nxt = 1'b1;
                end
            end
            if(y >= 50 + (4 * thick) && y <= 50 + (5 * thick)) begin
                if(scl_ff[2]) begin
                    px_data_nxt = 1'b1;
                end
            end
        end

        if(x >= 300 - (3*thick) && x < 300 - (2*thick)) begin
            if(y >= 50 && y < 50 + (3 * thick)) begin
                if(scl_ff[4]) begin
                    px_data_nxt = 1'b1;
                end
            end

            if(y >= 50 + (2*thick) && y < 50 + (5 * thick)) begin
                if(scl_ff[3]) begin
                    px_data_nxt = 1'b1;
                end
            end
        end

        if(x >= 300 - thick && x < 300) begin
            if(y >= 50 && y < 50 + (3 * thick)) begin
                if(scl_ff[0]) begin
                    px_data_nxt = 1'b1;
                end
            end

            if(y >= 50 + (2*thick) && y < 50 + (5 * thick)) begin
                if(scl_ff[1]) begin
                    px_data_nxt = 1'b1;
                end
            end
        end

        //draw score right
        if(mode != 2'b11) begin
            if(x >= 340 && x < 340 + (3 * thick)) begin
                if(y >= 50 && y <= 50 + thick) begin
                    if(scl_ff[5]) begin
                        px_data_nxt = 1'b1;
                    end
                end
                if(y >= 50 + (2 * thick) && y <= 50 + (3 * thick)) begin
                    if(scl_ff[6]) begin
                        px_data_nxt = 1'b1;
                    end
                end
                if(y >= 50 + (4 * thick) && y <= 50 + (5 * thick)) begin
                    if(scl_ff[2]) begin
                        px_data_nxt = 1'b1;
                    end
                end
            end

            if(x >= 340 && x < 340 + thick) begin
                if(y >= 50 && y < 50 + (3 * thick)) begin
                    if(scl_ff[4]) begin
                        px_data_nxt = 1'b1;
                    end
                end

                if(y >= 50 + (2*thick) && y < 50 + (5 * thick)) begin
                    if(scl_ff[3]) begin
                        px_data_nxt = 1'b1;
                    end
                end
            end

            if(x >= 340 + (2 * thick) && x < 340 + (3 * thick)) begin
                if(y >= 50 && y < 50 + (3 * thick)) begin
                    if(scl_ff[0]) begin
                        px_data_nxt = 1'b1;
                    end
                end

                if(y >= 50 + (2*thick) && y < 50 + (5 * thick)) begin
                    if(scl_ff[1]) begin
                        px_data_nxt = 1'b1;
                    end
                end
            end
        end

        //score counter
        case(p1_score)
            6'd0 : begin
                scl_nxt = 7'b0111111;
            end

            6'd1: begin
                scl_nxt = 7'b0000011;
            end

            6'd2 : begin
                scl_nxt = 7'b1101101;
            end

            6'd3: begin
                scl_nxt = 7'b1100111;
            end

            6'd4 : begin
                scl_nxt = 7'b1010011;
            end

            6'd5: begin
                scl_nxt = 7'b1110110;
            end

            6'd6 : begin
                scl_nxt = 7'b1111110;
            end

            6'd7: begin
                scl_nxt = 7'b0100011;
            end

            6'd8 : begin
                scl_nxt = 7'b1111111;
            end

            6'd9: begin
                scl_nxt = 7'b1110111;
            end

            default: begin
                scl_nxt = 7'b1111000;
            end
        endcase
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
            scl_ff <= 7'b0111111;
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
            scl_ff <= scl_nxt;
        end
    end
endmodule