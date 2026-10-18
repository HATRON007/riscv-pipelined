`timescale 1ns / 1ps

`ifdef BENCH_BINSEARCH
`define PROG_NAME "bp_binsearch"
`define MEM_FILE  "sw/build/bp_binsearch.mem"
`elsif BENCH_SIEVE
`define PROG_NAME "bp_sieve"
`define MEM_FILE  "sw/build/bp_sieve.mem"
`else
`define PROG_NAME "bp_bubblesort"
`define MEM_FILE  "sw/build/bp_bubblesort.mem"
`endif

// Counts cycles, instructions and branch outcomes for one core.
// The program marks the measured region with stores to magic addresses:
//   0x7FF0 = window (1 = start, 0 = end), 0x7FF4 = signature,
//   0x7FF8 = status (1 = pass), 0x7FFC = done
module bp_monitor(
    input clk,
    input reset,
    input [3:0]  we,
    input [31:0] st_addr,
    input [31:0] st_data,
    input clear,
    input hz_out_X,
    input hz_imul,
    input [31:0] ins,
    input is_jmp,
    input is_br,
    input actual_taken,
    input predict_taken,
    input [31:0] predict_target,
    input [31:0] br_target
);

    reg win = 0, done = 0;
    reg [31:0] sig = 0, status = 0;

    integer cycles = 0, instrs = 0, jmp_flush = 0;
    integer branches = 0, taken = 0, hits = 0;
    integer misses = 0, miss_dir = 0, miss_tgt = 0, miss_ft = 0;

    wire retire = !clear && !hz_out_X && hz_imul && (ins != 32'b0);

    always @(posedge clk) begin
        if (!reset && !done) begin

            // magic-address stores
            if (we == 4'b1111) begin
                case (st_addr)
                    32'h7FF0: win    <= (st_data != 0);
                    32'h7FF4: sig    <= st_data;
                    32'h7FF8: status <= st_data;
                    32'h7FFC: done   <= 1'b1;
                endcase
            end

            // statistics (only inside the window)
            if (win) begin
                cycles = cycles + 1;
                if (retire) instrs = instrs + 1;
                if (is_jmp) jmp_flush = jmp_flush + 1;

                if (is_br && !hz_out_X) begin
                    branches = branches + 1;
                    if (actual_taken) taken = taken + 1;

                    if (actual_taken ^ predict_taken) begin
                        misses = misses + 1;
                        miss_dir = miss_dir + 1;
                    end
                    else if (actual_taken && predict_target != br_target) begin
                        misses = misses + 1;
                        miss_tgt = miss_tgt + 1;
                    end
                    else
                        hits = hits + 1;
                end
                else if (!is_br && predict_taken) begin
                    misses = misses + 1;
                    miss_ft = miss_ft + 1;
                end
            end
        end
    end

endmodule


module tb_bench_bp;

    reg clk = 0;
    reg reset = 1;

    always #5 clk = ~clk;
    initial #25 reset = 0;

    // predictor on
    proc_top core_on(.clk(clk), .reset(reset));
    defparam core_on.datapath_inst.bp_inst.bp_on = 1;
    defparam core_on.datapath_inst.mem_inst_1.INIT_FILE = `MEM_FILE;
    defparam core_on.datapath_inst.mem_inst_2.INIT_FILE = `MEM_FILE;

    // predictor off (always predicts not-taken)
    proc_top core_off(.clk(clk), .reset(reset));
    defparam core_off.datapath_inst.bp_inst.bp_on = 0;
    defparam core_off.datapath_inst.mem_inst_1.INIT_FILE = `MEM_FILE;
    defparam core_off.datapath_inst.mem_inst_2.INIT_FILE = `MEM_FILE;

    bp_monitor mon_on(
        .clk(clk), .reset(reset),
        .we(core_on.datapath_inst.dmemory_stage_inst.we),
        .st_addr(core_on.datapath_inst.dmemory_stage_inst.ex_res_reg_M),
        .st_data(core_on.datapath_inst.dmemory_stage_inst.dstore_sram),
        .clear(core_on.clear),
        .hz_out_X(core_on.hz_out_X_wire),
        .hz_imul(core_on.hz_imul),
        .ins(core_on.ins),
        .is_jmp(core_on.reg_is_jmp_ins_wire),
        .is_br(core_on.regX_is_br_ins),
        .actual_taken(core_on.actual_taken),
        .predict_taken(core_on.predict_taken_X),
        .predict_target(core_on.predict_target_X),
        .br_target(core_on.br_target_X_wire)
    );

    bp_monitor mon_off(
        .clk(clk), .reset(reset),
        .we(core_off.datapath_inst.dmemory_stage_inst.we),
        .st_addr(core_off.datapath_inst.dmemory_stage_inst.ex_res_reg_M),
        .st_data(core_off.datapath_inst.dmemory_stage_inst.dstore_sram),
        .clear(core_off.clear),
        .hz_out_X(core_off.hz_out_X_wire),
        .hz_imul(core_off.hz_imul),
        .ins(core_off.ins),
        .is_jmp(core_off.reg_is_jmp_ins_wire),
        .is_br(core_off.regX_is_br_ins),
        .actual_taken(core_off.actual_taken),
        .predict_taken(core_off.predict_taken_X),
        .predict_target(core_off.predict_target_X),
        .br_target(core_off.br_target_X_wire)
    );

    // timeout
    initial begin
        #20000000;
        $display("[FATAL] tb_bench_bp: Simulation timeout.");
        $finish;
    end

        // report once both cores are done
    initial begin
        wait (mon_on.done && mon_off.done);
        #10;

        $display("\nBenchmark : %0s", `PROG_NAME);
        $display("Signature : 0x%08h", mon_on.sig);
        $display("");
        $display("                      BP_OFF       BP_ON");
        $display("Cycles          %12d%12d", mon_off.cycles,   mon_on.cycles);
        $display("Instructions    %12d%12d", mon_off.instrs,   mon_on.instrs);
        $display("CPI             %12.2f%12.2f",
                 mon_off.cycles * 1.0 / mon_off.instrs, mon_on.cycles * 1.0 / mon_on.instrs);
        $display("Branches        %12d%12d", mon_off.branches, mon_on.branches);
        $display("Taken           %12d%12d", mon_off.taken,    mon_on.taken);
        $display("Mispredicts     %12d%12d", mon_off.misses,   mon_on.misses);
        $display("Accuracy        %11.2f%%%11.2f%%",
                 mon_off.hits * 100.0 / mon_off.branches, mon_on.hits * 100.0 / mon_on.branches);
        if (mon_on.jmp_flush > 0)
            $display("JAL/JALR flushes: %0d (same in both, not predictor related)", mon_on.jmp_flush);
        $display("");
        $display("Speedup   : %0.2f%% (%0d cycles saved)",
                 (mon_off.cycles - mon_on.cycles) * 100.0 / mon_off.cycles,
                 mon_off.cycles - mon_on.cycles);

        // every avoided mispredict should save exactly 2 cycles
        if ((mon_off.cycles - mon_on.cycles) == 2 * (mon_off.misses - mon_on.misses))
            $display("[PASS] cycles saved == 2 * mispredicts avoided");
        else
            $display("[FAIL] cycles saved != 2 * mispredicts avoided");

        if (mon_on.status == 1 && mon_off.status == 1 && mon_on.sig === mon_off.sig)
            $display("[PASS] self-check passed, ON and OFF signatures match\n");
        else
            $display("[FAIL] self-check failed or signatures differ\n");

        $finish;
    end

endmodule