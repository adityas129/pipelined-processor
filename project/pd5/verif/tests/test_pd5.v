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

  /* your code below */
  `ifdef PC `ifdef INSN 
    `ifdef REGISTER_WRITE_ENABLE `ifdef REGISTER_WRITE_DESTINATION 
      `ifdef REGISTER_WRITE_DATA `ifdef REGISTER_READ_RS1 
        `ifdef REGISTER_READ_RS2 `ifdef REGISTER_READ_RS1_DATA 
          `ifdef REGISTER_READ_RS2_DATA    
            `define PROBES_OK
          `endif
        `endif `endif
      `endif `endif
    `endif `endif
  `endif `endif
  `ifndef PROBES_OK
    initial begin
      $fatal(1, "[PD5] Probes not defined");
    end
  `else
    initial begin
      $display("PC:        %x", dut.core.`PC);
      $display("INSN:      %x", dut.core.`INSN);
      $display("RegWE:     %b", dut.core.`REGISTER_WRITE_ENABLE);
      $display("RegRd:     %x", dut.core.`REGISTER_WRITE_DESTINATION);
      $display("RegWData:  %x", dut.core.`REGISTER_WRITE_DATA);
      $display("RegRS1:    %x", dut.core.`REGISTER_READ_RS1);      
      $display("RegRS2:    %x", dut.core.`REGISTER_READ_RS2);        
      $display("RegR1Data: %x", dut.core.`REGISTER_READ_RS1_DATA);
      $display("RegR2Data: %x", dut.core.`REGISTER_READ_RS2_DATA);   

      $display("[PD5] No error encountered");
      $finish;
    end
  `endif


endmodule
