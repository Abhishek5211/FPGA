`timescale 1ns / 1ps
module Decoder(
    input [7:0] IR,
    output reg [4:0] opcode,
    output reg [2:0] src_reg,
    output reg [2:0] dest_reg,
    output reg reg_write,
    output reg memr,
    output reg memw,
    output reg alu_enable,
    output reg use_immediate,
    output reg halt,
    output reg is_branch,
    output reg [3:0] branch_type,
    output reg [1:0] inst_length,
    output reg is_mov
);

// ALU operations
localparam [4:0]
    OP_AND  = 5'b00000,
    OP_CMA  = 5'b00001,
    OP_OR   = 5'b00010,
    OP_XOR  = 5'b00011,
    OP_ADD  = 5'b00100,
    OP_ADC  = 5'b00101,
    OP_SUB  = 5'b00110,
    OP_SBB  = 5'b00111,
    OP_INR  = 5'b01000,
    OP_DCR  = 5'b01001,
    OP_ROL  = 5'b01010,
    OP_ROR  = 5'b01011,
    OP_RLC  = 5'b01100,
    OP_RRC  = 5'b01101,
    OP_CMP  = 5'b01110,
    OP_NOP  = 5'b11111;

always @(*) begin
    // Default assignments
    opcode         = OP_NOP;
    reg_write      = 0;
    src_reg        = 3'b000;
    dest_reg       = 3'b000;
    memw           = 0;
    memr           = 0;
    alu_enable     = 0;
    use_immediate  = 0;
    halt           = 0;
    is_branch      = 0;
    branch_type    = 4'b0000;
    inst_length    = 2'b01;
    is_mov         = 0;

    casez (IR)
        8'b01??????: begin  // MOV
            dest_reg = IR[5:3];
            src_reg  = IR[2:0];
            reg_write = 1;
            is_mov = 1;
        end

        8'b00???110: begin  // MVI
            dest_reg = IR[5:3];
            reg_write = 1;
            use_immediate = 1;
            inst_length = 2;
        end

        8'b10000???: begin // ADD
            dest_reg = 3'b111;
            src_reg  = IR[2:0];
            opcode = OP_ADD;
            alu_enable = 1;
            reg_write = 1;
        end

        8'b10001???: begin // ADC
            dest_reg = 3'b111;
            src_reg  = IR[2:0];
            opcode = OP_ADC;
            alu_enable = 1;
            reg_write = 1;
        end

        8'b10010???: begin // SUB
            dest_reg = 3'b111;
            src_reg  = IR[2:0];
            opcode = OP_SUB;
            alu_enable = 1;
            reg_write = 1;
        end

        8'b10011???: begin // SBB
            dest_reg = 3'b111;
            src_reg  = IR[2:0];
            opcode = OP_SBB;
            alu_enable = 1;
            reg_write = 1;
        end

        8'b10100???: begin // ANA
            dest_reg = 3'b111;
            src_reg  = IR[2:0];
            opcode = OP_AND;
            alu_enable = 1;
            reg_write = 1;
        end

        8'b10101???: begin // XRA
            dest_reg = 3'b111;
            src_reg  = IR[2:0];
            opcode = OP_XOR;
            alu_enable = 1;
            reg_write = 1;
        end

        8'b10110???: begin // ORA
            dest_reg = 3'b111;
            src_reg  = IR[2:0];
            opcode = OP_OR;
            alu_enable = 1;
            reg_write = 1;
        end

        8'b10111???: begin // CMP
            dest_reg = 3'b111;
            src_reg  = IR[2:0];
            opcode = OP_CMP;
            alu_enable = 1;
            reg_write = 0;
        end

        8'b00???100: begin // INR
            dest_reg = IR[5:3];
            src_reg  = IR[5:3];
            opcode = OP_INR;
            alu_enable = 1;
            reg_write = 1;
        end

        8'b00???101: begin // DCR
            dest_reg = IR[5:3];
            src_reg  = IR[5:3];
            opcode = OP_DCR;
            alu_enable = 1;
            reg_write = 1;
        end

        8'h07: begin opcode = OP_RLC; alu_enable = 1; dest_reg = 3'b111; src_reg = 3'b111; reg_write = 1; end
        8'h0F: begin opcode = OP_RRC; alu_enable = 1; dest_reg = 3'b111; src_reg = 3'b111; reg_write = 1; end
        8'h17: begin opcode = OP_ROL; alu_enable = 1; dest_reg = 3'b111; src_reg = 3'b111; reg_write = 1; end
        8'h1F: begin opcode = OP_ROR; alu_enable = 1; dest_reg = 3'b111; src_reg = 3'b111; reg_write = 1; end

        8'h2F: begin opcode = OP_CMA; alu_enable = 1; dest_reg = 3'b111; src_reg = 3'b111; reg_write = 1; end

        8'h3A: begin // LDA
            memr = 1;
            dest_reg = 3'b111;
            reg_write = 1;
            inst_length = 2'b11;
        end

        8'h32: begin // STA
            memw = 1;
            src_reg = 3'b111;
            inst_length = 2'b11;
        end

        8'h76: halt = 1;

        8'hC3: begin is_branch = 1; branch_type = 4'b0000; inst_length = 2'b11; end // JMP
        8'hCA: begin is_branch = 1; branch_type = 4'b0001; inst_length = 2'b11; end // JZ
        8'hC2: begin is_branch = 1; branch_type = 4'b0010; inst_length = 2'b11; end // JNZ
        8'hDA: begin is_branch = 1; branch_type = 4'b0011; inst_length = 2'b11; end // JC
        8'hD2: begin is_branch = 1; branch_type = 4'b0100; inst_length = 2'b11; end // JNC
        8'hF2: begin is_branch = 1; branch_type = 4'b0101; inst_length = 2'b11; end // JP
        8'hFA: begin is_branch = 1; branch_type = 4'b0110; inst_length = 2'b11; end // JM
        8'hEA: begin is_branch = 1; branch_type = 4'b0111; inst_length = 2'b11; end // JPE
        8'hE2: begin is_branch = 1; branch_type = 4'b1000; inst_length = 2'b11; end // JPO

        default: ;
    endcase
end

endmodule
