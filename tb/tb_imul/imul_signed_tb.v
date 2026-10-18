`timescale 1ns / 1ps

module imul_signed_tb();

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

        uut.datapath_inst.mem_inst_2.memory[0] = 32'h00300093; // addi x1, x0, 3
        uut.datapath_inst.mem_inst_2.memory[1] = 32'h00400113; // addi x2, x0, 4
        uut.datapath_inst.mem_inst_2.memory[2] = 32'hffd00193; // addi x3, x0, -3
        uut.datapath_inst.mem_inst_2.memory[3] = 32'hffc00213; // addi x4, x0, -4

        uut.datapath_inst.mem_inst_2.memory[4] = 32'h022082b3; // mul x5, x1, x2  (12)
        uut.datapath_inst.mem_inst_2.memory[5] = 32'h02218333; // mul x6, x3, x2  (-12)
        uut.datapath_inst.mem_inst_2.memory[6] = 32'h024083b3; // mul x7, x1, x4  (-12)
        uut.datapath_inst.mem_inst_2.memory[7] = 32'h02418433; // mul x8, x3, x4  (12)

        uut.datapath_inst.mem_inst_2.memory[8]  = 32'h008284b3; // add x9, x5, x8   (24)
        uut.datapath_inst.mem_inst_2.memory[9]  = 32'h40648533; // sub x10, x9, x6  (36)
        uut.datapath_inst.mem_inst_2.memory[10] = 32'h407505b3; // sub x11, x10, x7 (48)

        uut.datapath_inst.mem_inst_2.memory[11] = 32'h7cb02823; // sw x11, 2000(x0)

        reset = 1;
        #25 reset = 0;

        #5000;
        $display("[FATAL] imul_signed_tb: Simulation timeout.");
        $finish;
    end

    always @(posedge clk) begin
        if (uut.datapath_inst.dmemory_stage_inst.we != 4'b0000) begin
            if (uut.datapath_inst.dmemory_stage_inst.ex_res_reg_M == 32'h7d0) begin
                if (uut.datapath_inst.dmemory_stage_inst.dstore_sram === 32'd48) begin
                    $display("[PASS] imul_signed_tb: Signed logic resolved correct signature.");
                end else begin
                    $display("[FAIL] imul_signed_tb: Expected 48, got %0d.", $signed(uut.datapath_inst.dmemory_stage_inst.dstore_sram));
                end
                $finish;
            end
        end
    end

endmodule