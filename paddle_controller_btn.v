module paddle_controller(input clk, rst, p, m, bat_size, output[9:0] p2_y);
    reg [16:0] counter_ff, counter_nxt;
    reg [9:0] p2_ff, p2_nxt;

    assign p2_y = p2_ff;

    always @* begin
        p2_nxt = p2_ff;
        counter_nxt = counter_ff + 17'd1;

        if(!counter_ff) begin

            if(!p) begin
                p2_nxt = p2_ff + 10'd1;
            end

            if(!m) begin
                p2_nxt = p2_ff - 10'd1;
            end
        end

        if(bat_size) begin
            if(p2_ff < 10'd40)  p2_nxt = 10'd40;
            if(p2_ff > 10'd440) p2_nxt = 10'd440;
        end else begin
            if(p2_ff < 10'd50)  p2_nxt = 10'd50;
            if(p2_ff > 10'd430) p2_nxt = 10'd430;
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            p2_ff <= 10'd240;
            counter_ff <= 17'd1;
        end else begin
            p2_ff <= p2_nxt;
            counter_ff <= counter_nxt;
        end
    end
endmodule