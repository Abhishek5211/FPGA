`timescale 1ns / 1ps

module ALU (
    input alu_enable,
    input [7:0] Acc, Operand, Flag,
    input [4:0] opcode,
    output reg [7:0] result,
    output reg [7:0] flags,
    output reg read_flags
);

    parameter CY_FLAG = 0;
    parameter ZERO_FLAG = 6;
    parameter SIGN_FLAG = 7;
    parameter PARITY_FLAG = 2;
    parameter AUX_CY_FLAG = 4;
    reg [8:0] temp_val;
    
    
 


    wire zero_flag,sign_flag, parity_flag, aux_carry_flag, carry_flag;
    assign zero_flag = (result == 8'b0);
    assign sign_flag = result[7];
    assign parity_flag = ~^result[7:0]; 
    assign aux_carry_flag = (Acc[3:0] + Operand[3:0] > 4'hF) || (Acc[3:0] - Operand[3:0] < 0); 
    assign carry_flag = flags[CY_FLAG]; 
    always @(*) begin
        result = 8'h00;    
        flags = 8'b0;      
        read_flags = 1;   

        if (alu_enable) begin
            case (opcode)
                5'b00000: begin  // AND
                    result = Acc & Operand;
                end
                5'b00001: begin  // CMA (NOT)
                    result = ~Acc;   
                end
                5'b00010: begin  // OR
                    result = Acc | Operand;
                end
                5'b00011: begin  // XOR
                    result = Acc ^ Operand;
                end
                5'b00100: begin  // ADD
                    temp_val = Acc + Operand;
                    result = temp_val[7:0];
                    flags[CY_FLAG] = temp_val[8];   
                end
                5'b00101: begin  // ADC (Add with carry)
                    temp_val = Acc + Operand + flags[CY_FLAG];
                    result = temp_val[7:0];
                    flags[CY_FLAG] = temp_val[8];   
                end
                5'b00110: begin  // SUB
                    temp_val = Acc - Operand;
                    result = temp_val[7:0];
                    flags[CY_FLAG] = temp_val[8];  
                end
                5'b00111: begin  // SBB (Subtract with borrow)
                    temp_val = Acc - Operand - flags[CY_FLAG];
                    result = temp_val[7:0];
                    flags[CY_FLAG] = temp_val[8];   
                end
                5'b01000: begin  // INR (Increment)
                    temp_val = Acc + 1;
                    result = temp_val[7:0];
                    flags[CY_FLAG] = temp_val[8];   
                end
                5'b01001: begin  // DCR (Decrement)
                    temp_val = Acc - 1;
                    result = temp_val[7:0];
                    flags[CY_FLAG] = temp_val[8];   
                end
                5'b01010: begin  // ROL (Rotate Left)
                    result = {Acc[6:0], Acc[7]};  
                    flags[CY_FLAG] = Acc[7];     
                end
                5'b01011: begin  // ROR  
                    result = {Acc[0], Acc[7:1]};  
                    flags[CY_FLAG] = Acc[0];      
                end
                5'b01100: begin  // RLC 
                    result = {flags[CY_FLAG], Acc[7:1]}; 
                    flags[CY_FLAG] = Acc[7];     
                end
                5'b01101: begin  // RRC (Rotate Right through Carry)
                    result = {Acc[0], Acc[7:1]};   
                    flags[CY_FLAG] = Acc[0];      
                end

                5'b01110: begin  // CMP (Compare)
                    temp_val = Acc - Operand;
                    flags[CY_FLAG] = temp_val[8]; 
                    flags[ZERO_FLAG] = (temp_val[7:0] == 8'b0);  
                    flags[SIGN_FLAG] = temp_val[7];  
                    flags[PARITY_FLAG] = ~^temp_val[7:0]; 
                    flags[AUX_CY_FLAG] = aux_carry_flag;  
                    result = 8'hFF;  // No result  needed
                end
                default: begin
                    result = 8'h00;  // Default result is 0
                end
            endcase

            // Setting flags after operations
            if (opcode != 5'b01110) begin   
                flags[ZERO_FLAG] = zero_flag;
                flags[SIGN_FLAG] = sign_flag;
                flags[PARITY_FLAG] = parity_flag;
                flags[AUX_CY_FLAG] = aux_carry_flag;
            end
        end
    end
endmodule