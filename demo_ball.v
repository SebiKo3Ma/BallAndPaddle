module demo_ball(input clk, rst, en, output [10:0] x, y);
    reg [10:0] x_ff, x_nxt, y_ff, y_nxt;
    reg xh_ff, xh_nxt, yh_ff, yh_nxt;
    reg [17:0] counter_ff, counter_nxt;

    assign x = x_ff;
    assign y = y_ff;

    always @* begin
        counter_nxt = counter_ff + 1;
        x_nxt = x_ff;
        y_nxt = y_ff;
        xh_nxt = xh_ff;
        yh_nxt = yh_nxt;

        if(!counter_ff) begin
            if(xh_ff) begin
                x_nxt = x_ff + 1;
            end else begin
                x_nxt = x_ff - 1;
            end

            if(yh_ff) begin
                y_nxt = y_ff + 1;
            end else begin
                y_nxt = y_ff - 1;
            end

            if(x_ff <= 11'd30) begin
                xh_nxt = 1'b1;
                x_nxt = 11'd31;
            end

            if(x_ff >= 11'd610) begin
                xh_nxt = 1'b0;
                x_nxt = 11'd609;
            end

            if(y_ff <= 11'd30) begin
                yh_nxt = 1'b1;
                y_nxt = 11'd31;
            end

            if(y_ff >= 11'd450) begin
                yh_nxt = 1'b0;
                y_nxt = 11'd445;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            counter_ff <= 18'd1;
            x_ff <= 11'd60;
            y_ff <= 11'd60;
            xh_ff <= 1'b1;
            yh_ff <= 1'b1;
        end else begin
            if(en) begin
                counter_ff <= counter_nxt;
            end
            x_ff <= x_nxt;
            y_ff <= y_nxt;
            xh_ff <= xh_nxt;
            yh_ff <= yh_nxt;
        end
    end

endmodule