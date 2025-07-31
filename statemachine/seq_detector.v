`timescale 1ns/1ps
module seq_detect_1010 (
    input wire x, clk, reset,
    output reg z
);


Clock clock(
    .clk(clk),
    .rst(reset),
    .clk_out(clk_out)
);

localparam S0 = 2'b00, 
           S1 = 2'b01, 
           S2 = 2'b10, 
           S3 = 2'b11;

reg [1:0] present_state, next_state;


always @(posedge clk_out or posedge reset) begin
    if (reset)
        present_state <= S0;
    else
        present_state <= next_state;
end


always @(*) begin
    case (present_state)
        S0: next_state = (x) ? S1 : S0;
        S1: next_state = (!x) ? S2 : S1;
        S2: next_state = (x) ? S3 : S0;
        S3: next_state = (!x) ? S0 : S1;
        default: next_state = S0;
    endcase
end

always @(*) begin
    case (present_state)
        S3:     z = (!x) ? 1'b1 : 1'b0;  
        default: z = 1'b0;
    endcase
end

endmodule
