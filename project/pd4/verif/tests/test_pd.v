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

  /* your code below */

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
      if (j == `MEM_DEPTH) begin 
        $finish;
      end
    end else begin
      $display("[F] %x %x", dut.core.`PROBE_ADDR, dut.core.`PROBE_DATA_OUT);
      $display("[D] %x %x %x %x %x %x %x %x %x", dut.core.addr, dut.core.op, dut.core.rd, dut.core.rs1, dut.core.rs2, dut.core.funct3, dut.core.funct7, dut.core.im, dut.core.shant );
      $display("[R] %x %x %x %x %x %x", dut.core.rs1, dut.core.rs2, dut.core.rd, dut.core.data_rs1, dut.core.data_rs2, dut.core.write_enable);
      $display("[E] %x %x %x %x", dut.core.addr, dut.core.alu_output, dut.core.effective_address , dut.core.bt);
      $display("[M] %x %x %x %x", dut.core.addr, dut.core.alu_output ,dut.core.read_write_mem, dut.core.access_size ,dut.core.data_out_d);
        $display("[W] %x %x %x %x", dut.core.addr, dut.core.write_enable, dut.core.rd, dut.core.data_rd);
  end;
  
  end


endmodule