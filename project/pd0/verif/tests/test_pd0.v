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
  integer counter = 0;
  integer errors = 0;

  always @(posedge clock) begin
    counter <= counter + 1;
    if(counter == 100) begin
      $display("[PD0] No error encountered");
      $finish;
    end
  end

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

  /**
  * assign_and test 
  * */
  reg assign_and_x, assign_and_y, assign_and_z;
  always @(*) begin : assign_and_input
    dut.core.`ASSIGN_AND_X = counter[0];
    dut.core.`ASSIGN_AND_Y = counter[1];
  end
  always @(posedge clock) begin: assign_and_test
    if(reset_done) begin
      if((assign_and_x & assign_and_y) != assign_and_z || assign_and_x === 1'bx || assign_and_y === 1'bx || assign_and_z === 1'bx) begin
        $fatal(1, "\n[PD0] assign_and_test: x=%b, y=%b, z=%b", assign_and_x, assign_and_y, assign_and_z);
      end
    end
    assign_and_x <= dut.core.`ASSIGN_AND_X;
    assign_and_y <= dut.core.`ASSIGN_AND_Y;
    assign_and_z <= dut.core.`ASSIGN_AND_Z;
  end

  /** 
  * reg_and_arst test 
  * */
  `ifdef PROBE_EX33_ARESET `ifdef PROBE_EX33_X `ifdef PROBE_EX33_Y `ifdef PROBE_EX33_Z
          `define EX33_SIGNAL_OK
  `endif `endif `endif `endif
  `ifdef EX33_SIGNAL_OK
  reg reg_and_arst_arst, reg_and_arst_x_and_y, reg_and_arst_z, reg_and_arst_x, reg_and_arst_y;
  // set areset at negative edge
  initial begin
    dut.core.`PROBE_EX33_ARESET = 0;
  end
  always @(negedge clock or posedge clock) begin : reg_and_arst_async_reset
    if(clock) dut.core.`PROBE_EX33_ARESET <= 0;
    else      dut.core.`PROBE_EX33_ARESET <= counter[2];
  end
  always @(*) begin : reg_and_arst_input
    dut.core.`PROBE_EX33_X = counter[0];
    dut.core.`PROBE_EX33_Y = counter[1];
  end
  always @(posedge clock) begin : reg_and_arst_test
    reg_and_arst_x_and_y <= dut.core.`PROBE_EX33_X & dut.core.`PROBE_EX33_Y && !dut.core.`PROBE_EX33_ARESET;
    reg_and_arst_x       <= dut.core.`PROBE_EX33_X;
    reg_and_arst_y       <= dut.core.`PROBE_EX33_Y;
    reg_and_arst_arst    <= dut.core.`PROBE_EX33_ARESET;
    if(reset_done) begin
      if(dut.core.`PROBE_EX33_ARESET) begin
        if(dut.core.`PROBE_EX33_Z !== 1'b0) begin
          $fatal(1, "\n[PD0] Exercise 3.3: reset is incorrect");
        end
      end else begin
        if(reg_and_arst_x_and_y != dut.core.`PROBE_EX33_Z) begin
          $fatal(1, "\n[PD0] Exercise 3.3: arst=%b, x=%b, y=%b, z=%b, z should be %b", reg_and_arst_arst, reg_and_arst_x, reg_and_arst_y, dut.core.`PROBE_EX33_Z, reg_and_arst_x_and_y);
        end
      end
    end
  end
  `else
  always @(posedge clock) begin : reg_and_arst_test
    $fatal(1, "\n[PD0] Signal(s) for exercise 3.3 is not defined in signals.h");
  end
  `endif

  /** 
  * reg_and_reg test 
  * */
  `ifdef PROBE_EX34_X `ifdef PROBE_EX34_Y `ifdef PROBE_EX34_Z
          `define EX34_SIGNAL_OK
  `endif `endif `endif
  `ifdef EX34_SIGNAL_OK
  reg[1:0] reg_and_reg_x;
  reg[1:0] reg_and_reg_y;
  reg      reg_and_reg_z;
  always @(*) begin : reg_and_reg_input
    dut.core.`PROBE_EX34_X = counter[0];
    dut.core.`PROBE_EX34_Y = counter[1];
  end
  always @(posedge clock) begin : reg_and_reg_test
    reg_and_reg_x[0]       <= dut.core.`PROBE_EX34_X;
    reg_and_reg_y[0]       <= dut.core.`PROBE_EX34_Y;
    reg_and_reg_x[1]       <= reg_and_reg_x[0];
    reg_and_reg_y[1]       <= reg_and_reg_y[0];
    if(reset_done) begin  // not testing reset for this case
      if((reg_and_reg_x[1] & reg_and_reg_y[1]) != dut.core.`PROBE_EX34_Z || reg_and_reg_x[1] === 1'bx || reg_and_reg_x[1] === 1'bx || dut.core.`PROBE_EX34_Z === 1'bx) begin
        $fatal(1, "\n[PD0] Exercise 3.4: x=%b, y=%b, z=%b, z should be %b", reg_and_reg_x[1], reg_and_reg_y[1], dut.core.`PROBE_EX34_Z, reg_and_reg_x[1] & reg_and_reg_y[1]);
      end
    end
  end
  `else
  always @(posedge clock) begin : reg_and_reg_test
    $fatal(1, "\n[PD0] Signal(s) for exercise 3.4 is not defined in signals.h");
  end
  `endif
  initial begin
	  $dumpfile("dump.vcd");
	  $dumpvars(0,dut.core);
  end

endmodule
