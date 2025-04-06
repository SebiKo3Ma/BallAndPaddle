module game_controller( input clk, rst,     
                        input  [10:0] p1_in,      // y input for player 1
                                      p2_in,      // y input for player 2
                        input  [1:0]  mode,       // game mode: 00-tennis, 01-soccer, 10-squash, 11-practice
                        input         ball_speed, // slow / fast
                                      serve_type, // auto / manual
                                      angle,      // narrow / wide
                                      bat_size,   // small / large
                                      serve,      // serve trigger
                        output [5:0]  p1_score,   // score for player 1
                                      p2_score,   // score for player 2
                        output [10:0] p1_y,       // vertical position of player 1
                                      p2_y,       // vertical position of player 2
                                      ball_x,     // horizontal position of ball
                                      ball_y);    // vertical position of ball

endmodule