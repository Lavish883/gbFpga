`ifndef GB_REGISTERS_V
`define GB_REGISTERS_V

localparam REG_B = 4'd0;
localparam REG_C = 4'd1;
localparam REG_D = 4'd2;
localparam REG_E = 4'd3;
localparam REG_H = 4'd4;
localparam REG_L = 4'd5;
localparam REG_F = 4'd6;
localparam REG_A = 4'd7;
localparam REG_IR = 4'd8;

module registers(
    input clk,
    input reset,
    
    // 8 bit registers, allows 2 of them to read/write at the same time to allow the 16 bit registers that are combination of them such BC, DE..
    input wire reg8_write_enable_1,
    input wire reg8_write_enable_2,
    input wire [3:0] reg8_select_1, 
    input wire [3:0] reg8_select_2, 
    input wire [7:0] reg8_write_data_1, 
    input wire [7:0] reg8_write_data_2,
    output wire [7:0] reg8_out_1,
    output wire [7:0] reg8_out_2,
    output wire [7:0] reg_IR_out, // Done so it can be used without select when decoding
    
    // Pure 16 bit registers, PC and SP
    input wire reg_PC_write_enable,
    input wire reg_SP_write_enable,
    output wire [15:0] reg_PC_out,
    output wire [15:0] reg_SP_out,
    input wire [15:0] reg_PC_write_data,
    input wire [15:0] reg_SP_write_data    
);
    // https://gbdev.io/pandocs/CPU_Instruction_Set.html (6 - [HL] but not real so F)
    // 0 - B , 1 - C, 2 - D, 3 - E, 4 - H, 5 - L, 6 - F, 7 - A, 8 - IR
    reg [7:0] regs [0:8];
    reg [15:0] reg_PC;
    reg [15:0] reg_SP;

    always @(posedge clk) begin
      if (reset) begin
        regs[REG_B] <= 8'h0;
        regs[REG_C] <= 8'h0;
        regs[REG_D] <= 8'h0;
        regs[REG_E] <= 8'h0;
        regs[REG_H] <= 8'h0;
        regs[REG_L] <= 8'h0;
        regs[REG_F] <= 8'h0;
        regs[REG_A] <= 8'h0;
        regs[REG_IR] <= 8'h0;
        reg_PC <= 16'h0;
        reg_SP <= 16'h0;
      end else begin
        if (reg_PC_write_enable) begin
          reg_PC <= reg_PC_write_data;
        end
        if (reg_SP_write_enable) begin
          reg_SP <= reg_SP_write_data;
        end
        if (reg8_write_enable_1) begin
          regs[reg8_select_1] <= reg8_write_data_1;
        end
        if (reg8_write_enable_2) begin
          regs[reg8_select_2] <= reg8_write_data_2;
        end
      end
    end

    assign reg8_out_1 = regs[reg8_select_1];
    assign reg8_out_2 = regs[reg8_select_2];
    assign reg_IR_out = regs[REG_IR];
    assign reg_PC_out = reg_PC;
    assign reg_SP_out = reg_SP;

endmodule
`endif
