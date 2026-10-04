`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.06.2026 00:50:18
// Design Name: 
// Module Name: proc_top
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


module proc_top(
    input clk,
    input reset
    );
    
    wire en_F, en_D, en_X, en_M, en_W;
    wire pc_sel_F, mem_en_wd_X_wire, mem_en_wd_M_wire, rf_en_wd, operand0_sel_D, wb_res_sel_M, clear;
    wire[1:0] operand1_sel_D;
    wire[2:0] imm_type_D;
    wire[4:0] alu_func_sel;
    wire reg_rf_en_wd_wire;
    wire[31:0] ins;
    wire br_con_eq_X;
    wire hz_out_X_wire;
    wire regX_wb_res_sel_M_wire;
    wire sr1_valid, sr1_valid_X, sr0_valid, sr0_valid_X, reg_is_jmp_ins_wire, reg_is_jalr_wire;
    wire hz_imul;
    wire [2:0] load_sel_M, store_sel_M;
    wire regX_is_br_ins;
    
    proc_control control_unit_inst(
        .clk(clk),
        .reset(reset),
        .ins(ins),
        .br_con_eq_X(br_con_eq_X),
        .hz_out_X(hz_out_X_wire),
        .clear(clear),
        .reg_en_F(en_F),
        .reg_en_D(en_D),
        .reg_en_X(en_X),
        .reg_en_M(en_M),
        .reg_en_W(en_W),
        .pc_sel_F(pc_sel_F),
        .mem_en_wd_X(mem_en_wd_X_wire),
        .mem_en_wd_M(mem_en_wd_M_wire),
        .rf_en_wd(rf_en_wd),
        .operand0_sel_D(operand0_sel_D),
        .operand1_sel_D(operand1_sel_D),
        .imm_type_D(imm_type_D),
        .alu_func_sel(alu_func_sel),
        .wb_res_sel_M(wb_res_sel_M),
        .regX_wb_res_sel_M(regX_wb_res_sel_M_wire),
        .sr0_valid(sr0_valid),
        .sr1_valid(sr1_valid),
        .sr0_valid_X(sr0_valid_X),
        .sr1_valid_X(sr1_valid_X),
        .reg_is_jmp_ins(reg_is_jmp_ins_wire),
        .reg_is_jalr(reg_is_jalr_wire),
        .reg_rf_en_wd(reg_rf_en_wd_wire),
        .hz_imul(hz_imul),
        .load_sel_M(load_sel_M),
        .store_sel_M(store_sel_M),
        .regX_is_br_ins(regX_is_br_ins)
    );
    
    proc_datapath datapath_inst(
        .clk(clk),
        .reset(reset),
        .clear(clear),
        .reg_en_F(en_F),
        .reg_en_D(en_D),
        .reg_en_X(en_X),
        .reg_en_M(en_M),
        .reg_en_W(en_W),
        .pc_sel_F(pc_sel_F),
        .mem_en_wd_X(mem_en_wd_X_wire),
        .mem_en_wd_M(mem_en_wd_M_wire),
        .operand0_sel_D(operand0_sel_D),
        .operand1_sel_D(operand1_sel_D),
        .imm_type_D(imm_type_D),
        .alu_func_sel(alu_func_sel),
        .wb_res_sel_M(wb_res_sel_M),
        .rf_enable_wd(rf_en_wd),
        .br_con_eq_X(br_con_eq_X),
        .ins_cu(ins),
        .hz_out_X(hz_out_X_wire),
        .regX_wb_res_sel_M(regX_wb_res_sel_M_wire),
        .sr0_valid(sr0_valid),
        .sr1_valid(sr1_valid),
        .sr0_valid_X(sr0_valid_X),
        .sr1_valid_X(sr1_valid_X),
        .reg_is_jmp_ins(reg_is_jmp_ins_wire),
        .reg_is_jalr(reg_is_jalr_wire),
        .reg_rf_en_wd(reg_rf_en_wd_wire),
        .hz_imul(hz_imul),
        .load_sel_M(load_sel_M),
        .store_sel_M(store_sel_M),
        .is_branch_X(regX_is_br_ins)
    );
    
endmodule





