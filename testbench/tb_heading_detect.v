module tb_heading_detect();
    reg clk, rst;
    reg [10:0] bx, by;
    wire xh, yh;

    heading_detect heading_detect(clk, rst, bx, by, xh, yh);

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1'b1;
        bx = 'd60;
        by = 'd60;
        #20 rst = 1'b0;
        #10 bx = 'd61;
            by = 'd61;
        #10 bx = 'd62;
            by = 'd62;
        #20 bx = 'd61;
            by = 'd62;
        #15 bx = 'd62;
            by = 'd61;
        #100bx = 'd61;
            by = 'd60;
        #10 bx = 'd60;
            by = 'd59;
        #50 $finish;        
    end
endmodule