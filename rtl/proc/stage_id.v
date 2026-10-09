`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.06.2026 08:46:58
// Design Name: 
// Module Name: stage_id
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


module stage_id(
    input clk,
    input reset,
    input clear,
    input wire hz_out_X,
    input wire[31:0] ins,
    input wire[31:0] rf_wd,
    input wire rf_enable_wd,
    input wire reg_rf_en_wd,
    input wire[4:0] dr,
    input wire[31:0] pc_reg_D,
    input wire[2:0] imm_type_D,
    input reg_en_X,
    input operand0_sel_D,
    input wire[1:0] operand1_sel_D,
    output reg[31:0] operand0_reg_X,
    output reg[31:0] operand1_reg_X,
    output reg[31:0] reg_rf_rd0,
    output reg[31:0] br_target_reg_X,
    output reg[4:0] dr_reg_X,
    output reg[31:0] dstore_reg_X,
    output wire[4:0] sr0,
    output wire[4:0] sr1,
    output reg[4:0] sr0_reg_X,
    output reg[4:0] sr1_reg_X,
    output reg[31:0] reg_sign_ext_imm,
    input wire predict_taken_D,
    input wire[31:0] predict_target_D,
    input wire[1:0] btb_history_D,
    output reg predict_taken_X,
    output reg[31:0] predict_target_X,
    output reg[1:0] btb_history_X,
    output reg[31:0] pc_reg_X
    );
    
    wire[31:0] pc_plus_imm_D, rf_rd0, rf_rd1, sign_ext_imm_D;
    wire[31:0] operand0_sel_mux_D;
    reg[31:0]  operand1_sel_mux_D;
    
    assign sr0 = ins[19:15];
    assign sr1 = ins[24:20];
    
    (* max_fanout = 32 *) wire flush_id = reset | clear | hz_out_X;
    always @(posedge clk) begin
        if(flush_id) begin
                    operand0_reg_X  <= 32'b0;
                    operand1_reg_X  <= 32'b0;
                    br_target_reg_X <= 32'b0;
                    dstore_reg_X    <= 32'b0;
                    dr_reg_X        <= 5'b0;
                    sr0_reg_X       <= 5'b0;
                    sr1_reg_X       <= 5'b0;
                    reg_sign_ext_imm    <= 32'b0;
                    reg_rf_rd0      <= 32'b0;

                    predict_taken_X <= 1'b0;
                    predict_target_X <= 32'b0;
                    btb_history_X <= 2'b0;
                    pc_reg_X <= 32'b0;
                  end
                  
        else begin
            operand0_reg_X  <= (reg_en_X)? operand0_sel_mux_D : operand0_reg_X;
            operand1_reg_X  <= (reg_en_X)? operand1_sel_mux_D : operand1_reg_X;
            reg_sign_ext_imm <= (reg_en_X)? sign_ext_imm_D : reg_sign_ext_imm;
            br_target_reg_X <= (reg_en_X)? pc_plus_imm_D : br_target_reg_X; 
            //dr_reg_X        <= (reg_en_X)? ins[11:7] : 5'b0;
            dr_reg_X        <= (reg_en_X)? (reg_rf_en_wd? ins[11:7] : 5'b0) : dr_reg_X;
            dstore_reg_X    <= (reg_en_X)? rf_rd1 : dstore_reg_X;
            sr0_reg_X       <= (reg_en_X)? sr0 : sr0_reg_X;
            sr1_reg_X       <= (reg_en_X)? sr1 : sr1_reg_X;
            reg_rf_rd0      <= (reg_en_X)? rf_rd0 : reg_rf_rd0;

            //for transferring the branch predictor result to execute stage
            predict_taken_X <= (reg_en_X)? predict_taken_D : predict_taken_X;
            predict_target_X <= (reg_en_X)? predict_target_D : predict_target_X;
            btb_history_X <= (reg_en_X)? btb_history_D : btb_history_X;
            pc_reg_X <= (reg_en_X)? pc_reg_D : pc_reg_X;
        end
    end
    
    regfile rf_inst(
        .clk(clk),
        .sr0(ins[19:15]),
        .sr1(ins[24:20]),
        .dr(dr),
        .rf_enable_wd(rf_enable_wd),
        .rf_wd(rf_wd),
        .rf_rd0(rf_rd0),
        .rf_rd1(rf_rd1)
    );
    
    imm_gen immgen_inst(
        .ins(ins),
        .imm_type_D(imm_type_D),
        .sign_ext_imm_D(sign_ext_imm_D)
    );
    
    assign operand0_sel_mux_D = (operand0_sel_D)? pc_reg_D : rf_rd0;
    //assign operand1_sel_mux_D = (operand1_sel_D)? sign_ext_imm_D : rf_rd1;
    always @(*) begin
        case(operand1_sel_D)
            2'd0 : operand1_sel_mux_D = rf_rd1;
            2'd1 : operand1_sel_mux_D = sign_ext_imm_D;
            2'd3 : operand1_sel_mux_D = 32'd4;
            default :  operand1_sel_mux_D = rf_rd1;
        endcase
    end
    
    assign pc_plus_imm_D = sign_ext_imm_D + pc_reg_D;
    
endmodule







