module cv32e40n_data_xbar
   (input  logic                         clk_i,
    input  logic                         rst_ni,
       
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

    // If NVPE makes memory request we switch over control of the bus until result is valid
    typedef enum { IDLE, M1_REQ, M2_REQ} m_mux_state;
    m_mux_state current_state, next_state;

    logic current_master;

    always_ff @(posedge clk_i, negedge rst_ni) begin
        if(~rst_ni)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always_comb begin
        current_master = 1'b0;
        next_state = IDLE;
        case(current_state)
            IDLE: begin 
                current_master = 1'b0;
                if(data_req_xbr_m2_i) begin
                    next_state = M2_REQ;
                    current_master = 1'b1;
                end else if(data_req_xbr_m1_i) 
                    next_state = M1_REQ;
                else
                    next_state = IDLE;
            end
            M1_REQ: begin
                current_master = 1'b0;
                if(data_rvalid_xbr_m1_o)
                    next_state = IDLE;
                else
                    next_state = M1_REQ;
            end
            M2_REQ: begin
                current_master = 1'b1;
                if(data_rvalid_xbr_m2_o)
                    next_state = IDLE;
                else
                    next_state = M2_REQ;
            end
        endcase
    end

    always_comb begin
        // To Slave
        data_req_xbr_s1_o    = current_master ? data_req_xbr_m2_i   : data_req_xbr_m1_i;
        data_addr_xbr_s1_o   = current_master ? data_addr_xbr_m2_i  : data_addr_xbr_m1_i;
        data_we_xbr_s1_o     = current_master ? data_we_xbr_m2_i    : data_we_xbr_m1_i;
        data_be_xbr_s1_o     = current_master ? data_be_xbr_m2_i    : data_be_xbr_m1_i;
        data_wdata_xbr_s1_o  = current_master ? data_wdata_xbr_m2_i : data_wdata_xbr_m1_i;

        // To Master
        data_gnt_xbr_m1_o    = current_master ?                 1'b0 : data_gnt_xbr_s1_i;
        data_rvalid_xbr_m1_o = current_master ?                 1'b0 : data_rvalid_xbr_s1_i;
        data_rdata_xbr_m1_o  = current_master ?                32'b0 : data_rdata_xbr_s1_i;
        data_gnt_xbr_m2_o    = current_master ? data_gnt_xbr_s1_i    :  1'b0;
        data_rvalid_xbr_m2_o = current_master ? data_rvalid_xbr_s1_i :  1'b0;
        data_rdata_xbr_m2_o  = current_master ? data_rdata_xbr_s1_i  : 32'b0;
    end

endmodule