module top(input clk, rst, bat_size, en, input[1:0] mode, output [9:0] RED, GRN, BLU, output HSYNC, VSYNC, px_clk, blank);
    wire [10:0] x, y, p1_y, p2_y, bx, by;
    wire px_data_out;
    wire [29:0] px_data_in;

    assign px_data_in = {30{px_data_out}};
    assign blank = 1'b1;

    demo_players demo_players(clk, rst, en, p1_y, p2_y);
    demo_ball demo_ball(clk, rst, en, bx, by);
    clk_divider clk_divider(clk, rst, px_clk);
    video_encoder video_encoder(clk, rst, bat_size, mode, 6'd0, 6'd0, p1_y, p2_y, bx, by, x, y, px_data_out);
    vga_controller vga_controller(px_clk, rst, px_data_in, x, y, RED, GRN, BLU, HSYNC, VSYNC);
endmodule