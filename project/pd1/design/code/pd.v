module pd(
  input clock,
  input reset
);
reg [31:0 ]addr;
reg [31:0 ]data_in;
reg [31:0 ]data_out;
reg read_write;
imemory imemory_0(
  .clock(clock), 
  .address(addr), 
  .data_in(data_in), 
  .data_out(data_out)
)

endmodule
