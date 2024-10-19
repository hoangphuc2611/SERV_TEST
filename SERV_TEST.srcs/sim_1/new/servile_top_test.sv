`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2024 01:15:54 PM
// Design Name: 
// Module Name: servile_top_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module servile_top_test();
   
   parameter CYCLE = 10;
   
   bit SystemClock;
   
   reg [7:0] time_out;
   
   servile_if top_io (SystemClock);
   
   servile_test_program test (top_io);
   
   
   
   always #(CYCLE / 2) SystemClock = ~SystemClock;
   
   always @(posedge SystemClock) begin
      time_out = time_out + 8'b1;
      if (time_out[7]) $stop;
   end
   
   always @(top_io.clk) time_out = 8'b0;
   
   initial begin
      SystemClock = 1'b0;
      time_out    = 8'b0;
   end

endmodule
