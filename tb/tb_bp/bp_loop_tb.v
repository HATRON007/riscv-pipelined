`timescale 1ns / 1ps

module bp_loop_tb();

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

        // Initialize limit (x1=5), accumulator (x2=0), and iterator (x3=0)
        uut.datapath_inst.mem_inst_2.memory[0] = 32'h00500093; // addi x1, x0, 5
        uut.datapath_inst.mem_inst_2.memory[1] = 32'h00000113; // addi x2, x0, 0
        uut.datapath_inst.mem_inst_2.memory[2] = 32'h00000193; // addi x3, x0, 0
        
        // Accumulate 1+2+3+4+5=15
        uut.datapath_inst.mem_inst_2.memory[3] = 32'h00118193; // addi x3, x3, 1
        uut.datapath_inst.mem_inst_2.memory[4] = 32'h00310133; // add x2, x2, x3
        
        // Loop back if x3 < 5. Predictor will miss initially, hit as history saturates, and miss on exit.
        uut.datapath_inst.mem_inst_2.memory[5] = 32'hfe11cce3; // blt x3, x1, -8
        
        // Write sum to mem[2000]
        uut.datapath_inst.mem_inst_2.memory[6] = 32'h7c202823; // sw x2, 2000(x0)

        reset = 1;
        #25 reset = 0;

        #5000;
        $display("[FATAL] bp_loop_tb: Simulation timeout.");
        $finish;
    end

    integer br_evals = 0;
    integer br_hits = 0;
    integer br_misses = 0;
    reg current_hit;

    // Track evaluated branches in the EX stage to calculate hit/miss ratio
    always @(posedge clk) begin
        if (!reset && uut.regX_is_br_ins && !uut.hz_out_X_wire) begin
            br_evals = br_evals + 1;
            
            current_hit = (uut.actual_taken == uut.predict_taken_X) && 
                          (uut.predict_target_X == uut.br_target_X_wire || !uut.actual_taken);
            
            if (current_hit) begin
                br_hits = br_hits + 1;
            end else begin
                br_misses = br_misses + 1;
            end
        end
    end

    // Verify signature
    always @(posedge clk) begin
        if (uut.datapath_inst.dmemory_stage_inst.we != 4'b0000) begin
            if (uut.datapath_inst.dmemory_stage_inst.ex_res_reg_M == 32'h7d0) begin 
                if (uut.datapath_inst.dmemory_stage_inst.dstore_sram === 32'd15) begin
                    if (br_hits > 0) begin
                        $display("[PASS] bp_loop_tb: Predictor learned branch patterns. Hits: %0d, Misses: %0d", br_hits, br_misses);
                    end else begin
                        $display("[FAIL] bp_loop_tb: Zero predictor hits logged.");
                    end
                end else begin
                    $display("[FAIL] bp_loop_tb: Expected signature 15, got %0d.", uut.datapath_inst.dmemory_stage_inst.dstore_sram);
                end
                $finish;
            end
        end
    end

endmodule