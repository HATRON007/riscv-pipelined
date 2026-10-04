`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.06.2026 19:30:41
// Design Name: 
// Module Name: proc_control
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


module proc_control(
    input clk,
    input reset,
    input wire[31:0] ins,
    input br_con_eq_X,
    input hz_out_X,
    input hz_imul,
    output wire clear,
    output reg reg_en_F,
    output reg reg_en_D,
    output reg reg_en_X,
    output reg reg_en_M,
    output reg reg_en_W,
    output wire pc_sel_F,
    output reg mem_en_wd_M,
    output reg mem_en_wd_X,
    output reg rf_en_wd,
    output reg operand0_sel_D,
    output reg[1:0] operand1_sel_D,
    output reg[2:0] imm_type_D,
    output reg[4:0] alu_func_sel,
    output reg wb_res_sel_M,
    output reg regX_wb_res_sel_M,
    output reg sr0_valid,
    output reg sr1_valid,
    output reg sr0_valid_X,
    output reg sr1_valid_X,
    output reg reg_is_jmp_ins,
    output reg reg_is_jalr,
    output reg reg_rf_en_wd,
    output reg[2:0] load_sel_M,
    output reg[2:0] store_sel_M
    );
    
    reg regX_rf_en_wd, regM_rf_en_wd;
    
    reg reg_wb_res_sel_M;
    reg reg_pc_sel_F;
    reg[4:0] reg_alu_func_sel;
    
    reg is_jmp_ins;
    reg is_jalr;
    
    reg reg_is_br_ins;
    reg regX_is_br_ins;
    reg mem_en_wd;

    reg[2:0] load_sel, load_sel_X; 
    reg[2:0] store_sel, store_sel_X; 

    assign pc_sel_F = (reg_is_jmp_ins)? 0 : (regX_is_br_ins && !hz_out_X && br_con_eq_X) ? 1'b0 : 1'b1;
    assign clear    = ((regX_is_br_ins && !hz_out_X) || reg_is_jmp_ins)? (br_con_eq_X | reg_is_jmp_ins) : 0;
    
    always @(*) begin
        reg_en_F = 1;
        reg_en_D = 1;
        reg_en_X = 1;
        reg_en_M = 1;
        reg_en_W = 1;
        operand0_sel_D = 0;
        sr0_valid = 1;
        sr1_valid = 1;
        is_jmp_ins = 0;
        is_jalr = 0;
        load_sel = 3'b0;
        store_sel = 3'b0;
        
        casez({ins[14:12], ins[6:0]}) 
            //R TYPE instructions
            10'h033 : if(ins[31:25] == 7'b0) begin //add
                        reg_alu_func_sel = 5'b0;
                        reg_rf_en_wd = 1'b1;
                        reg_wb_res_sel_M = 1'b0;
                        operand1_sel_D = 0;
                        reg_is_br_ins = 1'b0;
                        mem_en_wd = 0;
                        imm_type_D = 0;
                      end
                      else if(ins[31:25] == 7'd32) begin //sub
                        reg_alu_func_sel = 5'd2;
                        reg_rf_en_wd = 1'b1;
                        reg_wb_res_sel_M = 1'b0;
                        operand1_sel_D = 0;
                        reg_is_br_ins = 1'b0;
                        mem_en_wd = 0;
                        imm_type_D = 0;                               
                      end
                      else begin //mul
                        reg_alu_func_sel = 5'd11;
                        reg_rf_en_wd = 1'b1;
                        reg_wb_res_sel_M = 1'b0;
                        operand1_sel_D = 0;
                        reg_is_br_ins = 1'b0;
                        mem_en_wd = 0;
                        imm_type_D = 0;  
                      end
            10'h3B3 : begin //and
                        reg_alu_func_sel = 5'd3;
                        reg_rf_en_wd = 1'b1;
                        reg_wb_res_sel_M = 1'b0;
                        operand1_sel_D = 0;
                        reg_is_br_ins = 1'b0;
                        mem_en_wd = 0;
                        imm_type_D = 0;
                      end
            10'h333 : begin //or
                        reg_alu_func_sel = 5'd4;
                        reg_rf_en_wd = 1'b1;
                        reg_wb_res_sel_M = 1'b0;
                        operand1_sel_D = 0;
                        reg_is_br_ins = 1'b0;
                        mem_en_wd = 0;
                        imm_type_D = 0;
                      end
            10'h233 : begin //xor
                        reg_alu_func_sel = 5'd5;
                        reg_rf_en_wd = 1'b1;
                        reg_wb_res_sel_M = 1'b0;
                        operand1_sel_D = 0;
                        reg_is_br_ins = 1'b0;
                        mem_en_wd = 0;
                        imm_type_D = 0;
                      end
            10'h133 : begin //slt
                        reg_alu_func_sel = 5'd6;
                        reg_rf_en_wd = 1'b1;
                        reg_wb_res_sel_M = 1'b0;
                        operand1_sel_D = 0;
                        reg_is_br_ins = 1'b0;
                        mem_en_wd = 0;
                        imm_type_D = 0;
                      end
            10'h1B3 : begin //sltu
                        reg_alu_func_sel = 5'd7;
                        reg_rf_en_wd = 1'b1;
                        reg_wb_res_sel_M = 1'b0;
                        operand1_sel_D = 0;
                        reg_is_br_ins = 1'b0;
                        mem_en_wd = 0;
                        imm_type_D = 0;
                      end
            10'h2B3 : if(ins[31:25] == 7'b0)
                          begin //srl
                            reg_alu_func_sel = 5'd8;
                            reg_rf_en_wd = 1'b1;
                            reg_wb_res_sel_M = 1'b0;
                            operand1_sel_D = 0;
                            reg_is_br_ins = 1'b0;
                            mem_en_wd = 0;
                            imm_type_D = 0;
                          end
                       else
                          begin //sra
                            reg_alu_func_sel = 5'd9;
                            reg_rf_en_wd = 1'b1;
                            reg_wb_res_sel_M = 1'b0;
                            operand1_sel_D = 0;
                            reg_is_br_ins = 1'b0;
                            mem_en_wd = 0;
                            imm_type_D = 0;
                          end
            10'h0B3 : begin //sll
                        reg_alu_func_sel = 5'd10;
                        reg_rf_en_wd = 1'b1;
                        reg_wb_res_sel_M = 1'b0;
                        operand1_sel_D = 0;
                        reg_is_br_ins = 1'b0;
                        mem_en_wd = 0;
                        imm_type_D = 0;
                      end
            //I TYPE instructions
            10'h013 : begin //addi
                        reg_alu_func_sel = 5'b0;
                        reg_rf_en_wd = 1'b1;
                        reg_wb_res_sel_M = 1'b0;
                        operand1_sel_D = 1;
                        reg_is_br_ins = 1'b0;
                        mem_en_wd = 0;
                        imm_type_D = 0;
                        sr0_valid = 1;
                        sr1_valid = 0;
                      end
            10'h393 : begin //andi
                        reg_alu_func_sel = 5'd3;
                        reg_rf_en_wd = 1'b1;
                        reg_wb_res_sel_M = 1'b0;
                        operand1_sel_D = 1;
                        reg_is_br_ins = 1'b0;
                        mem_en_wd = 0;
                        imm_type_D = 0;
                        sr0_valid = 1;
                        sr1_valid = 0;
                      end
            10'h313 : begin //ori
                        reg_alu_func_sel = 5'd4;
                        reg_rf_en_wd = 1'b1;
                        reg_wb_res_sel_M = 1'b0;
                        operand1_sel_D = 1;
                        reg_is_br_ins = 1'b0;
                        mem_en_wd = 0;
                        imm_type_D = 0;
                        sr0_valid = 1;
                        sr1_valid = 0;
                      end
            10'h213 : begin //xori
                        reg_alu_func_sel = 5'd5;
                        reg_rf_en_wd = 1'b1;
                        reg_wb_res_sel_M = 1'b0;
                        operand1_sel_D = 1;
                        reg_is_br_ins = 1'b0;
                        mem_en_wd = 0;
                        imm_type_D = 0;
                        sr0_valid = 1;
                        sr1_valid = 0;
                      end      
            10'h113 : begin //slti
                        reg_alu_func_sel = 5'd6;
                        reg_rf_en_wd = 1'b1;
                        reg_wb_res_sel_M = 1'b0;
                        operand1_sel_D = 1;
                        reg_is_br_ins = 1'b0;
                        mem_en_wd = 0;
                        imm_type_D = 0;
                        sr0_valid = 1;
                        sr1_valid = 0;
                      end
            10'h193 : begin //sltiu
                        reg_alu_func_sel = 5'd7;
                        reg_rf_en_wd = 1'b1;
                        reg_wb_res_sel_M = 1'b0;
                        operand1_sel_D = 1;
                        reg_is_br_ins = 1'b0;
                        mem_en_wd = 0;
                        imm_type_D = 0;
                        sr0_valid = 1;
                        sr1_valid = 0;
                      end
            10'h293 : if(ins[31:25] == 7'b0)
                          begin //srli
                            reg_alu_func_sel = 5'd8;
                            reg_rf_en_wd = 1'b1;
                            reg_wb_res_sel_M = 1'b0;
                            operand1_sel_D = 1;
                            reg_is_br_ins = 1'b0;
                            mem_en_wd = 0;
                            imm_type_D = 3'd2;
                            sr0_valid = 1;
                            sr1_valid = 0;  
                          end
                      else 
                          begin //srai
                            reg_alu_func_sel = 5'd9;
                            reg_rf_en_wd = 1'b1;
                            reg_wb_res_sel_M = 1'b0;
                            operand1_sel_D = 1;
                            reg_is_br_ins = 1'b0;
                            mem_en_wd = 0;
                            imm_type_D = 3'd2;
                            sr0_valid = 1;
                            sr1_valid = 0;
                          end
            10'h093 : begin //slli
                        reg_alu_func_sel = 5'd10;
                        reg_rf_en_wd = 1'b1;
                        reg_wb_res_sel_M = 1'b0;
                        operand1_sel_D = 1;
                        reg_is_br_ins = 1'b0;
                        mem_en_wd = 0;
                        imm_type_D = 3'd2;
                        sr0_valid = 1;
                        sr1_valid = 0;
                      end
            10'b???0110111 : begin //lui
                                reg_alu_func_sel = 5'd12;
                                reg_rf_en_wd = 1'b1;
                                reg_wb_res_sel_M = 1'b0;
                                operand1_sel_D = 1;
                                reg_is_br_ins = 1'b0;
                                mem_en_wd = 0;
                                imm_type_D = 3'd3;
                                sr0_valid = 0;
                                sr1_valid = 0;
                              end 
            10'b???0010111 : begin //auipc
                                reg_alu_func_sel = 5'd0;
                                reg_rf_en_wd = 1'b1;
                                reg_wb_res_sel_M = 1'b0;
                                operand0_sel_D = 1;
                                operand1_sel_D = 1;
                                reg_is_br_ins = 1'b0;
                                mem_en_wd = 0;
                                imm_type_D = 3'd3;
                                sr0_valid = 0;
                                sr1_valid = 0;
                                
                              end
            //MEMORY TYPE INSTRUCTIONS
            10'h003 : begin //lb
                        reg_rf_en_wd = 1'b1;
                        reg_wb_res_sel_M = 1'b1;
                        reg_alu_func_sel = 5'b0;
                        operand1_sel_D = 1;
                        reg_is_br_ins = 1'b0;
                        mem_en_wd = 0;
                        imm_type_D = 0;
                        sr0_valid = 1;
                        sr1_valid = 0;
                        load_sel = ins[14:12];
                  end
            10'h083 : begin //lh
                        reg_rf_en_wd = 1'b1;
                        reg_wb_res_sel_M = 1'b1;
                        reg_alu_func_sel = 5'b0;
                        operand1_sel_D = 1;
                        reg_is_br_ins = 1'b0;
                        mem_en_wd = 0;
                        imm_type_D = 0;
                        sr0_valid = 1;
                        sr1_valid = 0;
                        load_sel = ins[14:12];
                  end
            10'h103 : begin //lw
                        reg_rf_en_wd = 1'b1;
                        reg_wb_res_sel_M = 1'b1;
                        reg_alu_func_sel = 5'b0;
                        operand1_sel_D = 1;
                        reg_is_br_ins = 1'b0;
                        mem_en_wd = 0;
                        imm_type_D = 0;
                        sr0_valid = 1;
                        sr1_valid = 0;
                        load_sel = ins[14:12];
                  end
            10'h203 : begin //lbu
                        reg_rf_en_wd = 1'b1;
                        reg_wb_res_sel_M = 1'b1;
                        reg_alu_func_sel = 5'b0;
                        operand1_sel_D = 1;
                        reg_is_br_ins = 1'b0;
                        mem_en_wd = 0;
                        imm_type_D = 0;
                        sr0_valid = 1;
                        sr1_valid = 0;
                        load_sel = ins[14:12];
                  end
            10'h283 : begin //lhu
                        reg_rf_en_wd = 1'b1;
                        reg_wb_res_sel_M = 1'b1;
                        reg_alu_func_sel = 5'b0;
                        operand1_sel_D = 1;
                        reg_is_br_ins = 1'b0;
                        mem_en_wd = 0;
                        imm_type_D = 0;
                        sr0_valid = 1;
                        sr1_valid = 0;
                        load_sel = ins[14:12];
                      end
            10'h023 : begin //sb
                        reg_rf_en_wd = 1'b0;
                        reg_wb_res_sel_M = 1'b0;
                        reg_alu_func_sel = 5'd0;
                        operand1_sel_D = 1;
                        reg_is_br_ins = 1'b0;
                        mem_en_wd = 1;
                        imm_type_D = 3'd5;
                        sr0_valid = 1;
                        sr1_valid = 1;
                        store_sel = ins[14:12];
                      end
            10'h0A3 : begin //sh
                        reg_rf_en_wd = 1'b0;
                        reg_wb_res_sel_M = 1'b0;
                        reg_alu_func_sel = 5'd0;
                        operand1_sel_D = 1;
                        reg_is_br_ins = 1'b0;
                        mem_en_wd = 1;
                        imm_type_D = 3'd5;
                        sr0_valid = 1;
                        sr1_valid = 1;
                        store_sel = ins[14:12];
                      end
            10'h123 : begin //sw
                        reg_rf_en_wd = 1'b0;
                        reg_wb_res_sel_M = 1'b0;
                        reg_alu_func_sel = 5'd0;
                        operand1_sel_D = 1;
                        reg_is_br_ins = 1'b0;
                        mem_en_wd = 1;
                        imm_type_D = 3'd5;
                        sr0_valid = 1;
                        sr1_valid = 1;
                        store_sel = ins[14:12];
                      end
            //J TYPE INSTRUCTIONS
            10'b???1101111 : begin //jal
                                reg_alu_func_sel = 5'd0;
                                reg_rf_en_wd = 1'b1;
                                reg_wb_res_sel_M = 1'b0;
                                operand1_sel_D = 2'd3;
                                operand0_sel_D = 1;
                                reg_is_br_ins = 1'b0;
                                mem_en_wd = 0;
                                imm_type_D = 3'd4;
                                sr0_valid = 0;
                                sr1_valid = 0;
                                is_jmp_ins = 1;
                             end
            10'b???1100111 : begin //jalr
                                reg_alu_func_sel = 5'd0;
                                reg_rf_en_wd = 1'b1;
                                reg_wb_res_sel_M = 1'b0;
                                operand1_sel_D = 2'd3;
                                operand0_sel_D = 1;
                                reg_is_br_ins = 1'b0;
                                mem_en_wd = 0;
                                imm_type_D = 3'd0;
                                sr0_valid = 1;
                                sr1_valid = 0;
                                is_jmp_ins = 1;
                                is_jalr = 1;
                             end
            //B TYPE INSTRUCTIONS
            10'h063 : begin //beq
                        reg_is_br_ins = 1;
                        reg_rf_en_wd = 0;
                        reg_wb_res_sel_M = 0;
                        reg_alu_func_sel = 5'b1;
                        operand1_sel_D = 0;
                        mem_en_wd = 0;
                        imm_type_D = 1;
                      end
            10'h0E3 : begin //bne
                        reg_is_br_ins = 1;
                        reg_rf_en_wd = 0;
                        reg_wb_res_sel_M = 0;
                        reg_alu_func_sel = 5'd13;
                        operand1_sel_D = 0;
                        mem_en_wd = 0;
                        imm_type_D = 1;
                      end
            10'h263 : begin //blt
                        reg_is_br_ins = 1;
                        reg_rf_en_wd = 0;
                        reg_wb_res_sel_M = 0;
                        reg_alu_func_sel = 5'd14;
                        operand1_sel_D = 0;
                        mem_en_wd = 0;
                        imm_type_D = 1;
                      end
            10'h2E3 : begin //bge
                        reg_is_br_ins = 1;
                        reg_rf_en_wd = 0;
                        reg_wb_res_sel_M = 0;
                        reg_alu_func_sel = 5'd15;
                        operand1_sel_D = 0;
                        mem_en_wd = 0;
                        imm_type_D = 1;
                      end 
            10'h363 : begin //bltu
                        reg_is_br_ins = 1;
                        reg_rf_en_wd = 0;
                        reg_wb_res_sel_M = 0;
                        reg_alu_func_sel = 5'd16;
                        operand1_sel_D = 0;
                        mem_en_wd = 0;
                        imm_type_D = 1;
                      end
            10'h3E3 : begin //bgeu
                        reg_is_br_ins = 1;
                        reg_rf_en_wd = 0;
                        reg_wb_res_sel_M = 0;
                        reg_alu_func_sel = 5'd17;
                        operand1_sel_D = 0;
                        mem_en_wd = 0;
                        imm_type_D = 1;
                      end
            default : begin
                        reg_alu_func_sel = 5'b0;
                        reg_rf_en_wd = 1'b0;
                        reg_wb_res_sel_M = 1'b0;
                        reg_is_br_ins = 1'b0;
                        operand1_sel_D = 0;
                        mem_en_wd = 0;
                        imm_type_D = 0;
                        sr0_valid = 0;
                        sr1_valid = 0;
                      end
                        
        endcase
    end
    
    always @(posedge clk) begin
    if(reset) begin
        regX_rf_en_wd <= 1'b0;
        regM_rf_en_wd <= 1'b0;
        regX_wb_res_sel_M <= 1'b0;
        regX_is_br_ins    <= 1'b0;
        mem_en_wd_X <= 0;
        mem_en_wd_M <= 0;
        load_sel_X <= 3'b0;
        load_sel_M <= 3'b0;
        store_sel_X <= 3'b0;
        store_sel_M <= 3'b0;
        rf_en_wd <= 0;
        wb_res_sel_M <= 0;
        alu_func_sel <= 5'b0;
        sr0_valid_X <= 0;
        sr1_valid_X <= 0;
        reg_is_jmp_ins <= 0;
        reg_is_jalr <= 0;
    end else begin
        // 1. Shift MEM -> WB
        rf_en_wd <= regM_rf_en_wd;

        // 2. Shift EX -> MEM (Must happen even if ID is flushing!)
        if(!hz_imul) begin
            regM_rf_en_wd <= 0;
            wb_res_sel_M <= 0;
            mem_en_wd_M <= 0;
            load_sel_M <= 3'b0;
            store_sel_M <= 3'b0;
        end else begin
            regM_rf_en_wd <= regX_rf_en_wd;
            wb_res_sel_M  <= regX_wb_res_sel_M;
            mem_en_wd_M   <= mem_en_wd_X;
            load_sel_M    <= load_sel_X;
            store_sel_M   <= store_sel_X;
        end
        
        // 3. Shift ID -> EX (Squash if branch taken or hazard)
        if(hz_out_X || clear) begin
            alu_func_sel <= 0;
            regX_rf_en_wd <= 0;
            regX_wb_res_sel_M <= 0;
            regX_is_br_ins <= 0;
            sr0_valid_X <= 0;
            sr1_valid_X <= 0;
            reg_is_jmp_ins <= 0;
            reg_is_jalr <= 0;
            mem_en_wd_X <= 0;
            load_sel_X <= 3'b0;
            store_sel_X <= 3'b0;
        end else if(hz_imul) begin
            alu_func_sel <= reg_alu_func_sel;
            regX_rf_en_wd <= reg_rf_en_wd;
            regX_wb_res_sel_M <= reg_wb_res_sel_M;
            regX_is_br_ins <= reg_is_br_ins;
            sr0_valid_X <= sr0_valid;
            sr1_valid_X <= sr1_valid;
            reg_is_jmp_ins <= is_jmp_ins;
            reg_is_jalr <= is_jalr;
            mem_en_wd_X <= mem_en_wd;
            load_sel_X <= load_sel;
            store_sel_X <= store_sel;
        end
    end
end
    
endmodule



