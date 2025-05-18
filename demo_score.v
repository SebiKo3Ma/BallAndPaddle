module demo_score(input clk, rst, en, output [4:0] score1, score2);
    reg [4:0] score1_ff, score1_nxt, score2_ff, score2_nxt;
    assign score1 = score1_ff;
    assign score2 = score2_ff;

    reg[24:0] counter_ff, counter_nxt;

    always @* begin
        counter_nxt = counter_ff + 1;
        score1_nxt = score1_ff;
        score2_nxt = score2_ff;

        if(!counter_ff) begin
            score1_nxt = score1_ff + 1;
            if(score1_nxt >= 5'd31) begin
                score1_nxt = 5'd0;
            end
            score2_nxt = 5'd31 - score1_ff;
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            counter_ff <= 25'd1;
            score1_ff <= 5'd0;
            score2_ff <= 5'd0;
        end else begin
            if(en) begin
                counter_ff <= counter_nxt;
            end
            score1_ff <= score1_nxt;
            score2_ff <= score2_nxt;
        end
    end
    
    endmodule