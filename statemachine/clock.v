`timescale 1ns/1ps

module Clock(
    input clk,
    input rst,
    output reg clk_out
);

    reg [31:0] counter;

    always @(posedge clk or posedge rst ) begin
        if(rst)  begin
          counter <= 32'd0;
            clk_out <= 1;
        end
         counter <= counter + 1;
        if(counter == 32'd10) begin  
            clk_out <= ~clk_out;  
            counter <= 32'd0;  
        end
    end

    endmodule