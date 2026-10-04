`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.06.2026 01:49:09
// Design Name: 
// Module Name: stage_mem
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


module stage_mem(
    input clk,
    input reset,
    input clear,
    input wire[31:0] ex_res_reg_M,
    input wire wb_res_sel_M,    //can also be used for identifing if ins is load
    input wire reg_en_W,
    input wire[4:0] dr_reg_M,
    input wire[2:0] load_sel_M,
    input wire[2:0] store_sel_M,
    input wire[31:0] dstore_reg_M,
    output reg[4:0] dr_reg_W,
    //output reg[31:0] wb_res_reg_W,
    output reg[31:0] dstore_sram,
    output reg[3:0] we,
    output reg[2:0] load_sel_W,
    output reg[31:0] ex_res_reg_W,
    output reg wb_res_sel_W,
    input mem_en_wd
    );

    //rd_mem = forward the result of M stage to X stage
    //mem_rd = 32 bit data coming out of SRAM
    
    //wire[31:0] wb_res_wire_W;
    // assign wb_res_wire_W = (wb_res_sel_M)? mem_rd_signext : ex_res_reg_M;
    // assign rd_mem = wb_res_wire_W;

    always @(*) begin

        case({mem_en_wd,store_sel_M})
            4'b1010: we = 4'b1111; //sw
            4'b1000: we = (ex_res_reg_M[1:0] == 2'b00)? 4'b0001 :
                          (ex_res_reg_M[1:0] == 2'b01)? 4'b0010 :
                          (ex_res_reg_M[1:0] == 2'b10)? 4'b0100 :
                          4'b1000; //sb
            4'b1001: we = (ex_res_reg_M[1] == 1'b0)? 4'b0011 : 4'b1100; //sh
            default: we = 4'b0000;
        endcase

        case(we)
            4'b0001: dstore_sram = dstore_reg_M;
            4'b0010: dstore_sram = dstore_reg_M << 8;
            4'b0100: dstore_sram = dstore_reg_M << 16;
            4'b1000: dstore_sram = dstore_reg_M << 24;
            4'b1111: dstore_sram = dstore_reg_M;
            4'b0011: dstore_sram = dstore_reg_M;
            4'b1100: dstore_sram = dstore_reg_M << 16;
            default: dstore_sram = 32'b0;
        endcase
    end
    
    
    always @(posedge clk) begin
        if(reset | clear) begin
                            //wb_res_reg_W <= 32'b0;
                            dr_reg_W <= 5'b0;
                            load_sel_W <= 3'b0;
                            ex_res_reg_W <= 32'b0;
                            wb_res_sel_W <= 1'b0;
                          end
        else begin
                //wb_res_reg_W <= (reg_en_W)? wb_res_wire_W : wb_res_reg_W;
                dr_reg_W <= (reg_en_W)? dr_reg_M : dr_reg_W;
                load_sel_W <= (reg_en_W)? load_sel_M : load_sel_W;
                ex_res_reg_W <= (reg_en_W)? ex_res_reg_M : ex_res_reg_W;
                wb_res_sel_W <= (reg_en_W)? wb_res_sel_M : wb_res_sel_W;
             end
    end
    
    
endmodule
