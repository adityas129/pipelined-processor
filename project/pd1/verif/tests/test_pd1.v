`include "signals.h"
module top;
  wire clock, reset;
  clockgen clkg(
    .clk(clock),
    .rst(reset)
  );
  design_wrapper dut(
    .clock(clock),
    .reset(reset)
  );
  integer counter = 0;
  integer errors = 0;

  always @(posedge clock) begin
    counter <= counter + 1;
    if(counter == 100) begin
      $fatal(1, "[PD1] Timeout");
    end
  end

  /* these should be done more easily with SystemVerilog */
  reg      reset_done;
  reg      reset_neg;
  reg      reset_reg;
  integer  reset_counter;
  always @(posedge clock) begin
    if(reset) reset_counter <= 0;
    else      reset_counter <= reset_counter + 1;
    // detect negedge
    reset_reg <= reset;
    if(reset_reg && !reset) reset_neg <= 1;
    // delay for some cycles
    if(reset_neg && reset_counter >= 3) begin
      reset_done <= 1;
    end
  end

  /* macro definition checking */
  `ifdef PROBE_ADDR `ifdef PROBE_DATA_IN `ifdef PROBE_DATA_OUT `ifdef PROBE_READ_WRITE
    `define PROBE_OK
  `endif `endif `endif `endif
  `ifndef PROBE_OK
    initial $fatal(1, "[PD1] Signal(s) not defined");
  `else

  localparam VECTOR_SIZE  = 32 + 32 + 32 + 4;

  reg[VECTOR_SIZE - 1:0] test_vector[0:1024];
  reg[31:0] addr, data_in, expected_data;
  reg[31:0] n_vec = 0;
  reg[3:0]  rw;
  reg[31:0] vec_counter = 1;
  reg[31:0] data_out;
  initial begin
    $readmemh(`TEST_VECTOR, test_vector);
    {n_vec, data_in, expected_data, rw} = test_vector[0];
    $display("[PD1] %d test vector(s)", n_vec);
  end
  always @(vec_counter) begin
    {addr, data_in, expected_data, rw} = test_vector[vec_counter];
    dut.core.`PROBE_ADDR       = addr;
    dut.core.`PROBE_DATA_IN    = data_in;
    dut.core.`PROBE_READ_WRITE = rw[0];
  end
  always @(posedge clock) begin
    if(reset_done) begin
      vec_counter <= vec_counter + 1;
      if(vec_counter == n_vec + 1) begin
        $display("[PD1] No error encountered");
        $finish;
      end else begin
        $display("[PD1] %t Test Vector: %x %x %x %b", $time, addr, data_in, expected_data, rw[0]);
        if(rw == 0) begin // read data
          if(dut.core.`PROBE_DATA_OUT !== expected_data) begin
            $fatal(1, "[PD1] Error at test vector %d, got %x, expected %x", 
              vec_counter, dut.core.`PROBE_DATA_OUT, expected_data);
          end
        end else begin
        end
      end
      
    end
  end
  
  `endif

endmodule
