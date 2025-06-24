module adc_reader(input clk, rst, input[8:0] adc, output sel, output[9:0] p1_y, p2_y);
    reg[9:0] p1_ff, p1_nxt, p2_ff, p2_nxt;
    reg sel_ff, sel_nxt;
    reg[17:0] counter_ff, counter_nxt;

    assign p1_y = p1_ff;
    assign p2_y = p2_ff;
    assign sel = sel_ff;

    always @* begin
        sel_nxt = sel_ff ;
        p1_nxt <= p1_ff;
        p2_nxt <= p2_ff;
        counter_nxt <= counter_ff + 18'd1;

        if(!counter_ff) begin
            sel_nxt = sel_ff + 1'b1;
            if(sel_ff) begin
                p2_nxt[8:0] = adc;
                p2_nxt[9] = 1'b0;
            end else begin
                p1_nxt[8:0] = adc;
                p1_nxt[9] = 1'b0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            p1_ff <= 9'd240;
            p2_ff <= 9'd240;
            sel_ff <= 1'b0;
            counter_ff <= 18'd1;
        end else begin
            p1_ff <= p1_nxt;
            p2_ff <= p2_nxt;
            sel_ff <= sel_nxt;
            counter_ff <= counter_nxt;
        end
    end
endmodule