module video_encoder(input        clk, rst,
                                  bat_size,
                                  p1_win,
                                  p2_win,
                                  turn,
                                  start_state,
                     input [1:0]  mode,
                     input [4:0]  p1_score,
                                  p2_score,
                     input [9:0] p1_y,
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
        input [9:0] tlx;
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
        input [9:0] tlx, tly, x, y;
        input [4:0] letter;
        input [3:0] size;
        
        reg [0:29] seg;
        reg [6:0] size2, size3, size4, size5, size6;
        reg[2:0] col;

        letter_data = 1'b0;

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
                5'd26 : seg = 30'b10000_10000_10000_10000_00000_10000; //!
                5'd27 : seg = 30'b00100_01010_00010_00100_00000_00100; //?
                5'd28 : seg = 30'b00000_00000_00000_00000_00000_00100; //.
                5'd29 : seg = 30'b00000_00000_01110_00000_00000_00000; //-
                5'd30 : seg = 30'b00100_01100_10100_00100_00100_00100; //1
                5'd31 : seg = 30'b01110_10001_00010_00100_01000_11111; //2

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

        
        //if(x >= 80  && x < 100) px_data_nxt = letter_data(10'd80 , 10'd80, x, y, 5'd12, 4'd3);

        //track squash turns
        if(mode == 2'b10) begin
            if(x >= 550  && x < 570 && y >= 50 && y < 70) px_data_nxt = letter_data(10'd550 , 10'd50, x, y, 5'd15, 4'd3);
            if(x >= 570  && x < 590 && y >= 50 && y < 70) begin
                if(!turn) begin
                    px_data_nxt = letter_data(10'd570 , 10'd50, x, y, 5'd30, 4'd3);
                end else begin
                    px_data_nxt = letter_data(10'd570 , 10'd50, x, y, 5'd31, 4'd3);
                end
            end                 
        end

        //show winners

        //first player
        if(p1_win || p2_win) begin
            if(x >= 120 && x < 160 && y >= 190 && y < 240) px_data_nxt = letter_data(10'd120, 10'd190, x, y, 5'd24, 4'd6);
            if(x >= 160 && x < 200 && y >= 190 && y < 240) px_data_nxt = letter_data(10'd160, 10'd190, x, y, 5'd14, 4'd6);
            if(x >= 200 && x < 240 && y >= 190 && y < 240) px_data_nxt = letter_data(10'd200, 10'd190, x, y, 5'd20, 4'd6);

            if(p1_win) begin
                if(x >= 114 && x < 154 && y >= 240 && y < 290) px_data_nxt = letter_data(10'd114, 10'd240, x, y, 5'd22, 4'd6);
                if(x >= 154 && x < 194 && y >= 240 && y < 290) px_data_nxt = letter_data(10'd154, 10'd240, x, y, 5'd8,  4'd6);
                if(x >= 194 && x < 234 && y >= 240 && y < 290) px_data_nxt = letter_data(10'd194, 10'd240, x, y, 5'd13, 4'd6);
                if(x >= 234 && x < 274 && y >= 240 && y < 290) px_data_nxt = letter_data(10'd234, 10'd240, x, y, 5'd26, 4'd6);
            end else begin
                if(x >=  92 && x < 132 && y >= 240 && y < 290) px_data_nxt = letter_data(10'd92 , 10'd240, x, y, 5'd11, 4'd6);
                if(x >= 132 && x < 172 && y >= 240 && y < 290) px_data_nxt = letter_data(10'd132, 10'd240, x, y, 5'd14, 4'd6);
                if(x >= 172 && x < 212 && y >= 240 && y < 290) px_data_nxt = letter_data(10'd172, 10'd240, x, y, 5'd18, 4'd6);
                if(x >= 212 && x < 252 && y >= 240 && y < 290) px_data_nxt = letter_data(10'd212, 10'd240, x, y, 5'd4,  4'd6);
                if(x >= 252 && x < 292 && y >= 240 && y < 290) px_data_nxt = letter_data(10'd252, 10'd240, x, y, 5'd26, 4'd6);
            end

            if(mode != 2'b11) begin
                if(x >= 410 && x < 450 && y >= 190 && y < 240) px_data_nxt = letter_data(10'd410, 10'd190, x, y, 5'd24, 4'd6);
                if(x >= 450 && x < 490 && y >= 190 && y < 240) px_data_nxt = letter_data(10'd450, 10'd190, x, y, 5'd14, 4'd6);
                if(x >= 490 && x < 530 && y >= 190 && y < 240) px_data_nxt = letter_data(10'd490, 10'd190, x, y, 5'd20, 4'd6);

                if(p2_win) begin
                    if(x >= 404 && x < 444 && y >= 240 && y < 290) px_data_nxt = letter_data(10'd404, 10'd240, x, y, 5'd22, 4'd6);
                    if(x >= 444 && x < 484 && y >= 240 && y < 290) px_data_nxt = letter_data(10'd444, 10'd240, x, y, 5'd8,  4'd6);
                    if(x >= 484 && x < 524 && y >= 240 && y < 290) px_data_nxt = letter_data(10'd484, 10'd240, x, y, 5'd13, 4'd6);
                    if(x >= 524 && x < 564 && y >= 240 && y < 290) px_data_nxt = letter_data(10'd524, 10'd240, x, y, 5'd26, 4'd6);
                end else begin
                    if(x >= 382 && x < 422 && y >= 240 && y < 290) px_data_nxt = letter_data(10'd382, 10'd240, x, y, 5'd11, 4'd6);
                    if(x >= 422 && x < 462 && y >= 240 && y < 290) px_data_nxt = letter_data(10'd422, 10'd240, x, y, 5'd14, 4'd6);
                    if(x >= 462 && x < 502 && y >= 240 && y < 290) px_data_nxt = letter_data(10'd462, 10'd240, x, y, 5'd18, 4'd6);
                    if(x >= 502 && x < 542 && y >= 240 && y < 290) px_data_nxt = letter_data(10'd502, 10'd240, x, y, 5'd4,  4'd6);
                    if(x >= 542 && x < 582 && y >= 240 && y < 290) px_data_nxt = letter_data(10'd542, 10'd240, x, y, 5'd26, 4'd6);
                end
            end
        end

        //instructions
        if(start_state) begin
            if(x >= 70  && x < 85  && y >= 380 && y < 400) px_data_nxt = letter_data(10'd70 , 10'd380, x, y, 5'd15, 4'd2);
            if(x >= 85  && x < 100 && y >= 380 && y < 400) px_data_nxt = letter_data(10'd85 , 10'd380, x, y, 5'd17, 4'd2);
            if(x >= 100 && x < 115 && y >= 380 && y < 400) px_data_nxt = letter_data(10'd100, 10'd380, x, y, 5'd4 , 4'd2);
            if(x >= 115 && x < 130 && y >= 380 && y < 400) px_data_nxt = letter_data(10'd115, 10'd380, x, y, 5'd18, 4'd2);
            if(x >= 130 && x < 145 && y >= 380 && y < 400) px_data_nxt = letter_data(10'd130, 10'd380, x, y, 5'd18, 4'd2);
            if(x >= 160 && x < 175 && y >= 380 && y < 400) px_data_nxt = letter_data(10'd160, 10'd380, x, y, 5'd18, 4'd2);
            if(x >= 175 && x < 190 && y >= 380 && y < 400) px_data_nxt = letter_data(10'd175, 10'd380, x, y, 5'd19, 4'd2);
            if(x >= 190 && x < 205 && y >= 380 && y < 400) px_data_nxt = letter_data(10'd190, 10'd380, x, y, 5'd0 , 4'd2);
            if(x >= 205 && x < 220 && y >= 380 && y < 400) px_data_nxt = letter_data(10'd205, 10'd380, x, y, 5'd17, 4'd2);
            if(x >= 220 && x < 235 && y >= 380 && y < 400) px_data_nxt = letter_data(10'd220, 10'd380, x, y, 5'd19, 4'd2);
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