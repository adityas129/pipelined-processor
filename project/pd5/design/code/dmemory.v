module dmemory(
  input wire clock,
  input wire [31:0] address,
  input wire [31:0] data_in,
  output reg [31:0] data_out,
  input wire read_write,
  input wire [1:0] access_size,
  input wire is_signed //is it signed
);

localparam ZERO = 8'b00000000;

reg [31:0] temp_memory [0:(`MEM_DEPTH/4)];
reg [7:0] main_memory [0:`MEM_DEPTH - 1];

integer i;
integer z = 0;
wire [31:0] actual_addr;
assign actual_addr = address - 32'h01000000; 

initial begin

    $readmemh(`MEM_PATH, temp_memory);
    for (z = 0; z < 10; z++) begin
      // $display("temp_memory[%d]: %x", z, temp_memory[z]);
    end
      z = 0;
      for (i = 0; i < `MEM_DEPTH; i=i+4) begin
        /* verilator lint_off WIDTH */
            main_memory[i] = temp_memory[z][7:0];
            main_memory[i+1] = temp_memory[z][15:8];
            main_memory[i+2] = temp_memory[z][23:16];
            main_memory[i+3] = temp_memory[z][31:24];
            z = z + 1;
            if (i < 10) begin
              // $display("main_memory[%d]: %x", i, main_memory[i]);
              // $display("main_memory[%d]: %x", i+1, main_memory[i+1]);
              // $display("main_memory[%d]: %x", i+2, main_memory[i+2]);
              // $display("main_memory[%d]: %x", i+3, main_memory[i+3]);
            end
      end
end
 //whenever a 32-bit address is supplied on the address line, main mem returns 32-bits onto data_out usnig little-endian ordering 
  always @(posedge clock) begin
    $display("readwrite from sw %x", read_write);
	  if (read_write == 1) begin
        $display("access size sw dmmmmmmdmmmmmm----------------%x", access_size );
      
          // do a write
        case (access_size) 
          2'b00: begin
            main_memory[actual_addr] <= data_in[7:0];
          end
          2'b01: begin
            main_memory[actual_addr+1] <= data_in[15:8];

            main_memory[actual_addr] <= data_in[7:0];

          end
          2'b10: begin
            main_memory[actual_addr+3] <= data_in[31:24];
            main_memory[actual_addr+1] <= data_in[15:8];

            main_memory[actual_addr] <= data_in[7:0];

            main_memory[actual_addr+2] <= data_in[23:16];
            
          end
          default: begin
          end
         
      endcase

  end  
  end
    //read ops

always@(actual_addr, read_write, access_size) begin
      $display("readwrite from lw %x", read_write);

        $display("access size lwdmmmmmmdmmmmmm ____%x", access_size );
        data_out = { main_memory[actual_addr +3 ], main_memory[actual_addr + 2],  main_memory[actual_addr + 1],main_memory[actual_addr + 0] };
        $display("data out ________________________ ____%x", data_out );

//         if (is_signed) begin 

//         case (access_size) 
//           2'b00: begin
//             data_out = {{8{main_memory[actual_addr][7]}}, {8{main_memory[actual_addr][7]}}, {8{main_memory[actual_addr][7]}}, main_memory[actual_addr]};
//           end
//           2'b01: begin
//             data_out = {{8{main_memory[actual_addr][7]}}, {8{main_memory[actual_addr][7]}}, main_memory[actual_addr+1],main_memory[actual_addr]} ;
//           end
//           2'b10: begin
//             data_out = { main_memory[actual_addr +3 ], main_memory[actual_addr + 2],  main_memory[actual_addr + 1],main_memory[actual_addr + 0] };
//           end
//           default: begin
//           end
//         endcase
//         $display("data out %x", data_out);
//         end else begin 

//         case (access_size) 
//           2'b00: begin
//             data_out = {ZERO, ZERO, ZERO, main_memory[actual_addr]};
//           end
//           2'b01: begin
//             data_out = {ZERO, ZERO, main_memory[actual_addr+1],main_memory[actual_addr]} ;
//           end
//           default: begin
//           end
//       endcase
// end
end



// always @(actual_addr) begin
//   $display("%x", actual_addr);
// end
  
endmodule