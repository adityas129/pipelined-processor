module pd(
  input clock,
  input reset
);

  reg [31:0 ]addr;
  reg [31:0 ]data_in;
  wire [31:0 ]data_out;
  reg read_write;

  imemory imemory_0(
    .clock(clock), 
    .address(addr), 
    .data_in(data_in), 
    .data_out(data_out), 
    .read_write(read_write)
  );


  reg[6:0]  op, funct7;  
  reg[31:0] im;
  reg[4:0] rs1, rs2, rd, shant;
  reg[2:0] funct3; 
  reg[1:0] valid = 0; 

  always @(posedge clock) begin
    addr <= addr + 4;
  end

  always @(data_out or posedge clock) begin
    op = data_out[6:0];
    case(op)
    // finish proper
      7'b0110111: begin 
        rd = data_out[11:7];
        funct3 = 0;
        rs1 = 0; 
        rs2 = 0; 
        funct7 = 0; 
        im = { data_out[31:12], 12'b0}; 
        shant = 0;
      end
      //  finish proper
      7'b0010111: begin 
        rd = data_out[11:7];
        funct3 = 0;
        rs1 = 0; 
        rs2 = 0; 
        funct7 = 0; 
        im = { data_out[31:12], 12'b0}; 
        shant = 0;
      end 
      //jtype... finish proper
      7'b1101111: begin 
        rd = data_out[11:7];
        funct3 = 0;
        rs1 = 0; 
        rs2 = 0; 
        funct7 = 0; 
        im = { {12{data_out[31]}}, data_out[19:12], data_out[20], data_out[30:25], data_out[24:21], 1'b0}; 
        shant = 0;
      end
      //jalr finish proper
      7'b1100111: begin 
        rd = data_out[11:7];
        funct3 = data_out[14:12];
        rs1 = data_out[19:15]; 
        rs2 = 0; 
        funct7 = 0; 
        im = { {21{data_out[31]}}, data_out[30:20]}; 
        shant = 0;
      end 
      //break bge etc. finish proper 
      7'b1100011: begin 
        rd = data_out[11:7];
        funct3 = data_out[14:12];
        rs1 = data_out[19:15]; 
        rs2 = data_out[24:20 ]; 
        funct7 = 0; 
        im = {{20{data_out[31]}}, data_out[7],data_out[30:25], data_out[11:8], 1'b0}; 
        shant = 0; 

      end    
      //lw lb etc. finish proper
      7'b0000011: begin 
        rd = data_out[11:7];
        funct3 = data_out[14:12];
        rs1 = data_out[19:15]; 
        rs2 = 5'b0; 
        funct7 = 7'b0; 
        im = {{21{data_out[31]}}, data_out[30:25], data_out[24:21], data_out[20]}; 
        shant = 0; 
      end    
      //sw sb etc.   finish proper
      7'b0100011: begin 
        rd = data_out[11:7];
        funct3 = 0;
        rs1 = data_out[19:15]; 
        rs2 =  data_out[24:20 ];
        funct7 = 7'b0; 
        im = {{21{data_out[31]}}, data_out[30:25], data_out[11:8], data_out[7]}; 

        shant = 0;     

      end 
      //stores s type  @TODO shamt stuff
      7'b0010011: begin
        if (data_out[12] == 1'b1 ) begin
          if (data_out[13] == 1'b0 ) begin
            rd = data_out[11:7];
            funct3 = data_out[14:12];
            rs1 = data_out[19:15]; 
            shant = data_out[24:20 ]; 
            funct7 = data_out[31:25]; 
            im = 0;
            rs2 = 0; 
          end else begin
            rd = data_out[11:7];
            funct3 = data_out[14:12];
            rs1 = data_out[19:15]; 
            rs2 = 0; 
            funct7 = 0; 
            im = { {21{data_out[31]}}, data_out[30:20]}; 
            shant = 0;
          end
        end else begin

        rd = data_out[11:7];
        funct3 = data_out[14:12];
        rs1 = data_out[19:15]; 
        rs2 = 0; 
        funct7 = 0; 
        im = { {21{data_out[31]}}, data_out[30:20]}; 
        shant = 0;
        end 
      end
      //finish proper
      7'b0110011: begin 
        rd = data_out[11:7];
        funct3 = data_out[14:12];
        rs1 = data_out[19:15]; 
        rs2 = data_out[24:20 ]; 
        funct7 = data_out[31:25]; 
        im = 0; 
        shant = 0;
      end
      //finish proper
      7'b1110011: begin 
        rd = 0;
        funct3 = 0;
        rs1 = 0; 
        rs2 = 0; 
        funct7 = 0; 
        im = 0; 
        shant = 0;
      end
      default: begin
        rd = 0;
        funct3 = 0;
        rs1 = 0; 
        rs2 = 0; 
        funct7 = 0; 
        im = 0; 
        shant = 0;
      end
    endcase
  end 
endmodule
