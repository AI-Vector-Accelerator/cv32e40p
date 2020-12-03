
module cv32e40n_apu_dummy import cv32e40p_apu_core_pkg::*;
   (input  logic                            clk_i,
    input  logic                            rst_ni,
    
    // request channel
    input  logic [APU_NARGS_CPU-1:0][31:0]  apu_operands_i,
    input  logic [APU_WOP_CPU-1:0]          apu_op_i,
    input  logic [APU_NDSFLAGS_CPU-1:0]     apu_flags_i,
    input  logic                            apu_req_i,
    // response channel
    output logic                            apu_rvalid_o,
    output logic [31:0]                     apu_result_o,
    output logic [APU_NUSFLAGS_CPU-1:0]     apu_flags_o,
    output logic                            apu_gnt_o,
    
    output logic                            mem_master_sel,

    // Data memory interface
    output logic                            data_req_o,
    input  logic                            data_gnt_i,
    input  logic                            data_rvalid_i,
    output logic                            data_we_o,
    output logic [3:0]                      data_be_o,
    output logic [31:0]                     data_addr_o,
    output logic [31:0]                     data_wdata_o,
    input  logic [31:0]                     data_rdata_i );

    assign apu_result_o = 'd0;
    assign apu_flags_o  = 'd0;

    typedef enum {IDLE, PROC, VALID} responder_state;
    responder_state current_s, next_s;

    always_ff @(posedge clk_i, negedge rst_ni) begin
        if(~rst_ni)
            current_s <= IDLE;
        else
            current_s <= next_s;
    end

    assign data_req_o = 1'b0;
    assign data_we_o  = 1'b0;
    assign data_be_o  = 4'b0;
    assign data_addr_0 = 31'd0;
    assign data_wdata_0 = 31'd0;

    always_comb begin
        apu_gnt_o = '0;
        apu_rvalid_o = '0;
        mem_master_sel = '0;

        case(current_s)
            IDLE: begin
                apu_gnt_o = '1;

                if(apu_req_i) // Do we have a transaction request?
                    next_s = PROC;
                else
                    next_s = IDLE;
            end
            PROC: begin
                next_s = VALID; // Single Cycle Instruction
            end
            VALID: begin
                apu_rvalid_o = '1;

                next_s = IDLE;
            end
        endcase

        if(apu_op_i[1:0] == 2'd1)
            mem_master_sel = 1'b1;
        else
            mem_master_sel = 1'b0;
    end

endmodule
