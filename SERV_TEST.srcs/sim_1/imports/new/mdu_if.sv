`timescale 1ns / 1ps

interface mdu_if#(
   parameter WIDTH = 32
)(
   input bit i_clk
);

   logic             i_rst;
   logic [WIDTH-1:0] i_mdu_rs1;
   logic [WIDTH-1:0] i_mdu_rs2;
   logic [2:0]       i_mdu_op;
   logic             i_mdu_valid;
   logic             o_mdu_ready;
   logic [WIDTH-1:0] o_mdu_rd;
   
   default clocking cb @(posedge i_clk);
      default input #0ns output #0ns;
      
      output i_rst;
      output i_mdu_rs1;
      output i_mdu_rs2;
      output i_mdu_op;
      output i_mdu_valid;
      input  o_mdu_ready;
      input  o_mdu_rd;
   
   endclocking
   
   modport TB(clocking cb, output i_rst);
   
endinterface
