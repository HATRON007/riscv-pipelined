`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 15:49:18
// Design Name: 
// Module Name: imm_gen
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


module imm_gen(
    input wire[31:0] ins,           //instruction
    input wire[2:0] imm_type_D,       //type for decoding immediate
    output reg[31:0] sign_ext_imm_D   //sign extended
    );
    
    always @(*) begin
        case (imm_type_D)
            3'b0  : sign_ext_imm_D = {{20{ins[31]}},ins[31:20]};     //lw 
            3'b1  : sign_ext_imm_D = {{20{ins[31]}}, ins[7], ins[30:25], ins[11:8], 1'b0};   //branch ins
            3'd2  : sign_ext_imm_D = {{27{1'b0}}, ins[24:20]};
            3'd3  : sign_ext_imm_D = {ins[31:12], 12'b0};
            3'd4  : sign_ext_imm_D = {{12{ins[31]}},ins[19:12], ins[20], ins[30:21], 1'b0};  //jal, jalr
            3'd5  : sign_ext_imm_D = {{20{ins[31]}}, ins[31:25], ins[11:7]}; //sw
            default : sign_ext_imm_D = 32'b0;
        endcase
    end
    
endmodule
