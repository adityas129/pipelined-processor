`include "signals.h"
module top;
  wire clock, reset;
  clockgen clkg(
    .clk(clock),
    .rst(reset)
  );
  design_wrapper dut(
    .clock(clock),
    .reset(reset)
  );

  /* these should be done more easily with SystemVerilog */
  reg      reset_done;
  reg      reset_neg;
  reg      reset_reg;
  integer  reset_counter;
  always @(posedge clock) begin
    if(reset) reset_counter <= 0;
    else      reset_counter <= reset_counter + 1;
    // detect negedge
    reset_reg <= reset;
    if(reset_reg && !reset) reset_neg <= 1;
    // delay for some cycles
    if(reset_neg && reset_counter >= 3) begin
      reset_done <= 1;
    end
  end

  // reg[31:0] data_in, expected_data;
  integer j = 0;

  initial begin
    // set addr to starting address
    dut.core.`PROBE_ADDR = 32'd16777216;
  end

  always @(posedge clock) begin
    if(reset_done) begin
      j <= j + 1;
      if (j < `NUM_LINES) begin 
           $display("[F] %x %x", dut.core.`PROBE_ADDR, dut.core.`PROBE_DATA_OUT);
            dut.core.`PROBE_ADDR <= dut.core.`PROBE_ADDR + 32'd4;
      end
    end else begin;
  end
  
  end


endmodule
