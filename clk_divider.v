module clk_divider(input clk, rst, output px_clk);
    reg px_clk_ff, px_clk_nxt;
    reg counter_ff, counter_nxt;

    assign px_clk = px_clk_ff;
    
    always @* begin
        px_clk_nxt = px_clk_ff;
        counter_nxt = counter_ff + 1;

        if(counter_ff) begin
            px_clk_nxt = ~px_clk_ff;
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            px_clk_ff <= 1'b0;
            counter_ff <= 1'b0;
        end else begin
            px_clk_ff <= px_clk_nxt;
            counter_ff <= counter_nxt;
        end
    end
endmodule