module stage_wb(
    input wire[31:0] mem_rd, //coming from sram
    input wire[31:0] ex_res_reg_W, //coming from M stage (alu result)
    input wire[2:0] load_sel_W,
    input wire wb_res_sel_W, //to identify between load and alu result (if 1, fw data from mem_rd, if 0 fw data from wb_res_reg_W)
    output reg[31:0] rd_mem
);
    reg[31:0] mem_rd_signext;
    wire[7:0] mem_rd_selector_b;
    wire[15:0] mem_rd_selector_h;

    assign mem_rd_selector_b = (ex_res_reg_W[1:0] == 2'b00)? mem_rd[7:0] :
                               (ex_res_reg_W[1:0] == 2'b01)? mem_rd[15:8] :
                               (ex_res_reg_W[1:0] == 2'b10)? mem_rd[23:16] :
                               mem_rd[31:24];

    //risc-v is little endian
    assign mem_rd_selector_h = (ex_res_reg_W[1] == 1'b0)? mem_rd[15:0] : mem_rd[31:16];

    always @(*) begin
        case(load_sel_W)
            3'b000: mem_rd_signext = {{24{mem_rd_selector_b[7]}}, mem_rd_selector_b}; //lb
            3'b001: mem_rd_signext = {{16{mem_rd_selector_h[15]}}, mem_rd_selector_h}; //lh
            3'b010: mem_rd_signext = mem_rd; //lw
            3'b100: mem_rd_signext = {24'b0, mem_rd_selector_b}; //lbu
            3'b101: mem_rd_signext = {16'b0, mem_rd_selector_h}; //lhu
            default: mem_rd_signext = 32'b0;
        endcase

        if(wb_res_sel_W) rd_mem = mem_rd_signext;
        else rd_mem = ex_res_reg_W;
    end

endmodule