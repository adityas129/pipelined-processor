/* dummy module for verilog tests */
module imemory(
  input             clock,
  input [31:0]      address,
  input [31:0]      data_in,
  output wire[31:0] data_out,
  input             read_write
);

endmodule

module dmemory(
  input             clock,
  input [31:0]      address,
  input [31:0]      data_in,
  output wire[31:0] data_out,
  input             read_write,
  input [1:0]       access_size
);

endmodule

module top(
  input wire        clock,
  input wire        reset,
  output wire[31:0] pc
);
  design_wrapper dut(
    .clock(clock),
    .reset(reset)
  );

  assign pc = dut.core.`PC;
endmodule
