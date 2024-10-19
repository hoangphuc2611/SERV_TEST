`timescale 1ns / 1ps

interface servant_if (input bit wb_clk);
   
   logic wb_rst;
   logic q;
   
   default clocking cb @(posedge wb_clk);
      default input #0ns output #0ns;
      
      output wb_rst;
      input  q;
   endclocking
   
   modport TB (output wb_rst, clocking cb);
   
endinterface