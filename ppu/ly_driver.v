`ifndef LY_DRIVER_PPU_V
`define LY_DRIVER_PPU_V

module ly_driver(
  input clk,
  input reset,
  output reg [7:0] LY
);
  reg [9:0] ClockCounterForLY;

  always @(posedge clk) begin
    if (reset) begin
      LY <= 8'b0;
      ClockCounterForLY <= 0;
    end else begin
      if (ClockCounterForLY == 455) begin
        ClockCounterForLY <= 0;
        LY <= LY == 153 ? 0 : LY + 1;
      end else begin
        ClockCounterForLY <= ClockCounterForLY + 1;
      end
    end
  end
endmodule
`endif
