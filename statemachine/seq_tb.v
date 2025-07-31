`timescale 1ns/1ns

module seq_tb;

    reg clk;
    reg reset;

    // Instantiate 
    seq_detect_1010 seq_det (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    always #8 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, seq_tb); // Dumps everything under this module
        clk = 0;
        reset = 1;
        #32;
        $finish;
    end
endmodule
