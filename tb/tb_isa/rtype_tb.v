`timescale 1ns / 1ps

module rtype_tb();

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

        uut.datapath_inst.mem_inst_2.memory[0] = 32'h00a00093; // addi x1, x0, 10
        uut.datapath_inst.mem_inst_2.memory[1] = 32'h00300113; // addi x2, x0, 3
        
        uut.datapath_inst.mem_inst_2.memory[2] = 32'h002081b3; // add x3, x1, x2  (13)
        uut.datapath_inst.mem_inst_2.memory[3] = 32'h40208233; // sub x4, x1, x2  (7)
        uut.datapath_inst.mem_inst_2.memory[4] = 32'h0041f2b3; // and x5, x3, x4  (5)
        uut.datapath_inst.mem_inst_2.memory[5] = 32'h0041e333; // or  x6, x3, x4  (15)
        uut.datapath_inst.mem_inst_2.memory[6] = 32'h0062c3b3; // xor x7, x5, x6  (10)

        uut.datapath_inst.mem_inst_2.memory[7] = 32'h7c702823; // sw x7, 2000(x0)

        reset = 1;
        #25 reset = 0;

        #5000;
        $display("[FATAL] rtype_tb: Simulation timeout.");
        $finish;
    end

    always @(posedge clk) begin
        if (uut.datapath_inst.dmemory_stage_inst.we != 4'b0000) begin
            if (uut.datapath_inst.dmemory_stage_inst.ex_res_reg_M == 32'h7d0) begin
                if (uut.datapath_inst.dmemory_stage_inst.dstore_sram === 32'd10) begin
                    $display("[PASS] rtype_tb: ALU outputs match expected signature.");
                end else begin
                    $display("[FAIL] rtype_tb: Expected 10, got %0d", uut.datapath_inst.dmemory_stage_inst.dstore_sram);
                end
                $finish;
            end
        end
    end

endmodule