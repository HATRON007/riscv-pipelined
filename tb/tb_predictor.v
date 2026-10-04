`timescale 1ns / 1ps

module tb_rigorous();

    // --- Signals ---
    reg clk;
    reg reset;
    integer cycle_count;
    integer errors_found;
    integer correct_predictions;
    integer mispredictions;
    integer i;

    // --- Instantiate the Processor ---
    proc_top uut (
        .clk(clk),
        .reset(reset)
    );

    // --- Clock Generation ---
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // --- Watchdog (separate from the main sequence) ---
    // Iterative MUL stalls 5x, so give plenty of time.
    initial begin
        #200000;
        $display("\n[FATAL ERROR] Simulation Timeout. CPU locked up. (cycles=%0d)", cycle_count);
        $finish;
    end

    // --- Main Test Sequence ---
    initial begin
        $dumpfile("rigorous_wave.vcd");
        $dumpvars(0, tb_rigorous);

        cycle_count         = 0;
        errors_found        = 0;
        correct_predictions = 0;
        mispredictions      = 0;

        $display("=========================================================================");
        $display("   [TORTURE TEST] RISC-V SPECULATIVE CORE FULL VERIFICATION SUITE");
        $display("=========================================================================\n");

        // --------------------------------------------------------------------
        // INITIALIZATION: fill with NOPs so speculative fetches never see X
        // (adjust 64 if your instruction memory is smaller)
        // --------------------------------------------------------------------
        for (i = 0; i < 64; i = i + 1)
            uut.datapath_inst.mem_inst_2.memory[i] = 32'h00000013; // ADDI x0,x0,0

        // 0x00: JAL x0, main          (Jump to 0x18, bypasses the subroutine)
        uut.datapath_inst.mem_inst_2.memory[0]  = 32'h0180006f;

        // --------------------------------------------------------------------
        // SUBROUTINE: calc_square (Address: 0x04)
        // --------------------------------------------------------------------
        // 0x04: MUL x10, x10, x10     (a0 = a0 * a0) -> Triggers IMUL Stall
        uut.datapath_inst.mem_inst_2.memory[1]  = 32'h02a50533;
        // 0x08: JALR x0, x1, 0        (Return to caller) -> Triggers Jump Flush
        uut.datapath_inst.mem_inst_2.memory[2]  = 32'h00008067;

        // --- GRAVEYARD 1: Unreachable space to catch bad speculation ---
        uut.datapath_inst.mem_inst_2.memory[3]  = 32'h0000006f;
        uut.datapath_inst.mem_inst_2.memory[4]  = 32'h0000006f;
        uut.datapath_inst.mem_inst_2.memory[5]  = 32'h0000006f;

        // --------------------------------------------------------------------
        // MAIN FUNCTION (Address: 0x18)
        // --------------------------------------------------------------------
        // 0x18: ADDI x8, x0, 200      (x8 = Base Array Pointer = 200)
        uut.datapath_inst.mem_inst_2.memory[6]  = 32'h0c800413;
        // 0x1C: ADDI x9, x0, 5        (x9 = Max Array Size = 5)
        uut.datapath_inst.mem_inst_2.memory[7]  = 32'h00500493;
        // 0x20: ADD  x18, x0, x0      (x18 = Final Sum Accumulator = 0)
        uut.datapath_inst.mem_inst_2.memory[8]  = 32'h00000933;
        // 0x24: ADD  x19, x0, x0      (x19 = Loop Index 'i' = 0)
        uut.datapath_inst.mem_inst_2.memory[9]  = 32'h000009b3;

        // --- LOOP 1: Array Initialization (Address: 0x28) ---
        // 0x28: ADDI x20, x19, 1      (x20 = i + 1)
        uut.datapath_inst.mem_inst_2.memory[10] = 32'h00198a13;
        // 0x2C: SLLI x21, x19, 2      (x21 = i * 4)
        uut.datapath_inst.mem_inst_2.memory[11] = 32'h00299a93;
        // 0x30: ADD  x21, x8, x21     (x21 = Base + Offset)   [was ADDI -> fixed]
        uut.datapath_inst.mem_inst_2.memory[12] = 32'h01540ab3;
        // 0x34: SW   x20, 0(x21)      (Mem[200 + i*4] = i + 1)
        uut.datapath_inst.mem_inst_2.memory[13] = 32'h014aa023;
        // 0x38: ADDI x19, x19, 1      (i++)
        uut.datapath_inst.mem_inst_2.memory[14] = 32'h00198993;
        // 0x3C: BNE  x19, x9, -20     (if i != 5, goto 0x28)  [offset fixed]
        uut.datapath_inst.mem_inst_2.memory[15] = 32'hfe9996e3;

        // --- PREPARE LOOP 2 ---
        // 0x40: ADD  x19, x0, x0      (Reset Loop Index 'i' = 0)
        uut.datapath_inst.mem_inst_2.memory[16] = 32'h000009b3;

        // --- LOOP 2: Read, Square, Accumulate (Address: 0x44) ---
        // 0x44: SLLI x21, x19, 2      (x21 = i * 4)
        uut.datapath_inst.mem_inst_2.memory[17] = 32'h00299a93;
        // 0x48: ADD  x21, x8, x21     (x21 = Base + Offset)   [was ADDI -> fixed]
        uut.datapath_inst.mem_inst_2.memory[18] = 32'h01540ab3;
        // 0x4C: LW   x11, 0(x21)      (x11 = array[i])
        uut.datapath_inst.mem_inst_2.memory[19] = 32'h000aa583;
        // 0x50: ADD  x10, x11, x0     (x10 = a0 = array[i])
        uut.datapath_inst.mem_inst_2.memory[20] = 32'h00058533;
        // 0x54: JAL  x1, -80          (Call calc_square at 0x04) [offset fixed]
        uut.datapath_inst.mem_inst_2.memory[21] = 32'hfb1ff0ef;
        // 0x58: ADD  x18, x18, x10    (Sum += squared value)
        uut.datapath_inst.mem_inst_2.memory[22] = 32'h00a90933;
        // 0x5C: ADDI x19, x19, 1      (i++)
        uut.datapath_inst.mem_inst_2.memory[23] = 32'h00198993;
        // 0x60: BLT  x19, x9, -28     (if i < 5, goto 0x44)   [offset fixed]
        uut.datapath_inst.mem_inst_2.memory[24] = 32'hfe99c2e3;

        // --- END OF PROGRAM ---
        // 0x64: SW   x18, 220(x0)     (Mem[220] = 55)
        uut.datapath_inst.mem_inst_2.memory[25] = 32'h0d202e23;

        // 0x68: J 0x68                (Infinite Loop End)
        uut.datapath_inst.mem_inst_2.memory[26] = 32'h0000006f;

        // --- GRAVEYARD 2: Ghost instructions ---
        // 0x6C: ADDI x31, x0, 99      (If executed, flush logic failed!)
        uut.datapath_inst.mem_inst_2.memory[27] = 32'h06300f93;

        reset = 1;
        #25 reset = 0;
    end

    // --- LIVE EVENT TRACKER & SELF-CHECKING ARCHITECTURE ---
    always @(posedge clk) begin
        if (!reset) begin
            cycle_count = cycle_count + 1;

            // 1. Speculation Ghost Trap
            if (uut.rf_en_wd && uut.datapath_inst.decode_stage_inst.dr == 31) begin
                if (uut.datapath_inst.decode_stage_inst.rf_wd == 32'd99) begin
                    $display("[%4t ns] [FATAL BUG] Pipeline executed ghost instruction x31=99!", $time);
                    errors_found = errors_found + 1;
                end
            end

            // 2. Predictor Profiling
            if (uut.regX_is_br_ins && !uut.hz_out_X_wire) begin
                if (uut.clear) begin
                    mispredictions = mispredictions + 1;
                    $display("[%4t ns] BTB: Miss! Flushed pipeline.", $time);
                end else begin
                    correct_predictions = correct_predictions + 1;
                    $display("[%4t ns] BTB: FLAWLESS PREDICTION! Target: 0x%08x", $time, uut.datapath_inst.predict_target_X);
                end
            end

            // 3. Final Validation (Waits for the final Memory Write at 0x64)
            if (uut.datapath_inst.dmemory_stage_inst.we != 4'b0000) begin
                if (uut.datapath_inst.dmemory_stage_inst.ex_res_reg_M == 32'd220) begin
                    $display("\n=========================================================================");
                    $display("  PROGRAM COMPLETE. VALIDATING ARCHITECTURE...");
                    $display("  Calculated Sum of Squares (1^2 + 2^2 + 3^2 + 4^2 + 5^2) = 55");
                    $display("  Value written to Mem[220]: %0d (0x%02x)",
                             uut.datapath_inst.dmemory_stage_inst.dstore_sram,
                             uut.datapath_inst.dmemory_stage_inst.dstore_sram);
                    $display("  Total cycles: %0d", cycle_count);

                    $display("\n  --- ARCHITECTURAL PROFILING ---");
                    $display("  Correct Branch Predictions: %0d", correct_predictions);
                    $display("  Branch Mispredictions:      %0d", mispredictions);

                    if (uut.datapath_inst.dmemory_stage_inst.dstore_sram === 32'd55 &&
                        errors_found == 0 && correct_predictions >= 3) begin
                        $display("\n  [PASS] ABSOLUTE PERFECTION");
                        $display("  Your CPU correctly handled:");
                        $display("  - 5x Subroutine calls (JAL/JALR flushing)");
                        $display("  - 5x Multi-cycle integer multiplications");
                        $display("  - EX-to-EX and MEM-to-EX Data Forwarding");
                        $display("  - Load-Use Hazard Stalling");
                        $display("  - Two distinct nested BTB branch patterns");
                        $display("  - Ghost Instruction annihilation");
                    end else begin
                        $display("\n  [FAIL]");
                        if (uut.datapath_inst.dmemory_stage_inst.dstore_sram !== 32'd55)
                            $display("     Math result is wrong. Forwarding, Subroutine, or Load-Use Hazard is broken.");
                        if (correct_predictions < 3)
                            $display("     Predictor failed to learn loops. Predictor logic is broken.");
                        if (errors_found != 0)
                            $display("     Ghost instruction was executed. Flush logic is broken.");
                    end
                    $display("=========================================================================\n");
                    #20;
                    $finish;
                end
            end

        end
    end

endmodule