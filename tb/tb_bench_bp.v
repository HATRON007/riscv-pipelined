`timescale 1ns / 1ps

`ifdef BENCH_BINSEARCH
`define MEM_FILE "sw/build/bp_binsearch.mem"
`elsif BENCH_SIEVE
`define MEM_FILE "sw/build/bp_sieve.mem"
`else
`define MEM_FILE "sw/build/bp_bubblesort.mem"
`endif

module tb_bench_bp();

    reg clk;
    reg reset;

    proc_top core_on (
        .clk(clk),
        .reset(reset)
    );
    defparam core_on.datapath_inst.bp_inst.bp_on = 1;
    defparam core_on.datapath_inst.mem_inst_1.INIT_FILE = `MEM_FILE;
    defparam core_on.datapath_inst.mem_inst_2.INIT_FILE = `MEM_FILE;

    proc_top core_off (
        .clk(clk),
        .reset(reset)
    );
    defparam core_off.datapath_inst.bp_inst.bp_on = 0;
    defparam core_off.datapath_inst.mem_inst_1.INIT_FILE = `MEM_FILE;
    defparam core_off.datapath_inst.mem_inst_2.INIT_FILE = `MEM_FILE;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        #25 reset = 0;

        #20000000;
        $display("[FATAL] tb_bench_bp: Simulation timeout.");
        $finish;
    end

    integer cycles_on = 0, cycles_off = 0;
    integer br_on = 0, hits_on = 0, misses_on = 0;
    integer br_off = 0, hits_off = 0, misses_off = 0;

    reg win_on = 0, win_off = 0;
    reg done_on = 0, done_off = 0;
    reg [31:0] sig_on = 0, sig_off = 0;
    reg [31:0] status_on = 0, status_off = 0;

    always @(posedge clk) begin
        if (!reset) begin
            if (!done_on) begin
                if (core_on.datapath_inst.dmemory_stage_inst.we == 4'b1111) begin
                    case (core_on.datapath_inst.dmemory_stage_inst.ex_res_reg_M)
                        32'h7FF0: win_on    <= (core_on.datapath_inst.dmemory_stage_inst.dstore_sram != 0);
                        32'h7FF4: sig_on    <= core_on.datapath_inst.dmemory_stage_inst.dstore_sram;
                        32'h7FF8: status_on <= core_on.datapath_inst.dmemory_stage_inst.dstore_sram;
                        32'h7FFC: done_on   <= 1'b1;
                    endcase
                end

                if (win_on) begin
                    cycles_on = cycles_on + 1;
                    if (core_on.regX_is_br_ins && !core_on.hz_out_X_wire) begin
                        br_on = br_on + 1;
                        if (core_on.clear)
                            misses_on = misses_on + 1;
                        else
                            hits_on = hits_on + 1;
                    end
                end
            end

            if (!done_off) begin
                if (core_off.datapath_inst.dmemory_stage_inst.we == 4'b1111) begin
                    case (core_off.datapath_inst.dmemory_stage_inst.ex_res_reg_M)
                        32'h7FF0: win_off    <= (core_off.datapath_inst.dmemory_stage_inst.dstore_sram != 0);
                        32'h7FF4: sig_off    <= core_off.datapath_inst.dmemory_stage_inst.dstore_sram;
                        32'h7FF8: status_off <= core_off.datapath_inst.dmemory_stage_inst.dstore_sram;
                        32'h7FFC: done_off   <= 1'b1;
                    endcase
                end

                if (win_off) begin
                    cycles_off = cycles_off + 1;
                    if (core_off.regX_is_br_ins && !core_off.hz_out_X_wire) begin
                        br_off = br_off + 1;
                        if (core_off.clear)
                            misses_off = misses_off + 1;
                        else
                            hits_off = hits_off + 1;
                    end
                end
            end

            if (done_on && done_off) begin
                $display("\nBenchmark : %s", `MEM_FILE);
                $display("Signature : BP_ON = %0d (status=%0d) | BP_OFF = %0d (status=%0d)",
                         $signed(sig_on), status_on, $signed(sig_off), status_off);
                $display("BP_OFF    : %0d cycles | Branches: %0d | Hits: %0d | Misses: %0d | Acc: %0.2f%%",
                         cycles_off, br_off, hits_off, misses_off, (hits_off * 100.0) / br_off);
                $display("BP_ON     : %0d cycles | Branches: %0d | Hits: %0d | Misses: %0d | Acc: %0.2f%%",
                         cycles_on, br_on, hits_on, misses_on, (hits_on * 100.0) / br_on);
                $display("Saved     : %0d cycles (%0.2f%% speedup)",
                         cycles_off - cycles_on, ((cycles_off - cycles_on) * 100.0) / cycles_off);

                if (status_on == 1 && status_off == 1 && sig_on === sig_off)
                    $display("[PASS] Functional self-check verified.\n");
                else
                    $display("[FAIL] Signature mismatch or self-check failure.\n");

                $finish;
            end
        end
    end

endmodule