module tb;
  // clock
  logic clk;
  logic rst;
  clockgen cb(.clk(clk), .rst(rst));
  top top(
    .clock(clk),
    .reset(rst)
  );

  task load_program;
    // path?
  endtask
endmodule;
