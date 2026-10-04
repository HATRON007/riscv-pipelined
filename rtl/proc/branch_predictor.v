module branch_predictor(
    input clk,

    input wire[31:0] pc_reg_F,
    output predict_taken,
    output wire[31:0] predict_target,
    output wire[1:0] btb_history,
    
    input wire[31:0] pc_reg_X,
    input wire[1:0] btb_history_X,
    input is_branch_X,
    input actual_taken,
    input wire[31:0] actual_target
);

    //valid_1b + tag_22b + target_32b + bth_2b
    reg [56:0] btb_array [255:0];

    wire [7:0] btb_index = pc_reg_F[9:2];
    wire[56:0] btb_rd = btb_array[btb_index];

    reg btb_we;
    reg[56:0] btb_wd;

    always @(*) begin
        case (actual_taken)
            1'b0: btb_wd[1:0] = (btb_history_X == 2'b00)? 2'b00 : btb_history_X - 2'b01; 
            1'b1: btb_wd[1:0] = (btb_history_X == 2'b11)? 2'b11 : btb_history_X + 2'b01;
            default: btb_wd[1:0] = 2'b00;
        endcase
        
        btb_wd[33:2] = actual_target;
        btb_wd[55:34] = pc_reg_X[31:10];
        btb_wd[56] = 1'b1; 
        btb_we = is_branch_X;
    end

    //getting the data out of read
    wire btb_valid = btb_rd[56];
    wire[21:0] btb_tag = btb_rd[55:34];
    wire[31:0] btb_target = btb_rd[33:2];
    assign btb_history = btb_rd[1:0];


    wire tag_match = (pc_reg_F[31:10] == btb_tag);
    assign predict_taken = (btb_valid & tag_match & (btb_history[1] == 1'b1));
    assign predict_target = btb_target;

    integer i;
    initial begin //instantiating the btb on reset
            for(i=0; i<256; i=i+1) begin
                btb_array[i] <= 57'b0;
            end
    end

    always @(posedge clk) begin
        if(btb_we) btb_array[pc_reg_X[9:2]] <= btb_wd;
    end
endmodule