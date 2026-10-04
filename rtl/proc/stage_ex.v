`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.06.2026 23:56:18
// Design Name: 
// Module Name: stage_ex
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


module stage_ex(
    input clk,
    input reset,
    input clear,
    input wire reg_en_M,
    input wire[4:0] alu_func_sel,
    input wire[31:0] operand0_reg_X,
    input wire[31:0] dstore_reg_X,
    input wire[31:0] operand1_reg_X,
    input wire[1:0] operand0_sel_X,
    input wire[1:0] operand1_sel_X,
    input wire[31:0] rd_mem,
    input wire[31:0] rd_wb,
    input wire[4:0] dr_reg_X,
    output wire br_con_eq_X,
    output reg[31:0] ex_res_reg_M,
    output reg[4:0] dr_reg_M,
    output reg[31:0] dstore_reg_M,
    input wire[31:0] reg_sign_ext_imm,
    output wire[31:0] jalr_pc_value,
    input wire[31:0] reg_rf_rd0,
    input reg_is_jalr,
    input mem_en_wd_X,
    input wire[1:0] ex_res_reg_sel_M,
    output wire in_imul_computation
    );
    
    wire[31:0] result, fwd_rd0;
    reg[31:0] alu_operand0_val, alu_operand1_val;
    
    assign fwd_rd0 = (operand0_sel_X == 2'd1)? rd_mem :
                     (operand0_sel_X == 2'd2)? rd_wb  :
                      reg_rf_rd0;
                      
    assign jalr_pc_value = (fwd_rd0 + reg_sign_ext_imm) & 32'hFFFFFFFE;      
    
    always @(*) begin
        if(reg_is_jalr) begin
            alu_operand0_val = operand0_reg_X;
        end
        else begin
            case(operand0_sel_X)
                2'd0 : alu_operand0_val = operand0_reg_X;
                2'd1 : alu_operand0_val = rd_mem;
                2'd2 : alu_operand0_val = rd_wb;
                default : alu_operand0_val = operand0_reg_X;
            endcase
        end
        
        case(operand1_sel_X)
            2'd0 : alu_operand1_val = operand1_reg_X;
            2'd1 : alu_operand1_val = rd_mem;
            2'd2 : alu_operand1_val = rd_wb;
            default : alu_operand1_val = operand1_reg_X;
        endcase
    end
    
    
    alu alu_inst(
        .operand0(alu_operand0_val),
        .operand1(alu_operand1_val),
        .alu_func_sel(alu_func_sel),
        .result(result),
        .br_con_eq_X(br_con_eq_X)
    );

    wire istream_val, istream_rdy, ostream_val;
    wire [31:0] ostream_msg;
    reg signal_X;

    assign istream_val = (alu_func_sel == 5'd11 && !signal_X)? 1'b1 : 1'b0;
    assign in_imul_computation = ((istream_val | signal_X) & !ostream_val)? (istream_val | signal_X) : 1'b0;
    

    imul_top imul_inst(
        .clk(clk),
        .rst(reset),
        .istream_msg({alu_operand0_val, alu_operand1_val}),
        .istream_val(istream_val),
        .istream_rdy(istream_rdy),
        .ostream_msg(ostream_msg),
        .ostream_val(ostream_val),
        .ostream_rdy(1'b1)
    );


    
    always @(posedge clk) begin
       
        signal_X <= (istream_val)? 1'b1 : (ostream_val)? 1'b0 : signal_X;

        if(reset | clear) begin
                            ex_res_reg_M <= 32'b0;
                            dr_reg_M <=5'b0;
                            dstore_reg_M <= 32'b0;
                            signal_X <= 1'b0;
                          end


        else begin
                ex_res_reg_M <= (reg_en_M)? ((ostream_val)? ostream_msg : result) : ex_res_reg_M;
                dr_reg_M <= (reg_en_M)? dr_reg_X : 5'd0;
                dstore_reg_M <= (!reg_en_M)? dstore_reg_M :
                                (ex_res_reg_sel_M == 2'd1)? rd_mem :
                                (ex_res_reg_sel_M == 2'd2)? rd_wb  :
                                 dstore_reg_X;
             end
    end
        
endmodule




