/**
* Exercise 3.4
* you can change the code below freely
  * */
module reg_and_reg(
  input wire clock,
  input wire reset,
  input wire x,
  input wire y,
  output reg z
);

  reg x_in = 0;
  reg y_in = 0;
  always @(posedge clock) begin
	if (reset)
		z <= 0;
	else
		x_in <= x;
		y_in <= y ;

 		z <= x_in & y_in;
  end
endmodule
