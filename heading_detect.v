module heading_detect(input clk, rst, input [10:0] x, y, output xh, yh);
    reg xh_ff, xh_nxt, yh_ff, yh_nxt;
    reg [10:0] x_ff, x_nxt, y_ff, y_nxt;

    assign xh = xh_ff;
    assign yh = yh_ff;

    always @* begin
        x_nxt = x;
        y_nxt = y;

        if(x < x_ff)
            xh_nxt = 1'b0;
        else if(x > x_ff)
            xh_nxt = 1'b1;
        else  xh_nxt = xh_ff;
        
        if(y < y_ff)
            yh_nxt = 1'b0;
        else if(y > y_ff)
            yh_nxt = 1'b1;
        else  yh_nxt = yh_ff;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            xh_ff <= 1'b1;
            yh_ff <= 1'b1;
            x_ff <= 11'd60;
            y_ff <= 11'd60;
        end else begin
            xh_ff <= xh_nxt;
            yh_ff <= yh_nxt;
            x_ff <= x_nxt;
            y_ff <= y_nxt;
        end
    end
endmodule