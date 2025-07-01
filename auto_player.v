module auto_player(
    input clk, rst, en,
          turn,
          hit,
          wall,
          start_state,
          hard_mode,
          xh, yh,
    input [1:0] mode,
    input [9:0] bx, by, py,
    output p, m
);

reg p_ff, p_nxt, //plus signal for paddle movement module
    m_ff, m_nxt; //minus signal for paddle movement module

reg [4:0] err_count_ff, err_count_nxt;
reg [5:0] error_ff, error_nxt;

reg wall_ff, wall_nxt;
assign p = p_ff;
assign m = m_ff;

always @* begin
    p_nxt = p_ff;
    m_nxt = m_ff;
    err_count_nxt = err_count_ff;
    error_nxt = error_ff;
    wall_nxt = wall_ff;

    if(!hard_mode) begin
        if(hit || (mode == 2'b10 && wall)) err_count_nxt = err_count_ff + 5'd1;
    end else err_count_nxt = 1'b0;

    if(start_state) begin
        wall_nxt = 1'b0;
    end

    if(wall) begin
        wall_nxt = 1'b1;
    end

    case(err_count_ff)
        5'd0  : error_nxt = 6'd0;
        5'd1  : error_nxt = 6'd5;
        5'd2  : error_nxt = 6'd26;
        5'd3  : error_nxt = 6'd29;
        5'd4  : error_nxt = 6'd0;
        5'd5  : error_nxt = 6'd30;
        5'd6  : error_nxt = 6'd26;
        5'd7  : error_nxt = 6'd28;
        5'd8  : error_nxt = 6'd5;
        5'd9  : error_nxt = 6'd7;
        5'd10 : error_nxt = 6'd40;
        5'd11 : error_nxt = 6'd26;
        5'd12 : error_nxt = 6'd24;
        5'd13 : error_nxt = 6'd19;
        5'd14 : error_nxt = 6'd29;
        5'd15 : error_nxt = 6'd26;
        5'd16 : error_nxt = 6'd31;
        5'd17 : error_nxt = 6'd5;
        5'd18 : error_nxt = 6'd28;
        5'd19 : error_nxt = 6'd31;
        5'd20 : error_nxt = 6'd27;
        5'd21 : error_nxt = 6'd0;
        5'd22 : error_nxt = 6'd17;
        5'd23 : error_nxt = 6'd31;
        5'd24 : error_nxt = 6'd26;
        5'd25 : error_nxt = 6'd27;
        5'd26 : error_nxt = 6'd26;
        5'd27 : error_nxt = 6'd28;
        5'd28 : error_nxt = 6'd31;
        5'd29 : error_nxt = 6'd34;
        5'd30 : error_nxt = 6'd8;
        5'd31 : error_nxt = 6'd26;

        default: error_nxt = 6'd0;
    endcase

    if((mode == 2'b00 && xh) || (mode == 2'b01 && wall_ff) || (mode == 2'b10 && turn)) begin //if ball headed towards auto paddle
            if(py < by - error_ff) begin
                p_nxt = 1'b0;
                m_nxt = 1'b1;
            end else if(py > by + error_ff) begin
                p_nxt = 1'b1;
                m_nxt = 1'b0;
            end else begin
                p_nxt = 1'b1;
                m_nxt = 1'b1;
            end
    end else begin //if ball going the other way
        p_nxt = 1'b1;
        m_nxt = 1'b1; 
        //makes sure the paddle is not moving
    end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        p_ff <= 1'b0;
        m_ff <= 1'b0;
        err_count_ff <= 5'd0;
        error_ff <= 6'd0;
        wall_ff <= 1'b0;
    end else if(en) begin
        p_ff <= p_nxt;
        m_ff <= m_nxt;
        err_count_ff <= err_count_nxt;
        error_ff <= error_nxt;
        wall_ff <= wall_nxt;
    end else begin
        p_ff <= 1'b1;
        m_ff <= 1'b1;
    end
end

endmodule