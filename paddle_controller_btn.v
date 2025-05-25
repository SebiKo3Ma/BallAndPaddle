module paddle_controller_btn(input clk, rst, p1p, p1m, p2p, p2m, bat_size, output[10:0] p1_y, p2_y);
    reg [16:0] counter_ff, counter_nxt;
    reg [10:0] p1_ff, p1_nxt, p2_ff, p2_nxt;

    assign p1_y = p1_ff;
    assign p2_y = p2_ff;

    always @* begin
        p1_nxt = p1_ff;
        p2_nxt = p2_ff;
        counter_nxt = counter_ff + 17'd1;

        if(!counter_ff) begin
            if(!p1p) begin
                p1_nxt = p1_ff + 11'd1;
            end

            if(!p1m) begin
                p1_nxt = p1_ff - 11'd1;
            end

            if(!p2p) begin
                p2_nxt = p2_ff + 11'd1;
            end

            if(!p2m) begin
                p2_nxt = p2_ff - 11'd1;
            end
        end

        if(bat_size) begin
            if(p1_ff < 11'd40)  p1_nxt = 11'd40;
            if(p1_ff > 11'd440) p1_nxt = 11'd440;
            if(p2_ff < 11'd40)  p2_nxt = 11'd40;
            if(p2_ff > 11'd440) p2_nxt = 11'd440;
        end else begin
            if(p1_ff < 11'd50)  p1_nxt = 11'd50;
            if(p1_ff > 11'd430) p1_nxt = 11'd430;
            if(p2_ff < 11'd50)  p2_nxt = 11'd50;
            if(p2_ff > 11'd430) p2_nxt = 11'd430;
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            p1_ff <= 11'd240;
            p2_ff <= 11'd240;
            counter_ff <= 17'd1;
        end else begin
            p1_ff <= p1_nxt;
            p2_ff <= p2_nxt;
            counter_ff <= counter_nxt;
        end
    end
endmodule