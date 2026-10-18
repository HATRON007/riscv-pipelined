`timescale 1ns / 1ps

module control_hazard_tb();

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

        uut.datapath_inst.mem_inst_2.memory[0] = 32'h00500093; // addi x1, x0, 5
        uut.datapath_inst.mem_inst_2.memory[1] = 32'h00c0006f; // jal x0, 12
        
        uut.datapath_inst.mem_inst_2.memory[2] = 32'h00a08093; // addi x1, x1, 10 (Flush target)
        uut.datapath_inst.mem_inst_2.memory[3] = 32'h01408093; // addi x1, x1, 20 (Flush target)
        
        uut.datapath_inst.mem_inst_2.memory[4] = 32'h00508113; // addi x2, x1, 5 (x2=10 if flush works)

        uut.datapath_inst.mem_inst_2.memory[5] = 32'h7c202823; // sw x2, 2000(x0)

        reset = 1;
        #25 reset = 0;

        #5000;
        $display("[FATAL] control_hazard_tb: Simulation timeout.");
        $finish;
    end

    always @(posedge clk) begin
        if (uut.datapath_inst.dmemory_stage_inst.we != 4'b0000) begin
            if (uut.datapath_inst.dmemory_stage_inst.ex_res_reg_M == 32'h7d0) begin
                if (uut.datapath_inst.dmemory_stage_inst.dstore_sram === 32'd10) begin
                    $display("[PASS] control_hazard_tb: Speculative instructions successfully flushed.");
                end else begin
                    $display("[FAIL] control_hazard_tb: Expected 10, got %0d.", uut.datapath_inst.dmemory_stage_inst.dstore_sram);
                end
                $finish;
            end
        end
    end

endmodule