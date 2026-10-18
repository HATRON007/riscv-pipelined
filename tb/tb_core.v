`timescale 1ns / 1ps

module tb_core();

    reg clk;
    reg reset;

    proc_top uut (
        .clk(clk),
        .reset(reset)
    );

    // loading the compiled C program into both Instruction and Data memories
    defparam uut.datapath_inst.mem_inst_1.INIT_FILE = "sw/build/quicksort.mem";
    defparam uut.datapath_inst.mem_inst_2.INIT_FILE = "sw/build/quicksort.mem";

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        #25 reset = 0;

        #500000;
        $display("[FATAL] tb_core: Simulation timeout.");
        $finish;
    end

    // monitoring for the signature write to 0x7F00
    always @(posedge clk) begin
        if (uut.datapath_inst.dmemory_stage_inst.we != 4'b0000) begin
            if (uut.datapath_inst.dmemory_stage_inst.ex_res_reg_M == 32'h7F00) begin
                if (uut.datapath_inst.dmemory_stage_inst.dstore_sram === 32'd315) begin
                    $display("[PASS] tb_core: Quicksort executed. Array sorted and signature (315) matches.");
                end else begin
                    $display("[FAIL] tb_core: Quicksort failed. Expected signature 315, got %0d.", uut.datapath_inst.dmemory_stage_inst.dstore_sram);
                end
                $finish;
            end
        end
    end

endmodule