`timescale 1ns / 1ps

`ifdef BENCH_MATMUL_W16
`define PROG_NAME "imul_matmul_w16"
`define MEM_FILE  "sw/build/imul_matmul_w16.mem"
`elsif BENCH_MATMUL_W32
`define PROG_NAME "imul_matmul_w32"
`define MEM_FILE  "sw/build/imul_matmul_w32.mem"
`else
`define PROG_NAME "imul_matmul_w8"
`define MEM_FILE  "sw/build/imul_matmul_w8.mem"
`endif

// Counts cycles, instructions and multiplier activity for one core.
// The program marks the measured region with stores to magic addresses:
//   0x7FF0 = window (1 = start, 0 = end), 0x7FF4 = signature,
//   0x7FF8 = status (1 = pass), 0x7FFC = done
module imul_monitor(
    input clk,
    input reset,
    input [3:0]  we,
    input [31:0] st_addr,
    input [31:0] st_data,
    input busy,          // multiplier is stalling the pipeline
    input clear,
    input hz_out_X,
    input hz_imul,
    input [31:0] ins
);

    reg win = 0, done = 0, prev_busy = 0;
    reg [31:0] sig = 0, status = 0;

    integer cycles = 0, instrs = 0, busy_cycles = 0;
    integer muls = 0, cur_lat = 0;
    integer min_lat = 999, max_lat = 0;

    wire retire = !clear && !hz_out_X && hz_imul && (ins != 32'b0);

    always @(posedge clk) begin
        if (!reset && !done) begin
            prev_busy <= busy;

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

                if (busy) begin
                    busy_cycles = busy_cycles + 1;
                    cur_lat = cur_lat + 1;
                end

                // busy just dropped: one multiply finished
                if (prev_busy && !busy) begin
                    muls = muls + 1;
                    if (cur_lat < min_lat) min_lat = cur_lat;
                    if (cur_lat > max_lat) max_lat = cur_lat;
                    cur_lat = 0;
                end
            end
        end
    end

endmodule


module tb_bench_imul;

    reg clk = 0;
    reg reset = 1;

    always #5 clk = ~clk;
    initial #25 reset = 0;

    // optimized multiplier (sparse skip + early exit)
    proc_top core_opt(.clk(clk), .reset(reset));
    defparam core_opt.datapath_inst.execute_stage_inst.imul_inst.ctrl.sparse_on = 1;
    defparam core_opt.datapath_inst.mem_inst_1.INIT_FILE = `MEM_FILE;
    defparam core_opt.datapath_inst.mem_inst_2.INIT_FILE = `MEM_FILE;

    // fixed multiplier (always 32 iterations)
    proc_top core_fixed(.clk(clk), .reset(reset));
    defparam core_fixed.datapath_inst.execute_stage_inst.imul_inst.ctrl.sparse_on = 0;
    defparam core_fixed.datapath_inst.mem_inst_1.INIT_FILE = `MEM_FILE;
    defparam core_fixed.datapath_inst.mem_inst_2.INIT_FILE = `MEM_FILE;

    imul_monitor mon_opt(
        .clk(clk), .reset(reset),
        .we(core_opt.datapath_inst.dmemory_stage_inst.we),
        .st_addr(core_opt.datapath_inst.dmemory_stage_inst.ex_res_reg_M),
        .st_data(core_opt.datapath_inst.dmemory_stage_inst.dstore_sram),
        .busy(core_opt.datapath_inst.execute_stage_inst.in_imul_computation),
        .clear(core_opt.clear),
        .hz_out_X(core_opt.hz_out_X_wire),
        .hz_imul(core_opt.hz_imul),
        .ins(core_opt.ins)
    );

    imul_monitor mon_fixed(
        .clk(clk), .reset(reset),
        .we(core_fixed.datapath_inst.dmemory_stage_inst.we),
        .st_addr(core_fixed.datapath_inst.dmemory_stage_inst.ex_res_reg_M),
        .st_data(core_fixed.datapath_inst.dmemory_stage_inst.dstore_sram),
        .busy(core_fixed.datapath_inst.execute_stage_inst.in_imul_computation),
        .clear(core_fixed.clear),
        .hz_out_X(core_fixed.hz_out_X_wire),
        .hz_imul(core_fixed.hz_imul),
        .ins(core_fixed.ins)
    );

    // timeout
    initial begin
        #30000000;
        $display("[FATAL] tb_bench_imul: Simulation timeout.");
        $finish;
    end

    // report once both cores are done
    initial begin
        wait (mon_opt.done && mon_fixed.done);
        #10;

        $display("\nBenchmark : %0s", `PROG_NAME);
        $display("Signature : 0x%08h", mon_opt.sig);
        $display("");
        $display("                %12s%12s", "FIXED", "OPT");
        $display("Cycles          %12d%12d", mon_fixed.cycles,      mon_opt.cycles);
        $display("Instructions    %12d%12d", mon_fixed.instrs,      mon_opt.instrs);
        $display("CPI             %12.2f%12.2f",
                 mon_fixed.cycles * 1.0 / mon_fixed.instrs, mon_opt.cycles * 1.0 / mon_opt.instrs);
        $display("MUL count       %12d%12d", mon_fixed.muls,        mon_opt.muls);
        $display("MUL busy cycles %12d%12d", mon_fixed.busy_cycles, mon_opt.busy_cycles);
        $display("MUL share       %11.1f%%%11.1f%%",
                 mon_fixed.busy_cycles * 100.0 / mon_fixed.cycles,
                 mon_opt.busy_cycles   * 100.0 / mon_opt.cycles);
        $display("Cycles per MUL  %12.2f%12.2f",
                 mon_fixed.busy_cycles * 1.0 / mon_fixed.muls,
                 mon_opt.busy_cycles   * 1.0 / mon_opt.muls);
        $display("Min latency     %12d%12d", mon_fixed.min_lat,     mon_opt.min_lat);
        $display("Max latency     %12d%12d", mon_fixed.max_lat,     mon_opt.max_lat);
        $display("Non-MUL cycles  %12d%12d",
                 mon_fixed.cycles - mon_fixed.busy_cycles,
                 mon_opt.cycles   - mon_opt.busy_cycles);
        $display("");
        $display("Speedup   : %0.2fx (%0d cycles saved)",
                 mon_fixed.cycles * 1.0 / mon_opt.cycles,
                 mon_fixed.cycles - mon_opt.cycles);

        // FIXED must take the same time for every multiply
        if (mon_fixed.min_lat == mon_fixed.max_lat)
            $display("[PASS] FIXED latency is constant");
        else
            $display("[FAIL] FIXED latency varies");

        // only the multiplier should differ between the two cores
        if (mon_fixed.cycles - mon_fixed.busy_cycles == mon_opt.cycles - mon_opt.busy_cycles)
            $display("[PASS] non-MUL cycles match");
        else
            $display("[FAIL] non-MUL cycles differ");

        if (mon_opt.status == 1 && mon_fixed.status == 1 && mon_opt.sig === mon_fixed.sig)
            $display("[PASS] self-check passed, FIXED and OPT signatures match\n");
        else
            $display("[FAIL] self-check failed or signatures differ\n");

        $finish;
    end

endmodule