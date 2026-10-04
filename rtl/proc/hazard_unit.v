`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.06.2026 20:23:07
// Design Name: 
// Module Name: hazard_unit
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


module hazard_unit(
    input wire mem_rd,
    input wire[4:0] sr0,
    input wire[4:0] sr1,
    input wire[4:0] sr0_reg_X,
    input wire[4:0] sr1_reg_X,
    input wire[4:0] dr_reg_X,
    input wire[4:0] dr_reg_M,
    input wire[4:0] dr_reg_W,
    input wire sr0_valid,
    input wire sr1_valid,
    input wire sr0_valid_X,
    input wire sr1_valid_X,
    output reg[1:0] operand0_sel_X,
    output reg[1:0] operand1_sel_X,
    output reg[1:0] ex_res_reg_sel_M,
    output reg hz_reg_F,
    output reg hz_reg_D,
    output reg hz_reg_X,
    output reg hz_out_X,
    input mem_en_wd_X,
    input wire in_imul_computation,
    output reg hz_imul,
    input wb_res_sel_M
    );
    
    //Forwarding Logic
        //operand0
    always @(*) begin
        if((dr_reg_M == sr0_reg_X) && (dr_reg_M != 0) && sr0_valid_X) begin
            operand0_sel_X = 2'd1;
        end
        
        else if((dr_reg_W == sr0_reg_X) && (dr_reg_W != 0) && sr0_valid_X) begin
            operand0_sel_X = 2'd2;
        end
        
        else operand0_sel_X = 2'd0;
    end
    
    always @(*) begin
        if((dr_reg_M == sr1_reg_X) && (dr_reg_M != 0) && mem_en_wd_X) begin
            ex_res_reg_sel_M = 2'd1;
        end
        
        else if((dr_reg_W == sr1_reg_X) && (dr_reg_W != 0) && mem_en_wd_X) begin
            ex_res_reg_sel_M = 2'd2;
        end
        
        else ex_res_reg_sel_M = 2'd0;
    end
    
        //operand1
    always @(*) begin 
       if((dr_reg_M == sr1_reg_X) && (dr_reg_M != 0) && sr1_valid_X && !mem_en_wd_X) begin
            operand1_sel_X = 2'd1;
        end
        
        else if((dr_reg_W == sr1_reg_X) && (dr_reg_W != 0) && sr1_valid_X && !mem_en_wd_X) begin
            operand1_sel_X = 2'd2;
        end
        
        else operand1_sel_X = 2'd0;
    end
    
    wire load_hazard_X;
    // wire load_hazard_M;
    assign load_hazard_X = (mem_rd == 1) && (dr_reg_X != 0) && (((dr_reg_X == sr0) && sr0_valid) || ((dr_reg_X == sr1) && sr1_valid));
    //assign load_hazard_M = (wb_res_sel_M == 1) && (dr_reg_M != 0) && (((dr_reg_M == sr0) && sr0_valid) || ((dr_reg_M == sr1) && sr1_valid));

    //Stalling Logic
    // 1-normal operation, 0-stall the pipeline
    always @(*) begin
        if(in_imul_computation) begin
            hz_reg_F = 0;
            hz_reg_D = 0;
            hz_reg_X = 0;
            hz_out_X = 0;
            hz_imul = 0;
        end
    
        else begin
                if(load_hazard_X) begin
                    hz_reg_F = 0;
                    hz_reg_D = 0;
                    hz_reg_X = 0;
                    hz_out_X = 1;
                    hz_imul = 1;
                end 
            
            else begin
                    hz_reg_F = 1;
                    hz_reg_D = 1;
                    hz_reg_X = 1;
                    hz_out_X = 0;
                    hz_imul = 1;
                end
        end
    end
    
endmodule



