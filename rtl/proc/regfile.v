`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 06:04:39
// Design Name: 
// Module Name: regfile
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


module regfile(
    input clk,
    input wire[4:0] sr0,      //sr - source register address
    input wire[4:0] sr1,
    input wire[4:0] dr,       //dr - destination register address
    input wire rf_enable_wd,
    input wire[31:0] rf_wd,   //wd - write data
    output wire[31:0] rf_rd0, //rf - read data
    output wire[31:0] rf_rd1
    );
    
    
    reg[31:0] register_file[31:0];
 
    always @(posedge clk) begin
        if(rf_enable_wd & |dr) register_file[dr] <= rf_wd;
    end
    assign rf_rd0 = (sr0 == 0)? 0 : ((rf_enable_wd && (dr == sr0))? rf_wd : register_file[sr0]);
    assign rf_rd1 = (sr1 == 0)? 0 : ((rf_enable_wd && (dr == sr1))? rf_wd : register_file[sr1]);
    
endmodule








