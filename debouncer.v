`timescale 1ns/1ns
module debouncer(input clk, rst, d, output q); 
  reg val_d1, val_d2, val_d3, val_d4, val_d5, val_save;
  
  assign q = val_save;
  
  always @(posedge clk or posedge rst) begin
    if(rst) begin
      val_d1   <= 1'b0;
      val_d2   <= 1'b0;
      val_d3   <= 1'b0;
      val_d4   <= 1'b0;
      val_d5   <= 1'b0;
      val_save <= 1'b0;
    end else begin
      val_d1 <= d;
      val_d2 <= val_d1;
      val_d3 <= val_d2;
      val_d4 <= val_d3;
      val_d5 <= val_d4;
      if(val_d2 == val_d1 == val_d3 == val_d4 == val_d5) begin
        val_save <= val_d1;
      end
    end
  end
endmodule