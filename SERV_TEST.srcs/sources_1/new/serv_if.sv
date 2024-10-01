`timescale 1ns / 1ps

interface serv_if (input bit clk);
   
   logic 	    i_rst;
   logic 	    i_timer_irq;
   // RISCV_FORMAL
   logic 	    rvfi_valid;
   logic [63:0] rvfi_order;
   logic [31:0] rvfi_insn;
   logic 	    rvfi_trap;
   logic 	    rvfi_halt;
   logic 	    rvfi_intr;
   logic [1:0]  rvfi_mode;
   logic [1:0]  rvfi_ixl;
   logic [4:0]  rvfi_rs1_addr;
   logic [4:0]  rvfi_rs2_addr;
   logic [31:0] rvfi_rs1_rdata;
   logic [31:0] rvfi_rs2_rdata;
   logic [4:0]  rvfi_rd_addr;
   logic [31:0] rvfi_rd_wdata;
   logic [31:0] rvfi_pc_rdata;
   logic [31:0] rvfi_pc_wdata;
   logic [31:0] rvfi_mem_addr;
   logic [3:0]  rvfi_mem_rmask;
   logic [3:0]  rvfi_mem_wmask;
   logic [31:0] rvfi_mem_rdata;
   logic [31:0] rvfi_mem_wdata;

   logic [31:0] o_ibus_adr;
   logic 	    o_ibus_cyc;
   logic [31:0] i_ibus_rdt;
   logic 	    i_ibus_ack;
   
   logic [31:0] o_dbus_adr;
   logic [31:0] o_dbus_dat;
   logic [3:0]  o_dbus_sel;
   logic 	    o_dbus_we ;
   logic 	    o_dbus_cyc;
   logic [31:0] i_dbus_rdt;
   logic 	    i_dbus_ack;

   // Extension
   logic [31:0] o_ext_rs1;
   logic [31:0] o_ext_rs2;
   logic [ 2:0] o_ext_funct3;
   logic [31:0] i_ext_rd;
   logic        i_ext_ready;
   // MDU
   logic        o_mdu_valid;
   
   default clocking cb @(posedge clk);
      default input #0ns output #0ns;
      input  i_rst;
      input  o_ibus_adr;
      input  o_ibus_cyc;
      output i_ibus_rdt;
      output i_ibus_ack;
      
      input  o_dbus_adr;
      input  o_dbus_dat;
      input  o_dbus_sel;
      input  o_dbus_we ;
      input  o_dbus_cyc;
      output i_dbus_rdt;
      output i_dbus_ack;
   endclocking
   
   modport TB (output i_rst, clocking cb, output i_ibus_ack);
   
endinterface
