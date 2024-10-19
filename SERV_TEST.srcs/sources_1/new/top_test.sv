`timescale 1ns / 1ps


module top_test ();
   
   parameter CYCLE = 10;
   
   bit SystemClock;
   
   logic [31:0] mdu_rs1;
   logic [31:0] mdu_rs2;
   logic [2:0]  mdu_op;
   logic        mdu_valid;
   logic        mdu_ready;
   logic [31:0] mdu_rd;
   
   assign top_io.o_mdu_valid  = mdu_valid;
   assign top_io.i_ext_ready  = mdu_ready;
   assign top_io.i_ext_rd     = mdu_rd;
   assign top_io.o_ext_funct3 = mdu_op;
   assign top_io.o_ext_rs2    = mdu_rs2;
   assign top_io.o_ext_rs1    = mdu_rs1;
   
   assign mdu_io.i_mdu_rs1   = mdu_rs1;
   assign mdu_io.i_mdu_rs2   = mdu_rs2;
   assign mdu_io.i_mdu_op    = mdu_op;
   assign mdu_io.i_mdu_valid = mdu_valid;
   assign mdu_io.o_mdu_ready = mdu_ready;
   assign mdu_io.o_mdu_rd    = mdu_rd;
   
   reg [7:0] time_out;
   
   serv_if top_io (SystemClock);
   
   mdu_if mdu_io (SystemClock);
   
   test_program test (top_io);
   
   serv_rf_top #(
      .RESET_PC      (32'd0),
      .COMPRESSED    (0),
      .ALIGN         (1'b0),
      .MDU           (1),
      .PRE_REGISTER  (1),
      .RESET_STRATEGY("MINI"),
      .WITH_CSR      (0),
      .RF_WIDTH      (32)
      // .RF_L2D        ()
   ) dut (
      .clk           (SystemClock),
      .i_rst         (top_io.i_rst),
      .i_timer_irq   (top_io.i_timer_irq),
`ifdef RISCV_FORMAL
      .rvfi_valid    (top_io.rvfi_valid),
      .rvfi_order    (top_io.rvfi_order),
      .rvfi_insn     (top_io.rvfi_insn),
      .rvfi_trap     (top_io.rvfi_trap),
      .rvfi_halt     (top_io.rvfi_halt),
      .rvfi_intr     (top_io.rvfi_intr),
      .rvfi_mode     (top_io.rvfi_mode),
      .rvfi_ixl      (top_io.rvfi_ixl),
      .rvfi_rs1_addr (top_io.rvfi_rs1_addr),
      .rvfi_rs2_addr (top_io.rvfi_rs2_addr),
      .rvfi_rs1_rdata(top_io.rvfi_rs1_rdata),
      .rvfi_rs2_rdata(top_io.rvfi_rs2_rdata),
      .rvfi_rd_addr  (top_io.rvfi_rd_addr),
      .rvfi_rd_wdata (top_io.rvfi_rd_wdata),
      .rvfi_pc_rdata (top_io.rvfi_pc_rdata),
      .rvfi_pc_wdata (top_io.rvfi_pc_wdata),
      .rvfi_mem_addr (top_io.rvfi_mem_addr),
      .rvfi_mem_rmask(top_io.rvfi_mem_rmask),
      .rvfi_mem_wmask(top_io.rvfi_mem_wmask),
      .rvfi_mem_rdata(top_io.rvfi_mem_rdata),
      .rvfi_mem_wdata(top_io.rvfi_mem_wdata),
`endif
      .o_ibus_adr    (top_io.o_ibus_adr),
      .o_ibus_cyc    (top_io.o_ibus_cyc),
      .i_ibus_rdt    (top_io.i_ibus_rdt),
      .i_ibus_ack    (top_io.i_ibus_ack),
      
      .o_dbus_adr    (top_io.o_dbus_adr),
      .o_dbus_dat    (top_io.o_dbus_dat),
      .o_dbus_sel    (top_io.o_dbus_sel),
      .o_dbus_we     (top_io.o_dbus_we),
      .o_dbus_cyc    (top_io.o_dbus_cyc),
      .i_dbus_rdt    (top_io.i_dbus_rdt),
      .i_dbus_ack    (top_io.i_dbus_ack),

      // Extension
      .o_ext_rs1     (mdu_rs1),
      .o_ext_rs2     (mdu_rs2),
      .o_ext_funct3  (mdu_op),
      .i_ext_rd      (mdu_rd),
      .i_ext_ready   (mdu_ready),
      // MDU
      .o_mdu_valid   (mdu_valid)
   );
   
   mdu_top #(
      .WIDTH(32)
   ) mdu_dut (
      .i_clk      (SystemClock),
      .i_rst      (top_io.i_rst),
      .i_mdu_rs1  (mdu_rs1),
      .i_mdu_rs2  (mdu_rs2),
      .i_mdu_op   (mdu_op),
      .i_mdu_valid(mdu_valid),
      .o_mdu_ready(mdu_ready),
      .o_mdu_rd   (mdu_rd)
   );
   
   always #(CYCLE / 2) SystemClock = ~SystemClock;
   
   always @(posedge SystemClock) begin
      time_out = time_out + 8'b1;
      if (time_out[7]) $stop;
   end
   
   always @(top_io.o_ibus_adr) time_out = 8'b0;
   
   initial begin
      SystemClock = 1'b0;
      time_out    = 8'b0;
   end
   
endmodule