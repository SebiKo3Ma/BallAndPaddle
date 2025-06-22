module sound_output(input clk, rst, hit, wall, goal, output sound);
    reg hit_ff , wall_ff , goal_ff,
        hit_nxt, wall_nxt, goal_nxt,
        sound_ff, sound_nxt;

    reg [23:0] counter_ff, counter_nxt;
    reg [16:0] pulse_ff, pulse_nxt;

    assign sound = sound_ff;

    always @* begin
        counter_nxt = counter_ff + 25'd1;
        hit_nxt = hit_ff;
        wall_nxt = wall_ff;
        goal_nxt = goal_ff;
        sound_nxt = sound_ff;
        pulse_nxt = 17'd1;

        if(hit) hit_nxt = 1'b1;
        if(wall) wall_nxt = 1'b1;
        if(goal) goal_nxt = 1'b1;
        if(hit || wall || goal) counter_nxt <= 25'b1;

        if(!counter_ff) begin
            hit_nxt = 1'b0;
            wall_nxt = 1'b0;
            goal_nxt = 1'b0;
        end

        if(hit_ff || wall_ff || goal_ff) begin
            pulse_nxt = pulse_ff + 1;
            if(hit_ff) begin
                if(pulse_ff == 17'd51546)
                    pulse_nxt = 17'd0;
            end

            if(wall_ff) begin
                if(pulse_ff == 17'd102459)
                    pulse_nxt = 17'd0;
            end

            if(goal_ff) begin
                if(pulse_ff == 17'd25641)
                    pulse_nxt = 17'd0;
            end

            if(!pulse_ff) begin
                sound_nxt = ~sound_ff;
            end
        end else sound_nxt = 1'b0;
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            counter_ff <= 25'd0;
            hit_ff <= 1'b0;
            wall_ff <= 1'b0;
            goal_ff <= 1'b0;
            sound_ff <= 1'b0;
            pulse_ff <= 17'd1;
        end else begin
            counter_ff <= counter_nxt;
            hit_ff <= hit_nxt;
            wall_ff <= wall_nxt;
            goal_ff <= goal_nxt;
            sound_ff <= sound_nxt;
            pulse_ff <= pulse_nxt;
        end
    end
endmodule