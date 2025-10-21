// riscv_cpu.v - single-cycle RISC-V CPU Processor

module riscv_cpu (
    input         clk, reset,
    output [31:0] PC,
    input  [31:0] Instr,
    output        MemWrite,
    output [31:0] Mem_WrAddr, Mem_WrData,
    input  [31:0] ReadData,
    output [31:0] Result,
    output [31:0] Mem_WrData_Orig
);

wire        ALUSrc, RegWrite, Jump, Zero, PCSrc, AUIPCsel;
wire        Negative, Carry, Overflow;
wire [1:0]  ResultSrc;
wire [2:0]  ImmSrc;
wire [3:0]  ALUControl;

// Controller
controller  c (
    .op(Instr[6:0]),
    .funct3(Instr[14:12]),
    .funct7b5(Instr[30]),
    .Zero(Zero),
    .Negative(Negative),
    .Carry(Carry),
    .Overflow(Overflow),
    .ResultSrc(ResultSrc),
    .MemWrite(MemWrite),
    .PCSrc(PCSrc),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite),
    .Jump(Jump),
    .ImmSrc(ImmSrc),
    .ALUControl(ALUControl),
    .AUIPCsel(AUIPCsel)
);

// Datapath
datapath    dp (
    .clk(clk),
    .reset(reset),
    .ResultSrc(ResultSrc),
    .PCSrc(PCSrc),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite),
    .ImmSrc(ImmSrc),
    .ALUControl(ALUControl),
    .AUIPCsel(AUIPCsel),
    .Jump(Jump),              
    .Zero(Zero),
    .Negative(Negative),
    .Carry(Carry),
    .Overflow(Overflow),
    .PC(PC),
    .Instr(Instr),
    .Mem_WrAddr(Mem_WrAddr),
    .Mem_WrData(Mem_WrData),
    .Mem_WrData_Orig(Mem_WrData_Orig),
    .ReadData(ReadData),
    .Result(Result)
);

endmodule