`include "./signals.h"

module design_wrapper(
  // Input to the design
  input wire clock,
  input wire reset
);

  `TOP_MODULE core(
    .clock(clock),
    .reset(reset)
  );

endmodule
