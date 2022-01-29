module top;
  wire clock, reset;
  clockgen clkg(
    .clk(clock),
    .rst(reset)
  );


  reg[4:0] rs1, rs2, rd;

  wire[31:0] data_rs1, data_rs2;
  reg [31:0] data_rd;

  reg we;

  register_file dut(
    .clock(clock),
    .addr_rs1(rs1),
    .addr_rs2(rs2),
    .addr_rd(rd),
    .data_rd(data_rd),
    .data_rs1(data_rs1),
    .data_rs2(data_rs2),
    .write_enable(we)
  );
  integer counter = 0;
  integer errors = 0;

  always @(posedge clock) begin
    counter <= counter + 1;
    if(counter == 100) begin
      $display("[PD3] No error encountered");
      $finish;
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
  wire[31:0] dw;
  wire[31:0] pdw;
  wire[31:0] ldw;

  assign dw = (counter*counter+counter) << 16; // data to write
  assign pdw = ((counter - 1)*(counter - 1)+ counter - 1) << 16; // data written in the last 1 cycle
  assign ldw = ((counter - 2)*(counter - 2)+ counter - 2) << 16; // data written in the last 2 cycle

  always @(posedge clock) begin : register_file_test
    if(reset) begin
      rs1 <= 0;
      rs2 <= 0;
      rd  <= 5'h1f;
      data_rd <= 0;
      we  <= 0;
    end else begin
      if(reset_done) begin
        we <= 1;
        rd <= rd + 1;
        rs1 <= rd + 1;
        rs2 <= rd;
        data_rd <= dw;
        if(we) begin
          // $display("[PD3] Written to x%02d with 0x%x", rd, data_rd);
        end
        if(we && data_rs1 == pdw) begin
          $fatal(1, "[PD3] Register file should not bypass");
        end
        if(we && rd != 0) begin
          if(rs2 != 0 && data_rs2 != ldw) begin
            $fatal(1, "[PD3] x%02d should read-back written value, expected: 0x%x, got: 0x%x", rs2, ldw, data_rs2);
          end else if(rs2 == 0 && data_rs2 != 0) begin
            $fatal(1, "[PD3] x0 should always be 0 even written to");
          end
        end
      end
    end
  end


endmodule
