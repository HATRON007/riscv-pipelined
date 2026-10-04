`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 05:33:18
// Design Name: 
// Module Name: proc_datapath
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


module proc_datapath(
    input clk,
    input reset,
    input clear,
    input reg_en_F,                   //pipeline registers
    input reg_en_D,
    input reg_en_X,
    input reg_en_M,
    input reg_en_W,
    input pc_sel_F,
    input mem_en_wd_X,
    input mem_en_wd_M,
    input regX_wb_res_sel_M,
    input operand0_sel_D,
    input wire[1:0] operand1_sel_D,
    input wire[2:0] imm_type_D,
    input wire[4:0] alu_func_sel,
    input wb_res_sel_M,
    input rf_enable_wd,
    input wire[2:0] load_sel_M,
    input wire[2:0] store_sel_M,
    output br_con_eq_X,
    output wire[31:0] ins_cu,
    output wire hz_out_X,
    input wire sr0_valid,
    input wire sr0_valid_X,
    input wire sr1_valid,
    input wire sr1_valid_X,
    input wire reg_is_jmp_ins,
    input wire reg_is_jalr,
    input wire reg_rf_en_wd,
    output wire hz_imul,
    input wire regX_is_br_ins,
    output wire actual_taken,
    output wire predict_taken_X,
    output wire[31:0] predict_target_X,
    output wire[31:0] br_target_X_wire
    );
    
    wire[31:0] pc_reg_D_wire, ins_reg_D_wire ;
    wire[31:0] pc_reg_F_wire, ins_wire, jalr_pc_value_wire;
    wire hz_reg_F_wire, hz_reg_D_wire, hz_reg_X_wire, flush_delay;


    

    reg[31:0] ins_hold; //added after the decode stage was overwritten by the next ins during stalls
    reg stall_q;
    wire stall_D = ~(reg_en_D & hz_reg_D_wire);
    wire [31:0] ins_eff = (stall_q)? ins_hold : ins_reg_D_wire; //ins_eff is the instruction that is actually decoded in the decode stage. It is either the instruction from the instruction memory or the instruction that was held in the ins_hold register during a stall.

    always @(posedge clk) begin
        if (reset) begin
            ins_hold <= 32'b0;
            stall_q <= 1'b0;
        end
        else begin
            stall_q <= stall_D;
            ins_hold <= ins_wire; //hold the instruction from the instruction memory during a stall
        end
    end

    assign ins_wire = ins_eff & {32{~flush_delay}}; //discard ins from bram during flush
    //could have used a mux to select between ins_wire and addix0, x0, 0 but that would have added an extra delay in the critical path. So, used bitwise AND operation to discard ins from bram during flush.
    //this ins would hit the default case of control unit, which disables the register write and memory write operations, thus preventing any unwanted writes to the register file or data memory during flush.
    assign ins_cu = ins_wire; //to be used in control unit for decoding
    wire predict_taken, predict_taken_D;
    wire [31:0] predict_target, predict_target_D;
    wire [1:0] btb_history, btb_history_D, btb_history_X;
    wire[31:0] pc_reg_X;

    assign actual_taken = !pc_sel_F; //if pc_sel_F is 0, then it is a branch instruction and the branch was taken, else it was not taken. 
    //no longer using it to select between pc_incr_F and br_target_X, branch predictor does that job now. now used to conclude whether the branch is actually taken or not

    stage_if fetch_stage_inst(
        .clk(clk),
        .clear(clear),
        .reset(reset),
        .reg_en_F(reg_en_F & hz_reg_F_wire), 
        .reg_en_D(reg_en_D & hz_reg_D_wire),
        .pc_sel_F(pc_sel_F),
        .reg_is_jmp_ins(reg_is_jmp_ins),
        // .ins(ins_wire),                     //have to instantiate two memory modules
        .br_target_X(br_target_X_wire),     //one that uses ins_wire, pc_reg_F_wire & another for data
        .pc_reg_D(pc_reg_D_wire),
        // .ins_reg_D(ins_reg_D_wire),
        .pc_reg_F(pc_reg_F_wire),            //instruction memory
        .jalr_pc_value(jalr_pc_value_wire),
        .reg_is_jalr(reg_is_jalr),
        .flush_delay(flush_delay),
        .predict_taken(predict_taken),
        .predict_target(predict_target),
        .btb_history(btb_history),
        .predict_taken_D(predict_taken_D),
        .predict_target_D(predict_target_D),
        .btb_history_D(btb_history_D),
        .pc_reg_X(pc_reg_X),
        .actual_taken(!pc_sel_F),
        .predict_taken_X(predict_taken_X)
    );

    branch_predictor bp_inst(
        .clk(clk),
        .pc_reg_F(pc_reg_F_wire),
        .predict_taken(predict_taken),
        .predict_target(predict_target),
        .btb_history(btb_history),
        .pc_reg_X(pc_reg_X),
        .btb_history_X(btb_history_X),
        .is_branch_X(regX_is_br_ins), //if pc_sel_F is 0, then it is a branch instruction
        .actual_taken(!pc_sel_F),
        .actual_target(br_target_X_wire)
    );
    
    wire[4:0] dr_reg_W_wire;        //from dmemory stage
    wire[4:0] dr_reg_X_wire;
    wire[31:0] operand0_reg_X_wire, operand1_reg_X_wire, dstore_reg_X_wire, reg_rf_rd0_wire, reg_sign_ext_imm_wire;
    wire[4:0] sr0_wire, sr1_wire, sr0_reg_X_wire, sr1_reg_X_wire;
    wire[31:0] rd_mem_wire;

    stage_id decode_stage_inst(
        .clk(clk),
        .reset(reset),
        .clear(clear),
        .hz_out_X(hz_out_X),
        .ins(ins_wire),
        .rf_wd(rd_mem_wire),
        .rf_enable_wd(rf_enable_wd),
        .dr(dr_reg_W_wire),        
        .pc_reg_D(pc_reg_D_wire),
        .imm_type_D(imm_type_D),
        .reg_en_X(reg_en_X & hz_reg_X_wire),
        .operand0_sel_D(operand0_sel_D),
        .operand1_sel_D(operand1_sel_D),
        .operand0_reg_X(operand0_reg_X_wire),
        .operand1_reg_X(operand1_reg_X_wire),
        .br_target_reg_X(br_target_X_wire),
        .dr_reg_X(dr_reg_X_wire),
        .dstore_reg_X(dstore_reg_X_wire),
        .sr0(sr0_wire),
        .sr1(sr1_wire),
        .sr0_reg_X(sr0_reg_X_wire),
        .sr1_reg_X(sr1_reg_X_wire),
        .reg_rf_rd0(reg_rf_rd0_wire),
        .reg_sign_ext_imm(reg_sign_ext_imm_wire),
        .reg_rf_en_wd(reg_rf_en_wd),
        .predict_taken_D(predict_taken_D),
        .predict_target_D(predict_target_D),
        .btb_history_D(btb_history_D),
        .predict_taken_X(predict_taken_X),
        .predict_target_X(predict_target_X),
        .btb_history_X(btb_history_X),
        .pc_reg_X(pc_reg_X)
    );
    
    wire[31:0] ex_res_reg_M_wire, dstore_reg_M_wire;
    wire[4:0] dr_reg_M_wire;
    wire[1:0] operand0_sel_X_wire, operand1_sel_X_wire, ex_res_reg_sel_M_wire;
    wire in_imul_computation;
    
    stage_ex execute_stage_inst(
        .clk(clk),
        .reset(reset),
        .clear(1'b0),
        .reg_en_M(reg_en_M & hz_imul),
        .alu_func_sel(alu_func_sel),
        .operand0_reg_X(operand0_reg_X_wire),
        .dstore_reg_X(dstore_reg_X_wire),
        .operand1_reg_X(operand1_reg_X_wire),
        .operand0_sel_X(operand0_sel_X_wire),
        .operand1_sel_X(operand1_sel_X_wire),
        .rd_mem(ex_res_reg_M_wire),
        .rd_wb(rd_mem_wire),
        .dr_reg_X(dr_reg_X_wire),
        .br_con_eq_X(br_con_eq_X),
        .ex_res_reg_M(ex_res_reg_M_wire),
        .dr_reg_M(dr_reg_M_wire),
        .dstore_reg_M(dstore_reg_M_wire),
        .reg_rf_rd0(reg_rf_rd0_wire),
        .reg_sign_ext_imm(reg_sign_ext_imm_wire),
        .jalr_pc_value(jalr_pc_value_wire),
        .reg_is_jalr(reg_is_jalr),
        .mem_en_wd_X(mem_en_wd_X),
        .ex_res_reg_sel_M(ex_res_reg_sel_M_wire),
        .in_imul_computation(in_imul_computation)
    );
    
    wire[31:0] mem_rd_wire, dstore_sram;
    wire[3:0] we;
    wire[2:0] load_sel_W;
    wire[31:0] ex_res_reg_W;
    wire wb_res_sel_W;
    
    stage_mem dmemory_stage_inst(
        .clk(clk),
        .reset(reset),
        .clear(1'b0),
        .ex_res_reg_M(ex_res_reg_M_wire),
        .wb_res_sel_M(wb_res_sel_M),
        .reg_en_W(reg_en_W),
        .dr_reg_M(dr_reg_M_wire),
        .dr_reg_W(dr_reg_W_wire),
        .load_sel_M(load_sel_M),
        .store_sel_M(store_sel_M),
        .dstore_reg_M(dstore_reg_M_wire),
        .dstore_sram(dstore_sram),
        .we(we),
        .mem_en_wd(mem_en_wd_M),
        .load_sel_W(load_sel_W),
        .ex_res_reg_W(ex_res_reg_W),
        .wb_res_sel_W(wb_res_sel_W)
    );

    stage_wb writeback_stage_inst(
        .mem_rd(mem_rd_wire),
        .ex_res_reg_W(ex_res_reg_W),
        .load_sel_W(load_sel_W),
        .wb_res_sel_W(wb_res_sel_W),
        .rd_mem(rd_mem_wire)
    );
        
    hazard_unit hazard_unit_inst(
        .mem_rd(regX_wb_res_sel_M),
        .sr0(sr0_wire),
        .sr1(sr1_wire),
        .sr0_reg_X(sr0_reg_X_wire),
        .sr1_reg_X(sr1_reg_X_wire),
        .dr_reg_X(dr_reg_X_wire),
        .dr_reg_M(dr_reg_M_wire),
        .dr_reg_W(dr_reg_W_wire),
        .operand0_sel_X(operand0_sel_X_wire),
        .operand1_sel_X(operand1_sel_X_wire),
        .hz_reg_F(hz_reg_F_wire),
        .hz_reg_D(hz_reg_D_wire),
        .hz_reg_X(hz_reg_X_wire),
        .hz_out_X(hz_out_X),
        .sr0_valid(sr0_valid),
        .sr1_valid(sr1_valid),
        .sr0_valid_X(sr0_valid_X),
        .sr1_valid_X(sr1_valid_X),
        .mem_en_wd_X(mem_en_wd_X),
        .ex_res_reg_sel_M(ex_res_reg_sel_M_wire),
        .in_imul_computation(in_imul_computation),
        .hz_imul(hz_imul),
        .wb_res_sel_M(wb_res_sel_M)
    );
    
    sram mem_inst_1(                         //data memory
        .clk(clk),
        .mem_address(ex_res_reg_M_wire),
        .mem_wd(dstore_sram),
        .we(we),
        .mem_rd(mem_rd_wire)
    );
    
    sram mem_inst_2(                         //instruction memory
        .clk(clk),
        .mem_address(pc_reg_F_wire),
        .mem_wd(32'b0),
        .we(4'b0),
        .mem_rd(ins_reg_D_wire)
    );
    
endmodule















