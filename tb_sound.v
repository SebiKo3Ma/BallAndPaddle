module tb_sound;
    reg clk, rst;
    reg hit, wall, goal;
    wire sound;

    sound_output sound_output(clk, rst, hit, wall, goal, sound);

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1'b1;
        hit = 1'b0;
        wall = 1'b0;
        goal = 1'b0;
        #20 rst = 1'b0;
        #100 hit = 1'b1;
        #10 hit = 1'b0;
        #100 wall = 1'b1;
        #10 wall = 1'b0;
        #100 goal = 1'b1;
        #10 goal = 1'b0;
    end
endmodule