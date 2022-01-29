
module imemory(
  input  wire clock,
  input wire address, //may be a reg
  input wire data_in, //may be a reg like this in input [31:0] data_in
  output wire data_out, //may be a reg
  output reg read_write
);
reg [31:0] temp_array [(MEM_DEPTH -1)/4:0];
initial begin 
  $readmemh(`MEM_PATH,temp_array );
end
  assign z = x & y;
endmodule // and_assign
