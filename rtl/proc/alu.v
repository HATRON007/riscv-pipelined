`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 05:37:43
// Design Name: 
// Module Name: alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu(
    input wire[31:0] operand0,
    input wire[31:0] operand1,
    input wire[4:0] alu_func_sel,
    output reg[31:0] result,
    output reg br_con_eq_X
    );
    
    always @(*) begin                                    
        case(alu_func_sel)
            5'd0  : begin        //add, lw
                        result = operand0 + operand1;
                        br_con_eq_X = 0;
                    end
            5'd1  : begin        //beq
                        br_con_eq_X = (operand0 == operand1);
                        result = 32'b0;
                    end
            5'd2 : begin        //sub
                        result = operand0 + 32'b1 + ~operand1;
                        br_con_eq_X = 0;
                   end
            5'd3 : begin        //and
                        result = operand0 & operand1;
                        br_con_eq_X = 0;
                   end
            5'd4 : begin       //or
                        result = operand0 | operand1;
                        br_con_eq_X = 0;
                   end
            5'd5 : begin       //xor
                        result = operand0 ^ operand1;
                        br_con_eq_X = 0;
                   end
            5'd6 : begin       //slt
//                    if((operand0[31] == 0) && (operand1[31] == 1)) result = 0;
//                    else if((operand0[31] == 1) && (operand1[31] == 0)) result = 1;
//                    else if((operand0[31] == 1) && (operand1[31] == 1)) result = (operand0 < operand1);
//                    else result = (operand0 < operand1);
                    result = ($signed(operand0) < $signed(operand1));
                    br_con_eq_X = 0;
                   end
            5'd7 : begin       //sltu
                        result = (operand0 < operand1);
                        br_con_eq_X = 0;
                   end
            5'd8 : begin       //srl
                        br_con_eq_X = 0;
                        result = operand0 >> operand1[4:0];
                   end
            5'd9 : begin       //sra
                        br_con_eq_X = 0;
                        result = $signed(operand0) >>> operand1[4:0];
                   end
            5'd10 : begin       //sll
                        br_con_eq_X = 0;
                        result = operand0 << operand1[4:0];
                   end        
            5'd11 : begin       //mul
                        br_con_eq_X = 0;
                        result = 32'b0;
                   end   
            5'd12 : begin       //lui
                        result = operand1;
                        br_con_eq_X = 0;
                    end
            5'd13 : begin       //bne
                        br_con_eq_X = (operand0 != operand1);
                        result = 32'b0;
                    end
            5'd14 : begin       //blt
//                        if((operand0[31] == 0) && (operand1[31] == 1)) br_con_eq_X = 0;
//                        else if((operand0[31] == 1) && (operand1[31] == 0)) br_con_eq_X = 1;
//                        else if((operand0[31] == 1) && (operand1[31] == 1)) br_con_eq_X = (operand0 < operand1);
//                        else br_con_eq_X = (operand0 < operand1);
                        br_con_eq_X = ($signed(operand0) < $signed(operand1));
                        result = 32'b0;
                   end
            5'd15 : begin       //bge
//                        if((operand0[31] == 1) && (operand1[31] == 0)) br_con_eq_X = 0;
//                        else if((operand0[31] == 0) && (operand1[31] == 1)) br_con_eq_X = 1;
//                        else if((operand0[31] == 1) && (operand1[31] == 1)) br_con_eq_X = (operand0 >= operand1);
//                        else br_con_eq_X = (operand0 >= operand1);
                        br_con_eq_X = ($signed(operand0) >= $signed(operand1));
                        result = 32'b0;
                   end
            5'd16 : begin       //bltu
                        br_con_eq_X = (operand0 < operand1);
                        result = 32'b0;
                    end
            5'd17 : begin       //bgeu
                        br_con_eq_X = (operand0 >= operand1);
                        result = 32'b0;
                    end
            default : begin
                        result = 32'b0;
                        br_con_eq_X = 0;
                      end
        endcase
    end
    
endmodule
