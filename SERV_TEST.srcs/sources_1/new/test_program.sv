`timescale 1ns / 1ps
/*
   SERV uses positive reset (i_rst = 1 ==> reset)
*/
program automatic test_program(
   serv_if.TB top_io
);
   localparam DW = 32; // Data width
   localparam AW = 32; // Address width 
      
   // Instruction bus signals
   reg [31:0] ibus_mem [0:1023];
   reg [31:0] ibus_dat;
   reg [31:0] ibus_adr;
   
   // Data bus signals
   reg [31:0] dbus_mem [0:1023];
   reg [31:0] dbus_adr;
   reg [31:0] dbus_dat;
   reg [ 3:0] dbus_sel;
   reg        dbus_we;
   
   integer stage_count; 
   
   integer ibus_num;
   integer dbus_read_num;
   integer dbus_write_num;
   
   initial begin
      $readmemh("test_instruction_hex.txt", ibus_mem);
      $readmemh("test_data_hex.txt", dbus_mem);
      reset();
      forever begin
         @(top_io.cb) stage_count = stage_count + 1'b1;
      end
   end
      
   task reset();
      top_io.i_rst = 1'b1;
      $display("%8d\t| ------- RESET START -------", $time);
      repeat(3) @(top_io.cb);
      top_io.i_rst = 1'b0;
      $display("%8d\t| ------- RESET DONE -------", $time);
   endtask : reset
   
   // INSTRUCTION BUS BEHAVIOUR
   initial begin
      ibus_num = 0;
      forever begin
         wb_ibus_init();
         ibus_adr = top_io.cb.o_ibus_adr;
         ibus_dat = ibus_mem[ibus_adr[31:2]];
         wb_ibus_next();
      end
   end   
   
   // INSTRUCTION BUS TASK -------
   task wb_ibus_init();
      $display("%8d\t| Inst #%0d\t%0s %0s", $time, ibus_num, "WB_IBUS_INIT", "START");
      top_io.cb.i_ibus_ack <= 1'b0;
      top_io.cb.i_ibus_rdt <= {DW{1'b0}};
      
      if (top_io.i_rst !== 1'b0) begin
         @(negedge top_io.i_rst);
         // @(top_io.cb);
      end
      
      //Catch start of next cycle
      if (!top_io.cb.o_ibus_cyc) begin
         @(posedge top_io.cb.o_ibus_cyc);
      end
      
      //Make sure that wb_cyc_i is still asserted at next clock edge to avoid glitches
      while(top_io.cb.o_ibus_cyc !== 1'b1)
         @(top_io.cb);
         
      ibus_adr = top_io.cb.o_ibus_adr;
      $display("%8d\t| Inst #%0d\t%0s %0s", $time, ibus_num, "WB_IBUS_INIT", "DONE");
   endtask

   task wb_ibus_next();
      $display("%8d\t| Inst #%0d\t%0s %0s", $time, ibus_num, "WB_IBUS_NEXT", "START");
      top_io.cb.i_ibus_rdt <= ibus_dat;
      top_io.cb.i_ibus_ack <= 1'b1 ;
      
      @(top_io.cb);
      
      top_io.cb.i_ibus_rdt <= 32'b0;
      top_io.cb.i_ibus_ack <= 1'b0;
      $display("%8d\t| Inst #%0d\t%0s %0s", $time, ibus_num, "WB_IBUS_NEXT", "DONE");
      ibus_num = ibus_num + 1;
         stage_count = 0;
      @(negedge top_io.cb.o_ibus_cyc);
   endtask
   // ----------------------------
   
   // DATA BUS BEHAVIOUR   
   initial begin
      dbus_write_num = 0;
      dbus_read_num  = 0;
      forever begin
         wb_dbus_init();
         dbus_adr = top_io.cb.o_dbus_adr;
         if (top_io.cb.o_dbus_we === 1'b1) begin // WRITE
            wb_dbus_read_ack(dbus_dat);
            for (int i=0; i < DW/8; i=i+1) begin
               if (dbus_sel[i]) begin
                  dbus_mem[dbus_adr[31:2]][i*8+:8] = dbus_dat[i*8+:8];
               end
            end
         end else begin // READ
            dbus_dat = {DW{1'b0}};
            for (int i=0; i < DW/8; i=i+1) begin
               if (top_io.cb.o_dbus_sel[i]) begin
                  dbus_dat[i*8+:8] = dbus_mem[dbus_adr[31:2]][i*8+:8];
               end
            end
            wb_dbus_read_ack(dbus_dat);
         end
         if (top_io.cb.o_dbus_we === 1'b1) begin
            dbus_write_num = dbus_write_num + 1'b1;
         end else begin
            dbus_read_num  = dbus_read_num  + 1'b1;
         end
      end
   end
   
   // DATA BUS task --------------
   task wb_dbus_init();
      begin
         top_io.cb.i_dbus_ack <= 1'b0;
         top_io.cb.i_dbus_rdt <= {DW{1'b0}};

         if(top_io.i_rst !== 1'b0) begin
            @(negedge top_io.i_rst);
            @(top_io.cb);
         end

         //Catch start of next cycle
         if (!top_io.cb.o_dbus_cyc)
            @(posedge top_io.cb.o_dbus_cyc);

         //Make sure that wb_cyc_i is still asserted at next clock edge to avoid glitches
         while(top_io.cb.o_dbus_cyc !== 1'b1)
            @(top_io.cb);
            
         dbus_we  = top_io.cb.o_dbus_we;
         dbus_adr = top_io.cb.o_dbus_adr;
         dbus_sel  = top_io.cb.o_dbus_sel;
      end
   endtask

   task wb_dbus_read_ack(input [DW-1:0] data_i);
      dbus_dat = data_i;
      wb_dbus_next();
   endtask

   task wb_dbus_write_ack(output [DW-1:0] data_o);
      wb_dbus_next();
      data_o = dbus_dat;
   endtask

   task wb_dbus_next();
      top_io.cb.i_dbus_rdt <= {DW{1'b0}};
      top_io.cb.i_dbus_ack <= 1'b0;
      
      if(dbus_we === 1'b0) // READ
         top_io.cb.i_dbus_rdt <= dbus_dat;
      top_io.cb.i_dbus_ack <= 1'b1;
      
      @(top_io.cb);

      top_io.cb.i_dbus_ack <= 1'b0;

      if(dbus_we === 1'b1) begin // WRITE
         dbus_dat = top_io.cb.o_dbus_dat;
         dbus_sel = top_io.cb.o_dbus_sel;
      end
      
      // dbus_adr = top_io.cb.o_dbus_adr;
      
      // top_io.cb.i_dbus_rdt <= 32'b0;
      
      @(negedge top_io.cb.o_ibus_cyc);
   endtask
   // ----------------------------
endprogram