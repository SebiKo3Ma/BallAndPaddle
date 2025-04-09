module top(input clk, rst, bat_size, input[1:0] mode, output [9:0] RED, GRN, BLU, output HSYNC, VSYNC, px_clk, blank);
    wire [10:0] x, y;
    wire px_data_out;
    wire [29:0] px_data_in;

    assign px_data_in = {30{px_data_out}};
    assign blank = 1'b1;

    clk_divider clk_divider(clk, rst, px_clk);
    video_encoder video_encoder(clk, rst, bat_size, mode, 6'd0, 6'd0, 11'd200, 11'd300, 11'd300, 11'd250, x, y, px_data_out);
    vga_controller vga_controller(px_clk, rst, px_data_in, x, y, RED, GRN, BLU, HSYNC, VSYNC);
endmodule