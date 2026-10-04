`timescale 1ns / 1ps

module tb_ultimate();

    // --- Signals ---
    reg clk;
    reg reset;
    integer cycle_count;
    integer errors_found;

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

    // --- Main Test Sequence ---
    initial begin
        $dumpfile("ultimate_wave.vcd");
        $dumpvars(0, tb_ultimate);
        
        cycle_count = 0;
        errors_found = 0;

        $display("=========================================================================");
        $display("   [ULTIMATE TEST] RISC-V PIPELINE ARCHITECTURE VERIFICATION SUITE");
        $display("=========================================================================\n");

        // --------------------------------------------------------------------
        // LOAD EXTREME EDGE-CASE INSTRUCTIONS DIRECTLY INTO BRAM
        // --------------------------------------------------------------------
        
        // 0x00: ADDI x1, x0, 1        (x1 = 1)
        uut.datapath_inst.mem_inst_2.memory[0] = 32'h00100093; 
        
        // 0x04: ADD  x2, x1, x1       (x2 = 2) -> EX-to-EX Data Forwarding
        uut.datapath_inst.mem_inst_2.memory[1] = 32'h00108133; 
        
        // 0x08: ADD  x3, x2, x1       (x3 = 3) -> EX-to-EX (x2) & MEM-to-EX (x1)
        uut.datapath_inst.mem_inst_2.memory[2] = 32'h001101b3; 
        
        // 0x0C: SLLI x4, x3, 2        (x4 = 12) -> Logical Shift 
        uut.datapath_inst.mem_inst_2.memory[3] = 32'h00219213; 
        
        // 0x10: MUL  x5, x3, x4       (x5 = 36) -> Multi-Cycle IMUL Stall test!
        uut.datapath_inst.mem_inst_2.memory[4] = 32'h024182b3; 
        
        // 0x14: BEQ  x5, x4, fail     (36 != 12) -> Branch NOT taken
        uut.datapath_inst.mem_inst_2.memory[5] = 32'h00428c63; 
        
        // 0x18: BNE  x5, x4, jump1    (36 != 12) -> Branch TAKEN to 0x20
        uut.datapath_inst.mem_inst_2.memory[6] = 32'h00429463; 
        
        // 0x1C: ADDI x6, x0, 99       (Ghost Instruction! MUST BE FLUSHED)
        uut.datapath_inst.mem_inst_2.memory[7] = 32'h06300313; 
        
        // 0x20: JAL  x7, func         (Jumps to 0x38. Saves Link PC+4 = 0x24 to x7)
        uut.datapath_inst.mem_inst_2.memory[8] = 32'h018003ef; 

        // ---------------------------------------------------
        // [RETURN FROM FUNCTION] - PC warps back here to 0x24!
        // ---------------------------------------------------
        // 0x24: LUI  x8, 0x87654      (x8 = 0x87654000)
        uut.datapath_inst.mem_inst_2.memory[9] = 32'h87654437; 
        
        // 0x28: ADDI x8, x8, 0x321    (x8 = 0x87654321)
        uut.datapath_inst.mem_inst_2.memory[10] = 32'h32140413; 
        
        // 0x2C: SW   x8, 400(x0)      (Mem[400] = 0x87654321)
        // 0x2C: SW x8, 400(x0)
        uut.datapath_inst.mem_inst_2.memory[11] = 32'h18802823; 
        
        // 0x30: LW   x9, 400(x0)      (x9 = 0x87654321)
        uut.datapath_inst.mem_inst_2.memory[12] = 32'h19002483; 
        
        // 0x34: BEQ  x9, x8, pass     (Stall for BRAM, then evaluates 0x87654321 == 0x87654321) -> Branch to 0x40
        uut.datapath_inst.mem_inst_2.memory[13] = 32'h00848663; 
        
        // ---------------------------------------------------
        // [FUNCTION DEFINITION]
        // ---------------------------------------------------
        // 0x38: ADDI x31, x0, 42      (x31 = 42)
        uut.datapath_inst.mem_inst_2.memory[14] = 32'h02a00f93; 
        
        // 0x3C: JALR x0, 0(x7)        (Jumps back to address stored in x7 -> 0x24)
        uut.datapath_inst.mem_inst_2.memory[15] = 32'h00038067; 
        
        // ---------------------------------------------------
        // [SUCCESS ENDPOINT]
        // ---------------------------------------------------
        // 0x40: SW   x31, 500(x0)     (Mem[500] = 42. Test completes!)
        uut.datapath_inst.mem_inst_2.memory[16] = 32'h1ff02a23; 
        
        // 0x44: J 0x44 (Infinite loop just in case)
        uut.datapath_inst.mem_inst_2.memory[17] = 32'h0000006f; 


        reset = 1;
        #25 reset = 0; 

        #2000;
        $display("\n[FATAL ERROR] Simulation Timeout. The CPU locked up!");
        $finish;
    end

    // --- EVENT TRACKER & DYNAMIC ASSERTION VERIFICATION ---
    always @(posedge clk) begin
        if (!reset) begin
            cycle_count = cycle_count + 1;
            
            // 1. Dynamic Register Checks
            if (uut.rf_en_wd && uut.datapath_inst.decode_stage_inst.dr != 5'd0) begin
                $display("[%4t ns] RF_WRITE : x%-2d <- 0x%08x", 
                         $time, uut.datapath_inst.decode_stage_inst.dr, uut.datapath_inst.decode_stage_inst.rf_wd);

                // Self-Checking Assertions
                if (uut.datapath_inst.decode_stage_inst.dr == 3 && uut.datapath_inst.decode_stage_inst.rf_wd !== 32'd3) begin
                    $display("    --> [FAIL] Forwarding logic broke! Expected x3 = 3."); errors_found = errors_found + 1;
                end
                if (uut.datapath_inst.decode_stage_inst.dr == 5 && uut.datapath_inst.decode_stage_inst.rf_wd !== 32'd36) begin
                    $display("    --> [FAIL] IMUL Multiplier logic failed! Expected x5 = 36."); errors_found = errors_found + 1;
                end
                if (uut.datapath_inst.decode_stage_inst.dr == 6) begin
                    $display("    --> [FAIL] Ghost instruction executed! Flush logic failed on branch."); errors_found = errors_found + 1;
                end
                if (uut.datapath_inst.decode_stage_inst.dr == 7 && uut.datapath_inst.decode_stage_inst.rf_wd !== 32'h24) begin
                    $display("    --> [FAIL] JAL Link Register failed! Expected return PC 0x24."); errors_found = errors_found + 1;
                end
                if (uut.datapath_inst.decode_stage_inst.dr == 9 && uut.datapath_inst.decode_stage_inst.rf_wd !== 32'h87654321) begin
                    $display("    --> [FAIL] BRAM Load-Use Hazard failed! Corrupted LW read."); errors_found = errors_found + 1;
                end
            end
            
            // 2. Track Stalls & Flushes
            if (uut.hz_out_X_wire) 
                $display("[%4t ns] PIPELINE STALL : Paused for Load-Use Hazard or IMUL", $time);
                
            if (uut.clear && uut.datapath_inst.fetch_stage_inst.pc_reg_D != 32'h44) 
                $display("[%4t ns] PIPELINE FLUSH : Branch or Jump taken!", $time);

            // 3. Evaluate Final Memory Condition
            if (uut.datapath_inst.dmemory_stage_inst.we != 4'b0000) begin
                $display("[%4t ns] MEM_WRITE: Mem[%0d] <- 0x%08x", 
                         $time, uut.datapath_inst.dmemory_stage_inst.ex_res_reg_M, uut.datapath_inst.dmemory_stage_inst.dstore_sram);
                         
                // Final Check at Mem[500]
                if (uut.datapath_inst.dmemory_stage_inst.ex_res_reg_M == 32'd500) begin
                    $display("\n=========================================================================");
                    if (uut.datapath_inst.dmemory_stage_inst.dstore_sram === 32'd42 && errors_found == 0) begin
                        $display("  \U0001f3c6 FLAWLESS VICTORY \U0001f3c6");
                        $display("  ALL ULTIMATE ASSERTIONS PASSED!");
                        $display("  Data Hazards, Control Hazards, Structural Hazards, and Latch Delays");
                        $display("  were all handled perfectly by your Pipeline.");
                    end else begin
                        $display("  \u274c TEST FAILED with %0d errors.", errors_found);
                        $display("  Check the timeline logs above to see which architectural block failed.");
                    end
                    $display("=========================================================================\n");
                    #20; 
                    $finish;
                end
            end

        end
    end

endmodule