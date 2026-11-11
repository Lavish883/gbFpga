`ifndef OPCODE_V
`define OPCODE_V


module opcode_decoder(
    input wire [7:0] opcode,
    input wire [2:0] on_m_cycle,
    output reg [3:0] alu_op,
    output reg [1:0] idu_op,
    output reg idu_target_select,
    output reg reg_PC_write_enable,
    output reg [2:0] m_cycle_required_by_instruction
);

always @(*) begin
    case (opcode)
        8'h00: begin // NOP
            m_cycle_required_by_instruction = 3'b001;
            idu_op = 2'b00; // Increment PC, for fetch
            idu_target_select = 1'b0;
            reg_PC_write_enable = 1'b1;
        end
        default: begin
            idu_target_select = 1'b0; // Default to PC
        end
    endcase
end



endmodule
`endif
