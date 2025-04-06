module video_encoder(input        clk, rst,
                                  vsync,
                                  hsync,
                     input [1:0]  mode,
                     input [5:0]  p1_score,
                                  p2_score,
                     input [10:0] p1_y,
                                  p2_y,
                                  ball_x,
                                  ball_y,
                     output [23:0] px_data);

endmodule