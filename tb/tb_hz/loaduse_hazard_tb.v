`timescale 1ns / 1ps

module loaduse_hazard_tb();

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

        uut.datapath_inst.mem_inst_2.memory[0] = 32'h000010b7; // lui x1, 1 (4096)
        uut.datapath_inst.mem_inst_2.memory[1] = 32'h00102023; // sw x1, 0(x0)
        
        uut.datapath_inst.mem_inst_2.memory[2] = 32'h00002103; // lw x2, 0(x0)
        uut.datapath_inst.mem_inst_2.memory[3] = 32'h002101b3; // add x3, x2, x2 (Stall, x3=8192)

        uut.datapath_inst.mem_inst_2.memory[4] = 32'h7c302823; // sw x3, 2000(x0)

        reset = 1;
        #25 reset = 0;

        #5000;
        $display("[FATAL] loaduse_hazard_tb: Simulation timeout.");
        $finish;
    end

    always @(posedge clk) begin
        if (uut.datapath_inst.dmemory_stage_inst.we != 4'b0000) begin
            if (uut.datapath_inst.dmemory_stage_inst.ex_res_reg_M == 32'h7d0) begin
                if (uut.datapath_inst.dmemory_stage_inst.dstore_sram === 32'd8192) begin
                    $display("[PASS] loaduse_hazard_tb: Load-Use pipeline interlock stalled correctly.");
                end else begin
                    $display("[FAIL] loaduse_hazard_tb: Expected 8192, got %0d.", uut.datapath_inst.dmemory_stage_inst.dstore_sram);
                end
                $finish;
            end
        end
    end

endmodule