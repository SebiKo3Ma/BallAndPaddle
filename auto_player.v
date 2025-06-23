module auto_player(
    input clk, rst, en,
          turn,
          xh, yh,
    input [1:0] mode,
    input [10:0] bx, by, py,
    output p, m
);

reg p_ff, p_nxt, //plus signal for paddle movement module
    m_ff, m_nxt; //minus signal for paddle movement module

assign p = p_ff;
assign m = m_ff;

always @* begin
    p_nxt = p_ff;
    m_nxt = m_ff;

    if((mode == 2'b00 && xh) || mode == 2'b01 || (mode == 2'b10 && turn)) begin //if ball headed towards AI paddle
            if(py < by) begin
                p_nxt = 1'b0;
                m_nxt = 1'b1;
            end else if(py > by) begin
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
    end else if(en) begin
        p_ff <= p_nxt;
        m_ff <= m_nxt;
    end else begin
        p_ff <= 1'b1;
        m_ff <= 1'b1;
    end
end

endmodule