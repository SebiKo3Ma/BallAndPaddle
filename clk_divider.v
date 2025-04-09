module clk_divider(input clk, rst, output px_clk);
    reg px_clk_ff, px_clk_nxt;

    assign px_clk = px_clk_ff;
    
    always @* begin
        px_clk_nxt = ~px_clk_ff;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            px_clk_ff <= 1'b0;
        end else begin
            px_clk_ff <= px_clk_nxt;
        end
    end
endmodule