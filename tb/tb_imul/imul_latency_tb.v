`timescale 1ns / 1ps

module imul_latency_tb();

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

        uut.datapath_inst.mem_inst_2.memory[0] = 32'h00200093; // addi x1, x0, 2
        uut.datapath_inst.mem_inst_2.memory[1] = 32'h00400113; // addi x2, x0, 4 (Sparse)
        uut.datapath_inst.mem_inst_2.memory[2] = 32'h0ffff1b7; // lui x3, 0x0FFFF (Dense positive: 0x0FFFF000)

        uut.datapath_inst.mem_inst_2.memory[3] = 32'h02208233; // mul x4, x1, x2 (2 * 4 = 8)
        uut.datapath_inst.mem_inst_2.memory[4] = 32'h00000013; // nop (Isolates cycle count tracking)
        uut.datapath_inst.mem_inst_2.memory[5] = 32'h023082b3; // mul x5, x1, x3 (2 * 0x0FFFF000 = 0x1FFFE000)

        uut.datapath_inst.mem_inst_2.memory[6] = 32'h00520333; // add x6, x4, x5 (8 + 0x1FFFE000 = 0x1FFFE008)
        uut.datapath_inst.mem_inst_2.memory[7] = 32'h7c602823; // sw x6, 2000(x0)

        reset = 1;
        #25 reset = 0;

        #5000;
        $display("[FATAL] imul_latency_tb: Simulation timeout.");
        $finish;
    end

    integer mul_count = 0;
    integer sparse_cycles = 0;
    integer dense_cycles = 0;
    reg prev_imul_state = 0;

    always @(posedge clk) begin
        if (!reset) begin
            prev_imul_state <= uut.datapath_inst.execute_stage_inst.in_imul_computation;
            
            if (uut.datapath_inst.execute_stage_inst.in_imul_computation) begin
                if (mul_count == 0) sparse_cycles = sparse_cycles + 1;
                if (mul_count == 1) dense_cycles = dense_cycles + 1;
            end
            
            if (prev_imul_state == 1 && uut.datapath_inst.execute_stage_inst.in_imul_computation == 0) begin
                mul_count = mul_count + 1;
            end
        end
    end

    always @(posedge clk) begin
        if (uut.datapath_inst.dmemory_stage_inst.we != 4'b0000) begin
            if (uut.datapath_inst.dmemory_stage_inst.ex_res_reg_M == 32'h7d0) begin
                if (uut.datapath_inst.dmemory_stage_inst.dstore_sram === 32'h1FFFE008) begin
                    if (dense_cycles > sparse_cycles) begin
                        $display("[PASS] imul_latency_tb: Sparse counter verified. Sparse: %0d cycles. Dense: %0d cycles.", sparse_cycles, dense_cycles);
                    end else begin
                        $display("[FAIL] imul_latency_tb: Dense cycle count did not exceed sparse cycle count. Sparse: %0d, Dense: %0d", sparse_cycles, dense_cycles);
                    end
                end else begin
                    $display("[FAIL] imul_latency_tb: Expected signature 0x1FFFE008, got 0x%h.", uut.datapath_inst.dmemory_stage_inst.dstore_sram);
                end
                $finish;
            end
        end
    end

endmodule