`ifndef IDU_V
`define IDU_V

module idu(
    input wire [15:0] a,
    output reg [15:0] result,
    input wire [1:0] op
);
    always @(*) begin
        case (op)
            2'b00: result = a + 1; // Increment
            2'b01: result = a - 1; // Decrement
            default: result = a;
        endcase
    end
endmodule
`endif
