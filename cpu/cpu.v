`ifndef CPU_V
`define CPU_V
`include "cpu/registers.v"
`include "cpu/alu.v"
`include "cpu/idu.v"
`include "cpu/opcode_decoder.v"


localparam DISABLED = 0;

module cpu(
  input clk,
  input reset,
  output wire [7:0] reg8_out_1
);
    // CPU state
    reg [1:0] t_count;
    wire m_cycle_high = (t_count == 2'd3);
    reg [2:0] m_cycle_count;
    wire [2:0] m_cycle_required_by_instruction;
    reg default_placeholder_cost;

    // Wires for Registers (input)
    reg reg8_write_enable_1 = 1'b1;
    wire reg8_write_enable_2 = 1'b0;
    reg [3:0] reg8_select_1 = REG_B;
    wire [3:0] reg8_select_2 = REG_C;
    reg [7:0] reg8_write_data_1;
    wire [7:0] reg8_write_data_2;
    wire reg_PC_write_enable;
    wire reg_SP_write_enable;
    wire [15:0] reg_PC_write_data;
    wire [15:0] reg_SP_write_data;
    
    // Wires for Registers (output)
    // wire [7:0] reg8_out_1;
    wire [7:0] reg8_out_2;
    wire [7:0] reg_IR_out;
    wire [15:0] reg_PC_out;
    wire [15:0] reg_SP_out;

    registers reg_inst (
        .clk(clk),
        .reset(reset),
        .reg8_write_enable_1(reg8_write_enable_1),
        .reg8_write_enable_2(reg8_write_enable_2),
        .reg8_select_1(reg8_select_1),
        .reg8_select_2(reg8_select_2),
        .reg8_write_data_1(reg8_write_data_1),
        .reg8_write_data_2(reg8_write_data_2),
        .reg8_out_1(reg8_out_1),
        .reg8_out_2(reg8_out_2),
        .reg_PC_write_enable(reg_PC_write_enable),
        .reg_SP_write_enable(reg_SP_write_enable),
        .reg_PC_out(reg_PC_out),
        .reg_SP_out(reg_SP_out),
        .reg_PC_write_data(reg_PC_write_data),
        .reg_SP_write_data(reg_SP_write_data),
        .reg_IR_out(reg_IR_out)
    );

    wire [3:0] alu_op;
    alu alu_inst (
        .a(reg8_out_1),
        .b(reg8_out_2),
        .op(alu_op),
        .result(reg8_write_data_1)
    );

    // IDU
    wire idu_target_select;
    wire [15:0] idu_in = (idu_target_select == 1'b0) ? reg_PC_out : reg_SP_out;
    wire [15:0] idu_result;
    wire [1:0] idu_op;

    assign reg_PC_write_data = idu_result;
    assign reg_SP_write_data = idu_result;

    idu idu_inst (
        .a(idu_in),
        .result(idu_result),
        .op(idu_op)
    );        

    // Drive the M-cycle counter
    always @(posedge clk) begin
        t_count <= reset ? 0 : t_count + 1;
        m_cycle_count <= reset ? 1 : m_cycle_count;

        if (m_cycle_high) begin
            if (m_cycle_count == m_cycle_required_by_instruction) begin
                m_cycle_count <= 1;
                // Now we would fetch the next instruction here done in opcode_decoder, Chapter 6 (fetch/execute overlap) https://gekkio.fi/files/gb-docs/gbctr.pdf      
            end else begin
                m_cycle_count <= m_cycle_count + 1;
            end
        end
    end

    opcode_decoder opcode_decoder_inst (
        .opcode(reg_IR_out),
        .on_m_cycle(m_cycle_count),
        .alu_op(alu_op),
        .idu_op(idu_op),
        .idu_target_select(idu_target_select),
        .reg_PC_write_enable(reg_PC_write_enable),
        .m_cycle_required_by_instruction(m_cycle_required_by_instruction)
    );

endmodule
`endif
