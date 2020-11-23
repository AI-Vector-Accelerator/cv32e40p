module cv32e40n_data_xbar
   (input  logic                         clk_i,
    input  logic                         rst_ni,
    input  logic                         xbar_master_sel,
       
    // Data crossbar slave 1 (Memory)
    output logic                         data_req_xbr_s1_o,
    input  logic                         data_gnt_xbr_s1_i,
    input  logic                         data_rvalid_xbr_s1_i,
    output logic [31:0]                  data_addr_xbr_s1_o,
    output logic                         data_we_xbr_s1_o,
    output logic [3:0]                   data_be_xbr_s1_o,
    input  logic [31:0]                  data_rdata_xbr_s1_i,
    output logic [31:0]                  data_wdata_xbr_s1_o,
    // Data crossbar master 1 (CPU)
    input  logic                         data_req_xbr_m1_i,
    output logic                         data_gnt_xbr_m1_o,
    output logic                         data_rvalid_xbr_m1_o,
    input  logic [31:0]                  data_addr_xbr_m1_i,
    input  logic                         data_we_xbr_m1_i,
    input  logic [3:0]                   data_be_xbr_m1_i,
    output logic [31:0]                  data_rdata_xbr_m1_o,
    input  logic [31:0]                  data_wdata_xbr_m1_i,
    // Data crossbar master 2 (NVPE)
    input  logic                         data_req_xbr_m2_i,
    output logic                         data_gnt_xbr_m2_o,
    output logic                         data_rvalid_xbr_m2_o,
    input  logic [31:0]                  data_addr_xbr_m2_i,
    input  logic                         data_we_xbr_m2_i,
    input  logic [3:0]                   data_be_xbr_m2_i,
    output logic [31:0]                  data_rdata_xbr_m2_o,
    input  logic [31:0]                  data_wdata_xbr_m2_i );

    logic xbar_master_sync;
    always_ff @(posedge clk_i, negedge rst_ni) begin
        if(~rst_ni)
            xbar_master_sync <= 1'b0;
        else
            xbar_master_sync <= xbar_master_sel;
    end

    always_comb begin
        // To Slave
        data_req_xbr_s1_o    = xbar_master_sel ? data_req_xbr_m2_i   : data_req_xbr_m1_i;
        data_addr_xbr_s1_o   = xbar_master_sel ? data_addr_xbr_m2_i  : data_addr_xbr_m1_i;
        data_we_xbr_s1_o     = xbar_master_sel ? data_we_xbr_m2_i    : data_we_xbr_m1_i;
        data_be_xbr_s1_o     = xbar_master_sel ? data_be_xbr_m2_i    : data_be_xbr_m1_i;
        data_wdata_xbr_s1_o  = xbar_master_sel ? data_wdata_xbr_m2_i : data_wdata_xbr_m1_i;

        // To Master
        data_gnt_xbr_m1_o    = xbar_master_sel ?                 1'b0 : data_gnt_xbr_s1_i;
        data_rvalid_xbr_m1_o = xbar_master_sel ?                 1'b0 : data_rvalid_xbr_s1_i;
        data_rdata_xbr_m1_o  = xbar_master_sel ?                32'b0 : data_rdata_xbr_s1_i;
        data_gnt_xbr_m2_o    = xbar_master_sel ? data_gnt_xbr_s1_i    :  1'b0;
        data_rvalid_xbr_m2_o = xbar_master_sel ? data_rvalid_xbr_s1_i :  1'b0;
        data_rdata_xbr_m2_o  = xbar_master_sel ? data_rdata_xbr_s1_i  : 32'b0;
    end

endmodule