`timescale 1ns / 1ps

module lsu_tb();

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
        uut.datapath_inst.mem_inst_2.memory[1] = 32'h40000093; // addi x1, x0, 1024
        uut.datapath_inst.mem_inst_2.memory[2] = 32'h81b2c137; // lui x2, 0x81b2c
        uut.datapath_inst.mem_inst_2.memory[3] = 32'h3d410113; // addi x2, x2, 980
        uut.datapath_inst.mem_inst_2.memory[4] = 32'h0020a023; // sw x2, 0(x1)
        uut.datapath_inst.mem_inst_2.memory[5] = 32'h0000a503; // lw x10, 0(x1)
        uut.datapath_inst.mem_inst_2.memory[6] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[7] = 32'h00009503; // lh x10, 0(x1)
        uut.datapath_inst.mem_inst_2.memory[8] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[9] = 32'h00209503; // lh x10, 2(x1)
        uut.datapath_inst.mem_inst_2.memory[10] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[11] = 32'h0000d503; // lhu x10, 0(x1)
        uut.datapath_inst.mem_inst_2.memory[12] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[13] = 32'h0020d503; // lhu x10, 2(x1)
        uut.datapath_inst.mem_inst_2.memory[14] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[15] = 32'h00008503; // lb x10, 0(x1)
        uut.datapath_inst.mem_inst_2.memory[16] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[17] = 32'h00108503; // lb x10, 1(x1)
        uut.datapath_inst.mem_inst_2.memory[18] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[19] = 32'h00208503; // lb x10, 2(x1)
        uut.datapath_inst.mem_inst_2.memory[20] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[21] = 32'h00308503; // lb x10, 3(x1)
        uut.datapath_inst.mem_inst_2.memory[22] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[23] = 32'h0000c503; // lbu x10, 0(x1)
        uut.datapath_inst.mem_inst_2.memory[24] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[25] = 32'h0010c503; // lbu x10, 1(x1)
        uut.datapath_inst.mem_inst_2.memory[26] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[27] = 32'h0020c503; // lbu x10, 2(x1)
        uut.datapath_inst.mem_inst_2.memory[28] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[29] = 32'h0030c503; // lbu x10, 3(x1)
        uut.datapath_inst.mem_inst_2.memory[30] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[31] = 32'h0000a223; // sw x0, 4(x1)
        uut.datapath_inst.mem_inst_2.memory[32] = 32'h002082a3; // sb x2, 5(x1)
        uut.datapath_inst.mem_inst_2.memory[33] = 32'h0040a503; // lw x10, 4(x1)
        uut.datapath_inst.mem_inst_2.memory[34] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[35] = 32'h00209323; // sh x2, 6(x1)
        uut.datapath_inst.mem_inst_2.memory[36] = 32'h0040a503; // lw x10, 4(x1)
        uut.datapath_inst.mem_inst_2.memory[37] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[38] = 32'h00208223; // sb x2, 4(x1)
        uut.datapath_inst.mem_inst_2.memory[39] = 32'h0040a503; // lw x10, 4(x1)
        uut.datapath_inst.mem_inst_2.memory[40] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[41] = 32'h002083a3; // sb x2, 7(x1)
        uut.datapath_inst.mem_inst_2.memory[42] = 32'h0040a503; // lw x10, 4(x1)
        uut.datapath_inst.mem_inst_2.memory[43] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[44] = 32'h00209223; // sh x2, 4(x1)
        uut.datapath_inst.mem_inst_2.memory[45] = 32'h0040a503; // lw x10, 4(x1)
        uut.datapath_inst.mem_inst_2.memory[46] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[47] = 32'h01008193; // addi x3, x1, 16
        uut.datapath_inst.mem_inst_2.memory[48] = 32'hfe21ac23; // sw x2, -8(x3)
        uut.datapath_inst.mem_inst_2.memory[49] = 32'hff81a503; // lw x10, -8(x3)
        uut.datapath_inst.mem_inst_2.memory[50] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[51] = 32'h0080a503; // lw x10, 8(x1)
        uut.datapath_inst.mem_inst_2.memory[52] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[53] = 32'hffb18503; // lb x10, -5(x3)
        uut.datapath_inst.mem_inst_2.memory[54] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[55] = 32'h7d402823; // sw x20, 2000(x0)

        reset = 1;
        #25 reset = 0;

        #20000;
        $display("[FATAL] lsu_tb: Simulation timeout.");
        $finish;
    end

    always @(posedge clk) begin
        if (uut.datapath_inst.dmemory_stage_inst.we != 4'b0000) begin
            if (uut.datapath_inst.dmemory_stage_inst.ex_res_reg_M == 32'h7d0) begin
                if (uut.datapath_inst.dmemory_stage_inst.dstore_sram === 32'hb66ced19) begin
                    $display("[PASS] lsu_tb: final checksum matches expected value.");
                end else begin
                    $display("[FAIL] lsu_tb: Expected b66ced19, got %h", uut.datapath_inst.dmemory_stage_inst.dstore_sram);
                end
                $finish;
            end
        end
    end

endmodule