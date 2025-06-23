module color_module(
    input         clk, rst,
                  px_data,
                  enable,
    input   [1:0] mode,
    input  [9:0] x, y,
    output [29:0] color_data);

    assign color_data = color_data_ff;

    reg [29:0] color_data_ff, color_data_nxt;

    always @* begin
        color_data_nxt = color_data_ff;

        if(mode == 1'b00) begin //tennis court
            if(!px_data) begin
                color_data_nxt = 30'b1101000000_0101000000_0011000000;
            end else color_data_nxt = 30'b1111111111_1111111111_1111111111;
        end else if(mode == 1'b01) begin //football field
            if(!px_data) begin
                if(x > 0   && x <  80 ||
                   x > 160 && x < 240 ||
                   x > 320 && x < 400 ||
                   x > 480 && x < 560) begin
                    color_data_nxt = 30'b0010000000_1000000000_0010000000;
                   end else color_data_nxt = 30'b0000000000_0110000000_0000000000;
            end else color_data_nxt = 30'b1111111111_1111111111_1111111111;

        end else begin //squash and practice hall
            if(!px_data) begin
                if(x % 10 == 0) begin //vertical lines
                    color_data_nxt = 30'b1010000000_0110000000_0010000000;
                end else color_data_nxt = 30'b1100000000_1000000000_0100000000; //background

                if((x/10)%2) begin //horizontal line on even column
                    if(y == 120 || y == 240 || y == 360) begin
                        color_data_nxt = 30'b1010000000_0110000000_0010000000;
                    end
                end else begin
                    if(y == 60 || y == 180 || y == 300 || y == 420) begin
                        color_data_nxt = 30'b1010000000_0110000000_0010000000;
                    end
                end
            end else color_data_nxt = 30'b1111111111_1111111111_1111111111;
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            color_data_ff <= 30'b0000000000_0000000000_0000000000;
        end else if(enable) begin
            color_data_ff <= color_data_nxt;
        end else if(px_data) begin
            color_data_ff <= 30'b1111111111_1111111111_1111111111;
        end else begin
            color_data_ff <= 1'b0000000000_0000000000_0000000000;
        end
    end

endmodule