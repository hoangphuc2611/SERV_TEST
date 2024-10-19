`timescale 1ns / 1ps

module servant_top_test ();
   
   parameter CYCLE = 10;
   
   bit SystemClock;
   
   reg [31:0] instruction;
   reg [31:0] address; 
   reg [7:0]  time_out;
   
   servant_if top_io (SystemClock);
   
   servant_test_program test (top_io);
   
   servant dut (
      .wb_clk(top_io.wb_clk),
      .wb_rst(top_io.wb_rst),
      .q     (top_io.q)
   );
   
   always #(CYCLE / 2) SystemClock = ~SystemClock;
   
   always @(posedge SystemClock) begin
      time_out = time_out + 8'b1;
      if (time_out[7]) $stop;
   end
   
   always @(posedge dut.cpu.cpu.i_ibus_ack) begin
      instruction <= dut.cpu.cpu.i_ibus_rdt;
      address     <= dut.cpu.cpu.o_ibus_adr; 
   end
   
   always @(dut.cpu.wb_ibus_rdt) time_out = 8'b0;
   
   initial begin
      SystemClock = 1'b0;
      time_out    = 8'b0;
   end
   
endmodule