`timescale 1ns / 1ps

module itype_tb();

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

        uut.datapath_inst.mem_inst_2.memory[0] = 32'h000040b7; // lui x1, 4 (0x4000)
        uut.datapath_inst.mem_inst_2.memory[1] = 32'hfff08113; // addi x2, x1, -1 (0x3FFF)
        
        uut.datapath_inst.mem_inst_2.memory[2] = 32'h00411193; // slli x3, x2, 4 (0x3FFF0)
        uut.datapath_inst.mem_inst_2.memory[3] = 32'h0021d213; // srli x4, x3, 2 (0x0FFFC)

        uut.datapath_inst.mem_inst_2.memory[4] = 32'hff000313; // addi x6, x0, -16 (0xFFFFFFF0)
        uut.datapath_inst.mem_inst_2.memory[5] = 32'h40235393; // srai x7, x6, 2 (-4)

        uut.datapath_inst.mem_inst_2.memory[6] = 32'h7c702823; // sw x7, 2000(x0)

        reset = 1;
        #25 reset = 0;

        #5000;
        $display("[FATAL] itype_tb: Simulation timeout.");
        $finish;
    end

    always @(posedge clk) begin
        if (uut.datapath_inst.dmemory_stage_inst.we != 4'b0000) begin
            if (uut.datapath_inst.dmemory_stage_inst.ex_res_reg_M == 32'h7d0) begin
                if (uut.datapath_inst.dmemory_stage_inst.dstore_sram === 32'hfffffffc) begin
                    $display("[PASS] itype_tb: Immediate and arithmetic shifts match expected signature.");
                end else begin
                    $display("[FAIL] itype_tb: Expected -4, got %0d", $signed(uut.datapath_inst.dmemory_stage_inst.dstore_sram));
                end
                $finish;
            end
        end
    end

endmodule