`timescale 1ns / 1ps

module Register(
    input clk,
    input reset,

    input write_enable,

    input wire[2:0] read_addr1,
    input wire[2:0] read_addr2,

    input wire[2:0] write_addr,
    input [7:0] data_in,

    output reg [7:0] data_out1,
    output reg [7:0] data_out2
);

reg [7:0] regs [0:7];

always @(posedge clk or posedge reset) begin
    if(reset) begin
        regs[0] <= 8'b0;
        regs[1] <= 8'b0;
        regs[2] <= 8'b0;
        regs[3] <= 8'b0;
        regs[4] <= 8'b0;
        regs[5] <= 8'b0;
        regs[6] <= 8'b0;
        regs[7] <= 8'b0;
    end

    else if(write_enable && write_addr != 3'b110) begin
        regs[write_addr] <= data_in;
    end
end


always @(*) begin
    data_out1 <= regs[read_addr1]; //Might need to add condition for b'110
    data_out2 <= regs[read_addr2];
end

endmodule
