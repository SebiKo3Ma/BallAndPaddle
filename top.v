module top(input clk, rst, output [7:0] RED, GRN, BLU, output HSYNC, VSYNC);
    wire [10:0] x, y;
    wire px_data_out;
    wire [23:0] px_data_in;
    wire px_clk;

    assign px_data_in = {24{px_data_out}};

    clk_divider clk_divider(clk, rst, px_clk);
    video_encoder video_encoder(clk, rst, 1'b0, 2'b00, 6'd0, 6'd0, 11'd200, 11'd200, 11'd300, 11'd250, x, y, px_data_out);
    vga_controller vga_controller(px_clk, rst, px_data_in, x, y, RED, GRN, BLU, HSYNC, VSYNC);
endmodule