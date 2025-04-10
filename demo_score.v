module demo_score(input clk, rst, en, output [5:0] score1, score2);
    reg [5:0] score_ff, score_nxt;
    assign score1 = score_ff;
    assign score2 = score_ff;

    reg[24:0] counter_ff, counter_nxt;

    always @* begin
        counter_nxt = counter_ff + 1;
        score_nxt = score_ff;

        if(!counter_ff) begin
            score_nxt = score_ff + 1;
            if(score_nxt >= 6'd10) begin
                score_nxt = 6'd0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            counter_ff <= 25'd1;
            score_ff <= 6'd0;
        end else begin
            if(en) begin
                counter_ff <= counter_nxt;
            end
            score_ff <= score_nxt;
        end
    end
    
    endmodule