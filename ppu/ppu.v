`include "ppu/ly_driver.v"

`ifndef PPU_V
`define PPU_V

module ppu(
  input clk,
  input reset,
  output reg [7:0] LY
);
  // Drives the LY register
  ly_driver ly_driver_inst(
    .clk(clk),
    .reset(reset),
    .LY(LY)
  );
  
endmodule

`endif
