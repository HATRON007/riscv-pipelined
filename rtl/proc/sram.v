`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 18:41:53
// Design Name: 
// Module Name: sram
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


module sram(
    input clk,
    input wire[31:0] mem_address,
    input wire[31:0] mem_wd ,        //memory write data
    input wire[3:0] we,              //write enable
    output reg[31:0] mem_rd
    );
    

    reg[31:0] memory[1023:0];
    integer i;
    initial begin
        for(i=0; i<1024; i=i+1) begin
            memory[i] = 32'b0;
        end
    end
    
    always @(posedge clk) begin
        mem_rd <= memory[mem_address >> 2];
        if(we[0]) memory[mem_address >> 2][7:0] <= mem_wd[7:0];
        if(we[1]) memory[mem_address >> 2][15:8] <= mem_wd[15:8];
        if(we[2]) memory[mem_address >> 2][23:16] <= mem_wd[23:16];
        if(we[3]) memory[mem_address >> 2][31:24] <= mem_wd[31:24];
    end
    
endmodule
