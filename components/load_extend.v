// load_extend.v - Load data extension module
// Handles LB, LH, LW, LBU, LHU instructions

module load_extend (
    input  [31:0] ReadData,      // Data from memory (full 32-bit word)
    input  [31:0] ALUResult,     // Address (lower 2 bits indicate byte offset)
    input  [2:0]  funct3,        // Instruction funct3 field
    output reg [31:0] LoadData   // Extended load data
);

    wire [1:0] byte_offset;
    wire [15:0] halfword;
    reg [7:0] byte_data;
    
    assign byte_offset = ALUResult[1:0];
    
    // Extract byte based on offset
    always @(*) begin
        case(byte_offset)
            2'b00: byte_data = ReadData[7:0];
            2'b01: byte_data = ReadData[15:8];
            2'b10: byte_data = ReadData[23:16];
            2'b11: byte_data = ReadData[31:24];
            default: byte_data = 8'b0;
        endcase
    end
    
    // Extract halfword based on offset (bit [1] determines upper or lower half)
    assign halfword = ALUResult[1] ? ReadData[31:16] : ReadData[15:0];
    
    // Extend based on funct3
    always @(*) begin
        case(funct3)
            3'b000: LoadData = {{24{byte_data[7]}}, byte_data};      // LB: sign-extend byte
            3'b001: LoadData = {{16{halfword[15]}}, halfword};       // LH: sign-extend halfword
            3'b010: LoadData = ReadData;                             // LW: word (no extension)
            3'b100: LoadData = {24'b0, byte_data};                   // LBU: zero-extend byte
            3'b101: LoadData = {16'b0, halfword};                    // LHU: zero-extend halfword
            default: LoadData = ReadData;
        endcase
    end

endmodule