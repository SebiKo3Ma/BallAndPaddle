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

    function automatic [2:0] column;
        input [10:0] tlx;
        input [6:0] size, size2, size3, size4, size5;
        begin
            if(x >= tlx && x < tlx + size) begin
                column = 0;
            end else
            if(x >= tlx + size && x < tlx + size2) begin
                column = 1;
            end else
            if(x >= tlx + size2 && x < tlx + size3) begin
                column = 2;
            end else
            if(x >= tlx + size3 && x < tlx + size4) begin
                column = 3;
            end else
            if(x >= tlx + size4 && x < tlx + size5) begin
                column = 4;
            end else column = 5;
        end
    endfunction
    
    function automatic letter_data;
        input [10:0] tlx, tly, x, y;
        input [4:0] letter;
        input [3:0] size;
        
        reg [0:29] seg;
        reg [6:0] size2, size3, size4, size5, size6;
        reg[2:0] col;

        begin
            case(letter)
                5'd0  : seg = 30'b01110_10001_11111_10001_10001_10001; //A
                5'd1  : seg = 30'b11110_10001_11110_10001_10001_11110; //B
                5'd2  : seg = 30'b01110_10001_10000_10000_10001_01110; //C
                5'd3  : seg = 30'b11110_10001_10001_10001_10001_11110; //D
                5'd4  : seg = 30'b11111_10000_11100_10000_10000_11111; //E
                5'd5  : seg = 30'b11111_10000_11100_10000_10000_10000; //F
                5'd6  : seg = 30'b01110_10001_10000_10011_10001_01110; //G
                5'd7  : seg = 30'b10001_10001_10001_11111_10001_10001; //H
                5'd8  : seg = 30'b01110_00100_00100_00100_00100_01110; //I
                5'd9  : seg = 30'b00010_00010_00010_00010_01010_00100; //J
                5'd10 : seg = 30'b10001_10010_11100_10010_10001_10001; //K
                5'd11 : seg = 30'b10000_10000_10000_10000_10000_11111; //L
                5'd12 : seg = 30'b10001_11011_10101_10001_10001_10001; //M
                5'd13 : seg = 30'b10001_11001_10101_10011_10001_10001; //N
                5'd14 : seg = 30'b01110_10001_10001_10001_10001_01110; //O
                5'd15 : seg = 30'b11110_10001_11110_10000_10000_10000; //P
                5'd16 : seg = 30'b01100_10010_10010_10010_10010_01101; //Q
                5'd17 : seg = 30'b11110_10001_11110_10100_10010_10001; //R
                5'd18 : seg = 30'b01111_10000_01110_00001_00001_11110; //S
                5'd19 : seg = 30'b11111_00100_00100_00100_00100_00100; //T
                5'd20 : seg = 30'b10001_10001_10001_10001_10001_01110; //U
                5'd21 : seg = 30'b10001_10001_10001_01010_01010_00100; //V
                5'd22 : seg = 30'b10001_10001_10001_10101_10101_01010; //W
                5'd23 : seg = 30'b10001_01010_00100_01010_10001_10001; //X
                5'd24 : seg = 30'b10001_01010_00100_00100_00100_00100; //Y
                5'd25 : seg = 30'b11111_00010_00100_01000_10000_11111; //Z
                5'd26 : seg = 30'b00100_00100_00100_00100_00000_00100; //!
                5'd27 : seg = 30'b00100_01010_00010_00100_00000_00100; //?
                5'd28 : seg = 30'b00000_00000_00000_00000_00000_00100; //.
                5'd29 : seg = 30'b00000_00000_01110_00000_00000_00000; //-
                5'd30 : seg = 30'b00000_00000_00000_00000_00000_00000; //
                5'd31 : seg = 30'b00000_00000_00000_00000_00000_00000; //space

                default: seg = 30'b00000_00000_00000_00000_00000_00000;
            endcase

            size2 = size  + size;
            size3 = size2 + size;
            size4 = size3 + size;
            size5 = size4 + size;
            size6 = size5 + size;
            col = column(tlx, size, size2, size3, size4, size5);

            if(col != 5) begin
                if(y >= tly && y < tly + size ) begin
                    if(seg[col]) letter_data = 1'b1;
                end
                if(y >= tly + size  && y < tly + size2) begin
                    if(seg[5 + col]) letter_data = 1'b1;
                end
                if(y >= tly + size2 && y < tly + size3) begin
                    if(seg[10 + col]) letter_data = 1'b1;
                end
                if(y >= tly + size3 && y < tly + size4) begin
                    if(seg[15 + col]) letter_data = 1'b1;
                end
                if(y >= tly + size4 && y < tly + size5) begin
                    if(seg[20 + col]) letter_data = 1'b1;
                end
                if(y >= tly + size5 && y < tly + size6) begin
                    if(seg[25 + col]) letter_data = 1'b1;
                end
            end
        end
    endfunction

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

        if(x >= 80  && x < 100) px_data_nxt = letter_data(11'd80 , 11'd80, x, y, 5'd12, 4'd3);

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
            size_nxt = 6'd15;
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
            if(P2S_ff && (x == 500 || x == 501 || x == 504 || x == 505)) begin
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