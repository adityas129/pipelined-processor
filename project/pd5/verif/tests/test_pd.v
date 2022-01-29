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
    if(reset_done) beginz
      j <= j + 1;
      if (j == `MEM_DEPTH) begin 
        $finish;
      end
      $display("[F] %x %x", dut.core.`PROBE_ADDR, dut.core.`PROBE_DATA_OUT);
      $display("[D] %x %x %x %x %x %x %x %x %x", dut.core.pc_d, dut.core.op, dut.core.rd, dut.core.rs1, dut.core.rs2, dut.core.funct3, dut.core.funct7, dut.core.im, dut.core.shant );
      $display("[R] %x %x %x %x %x %x", dut.core.rs1, dut.core.rs2, dut.core.rd_w, dut.core.data_rs1_d, dut.core.data_rs2_d, dut.core.write_enable_w);
      $display("[E] %x %x %x %x", dut.core.pc_x, dut.core.alu_output, dut.core.effective_address , dut.core.bt);
      $display("[M] %x %x %x %x %x", dut.core.pc_m, dut.core.alu_m ,dut.core.read_write_mem_m, dut.core.access_size_m ,dut.core.data_out_d);
      $display("[W] %x %x %x %x", dut.core.pc_w, dut.core.write_enable_w, dut.core.rd_w, dut.core.data_rd_www);
    end else begin

  end;
  
  end
  always @(posedge clock) begin
      $display("[F] %x %x", dut.core.`PROBE_ADDR, dut.core.`PROBE_DATA_OUT);
      $display("[D] %x %x %x %x %x %x %x %x %x", dut.core.pc_d, dut.core.op, dut.core.rd, dut.core.rs1, dut.core.rs2, dut.core.funct3, dut.core.funct7, dut.core.im, dut.core.shant );
      $display("[R] %x %x %x %x %x %x", dut.core.rs1, dut.core.rs2, dut.core.rd_w, dut.core.data_rs1_d, dut.core.data_rs2_d, dut.core.write_enable_w);
      $display("[E] %x %x %x %x", dut.core.pc_x, dut.core.alu_output, dut.core.effective_address , dut.core.bt);
      $display("[M] %x %x %x %x %x", dut.core.pc_m, dut.core.alu_m ,dut.core.read_write_mem_m, dut.core.access_size_m ,dut.core.data_out_d);
      $display("[W] %x %x %x %x", dut.core.pc_w, dut.core.write_enable_w, dut.core.rd_w, dut.core.data_rd_www);
  end


endmodule