module pd(
  input clock,
  input reset
);

  reg [31:0 ]addr;
  reg [31:0 ]data_in;
  wire [31:0 ]data_out;
  reg read_write;
  wire [3:0] sel;
  wire  imm_cntrl;
  reg [1:0] access_size;
  wire lb_cntr;

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
  reg[1:0] valid; 
  reg read_write_mem;

  always @(posedge clock) begin
    addr <= addr + 4;
  end

  always @(data_out or posedge clock) begin
    valid = 0;
    op = data_out[6:0];
    case(op)
    // finish proper
      7'b0110111: begin 
        write_enable = 1;
        sel = 4'b0 ;
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
        write_enable = 1;
        sel = 4'b1 ;
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
        write_enable = 1;
        sel = 4'b10 ;
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
        write_enable = 1;
        sel = 4'b11 ;
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
        sel = 4'b100 ;
        write_enable = 0;
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
        read_write_mem = 1'b0;
        sel = 4'b101 ;
        write_enable = 1;

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
        read_write_mem = 1'b1;

        write_enable = 0;
        sel = 4'b110 ;
        rd = data_out[11:7];
        funct3 = 0;
        rs1 = data_out[19:15]; 
        rs2 =  data_out[24:20 ];
        funct7 = 7'b0; 
        im = {{21{data_out[31]}}, data_out[30:25], data_out[11:8], data_out[7]}; 

        shant = 0;     

      end 
      //stores addi slli type  @TODO shamt stuff
      7'b0010011: begin
        sel = 4'b111 ;
        write_enable = 1;

        if (data_out[12] == 1'b1 ) begin
          if (data_out[13] == 1'b0 ) begin
            rd = data_out[11:7];
            funct3 = data_out[14:12];
            rs1 = data_out[19:15]; 
            shant = data_out[24:20 ]; 
            funct7 = data_out[31:25]; 
            im = 0;
            rs2 = 0; 
            imm_cntrl = 1'b0;
          end else begin
            rd = data_out[11:7];
            funct3 = data_out[14:12];
            rs1 = data_out[19:15]; 
            rs2 = 0; 
            funct7 = 0; 
            im = { {21{data_out[31]}}, data_out[30:20]}; 
            shant = 0;
            imm_cntrl = 1'b1;
          end
        end else begin

        rd = data_out[11:7];
        funct3 = data_out[14:12];
        rs1 = data_out[19:15]; 
        rs2 = 0; 
        funct7 = 0; 
        im = { {21{data_out[31]}}, data_out[30:20]}; 
        shant = 0;
        imm_cntrl = 1'b1;

        end 
      end
      //finish proper
      7'b0110011: begin 
        sel = 4'b1000 ;
        write_enable = 1;

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
        sel = 4'b1001 ;
        write_enable = 0;

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

  reg [31:0] data_rd
  reg [31:0] data_rs1;
  reg [31:0] data_rs2;
  reg write_enable; 
  reg [4:0] addr_rs1;
  reg [4:0] addr_rs2;
  reg [31:0] addr_actual;
  reg [31:0] data_rd_1;
  reg [31:0] data_rs1_1;
  reg [31:0] data_rs2_1;
  reg write_enable_1; 
  reg [4:0] addr_rs1_1;
  reg [4:0] addr_rs2_1;
  reg [31:0] addr_actual_1;
  reg [31:0] alu_output;

  reg bt;

  // //i think this is right? @understand 1
  register_file register_file_0(
    .clock(clock),
    .addr_rs1(addr_rs1),
    .addr_rs2(addr_rs2),
    .addr_rd(addr_actual), 
    .data_rd(data_rd),
    .data_rs1(data_rs1),
    .data_rs2(data_rs2),
    .write_enable(write_enable)
  );

//ask about upper immediate and load and exit condition
  always @( * ) begin 
    lb_cntr = 0;
    case(sel)
      4'b0: begin 
        //load upper add
        alu_output = imm ;
        // i don't htink anything needs to be done here
        // lui (Load Upper Immediate): this sets rd to a 32-bit value with the low 12 bits being 0 and the high 20 bits coming from the U-type immediate.
// auipc (Add Upper Immediate to Program Counter): this sets rd to the sum of the current PC and a 32-bit v
      end 
      4'b1: begin 
          //auipc
        alu_output = addr  + $signed(imm);
          //same as lui - don't think anything needs to be done on execute phase
      end 
      //jal - doesn't use alu only effective addr
      4'b10: begin 
        bt == 1'b1;
      end 
      //jalr
      4'b11: begin  sw x0 4(0x10)
        //gotta save and do $ra <— PC+4  
        //$ra <— return address store return address in register file 
        addr_actual = ($signed(data_rs1) + $signed(imm)) & 0xFFFFFFFE;
        alu_output = $signed(data_rs1) + $signed(imm);
      end 
      //beq/other breaks
      4'b100: begin 
        case(funct3) begin
          3'b000: begin 
            if (data_rs1 == data_rs2) 
              bt = 1'b1;
            else
              bt = 1'b0;
          end
          3'b001: begin
            if (data_rs1 != data_rs2) 
              bt = 1'b1;
            else
              bt = 1'b0;
           end
          3'b100: begin 
            if ($signed(data_rs1) < $signed(data_rs2)) 
              bt = 1'b1;
            else
              bt = 1'b0;
          end
          3'b101: begin 
            if ($signed(data_rs1) > $signed(data_rs2)) 
              bt = 1'b1;
            else
              bt = 1'b0;
          end
          3'b110: begin 
              bt = ((data_rs1) < (imm)) ? 1'b1 : 1'b0;
          end
          3'b111: begin
              bt = ((data_rs1) > (imm)) ? 1'b1 : 1'b0;
           end
          //default 
          default: begin
            bt = 1'b0;
          end 
        endcase
        end 
      end 
      4'b101: begin 
        //unsure how to do load word and store word
        addr_actual = data_rs1 + imm;
        alu_output = data_rs1 + imm;
        lb_cntr = 1;
        case(funct3)
          3'b000: begin
            access_size = 2'b00;
          end
          3'b001: begin
            access_size = 2'b01;
            
          end
          3'b010: begin
            access_size = 2'b10;
          end
          3'b100: begin
            access_size = 2'b00;
          end
          3'b101: begin

            access_size = 2'b01;
          end
          default: begin
            access_size = 2'b10;
          end

        endcase
      end 
      4'b110: begin 
//unsure how to do load word and store word
        addr_actual = data_rs1 + imm;
        alu_output = data_rs1 + imm;

        case(funct3)
          3'b000: begin
            access_size = 2'b00;
          end
          3'b001: begin
            access_size = 2'b01;
            
          end
          3'b010: begin
            access_size = 2'b10;
          default: begin
            access_size = 2'b10;
          end
        endcase
      end 

      //arithmetics with imm
      4'b111: begin 
        if (imm_cntrl == 1'b0) begin
          if (funct3 == 3'b001) begin
            alu_output = data_rs1 << imm[4:0];
          end else begin
            if (funct7 == 7'b0000000) begin
              alu_output = data_rs1 >> imm[4:0];
            end else begin
              alu_output = $signed(data_rs1) >>> imm[4:0];
            end
          end 
        end else begin
          case (funct3)
            3'b000: begin
              alu_output = data_rs1 + imm;
            end
            3'b010: begin
              alu_output = ($signed(data_rs1) < $signed(imm)) ? 1'b1: 1'b0;
            end 
            3'b011: begin
              alu_output = ((data_rs1) < (imm)) ? 1'b1 : 1'b0;
            end 
            3'b100: begin
              alu_output = data_rs1 ^ imm;
            end 
            3'b110: begin
              alu_output = data_rs1 | imm;
            end   
            3'b111: begin
              alu_output = data_rs1 & imm;
            end
            default: begin
              alu_output = 0;
            end 
            //add default
          endcase
        end 
      end
      //hardcore arithmetics
      4'b1000: begin 
        case (funct3): 
          3'b000: begin 
            if (funct7 == 7'b0000000) begin
              alu_output = data_rs2 + data_rs1;
            end else begin
              alu_output = data_rs1 - data_rs2;
            end
          end 
          3'b001: begin 
            alu_output = data_rs1 << data_rs2[4:0];
          end
          3'b010: begin 
            alu_output = ($signed(data_rs1) < $signed(data_rs2)) ? 1'b1 : 1'b0;
          end
          3'b011: begin 
            alu_output = (data_rs1 < data_rs2) ? 1'b1 : 1'b0; 
          end
          3'b100: begin 
            alu_output = data_rs1 ^ data_rs2; 
          end
          3'b101: begin 
            if (funct7 == 7'b0000000) begin
              alu_output = data_rs1 >> data_rs2[4:0]; 
            end else begin
              alu_output = $signed(data_rs1) >> data_rs2[4:0]; 
            end
          end
          3'b110: begin 
            alu_output = data_rs1 | data_rs2;
          end
          3'b111: begin 
            alu_output = data_rs1 & data_rs2;
          end
          default: begin
              alu_output = 0;
          end 
        endcase
      end 
      4'b1001: begin 
        alu_output = 0;
      end 
      default: begin
        alu_output = 0;
      end
    endcase
  end


//add branch comparator logic 
  always @(bt) begin
    if (bt == 1'b1) begin
      alu_output = (addr + imm);
    end else begin
      alu_output = (addr + 4); //maybe don't need if always incrementing in writeback
    end 
    addr = alu_output;
    addr_actual = alu_output;
  end 

  reg [31:0 ]data_in_d;
  wire [31:0 ]data_out_d;

  //memory -> incrementing pointer
  always @(*) begin
    if (read_write_mem == 1'b0 ) begin 
      data_in_d = 
      data_out_d = 0
    end else begin

    end

  dmemory dmemory_0(
    .clock(clock), 
    .address(alu_output), 
    .data_in(data_in_d), 
    .data_out(data_out_d), 
    .read_write(read_write_mem), 
    .access_size(access_size)
  );
  
  //write back
  register_file register_file_1(
    .clock(clock),
    .addr_rs1(addr_rs1_1),
    .addr_rs2(addr_rs2_1),
    .addr_rd(addr_actual_1), 
    .data_rd(data_out_d),
    .data_rs1(data_rs1_1),
    .data_rs2(data_rs2_1),
    .write_enable(write_enable)
  );
  always @(data_out or posedge clock  ) begin
    if (lb_cntr == 1) begin
      data_rd = data_out_d;
    end else begin
      data_rd = alu_output;
    end

  end

endmodule
