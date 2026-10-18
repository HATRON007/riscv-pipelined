`timescale 1ns / 1ps

module jump_tb();

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

        uut.datapath_inst.mem_inst_2.memory[0] = 32'h018000ef; // jal x1, 24 -> jumps to 0x18
        
        uut.datapath_inst.mem_inst_2.memory[4] = 32'h7c202823; // sw x2, 2000(x0)
        uut.datapath_inst.mem_inst_2.memory[5] = 32'h0000006f; // jal x0, 0
        
        uut.datapath_inst.mem_inst_2.memory[6] = 32'h00008113; // addi x2, x1, 0 (x2 = 4)
        uut.datapath_inst.mem_inst_2.memory[7] = 32'h00c08067; // jalr x0, x1, 12 -> jumps to 0x10

        reset = 1;
        #25 reset = 0;

        #5000;
        $display("[FATAL] jump_tb: Simulation timeout.");
        $finish;
    end

    always @(posedge clk) begin
        if (uut.datapath_inst.dmemory_stage_inst.we != 4'b0000) begin
            if (uut.datapath_inst.dmemory_stage_inst.ex_res_reg_M == 32'h7d0) begin
                if (uut.datapath_inst.dmemory_stage_inst.dstore_sram === 32'd4) begin
                    $display("[PASS] jump_tb: JAL and JALR PC arithmetic matches expected signature.");
                end else begin
                    $display("[FAIL] jump_tb: Expected 4, got %0d", uut.datapath_inst.dmemory_stage_inst.dstore_sram);
                end
                $finish;
            end
        end
    end

endmodule