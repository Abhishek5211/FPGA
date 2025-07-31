`timescale 1ns/1ps

module CPU(
    input clk,
    input rst
);

reg [15:0] PC;
reg [15:0] MAR;
reg [7:0] MBR;
reg [7:0] IR;

// Memory
wire [7:0] mem_out;
reg [7:0] mem_in;
wire mem_read, mem_write;

// Registers
wire [2:0] src_reg, dst_reg;
wire reg_write;
wire [7:0] reg_data_out1, reg_data_out2;

// ALU
wire alu_enable;
wire [7:0] alu_result, alu_flags;
wire read_flags;
wire [4:0] alu_opcode;

// For saving flags
reg [7:0] flags;

// Instruction Properties
wire halt, is_branch;
wire [3:0] branch_type;
wire [1:0] inst_length;
wire is_mov;
wire inst_is_2B, inst_is_3B;

// Control Unit
wire pc_inc, ir_load, mar_load, mar_sel_wz;
wire [2:0] latched_src_reg, latched_dst_reg;
wire [4:0] latched_alu_op;
wire latched_use_imm, latch_is_mov, latched_is_branch, use_alu;
wire [1:0] latched_inst_len;

// Decoder outputs
wire decoder_reg_write, decoder_mem_read, decoder_mem_write;
wire [3:0] decoder_branch_type;

wire [7:0] W, Z;

Register regfile(
    .clk(clk),
    .reset(rst),
    .write_enable(reg_write),
    .read_addr1(latched_src_reg),
    .read_addr2(latched_dst_reg),
    .write_addr(latched_dst_reg),
    .data_in(temp),
    .data_out1(reg_data_out1),
    .data_out2(reg_data_out2)
);

ControlUnit control_unit(
    .clk(clk),
    .rst(rst),
    .decoder_reg_write(decoder_reg_write),
    .decoder_mem_read(decoder_mem_read),
    .decoder_mem_write(decoder_mem_write),
    .decoder_use_alu(use_alu),
    .decoder_use_immediate(latched_use_imm),
    .decoder_is_branch(latched_is_branch),
    .decoder_branch_type(decoder_branch_type),
    .decoder_halt(halt),
    .decoder_inst_length({inst_is_3B, inst_is_2B}),
    .decoder_src_reg(src_reg),
    .decoder_dst_reg(dst_reg),
    .decoder_alu_op(alu_opcode),
    .mem_out(mem_out),
    .FLAGS(flags),

    // Outputs
    .pc_enable(pc_inc),
    .ir_load(ir_load),
    .mar_load(mar_load),
    .mar_sel_wz(mar_sel_wz),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .reg_write(reg_write),
    .alu_enable(alu_enable),
    .latched_src_reg(latched_src_reg),
    .latched_dst_reg(latched_dst_reg),
    .latched_alu_op(latched_alu_op),
    .W(W), 
    .Z(Z), 
    .latched_use_imm(latched_use_imm), 
    .latch_is_mov(latch_is_mov), 
    .latched_is_branch(latched_is_branch)
);

Decoder decoder(
    .IR(IR),
    .opcode(alu_opcode),
    .src_reg(src_reg),
    .dest_reg(dst_reg),
    .reg_write(decoder_reg_write),
    .memr(decoder_mem_read),
    .memw(decoder_mem_write),
    .alu_enable(use_alu),
    .use_immediate(latched_use_imm),
    .halt(halt),
    .is_branch(latched_is_branch),
    .branch_type(decoder_branch_type),
    .inst_length({inst_is_3B, inst_is_2B}),
    .is_mov(latch_is_mov)
);

Memory memory(
    .clk(clk),
    .rst(rst),
    .write_enable(mem_write),
    .read_enable(mem_read),
    .addr(MAR),
    .data_in(MBR),
    .data_out(mem_out)
);

ALU alu(
    .alu_enable(alu_enable),
    .Acc(reg_data_out1),
    .Operand(reg_data_out2),
    .Flag(flags),
    .opcode(alu_opcode),
    .result(alu_result),
    .flags(alu_flags),
    .read_flags(read_flags)
);

reg [7:0] temp;
always @(posedge clk) begin
    if (alu_enable) begin
        temp <= alu_result;
        flags <= alu_flags;
    end
    else if (latched_use_imm && decoder_reg_write) begin
        temp <= Z;
    end
    else if (decoder_mem_read) begin
        temp <= MBR;
    end
    else begin
        temp <= 8'h00;
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        PC <= 16'b0;
        MAR <= 16'b0;
        MBR <= 8'b0;
        IR <= 8'b0;
        flags <= 8'b0;
    end else begin
        if (mar_load) begin
            MAR <= ((inst_is_2B || inst_is_3B) && mar_sel_wz) ? {W, Z} : PC;
        end

        if (decoder_mem_read) begin
            MBR <= mem_out;
        end

        if (ir_load) begin
            IR <= mem_out;
        end

        if (latched_is_branch && mar_sel_wz) begin
            PC <= {W, Z};
        end else if (pc_inc && !(is_branch && mar_sel_wz)) begin
            PC <= PC + 16'h0001;
        end

        if (!read_flags && use_alu) begin
            flags <= alu_flags;
        end
    end
end

always @(*) begin
    if (decoder_mem_write)
        mem_in = reg_data_out1;
    else
        mem_in = 8'h00;
end

endmodule
