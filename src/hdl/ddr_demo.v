`timescale 1ps / 1ns

module ddr_demo(
    // Nexys4 DDR
    input    CLK100MHZ,
    input    [2:0] SW,
    output   [15:0] LED,
    // DDR2 signals
    output   [12:0] ddr2_addr,
    output   [2:0] ddr2_ba,
    output   ddr2_ras_n,
    output   ddr2_cas_n,
    output   ddr2_we_n,
    output   ddr2_ck_p,
    output   ddr2_ck_n,
    output   ddr2_cke,
    output   ddr2_cs_n,
    output   [1:0] ddr2_dm,
    output   ddr2_odt,
    inout    [15:0] ddr2_dq,
    inout    [1:0] ddr2_dqs_p,
    inout    [1:0] ddr2_dqs_n
);
    
    localparam ADDR_WIDTH = 27;
    localparam APP_DATA_WIDTH = 64;
    localparam APP_MASK_WIDTH = 8;
    localparam CMD_WRITE = 3'b000;
    localparam CMD_READ = 3'b001;
    
    wire [ADDR_WIDTH - 1 : 0]     app_addr;           // memory address
    wire [2:0]                    app_cmd;            // cmd => command: 001 #=> Read, 000 #=> Write
    wire                          app_en;             // active-high strobe for app_addr, app_cmd, app_sz, app_hi_pri
    wire [APP_DATA_WIDTH - 1 : 0] app_wdf_data;       // data to write
    wire                          app_wdf_end;        // active high, indicating the last cycle for app_wdf_data[]
    wire                          app_wdf_wren;       // active-high strobe for app_wdf_data[]
    wire [APP_DATA_WIDTH - 1 : 0] app_rd_data;        // data to read
    wire                          app_rd_data_end;    // active-high, indicating the last cyccle for app_rd_data[]
    wire                          app_rd_data_valid;  // active-high, indicating app_rd_data[] is valid
    wire                          app_rdy;            // active-high, indicating the UI is ready to accept commands
    wire                          app_wdf_rdy;        // indicating FIFO is ready to accept app_wdf_data[]
    wire                          app_sr_active;      // ???
    wire                          app_ref_ack;        // ???
    wire                          app_zq_ack;         // ???
    wire                          clk;                // output! must be a half or a quarter of DRAM clk
    wire                          rst;                // output! active-high UI reset
    wire [APP_MASK_WIDTH - 1 : 0] app_wdf_mask;       // mask for app_wdf_data[]
    wire                          sys_clk_i;          // should be 200MHz according to Bram2Ddr.vhd
    wire                          sys_rst;            // system reset
    
    assign app_addr = 0;
    assign app_cmd = SW[0] ? CMD_WRITE : CMD_READ;
    assign app_en = 1'b1;
    assign app_wdf_data = 64'h0123456789ABCDEF;
    assign app_wdf_wren = 1'b1;
    assign app_wdf_end = SW[1];
    assign app_wdf_mask = 0;
    assign sys_rst = SW[2];
    
    assign LED[0] = app_rd_data_end;
    assign LED[1] = app_rd_data_valid;
    assign LED[2] = app_rdy;
    assign LED[3] = app_wdf_rdy;
    assign LED[4] = clk;
    assign LED[5] = rst;
    assign LED[6] = app_sr_active;
    assign LED[7] = app_ref_ack;
    assign LED[8] = app_zq_ack;
    
    assign LED[15:9] = app_rd_data[6:0];

    clk_wiz_0 clk_gen
    (
        .clk_in1   (CLK100MHZ),
        .clk_out1  (sys_clk_i)
    );

    mig_nexys4ddr u_mig_ddr
    (   
        // Memory interface ports
       .ddr2_addr                      (ddr2_addr),
       .ddr2_ba                        (ddr2_ba),
       .ddr2_cas_n                     (ddr2_cas_n),
       .ddr2_ck_n                      (ddr2_ck_n),
       .ddr2_ck_p                      (ddr2_ck_p),
       .ddr2_cke                       (ddr2_cke),
       .ddr2_ras_n                     (ddr2_ras_n),
       .ddr2_we_n                      (ddr2_we_n),
       .ddr2_dq                        (ddr2_dq),
       .ddr2_dqs_n                     (ddr2_dqs_n),
       .ddr2_dqs_p                     (ddr2_dqs_p),
       .init_calib_complete            (init_calib_complete),

       .ddr2_cs_n                      (ddr2_cs_n),
       .ddr2_dm                        (ddr2_dm),
       .ddr2_odt                       (ddr2_odt),
        // Application interface ports
       .app_addr                       (app_addr),
       .app_cmd                        (app_cmd),
       .app_en                         (app_en),
       .app_wdf_data                   (app_wdf_data),
       .app_wdf_end                    (app_wdf_end),
       .app_wdf_wren                   (app_wdf_wren),
       .app_rd_data                    (app_rd_data),
       .app_rd_data_end                (app_rd_data_end),
       .app_rd_data_valid              (app_rd_data_valid),
       .app_rdy                        (app_rdy),
       .app_wdf_rdy                    (app_wdf_rdy),
       .app_sr_req                     (1'b0),
       .app_ref_req                    (1'b0),
       .app_zq_req                     (1'b0),
       .app_sr_active                  (app_sr_active),
       .app_ref_ack                    (app_ref_ack),
       .app_zq_ack                     (app_zq_ack),
       .ui_clk                         (clk),
       .ui_clk_sync_rst                (rst),
      
       .app_wdf_mask                   (app_wdf_mask),

        // System Clock Ports
       .sys_clk_i                      (sys_clk_i),
       .sys_rst                        (sys_rst)
    );

endmodule