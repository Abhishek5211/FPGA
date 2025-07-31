`timescale 1ns / 1ps

module cpu_tb;

    reg clk;
    reg reset;

    // Instantiate the CPU
    CPU uut (
        .clk(clk),
        .rst(reset)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Instruction Memory Initialization
    // Assumes internal memory can be accessed from here via hierarchical reference
    initial begin
        $dumpfile("cpu_tb.vcd");
        $dumpvars(0, cpu_tb); // Dumps everything under this module
        clk = 0;
        reset = 1;

        // Wait a few cycles with reset
        #10;
        reset = 0;
        #2020;
        $finish;
    end
endmodule
