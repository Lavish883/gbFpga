`include "ppu/ppu.v"
`include "cpu/cpu.v"

module gb_fpga_top(
  input clk, 
  output [31:0] rgba,
  output [7:0] LY
);
  // combine signals for RGB output
  wire [7:0] r = {8{1'b1}};
  wire [7:0] g = {8{1'b0}};
  wire [7:0] b = {8{1'b0}};
  wire [7:0] a = {8{1'b1}};
  wire [7:0] reg8_out_1;

  ppu ppu_inst(
    .clk(clk),
    .reset(1'b0),
    .LY(LY)
  );

  cpu cpu_inst(
    .clk(clk),
    .reset(1'b0),
    .reg8_out_1(reg8_out_1)
  );
  
  assign rgba = { a, LY ^ 8'hF0, LY & 8'hF0, LY | 8'hF0};

endmodule
