// datapath.v
module datapath (
    input         clk, reset,
    input  [1:0]  ResultSrc,
    input         PCSrc, ALUSrc,
    input         RegWrite,
    input  [2:0]  ImmSrc,
    input  [3:0]  ALUControl,
    input         AUIPCsel,
    input         Jump,        // NEW: Need Jump signal to distinguish JALR
    output        Zero,
    output        Negative,
    output        Carry,
    output        Overflow,
    output [31:0] PC,
    input  [31:0] Instr,
    output [31:0] Mem_WrAddr, Mem_WrData,
    output [31:0] Mem_WrData_Orig,
    input  [31:0] ReadData,
    output [31:0] Result
);

wire [31:0] PCNext, PCPlus4, PCTarget, PCTargetBase;
wire [31:0] ImmExt, SrcB, WriteData, ALUResult;
wire [31:0] RegSrcA, ALUSrcA;
wire [31:0] LoadData;
wire [31:0] StoreData;

// Next PC logic
reset_ff #(32) pcreg(clk, reset, PCNext, PC);
adder          pcadd4(PC, 32'd4, PCPlus4);

// NEW: Select between PC (for branches) and rs1 (for JALR)
mux2 #(32)     pctargetbasemux(PC, RegSrcA, Jump, PCTargetBase);
adder          pcaddbranch(PCTargetBase, ImmExt, PCTarget);

mux2 #(32)     pcmux(PCPlus4, PCTarget, PCSrc, PCNext);

// Register file logic
reg_file       rf(clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, RegSrcA, WriteData);

// Immediate extension
imm_extend     ext(Instr[31:7], ImmSrc, ImmExt);

// ALU logic
mux2 #(32)     srcamux(RegSrcA, PC, AUIPCsel, ALUSrcA);
mux2 #(32)     srcbmux(WriteData, ImmExt, ALUSrc, SrcB);
alu            alu_inst(ALUSrcA, SrcB, ALUControl, ALUResult, Zero, Negative, Carry, Overflow);

// Load data extension
load_extend    load_ext(ReadData, ALUResult, Instr[14:12], LoadData);

// Store data preparation
store_extend   store_ext(WriteData, ALUResult, Instr[14:12], ReadData, StoreData);

// Result selection
mux3 #(32)     resultmux(ALUResult, LoadData, PCPlus4, ResultSrc, Result);

// Memory interface
assign Mem_WrData = StoreData;
assign Mem_WrData_Orig = WriteData;
assign Mem_WrAddr = ALUResult;

endmodule