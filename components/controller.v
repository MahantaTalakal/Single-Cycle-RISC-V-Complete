// controller.v - controller for RISC-V CPU

module controller (
    input [6:0]  op,
    input [2:0]  funct3,
    input        funct7b5,
    input        Zero,
    input        Negative,    // NEW: for signed comparison
    input        Carry,       // NEW: for unsigned comparison  
    input        Overflow,    // NEW: for overflow detection
    output [1:0] ResultSrc,
    output       MemWrite,
    output       PCSrc, ALUSrc,
    output       RegWrite, Jump,
    output [2:0] ImmSrc,
    output [3:0] ALUControl,
    output       AUIPCsel
);

wire [1:0] ALUOp;
wire       Branch;
reg        BranchCondition;

main_decoder md (
    .op(op),
    .ResultSrc(ResultSrc),
    .MemWrite(MemWrite),
    .Branch(Branch),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite),
    .Jump(Jump),
    .ImmSrc(ImmSrc),
    .ALUOp(ALUOp),
    .AUIPCsel(AUIPCsel)
);

alu_decoder ad (
    .opb5(op[5]),
    .funct3(funct3),
    .funct7b5(funct7b5),
    .ALUOp(ALUOp),
    .ALUControl(ALUControl)
);

// Branch condition logic based on funct3
always @(*) begin
    case(funct3)
        3'b000: BranchCondition = Zero;                    // BEQ: branch if equal
        3'b001: BranchCondition = ~Zero;                   // BNE: branch if not equal
        3'b100: BranchCondition = Negative ^ Overflow;     // BLT: branch if less than (signed)
        3'b101: BranchCondition = ~(Negative ^ Overflow);  // BGE: branch if greater or equal (signed)
        3'b110: BranchCondition = ~Carry;                  // BLTU: branch if less than (unsigned)
        3'b111: BranchCondition = Carry;                   // BGEU: branch if greater or equal (unsigned)
        default: BranchCondition = 1'b0;
    endcase
end

assign PCSrc = (Branch & BranchCondition) | Jump;

endmodule