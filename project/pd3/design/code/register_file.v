
module register_file(
  input  clock,
  input  [4:0] addr_rs1;
  input  [4:0] addr_rs2;
  input  [4:0] addr_rd;
  input  [31:0] data_rd,
  output reg [31:0] data_rs1,
  output reg [31:0] data_rs2,
  input  write_enable
);


reg[31:0] mem_reg [31:0];
integer i;
initial  begin 
    for (i = 0; i <32; i++) begin
        mem_reg[i] = 0;
    end
    mem_reg[2] = 0x01000000 + `MEM_DEPTH;
    
    
end


always @(addr_rs1 or addr_rs2 ) begin
    data_rs1 = mem_reg[addr_rs1];
    data_rs2 = mem_reg[addr_rs2];
end

always @(posedge clock) begin
        if (write_enable == 1 && addr_rd!= 0) begin
            mem_reg[addr_rd] = data_rd;
        end
end

endmodule