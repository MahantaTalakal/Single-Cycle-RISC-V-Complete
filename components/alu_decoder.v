
// alu_decoder.v - logic for ALU decoder

module alu_decoder (
    input            opb5,
    input [2:0]      funct3,
    input            funct7b5,
    input [1:0]      ALUOp,
    output reg [3:0] ALUControl
);

wire RtypeSub;
    assign RtypeSub = funct7b5 & opb5; // TRUE for R-type subtract

    // ALU Control Encoding:
    // 4'b0000 = ADD (add, addi)
    // 4'b0001 = SUB (sub)
    // 4'b0010 = AND (and, andi)
    // 4'b0011 = OR (or, ori)
    // 4'b0100 = XOR (xor, xori)
    // 4'b0101 = SLT (slt, slti) - set less than
    // 4'b0110 = SLTU (sltu, sltiu) - set less than unsigned
    // 4'b1010 = SLL (sll, slli) - shift left logical
    // 4'b1011 = SRA (sra, srai) - shift right arithmetic
    // 4'b1100 = SRL (srl, srli) - shift right logical
    // 4'b1000 = AUIPC
    // 4'b1001 = LUI

    always @(*) begin
        case(ALUOp)
            2'b00: ALUControl = 4'b0000; // addition
            2'b01: ALUControl = 4'b0001; // subtraction
            2'b10: begin // R-type or I-type ALU
                case(funct3)
                    3'b000: begin
                        if (RtypeSub) 
                            ALUControl = 4'b0001; // sub
                        else 
                            ALUControl = 4'b0000; // add, addi
                    end
                    3'b001: ALUControl = 4'b1010; // sll, slli - shift left logical
                    3'b010: ALUControl = 4'b0101; // slt, slti - set less than
                    3'b011: ALUControl = 4'b0110; // sltu, sltiu - set less than unsigned
                    3'b100: ALUControl = 4'b0100; // xor, xori
                    3'b101: begin
                        if (funct7b5) 
                            ALUControl = 4'b1011; // sra, srai - shift right arithmetic
                        else 
                            ALUControl = 4'b1100; // srl, srli - shift right logical
                    end
                    3'b110: ALUControl = 4'b0011; // or, ori
                    3'b111: ALUControl = 4'b0010; // and, andi
                    default: ALUControl = 4'bxxxx; 
                endcase
            end
            2'b11: begin // AUIPC and LUI
                case(funct3)
                    3'b000: ALUControl = 4'b1000; // AUIPC
                    3'b001: ALUControl = 4'b1001; // LUI
                    default: ALUControl = 4'bxxxx;
                endcase
            end
            default: ALUControl = 4'bxxxx;
        endcase
    end

endmodule