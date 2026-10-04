`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.06.2026 08:43:50
// Design Name: 
// Module Name: stage_if
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


module stage_if(
    input clk,
    input clear,
    input reset,
    input reg_en_F, 
    input reg_en_D,
    input pc_sel_F,
    input reg_is_jmp_ins,
    input reg_is_jalr,
    // input wire[31:0] ins,
    input wire[31:0] br_target_X,
    output reg[31:0] pc_reg_D,
    // output reg[31:0] ins_reg_D, before synchronous ram
    output reg[31:0] pc_reg_F,
    input wire[31:0] jalr_pc_value,
    output reg flush_delay, //to discard ins from bram during flush,
    
    //from branch predictor
    input wire predict_taken,
    input wire[31:0] predict_target,
    input wire[1:0] btb_history,
    output reg predict_taken_D,
    output reg[31:0] predict_target_D,
    output reg[1:0] btb_history_D,

    //bp result from execute stage
    input wire[31:0] pc_reg_X,
    input wire actual_taken,
    input wire predict_taken_X
    );

    
    wire[31:0] pc_incr_F;
    reg[31:0] pc_next_F;
    
    always @(posedge clk) begin
        if(reset) begin
                    pc_reg_F  <= 32'b0;
                    pc_reg_D  <= 32'b0;
                    // ins_reg_D <= 32'b0;
                    flush_delay <= 1'b1;
                    predict_taken_D <= 1'b0;
                    predict_target_D <= 32'b0;
                    btb_history_D <= 2'b0;
                  end
        else if (clear) begin
                            pc_reg_D  <= 32'b0;
                            // ins_reg_D <= 32'b0;
                            pc_reg_F <= (reg_en_F)? pc_next_F : pc_reg_F;
                            flush_delay <= 1'b1;
                            predict_taken_D <= 1'b0;
                            predict_target_D <= 32'b0;
                            btb_history_D <= 2'b0;

                        end         
        else begin
                pc_reg_F <= (reg_en_F)? pc_next_F : pc_reg_F;
                pc_reg_D <= (reg_en_D)? pc_reg_F : pc_reg_D;
                // ins_reg_D <= (reg_en_D)? ins : ins_reg_D;
                flush_delay <= 1'b0;
                predict_taken_D <= (reg_en_D)? predict_taken : predict_taken_D;
                predict_target_D <= (reg_en_D)? predict_target : predict_target_D;
                btb_history_D <= (reg_en_D)? btb_history : btb_history_D;
             end
    end
    
    assign pc_incr_F = pc_reg_F + 32'd4;
    //always @(*) pc_next_F = (pc_sel_F)? pc_incr_F : br_target_X; //sel is 0 for branch
    always @(*) begin
        if(reg_is_jmp_ins & reg_is_jalr) pc_next_F = jalr_pc_value;
        //else pc_next_F = (pc_sel_F)? pc_incr_F : br_target_X;
        else begin
            if(clear) pc_next_F = ({predict_taken_X, actual_taken} == 2'b10)? pc_reg_X + 32'd4 : br_target_X;
            else pc_next_F = (predict_taken)? predict_target : pc_incr_F;
        end
    end
    
endmodule
