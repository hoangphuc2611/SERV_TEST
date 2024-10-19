`timescale 1ns / 1ps

interface servile_if #(
   parameter       reset_pc = 32'h00000000,
   parameter       reset_strategy = "MINI",
   parameter       rf_width = 8,
   parameter [0:0] sim = 1'b0,
   parameter [0:0] with_c = 1'b0,
   parameter [0:0] with_csr = 1'b0,
   parameter [0:0] with_mdu = 1'b0,
   //Internally calculated. Do not touch
   parameter       regs = 32+with_csr*4,
   parameter       rf_l2d = $clog2(regs*32/rf_width))
    
   (input bit clk);
   
   logic        i_clk;
   logic        i_rst;
   logic        i_timer_irq;

   //Memory (WB) interface
   logic [31:0] o_wb_mem_adr;
   logic [31:0] o_wb_mem_dat;
   logic [3:0]  o_wb_mem_sel;
   logic        o_wb_mem_we ;
   logic        o_wb_mem_stb;
   logic [31:0] i_wb_mem_rdt;
   logic        i_wb_mem_ack;

   //Extension (WB) interface
   logic [31:0] o_wb_ext_adr;
   logic [31:0] o_wb_ext_dat;
   logic [3:0]  o_wb_ext_sel;
   logic        o_wb_ext_we ;
   logic        o_wb_ext_stb;
   logic [31:0] i_wb_ext_rdt;
   logic        i_wb_ext_ack;

   //RF (SRAM) interface
   logic [rf_l2d-1:0]   o_rf_waddr;
   logic [rf_width-1:0] o_rf_wdata;
   logic                o_rf_wen;
   logic [rf_l2d-1:0]   o_rf_raddr;
   logic [rf_width-1:0] i_rf_rdata;
   logic                o_rf_ren;
   
   default clocking cb @(posedge clk);
      default input #0ns output #0ns;
      input  i_rst;
      
      //Memory (WB) interface
      input  o_wb_mem_adr;
      input  o_wb_mem_dat;
      input  o_wb_mem_sel;
      input  o_wb_mem_we ;
      input  o_wb_mem_stb;
      output i_wb_mem_rdt;
      output i_wb_mem_ack;

      //Extension (WB) interface
      input  o_wb_ext_adr;
      input  o_wb_ext_dat;
      input  o_wb_ext_sel;
      input  o_wb_ext_we ;
      input  o_wb_ext_stb;
      output i_wb_ext_rdt;
      output i_wb_ext_ack;

      //RF (SRAM) interface
      input  o_rf_waddr;
      input  o_rf_wdata;
      input  o_rf_wen  ;
      input  o_rf_raddr;
      output i_rf_rdata;
      input  o_rf_ren  ;
   endclocking
   
   modport TB (output i_rst, clocking cb);
   
endinterface