// alu.v - ALU module

module alu #(parameter WIDTH = 32) (
    input         [WIDTH-1:0] a, b,       // operands (signed for arithmetic shifts)
    input         [3:0]       alu_ctrl,   // ALU control (4-bit for all operations)
    output reg    [WIDTH-1:0] alu_out,    // ALU output
    output                    zero,       // zero flag
    output                    negative,   // negative flag (for signed comparison)
    output                    carry,      // carry flag (for unsigned comparison)
    output                    overflow    // overflow flag
);

    wire [WIDTH-1:0] sum;
    wire             slt, sltu;
    wire [WIDTH:0]   sum_unsigned;  // 33-bit for carry detection
    
    // Addition/Subtraction logic
    assign sum = a + (alu_ctrl[0] ? ~b : b) + alu_ctrl[0];
    assign sum_unsigned = {1'b0, a} + {1'b0, (alu_ctrl[0] ? ~b : b)} + alu_ctrl[0];
    
    // Set less than (signed comparison)
    assign slt = (a[31] == b[31]) ? (a < b) : a[31];
    
    // Set less than unsigned
    assign sltu = a < b;

    always @(*) begin
        case(alu_ctrl)
            4'b0000: alu_out = sum;              // ADD (add, addi)
            4'b0001: alu_out = sum;              // SUB (sub)
            4'b0010: alu_out = a & b;            // AND (and, andi)
            4'b0011: alu_out = a | b;            // OR (or, ori)
            4'b0100: alu_out = a ^ b;            // XOR (xor, xori)
            4'b0101: alu_out = {31'b0, slt};     // SLT (slt, slti) - set less than
            4'b0110: alu_out = {31'b0, sltu};    // SLTU (sltu, sltiu) - set less than unsigned
            4'b0111: alu_out = {a[31:12], 12'b0}; // LUI (load upper immediate)
            4'b1000: alu_out = a + {b[31:12], 12'b0}; // AUIPC (add upper immediate to PC)
            4'b1001: alu_out = {b[31:12], 12'b0};     // LUI alternative encoding
            4'b1010: alu_out = a << b[4:0];      // SLL (sll, slli) - shift left logical
            4'b1011: alu_out = $signed(a) >>> b[4:0];     // SRA (sra, srai) - shift right arithmetic
            4'b1100: alu_out = a >> b[4:0];      // SRL (srl, srli) - shift right logical
            default: alu_out = {WIDTH{1'bx}};    // Unknown operation
        endcase
    end

    assign zero = (alu_out == 32'b0);
    assign negative = sum[31];              // Sign bit of subtraction result
    assign carry = sum_unsigned[32];        // Carry out for unsigned comparison
    assign overflow = (a[31] == (~b[31] & alu_ctrl[0])) & (a[31] != sum[31]); // Overflow detection

endmodule