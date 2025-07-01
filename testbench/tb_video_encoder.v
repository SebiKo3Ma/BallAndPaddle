module tb_video_encoder();
    reg clk, rst, bat_size;
    reg [1:0]  mode;
    reg [5:0]  p1_score, p2_score;
    reg [10:0] p1_y, p2_y, ball_x, ball_y, x, y, i, j;
    wire px_data;

    video_encoder vd_en(clk, rst, bat_size, mode, p1_score, p2_score, p1_y, p2_y, ball_x, ball_y, x, y, px_data);

    task print_screen();
        for(i = 0 ; i < 640 ; i = i + 1) begin
            for(j = 0 ; j < 480 ; j = j + 1) begin
                x = i;
                y = j;
                #40;
            end
        end
    endtask

    initial begin
        clk = 0;
        forever #5 clk = !clk;
    end

    initial begin
        rst = 1'b1;
        bat_size = 1'b0;
        mode = 2'b00;
        p1_score = 6'd0;
        p2_score = 6'd0;
        p1_y = 11'd200;
        p2_y = 11'd200;
        ball_x = 11'd300;
        ball_y = 11'd250;
        x = 11'd0;
        y = 11'd0;

        #20 rst = 1'b0;

        print_screen();

        #40 mode = 2'b01;

        print_screen();

        #40 mode = 2'b10;

        print_screen();

        #40 mode = 2'b11;

        print_screen();        
    end
endmodule