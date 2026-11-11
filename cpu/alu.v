`ifndef ALU_V
`define ALU_V

module alu(
    input wire [7:0] a,
    input wire [7:0] b,
    input wire [3:0] op,
    output reg [7:0] result
);
    always @(*) begin
        case (op)
            4'b0000: result = a + b; // ADD
            4'b0001: result = a - b; // SUB
            4'b0010: result = a & b; // AND
            4'b0011: result = a | b; // OR
            4'b0100: result = a ^ b; // XOR
            4'b0101: result = ~a;    // NOT
            4'b0110: result = a << 1; // SHL
            4'b0111: result = a >> 1; // SHR
            4'b1000: result = a + 1; // INC
            4'b1001: result = a - 1; // DEC
            default: result = a; // No operation, just move a to result
        endcase
    end
endmodule
`endif
