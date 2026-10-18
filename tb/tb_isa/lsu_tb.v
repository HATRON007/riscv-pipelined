`timescale 1ns / 1ps

module lsu_tb();

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

        uut.datapath_inst.mem_inst_2.memory[0] = 32'h000000b7; // lui x1, 0
        uut.datapath_inst.mem_inst_2.memory[1] = 32'h19008093; // addi x1, x1, 400
        
        uut.datapath_inst.mem_inst_2.memory[2] = 32'h00001137; // lui x2, 1
        uut.datapath_inst.mem_inst_2.memory[3] = 32'h0ff10113; // addi x2, x2, 255
        
        uut.datapath_inst.mem_inst_2.memory[4] = 32'h0020a023; // sw x2, 0(x1)
        
        uut.datapath_inst.mem_inst_2.memory[5] = 32'h00008183; // lb x3, 0(x1) (-1)
        uut.datapath_inst.mem_inst_2.memory[6] = 32'h0010c203; // lbu x4, 1(x1) (16)
        
        uut.datapath_inst.mem_inst_2.memory[7] = 32'h004182b3; // add x5, x3, x4 (15)

        uut.datapath_inst.mem_inst_2.memory[8] = 32'h7c502823; // sw x5, 2000(x0)

        reset = 1;
        #25 reset = 0;

        #5000;
        $display("[FATAL] lsu_tb: Simulation timeout.");
        $finish;
    end

    always @(posedge clk) begin
        if (uut.datapath_inst.dmemory_stage_inst.we != 4'b0000) begin
            if (uut.datapath_inst.dmemory_stage_inst.ex_res_reg_M == 32'h7d0) begin
                if (uut.datapath_inst.dmemory_stage_inst.dstore_sram === 32'd15) begin
                    $display("[PASS] lsu_tb: Memory alignment and extensions match expected signature.");
                end else begin
                    $display("[FAIL] lsu_tb: Expected 15, got %0d", uut.datapath_inst.dmemory_stage_inst.dstore_sram);
                end
                $finish;
            end
        end
    end

endmodule