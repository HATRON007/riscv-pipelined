`timescale 1ns / 1ps

module jump_tb();

    reg clk;
    reg reset;

    proc_top uut (
        .clk(clk),
        .reset(reset)
    );

    defparam uut.datapath_inst.mem_inst_2.INIT_FILE = "";

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    integer i;
    initial begin
        #1;
        for (i = 0; i < 1024; i = i + 1) begin
            uut.datapath_inst.mem_inst_2.memory[i] = 32'h00000013;
        end

        uut.datapath_inst.mem_inst_2.memory[0] = 32'h00000a13; // addi x20, x0, 0
        uut.datapath_inst.mem_inst_2.memory[1] = 32'h00500093; // addi x1, x0, 5
        uut.datapath_inst.mem_inst_2.memory[2] = 32'hffd00113; // addi x2, x0, -3
        uut.datapath_inst.mem_inst_2.memory[3] = 32'h00500193; // addi x3, x0, 5
        uut.datapath_inst.mem_inst_2.memory[4] = 32'h00100513; // addi x10, x0, 1
        uut.datapath_inst.mem_inst_2.memory[5] = 32'h00308463; // beq x1, x3, 8
        uut.datapath_inst.mem_inst_2.memory[6] = 32'h00200513; // addi x10, x0, 2
        uut.datapath_inst.mem_inst_2.memory[7] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[8] = 32'h00100513; // addi x10, x0, 1
        uut.datapath_inst.mem_inst_2.memory[9] = 32'h00208463; // beq x1, x2, 8
        uut.datapath_inst.mem_inst_2.memory[10] = 32'h00200513; // addi x10, x0, 2
        uut.datapath_inst.mem_inst_2.memory[11] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[12] = 32'h00100513; // addi x10, x0, 1
        uut.datapath_inst.mem_inst_2.memory[13] = 32'h00209463; // bne x1, x2, 8
        uut.datapath_inst.mem_inst_2.memory[14] = 32'h00200513; // addi x10, x0, 2
        uut.datapath_inst.mem_inst_2.memory[15] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[16] = 32'h00100513; // addi x10, x0, 1
        uut.datapath_inst.mem_inst_2.memory[17] = 32'h00309463; // bne x1, x3, 8
        uut.datapath_inst.mem_inst_2.memory[18] = 32'h00200513; // addi x10, x0, 2
        uut.datapath_inst.mem_inst_2.memory[19] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[20] = 32'h00100513; // addi x10, x0, 1
        uut.datapath_inst.mem_inst_2.memory[21] = 32'h00114463; // blt x2, x1, 8
        uut.datapath_inst.mem_inst_2.memory[22] = 32'h00200513; // addi x10, x0, 2
        uut.datapath_inst.mem_inst_2.memory[23] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[24] = 32'h00100513; // addi x10, x0, 1
        uut.datapath_inst.mem_inst_2.memory[25] = 32'h0020c463; // blt x1, x2, 8
        uut.datapath_inst.mem_inst_2.memory[26] = 32'h00200513; // addi x10, x0, 2
        uut.datapath_inst.mem_inst_2.memory[27] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[28] = 32'h00100513; // addi x10, x0, 1
        uut.datapath_inst.mem_inst_2.memory[29] = 32'h0020d463; // bge x1, x2, 8
        uut.datapath_inst.mem_inst_2.memory[30] = 32'h00200513; // addi x10, x0, 2
        uut.datapath_inst.mem_inst_2.memory[31] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[32] = 32'h00100513; // addi x10, x0, 1
        uut.datapath_inst.mem_inst_2.memory[33] = 32'h00115463; // bge x2, x1, 8
        uut.datapath_inst.mem_inst_2.memory[34] = 32'h00200513; // addi x10, x0, 2
        uut.datapath_inst.mem_inst_2.memory[35] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[36] = 32'h00100513; // addi x10, x0, 1
        uut.datapath_inst.mem_inst_2.memory[37] = 32'h0030d463; // bge x1, x3, 8
        uut.datapath_inst.mem_inst_2.memory[38] = 32'h00200513; // addi x10, x0, 2
        uut.datapath_inst.mem_inst_2.memory[39] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[40] = 32'h00100513; // addi x10, x0, 1
        uut.datapath_inst.mem_inst_2.memory[41] = 32'h0020e463; // bltu x1, x2, 8
        uut.datapath_inst.mem_inst_2.memory[42] = 32'h00200513; // addi x10, x0, 2
        uut.datapath_inst.mem_inst_2.memory[43] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[44] = 32'h00100513; // addi x10, x0, 1
        uut.datapath_inst.mem_inst_2.memory[45] = 32'h00116463; // bltu x2, x1, 8
        uut.datapath_inst.mem_inst_2.memory[46] = 32'h00200513; // addi x10, x0, 2
        uut.datapath_inst.mem_inst_2.memory[47] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[48] = 32'h00100513; // addi x10, x0, 1
        uut.datapath_inst.mem_inst_2.memory[49] = 32'h00117463; // bgeu x2, x1, 8
        uut.datapath_inst.mem_inst_2.memory[50] = 32'h00200513; // addi x10, x0, 2
        uut.datapath_inst.mem_inst_2.memory[51] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[52] = 32'h00100513; // addi x10, x0, 1
        uut.datapath_inst.mem_inst_2.memory[53] = 32'h0020f463; // bgeu x1, x2, 8
        uut.datapath_inst.mem_inst_2.memory[54] = 32'h00200513; // addi x10, x0, 2
        uut.datapath_inst.mem_inst_2.memory[55] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[56] = 32'h00100513; // addi x10, x0, 1
        uut.datapath_inst.mem_inst_2.memory[57] = 32'h0030f463; // bgeu x1, x3, 8
        uut.datapath_inst.mem_inst_2.memory[58] = 32'h00200513; // addi x10, x0, 2
        uut.datapath_inst.mem_inst_2.memory[59] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[60] = 32'h00000613; // addi x12, x0, 0
        uut.datapath_inst.mem_inst_2.memory[61] = 32'h00300593; // addi x11, x0, 3
        uut.datapath_inst.mem_inst_2.memory[62] = 32'h00260613; // addi x12, x12, 2
        uut.datapath_inst.mem_inst_2.memory[63] = 32'hfff58593; // addi x11, x11, -1
        uut.datapath_inst.mem_inst_2.memory[64] = 32'hfe059ce3; // bne x11, x0, -8
        uut.datapath_inst.mem_inst_2.memory[65] = 32'h00ca0a33; // add x20, x20, x12
        uut.datapath_inst.mem_inst_2.memory[66] = 32'h00ba0a33; // add x20, x20, x11
        uut.datapath_inst.mem_inst_2.memory[67] = 32'h00000513; // addi x10, x0, 0
        uut.datapath_inst.mem_inst_2.memory[68] = 32'h00c002ef; // jal x5, 12
        uut.datapath_inst.mem_inst_2.memory[69] = 32'h00150513; // addi x10, x10, 1
        uut.datapath_inst.mem_inst_2.memory[70] = 32'h00250513; // addi x10, x10, 2
        uut.datapath_inst.mem_inst_2.memory[71] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[72] = 32'h005a0a33; // add x20, x20, x5
        uut.datapath_inst.mem_inst_2.memory[73] = 32'h00000513; // addi x10, x0, 0
        uut.datapath_inst.mem_inst_2.memory[74] = 32'h00c0006f; // jal x0, 12
        uut.datapath_inst.mem_inst_2.memory[75] = 32'h00150513; // addi x10, x10, 1
        uut.datapath_inst.mem_inst_2.memory[76] = 32'h00250513; // addi x10, x10, 2
        uut.datapath_inst.mem_inst_2.memory[77] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[78] = 32'h000a0a33; // add x20, x20, x0
        uut.datapath_inst.mem_inst_2.memory[79] = 32'h00000513; // addi x10, x0, 0
        uut.datapath_inst.mem_inst_2.memory[80] = 32'h00000317; // auipc x6, 0x0
        uut.datapath_inst.mem_inst_2.memory[81] = 32'h010303e7; // jalr x7, 16(x6)
        uut.datapath_inst.mem_inst_2.memory[82] = 32'h00150513; // addi x10, x10, 1
        uut.datapath_inst.mem_inst_2.memory[83] = 32'h00250513; // addi x10, x10, 2
        uut.datapath_inst.mem_inst_2.memory[84] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[85] = 32'h007a0a33; // add x20, x20, x7
        uut.datapath_inst.mem_inst_2.memory[86] = 32'h00000513; // addi x10, x0, 0
        uut.datapath_inst.mem_inst_2.memory[87] = 32'h00000317; // auipc x6, 0x0
        uut.datapath_inst.mem_inst_2.memory[88] = 32'h011303e7; // jalr x7, 17(x6)
        uut.datapath_inst.mem_inst_2.memory[89] = 32'h00150513; // addi x10, x10, 1
        uut.datapath_inst.mem_inst_2.memory[90] = 32'h00250513; // addi x10, x10, 2
        uut.datapath_inst.mem_inst_2.memory[91] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[92] = 32'h007a0a33; // add x20, x20, x7
        uut.datapath_inst.mem_inst_2.memory[93] = 32'h7d402823; // sw x20, 2000(x0)

        reset = 1;
        #25 reset = 0;

        #20000;
        $display("[FATAL] jump_tb: Simulation timeout.");
        $finish;
    end

    always @(posedge clk) begin
        if (uut.datapath_inst.dmemory_stage_inst.we != 4'b0000) begin
            if (uut.datapath_inst.dmemory_stage_inst.ex_res_reg_M == 32'h7d0) begin
                if (uut.datapath_inst.dmemory_stage_inst.dstore_sram === 32'h000003da) begin
                    $display("[PASS] jump_tb: final checksum matches expected value.");
                end else begin
                    $display("[FAIL] jump_tb: Expected 000003da, got %h", uut.datapath_inst.dmemory_stage_inst.dstore_sram);
                end
                $finish;
            end
        end
    end

endmodule