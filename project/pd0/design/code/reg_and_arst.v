module reg_and_arst(
  input  wire clock,
  input  wire areset,
  input  wire x,
  input  wire y,
  output reg  z
);
  always @(posedge clock, posedge areset) begin
    if (areset)
	    z <= 0;
    else
    	z <= x & y;
  end
endmodule
