`timescale 1ns / 1ps

module rtype_tb();

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
        uut.datapath_inst.mem_inst_2.memory[2] = 32'h00300113; // addi x2, x0, 3
        uut.datapath_inst.mem_inst_2.memory[3] = 32'h00208533; // add x10, x1, x2
        uut.datapath_inst.mem_inst_2.memory[4] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[5] = 32'h40208533; // sub x10, x1, x2
        uut.datapath_inst.mem_inst_2.memory[6] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[7] = 32'h00209533; // sll x10, x1, x2
        uut.datapath_inst.mem_inst_2.memory[8] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[9] = 32'h0020a533; // slt x10, x1, x2
        uut.datapath_inst.mem_inst_2.memory[10] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[11] = 32'h0020b533; // sltu x10, x1, x2
        uut.datapath_inst.mem_inst_2.memory[12] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[13] = 32'h0020c533; // xor x10, x1, x2
        uut.datapath_inst.mem_inst_2.memory[14] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[15] = 32'h0020d533; // srl x10, x1, x2
        uut.datapath_inst.mem_inst_2.memory[16] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[17] = 32'h4020d533; // sra x10, x1, x2
        uut.datapath_inst.mem_inst_2.memory[18] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[19] = 32'h0020e533; // or x10, x1, x2
        uut.datapath_inst.mem_inst_2.memory[20] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[21] = 32'h0020f533; // and x10, x1, x2
        uut.datapath_inst.mem_inst_2.memory[22] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[23] = 32'h00112533; // slt x10, x2, x1
        uut.datapath_inst.mem_inst_2.memory[24] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[25] = 32'h00113533; // sltu x10, x2, x1
        uut.datapath_inst.mem_inst_2.memory[26] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[27] = 32'h02208533; // mul x10, x1, x2
        uut.datapath_inst.mem_inst_2.memory[28] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[29] = 32'h40110533; // sub x10, x2, x1
        uut.datapath_inst.mem_inst_2.memory[30] = 32'h00aa0a33; // add x20, x20, x10
        uut.datapath_inst.mem_inst_2.memory[31] = 32'h7d402823; // sw x20, 2000(x0)

        reset = 1;
        #25 reset = 0;

        #20000;
        $display("[FATAL] rtype_tb: Simulation timeout.");
        $finish;
    end

    always @(posedge clk) begin
        if (uut.datapath_inst.dmemory_stage_inst.we != 4'b0000) begin
            if (uut.datapath_inst.dmemory_stage_inst.ex_res_reg_M == 32'h7d0) begin
                if (uut.datapath_inst.dmemory_stage_inst.dstore_sram === 32'h1fffff27) begin
                    $display("[PASS] rtype_tb: final checksum matches expected value.");
                end else begin
                    $display("[FAIL] rtype_tb: Expected 1fffff27, got %h", uut.datapath_inst.dmemory_stage_inst.dstore_sram);
                end
                $finish;
            end
        end
    end

endmodule