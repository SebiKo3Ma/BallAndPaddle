module demo_players(input clk, rst, en, output [10:0] p1_y, p2_y);
    reg [17:0] counter_ff, counter_nxt;
    reg [10:0] p1_ff, p1_nxt, p2_ff, p2_nxt;
    reg heading_ff, heading_nxt;

    assign p1_y = p1_ff;
    assign p2_y = p2_ff;

    always @* begin
        counter_nxt = counter_ff + 1;
        heading_nxt = heading_ff;
        p1_nxt = p1_ff;
        p2_nxt = p2_ff;

        if(!counter_ff) begin
            if(p1_ff > 61  && p1_ff < 419) begin
                if(heading_ff) begin
                    p1_nxt = p1_ff + 1;
                    p2_nxt = p2_ff - 1;
                end else begin
                    p1_nxt = p1_ff - 1;
                    p2_nxt = p2_ff + 1;
                end
            end else if(p1_ff == 61) begin
                heading_nxt = ~heading_ff;
                p1_nxt = 11'd62;
            end else begin
                heading_nxt = ~heading_ff;
                p1_nxt = 11'd418;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            counter_ff <= 17'd0;
            p1_ff <= 11'd62;
            p2_ff <= 11'd418;
            heading_ff <= 1'b1;
        end else begin
            if(en) begin
                counter_ff <= counter_nxt;
            end
            p1_ff <= p1_nxt;
            p2_ff <= p2_nxt;
            heading_ff <= heading_nxt;
        end
    end
endmodule