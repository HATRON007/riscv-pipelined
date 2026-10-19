`timescale 1ns / 1ps

module itype_tb();

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
        uut.datapath_inst.mem_inst_2.memory[1] = 32'hff000093; // addi x1, x0, -16
        uut.datapath_inst.mem_inst_2.memory[2] = 32'h06408513; // addi x10, x1, 100
        uut.datapath_inst.mem_inst_2.memory[3] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[4] = 32'h80008513; // addi x10, x1, -2048
        uut.datapath_inst.mem_inst_2.memory[5] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[6] = 32'h0000a513; // slti x10, x1, 0
        uut.datapath_inst.mem_inst_2.memory[7] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[8] = 32'hfef0a513; // slti x10, x1, -17
        uut.datapath_inst.mem_inst_2.memory[9] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[10] = 32'hfff0b513; // sltiu x10, x1, -1
        uut.datapath_inst.mem_inst_2.memory[11] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[12] = 32'h0050b513; // sltiu x10, x1, 5
        uut.datapath_inst.mem_inst_2.memory[13] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[14] = 32'h0ff0c513; // xori x10, x1, 255
        uut.datapath_inst.mem_inst_2.memory[15] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[16] = 32'hfff0c513; // xori x10, x1, -1
        uut.datapath_inst.mem_inst_2.memory[17] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[18] = 32'h00f0e513; // ori x10, x1, 15
        uut.datapath_inst.mem_inst_2.memory[19] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[20] = 32'h03c0f513; // andi x10, x1, 60
        uut.datapath_inst.mem_inst_2.memory[21] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[22] = 32'hfff0f513; // andi x10, x1, -1
        uut.datapath_inst.mem_inst_2.memory[23] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[24] = 32'h00409513; // slli x10, x1, 4
        uut.datapath_inst.mem_inst_2.memory[25] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[26] = 32'h01f09513; // slli x10, x1, 31
        uut.datapath_inst.mem_inst_2.memory[27] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[28] = 32'h0040d513; // srli x10, x1, 4
        uut.datapath_inst.mem_inst_2.memory[29] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[30] = 32'h01f0d513; // srli x10, x1, 31
        uut.datapath_inst.mem_inst_2.memory[31] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[32] = 32'h4040d513; // srai x10, x1, 4
        uut.datapath_inst.mem_inst_2.memory[33] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[34] = 32'h41f0d513; // srai x10, x1, 31
        uut.datapath_inst.mem_inst_2.memory[35] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[36] = 32'h12345537; // lui x10, 0x12345
        uut.datapath_inst.mem_inst_2.memory[37] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[38] = 32'hfffff537; // lui x10, 0xfffff
        uut.datapath_inst.mem_inst_2.memory[39] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[40] = 32'h00001517; // auipc x10, 0x1
        uut.datapath_inst.mem_inst_2.memory[41] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[42] = 32'h00000517; // auipc x10, 0x0
        uut.datapath_inst.mem_inst_2.memory[43] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[44] = 32'h7d402823; // sw x20, 2000(x0)

        reset = 1;
        #25 reset = 0;

        #20000;
        $display("[FATAL] itype_tb: Simulation timeout.");
        $finish;
    end

    always @(posedge clk) begin
        if (uut.datapath_inst.dmemory_stage_inst.we != 4'b0000) begin
            if (uut.datapath_inst.dmemory_stage_inst.ex_res_reg_M == 32'h7d0) begin
                if (uut.datapath_inst.dmemory_stage_inst.dstore_sram === 32'h223447c9) begin
                    $display("[PASS] itype_tb: final checksum matches expected value.");
                end else begin
                    $display("[FAIL] itype_tb: Expected 223447c9, got %h", uut.datapath_inst.dmemory_stage_inst.dstore_sram);
                end
                $finish;
            end
        end
    end

endmodule