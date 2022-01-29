
module register_file(
  input  clock,
  input  wire [4:0] addr_rs1,
  input  wire [4:0] addr_rs2,
  input  wire [4:0] addr_rd,
  input  wire [31:0] data_rd,
  output reg [31:0] data_rs1,
  output reg [31:0] data_rs2,
  input  reg write_enable
);



reg[31:0] mem_reg [31:0];
integer i;
initial  begin 
    for (i = 0; i <32; i++) begin
        mem_reg[i] = 0;
    end
    mem_reg[2] = 32'h01000000 + `MEM_DEPTH;
    
    
end


always @(addr_rs1 or addr_rs2 ) begin
    data_rs1 = mem_reg[addr_rs1];
    data_rs2 = mem_reg[addr_rs2];
end

always @(posedge clock) begin
        // $display("write_enable %x \n, addr_rd %x \n, data being written %x \n  ",write_enable, addr_rd, data_rd );
        if (write_enable == 1 && addr_rd!= 0) begin
            mem_reg[addr_rd] = data_rd;
        end
end

endmodule