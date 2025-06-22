module color_module(
    input         clk, rst,
                  px_data,
                  enable,
    input   [1:0] mode,
    input  [10:0] x, y,
    output [29:0] color_data);

    assign color_data = color_data_ff;

    reg [29:0] color_data_ff, color_data_nxt;

    always @* begin
        color_data_nxt = color_data_ff;

        if(mode == 1'b00) begin
            if(!px_data) begin
                color_data_nxt = 30'b1101000000_0101000000_0011000000;
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