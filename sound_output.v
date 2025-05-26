module sound_output(input clk, rst, hit, wall, goal, output hit_out, wall_out, goal_out);
    reg hit_ff , wall_ff , goal_ff,
        hit_nxt, wall_nxt, goal_nxt;

    reg [24:0] counter_ff, counter_nxt;

    assign hit_out = hit_ff;
    assign wall_out = wall_ff;
    assign goal_out = goal_ff;

    always @* begin
        counter_nxt = counter_ff + 25'd1;
        hit_nxt = hit_ff;
        wall_nxt = wall_ff;
        goal_nxt = goal_ff;

        if(hit) hit_nxt = 1'b1;
        if(wall) wall_nxt = 1'b1;
        if(goal) goal_nxt = 1'b1;
        if(hit || wall || goal) counter_nxt <= 25'b1;

        if(!counter_ff) begin
            hit_nxt = 1'b0;
            wall_nxt = 1'b0;
            goal_nxt = 1'b0;
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            counter_ff <= 25'd0;
            hit_ff <= 1'b0;
            wall_ff <= 1'b0;
            goal_ff <= 1'b0;
        end else begin
            counter_ff <= counter_nxt;
            hit_ff <= hit_nxt;
            wall_ff <= wall_nxt;
            goal_ff <= goal_nxt;
        end
    end
endmodule