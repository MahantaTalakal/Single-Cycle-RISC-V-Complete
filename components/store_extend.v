// store_extend.v - Store data preparation module
// Positions bytes/halfwords correctly within 32-bit word

module store_extend (
    input  [31:0] WriteData,     // Data from register (rs2)
    input  [31:0] ALUResult,     // Address
    input  [2:0]  funct3,        // Instruction funct3 field (for store type)
    input  [31:0] ReadData,      // Current memory data (for read-modify-write)
    output reg [31:0] StoreData  // Modified data to write back
);

    wire [1:0] byte_offset;
    
    assign byte_offset = ALUResult[1:0];
    
    always @(*) begin
        case(funct3)
            3'b000: begin // SB: Store Byte
                case(byte_offset)
                    2'b00: StoreData = {ReadData[31:8],  WriteData[7:0]};
                    2'b01: StoreData = {ReadData[31:16], WriteData[7:0], ReadData[7:0]};
                    2'b10: StoreData = {ReadData[31:24], WriteData[7:0], ReadData[15:0]};
                    2'b11: StoreData = {WriteData[7:0],  ReadData[23:0]};
                    default: StoreData = WriteData;
                endcase
            end
            
            3'b001: begin // SH: Store Halfword
                if (ALUResult[1]) begin
                    StoreData = {WriteData[15:0], ReadData[15:0]};  // Upper halfword
                end else begin
                    StoreData = {ReadData[31:16], WriteData[15:0]}; // Lower halfword
                end
            end
            
            3'b010: begin // SW: Store Word
                StoreData = WriteData;
            end
            
            default: begin
                StoreData = WriteData;
            end
        endcase
    end

endmodule