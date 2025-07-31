module Memory (
    input clk,
    input rst,
    input write_enable,
    input read_enable,
    input [15:0] addr,
    input [7:0] data_in,
    output reg [7:0] data_out
);
   parameter MEM_SIZE = 65536; // 64K memory
    reg [7:0] mem [0:MEM_SIZE-1];
    integer i;
    always @(posedge clk) begin
        if (rst) begin
            for ( i = 0; i < MEM_SIZE; i = i + 1)
                mem[i] <= 8'd0;

            // === Load A with 0x0F ===
            mem[16'h0000] <= 8'h3E;  // MVI A, 0F
            mem[16'h0001] <= 8'h0F;

            // === Load C with 0x05 ===
            mem[16'h0002] <= 8'h0E;  // MVI C, 05
            mem[16'h0003] <= 8'h05;

            // === INR C ===
            mem[16'h0004] <= 8'h0C;  // INR C  ? C = 06

            // === DCR C ===
            mem[16'h0005] <= 8'h0D;  // DCR C  ? C = 05

            // === CMP C ===
            mem[16'h0006] <= 8'hB9;  // CMP C  ? flags updated (A = 0F, C = 05)

            // === ANA C ===
            mem[16'h0007] <= 8'hA1;  // ANA C  ? A = 0F & 05 = 05

            // === ORA C ===
            mem[16'h0008] <= 8'hB1;  // ORA C  ? A = 05 | 05 = 05

            // === XRA C ===
            mem[16'h0009] <= 8'hA9;  // XRA C  ? A = 05 ^ 05 = 00 ? Zero flag set

            // === Load C with 0x01 again ===
            mem[16'h000A] <= 8'h0E;  // MVI C, 01
            mem[16'h000B] <= 8'h01;

            // === Load A with 0x05 again ===
            mem[16'h000C] <= 8'h3E;  // MVI A, 05
            mem[16'h000D] <= 8'h05;

            // === SUB C ===
            mem[16'h000E] <= 8'h91;  // SUB C  ? A = 05 - 01 = 04

            // === HALT ===
            mem[16'h000F] <= 8'h76;  // HLT
        end
        else if (write_enable && addr < MEM_SIZE) begin
            mem[addr] <= data_in;
    end
    end 
    

     always @(posedge clk) begin
        data_out <= (read_enable && addr < MEM_SIZE) ? mem[addr] : 8'b0;
     end
endmodule
