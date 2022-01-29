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


  always @(*) begin
    valid = 0;
    op = data_out[6:0];
    read_write_mem = 1'b0;
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
        rd = 0;
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
        rd = 0;
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
        write_enable = 0;
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



// end decoder 
//start fetch/alu compute

  reg [31:0] data_rd;
  reg [31:0] data_rs1;
  reg [31:0] data_rs2;
  reg write_enable; 
  reg [4:0] addr_rs1;
  reg [4:0] addr_rs2;
  reg [31:0] addr_write_to;
  reg [31:0] data_rd_1;
  reg [31:0] data_rs1_1;
  reg [31:0] data_rs2_1;
  reg write_enable_1; 
  reg [4:0] addr_rs2_1;
  reg [4:0] addr_rs1_1;
  reg [31:0] addr_actual_1;
  reg [31:0] alu_output;
 reg [31:0] effective_address; 
  reg pc_sel_jal;
  reg [31:0] pc_for_jal_to_write_back;
  reg bt;

  // //i think this is right? @understand 1
  register_file register_file_0(
    .clock(clock),
    .addr_rs1(rs1),
    .addr_rs2(rs2), 
    .addr_rd(rd), 
    .data_rd(data_rd), // decide in the writeback
    .data_rs1(data_rs1),
    .data_rs2(data_rs2),
    .write_enable(write_enable)
  );

  //two things needed to be implemented 
 //- i would need ot select btwn alu_output, pcoutput +4, or addr
//ask about upper immediate and load and exit condition
  always @( * ) begin 
    $display("PC: %x and reg address == %x \n rs1 == %x \n rs2 == %x", addr ,register_file_0.mem_reg[3], register_file_0.mem_reg[1], register_file_0.mem_reg[2]);
    $display("this is  control signals control %x \n\n opcode %x \n, rd : %x \n, rs1 : %x \n, rs2 : %x \n, im : %x \n, shant : %x \n", funct3, op, rd, rs1, rs2, im, shant);

    lb_cntr = 0;
    pc_for_jal_to_write_back = 32'b0;
    case(sel)
      4'b0: begin 
        bt = 1'b0;
        pc_sel_jal = 1'b0;
        //load upper add
        alu_output = im;
        // i don't htink anything needs to be done here
        // lui (Load Upper Immediate): this sets rd to a 32-bit value with the low 12 bits being 0 and the high 20 bits coming from the U-type immediate.
// auipc (Add Upper Immediate to Program Counter): this sets rd to the sum of the current PC and a 32-bit v
      end 
      4'b1: begin 
          //auipc
        bt = 1'b0;
        pc_sel_jal = 1'b0;


        alu_output = addr  + $signed(im);
          //same as lui - don't think anything needs to be done on execute phase
      end 
      //jal - doesn't use alu only effective addr
      4'b10: begin 
        pc_sel_jal = 1'b1;
        bt = 1'b0;
        //current
        pc_for_jal_to_write_back = addr;
        alu_output = addr + $signed(im);
      end 
      //jalr
      4'b11: begin  
        bt = 1'b0;
        pc_sel_jal = 1'b1; 
        pc_for_jal_to_write_back = addr;
        //gotta save and do $ra <— PC+4  
        //$ra <— return address store return address in register file 
        // alu_output = $signed(data_rs1) + $signed(im);
        alu_output = ($signed(data_rs1) + $signed(im))  & ('hFFFFFFFE);
      end 
      //beq/other breaks
      4'b100: begin 
        write_enable = 1'b0;
        pc_sel_jal = 1'b0;

        case(funct3) 
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
            if ($signed(data_rs1) >= $signed(data_rs2)) 
              bt = 1'b1;
            else
              bt = 1'b0;
          end
          3'b110: begin 
            if ((data_rs1) < (data_rs2)) begin
              // $display("leggoleggoleggoleggoleggoleggoleggoleggoleggoleggoleggoleggoleggoleggoleggo");
              bt = 1'b1;
            end else begin
              // $display("shootshootshootshootshootshootshootshootshootshootshootshootshootshootshootshootshoot");
              bt = 1'b0;          
            end
          end
          3'b111: begin
            // $display("hiiiii1 alu_output %x   data_rs4  %x   im   %x     ", alu_output, register_file_0.mem_reg[4], im);

            if ((data_rs1) >= (data_rs2)) begin
              // $display("leggoleggoleggoleggoleggoleggoleggoleggoleggoleggoleggoleggoleggoleggoleggo");
              bt = 1'b1;
            end else begin
              // $display("shootshootshootshootshootshootshootshootshootshootshootshootshootshootshootshootshoot");
              bt = 1'b0;
            end

           end
          //default 
          default: begin
            bt = 1'b0;
          end 
        endcase
      end 
  // end
      4'b101: begin  //lw ops
        bt = 1'b0;
        pc_sel_jal = 1'b0;

        //unsure how to do load word and store word
        // addr = data_rs1 + im;
        write_enable = 1'b1;
        alu_output = $signed(data_rs1) + $signed(im);
        lb_cntr = 1;
        case(funct3)
          3'b000: begin //signed but essentially the same logic when it comes to alu
            access_size = 2'b00;
          end
          3'b001: begin
            access_size = 2'b01;
            
          end
          3'b010: begin
            access_size = 2'b10;
          end
          3'b100: begin // unsigned 
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
        bt = 1'b0;
        pc_sel_jal = 1'b0;

//unsure how to do load word and store word
        alu_output = $signed(data_rs1) + $signed(im);

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
          default: begin
            access_size = 2'b10;
          end
        endcase
      end 

      //arithmetics with im
      4'b111: begin 
        pc_sel_jal = 1'b0;

        // $display("p---------addr %x", addr);
        bt = 1'b0;
        write_enable = 1'b1;
        if (imm_cntrl == 1'b0) begin
          if (funct3 == 3'b001) begin
            alu_output = data_rs1 << im[4:0];
          end else begin
            if (funct7 == 7'b0000000) begin
              alu_output = data_rs1 >> im[4:0];
            end else begin
              alu_output = $signed(data_rs1) >>> $signed(im[4:0]);
            end
          end 
        end else begin
          case (funct3)
            3'b000: begin
              alu_output = $signed(data_rs1) + $signed(im);
              // $display("hiiiii alu_output %x   data_rs1  %x   im   %x     ", alu_output, data_rs1, im);
            end
            3'b010: begin
              alu_output = ($signed(data_rs1) < $signed(im)) ? 1 : 0;
            end 
            3'b011: begin
              alu_output = ((data_rs1) < (im)) ? 1 : 0;
            end 
            3'b100: begin
              alu_output = data_rs1 ^ im;
            end 
            3'b110: begin
              alu_output = data_rs1 | im;
            end   
            3'b111: begin
              alu_output = data_rs1 & im;
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
        pc_sel_jal = 1'b0;

        bt = 1'b0;
        case (funct3)
          3'b000: begin 
            if (funct7 == 7'b0000000) begin
              alu_output = $signed(data_rs2) + $signed(data_rs1);
            end else begin
              alu_output = $signed(data_rs1) - $signed(data_rs2);
            end
          end 
          3'b001: begin 
            alu_output = $signed(data_rs1) << data_rs2[4:0];
          end
          3'b010: begin 
            alu_output = ($signed(data_rs1) < $signed(data_rs2)) ? 1 : 0;
          end
          3'b011: begin 
            alu_output = (data_rs1 < data_rs2) ? 1 : 0; 
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
        bt = 1'b0;
        pc_sel_jal = 1'b0;

        alu_output = 0;
      end 
      default: begin
        pc_sel_jal = 1'b0;

        bt = 1'b0;
        alu_output = 0;
      end
    endcase
    // $display("hiiiii2 alu_output %x   data_rs4  %x   im   %x    \n ---------- writeen  ", alu_output, register_file_0.mem_reg[4], im, write_enable);
    effective_address = alu_output;

  end

//current2
//branch comparator logic 
// if i am in a jal condition, then my alu computes my address otherwise
// if i am in a branch condition and it is successful my address is jumped to function else i just go down the pc
  always @( posedge clock) begin
    // $display("hiiiii3 alu_output %x   data_rs4  %x   im   %x    \n ---------- writeen  ", alu_output, register_file_0.mem_reg[4], im, write_enable);
    
    // addr <= ((pc_sel_jal) ?  : (bt ? (addr+im) : (addr + 4)));
    if (pc_sel_jal) begin
      $display(" sel1  ");
      addr <= alu_output;
    end else begin
      $display(" sel2");
      if (bt) begin
        addr <= (addr+im);
      end else begin
        addr <= (addr+4);
      end
      
    end 
    $display("these are the control signals here: pc_sel_jal %x \n, alu_output %x \n, bt %x\n,addragain %x \n",pc_sel_jal,alu_output,bt, addr );
    // bt = 1'b0;
  end 

  
  reg [31:0 ]data_in_d;
  wire [31:0 ]data_out_d;

  //memory -> incrementing pointer
  // always @(*) begin
  //   if (read_write_mem == 1'b0 ) begin 
  //     data_in_d = 
  //     data_out_d = 0
  //   end else begin

  //   end
//memory stage
  dmemory dmemory_0(
    .clock(clock), 
    .address(alu_output), 
    .data_in(data_in_d), 
    .data_out(data_out_d), 
    .read_write(read_write_mem), 
    .access_size(access_size)
  );

  //checkpoint - everything seems reasonable up till memory stage
  
  //write back

  //i'm going 
  always @( posedge clock  ) begin
    if (lb_cntr == 1) begin
      data_rd = data_out_d;
    end else begin
      write_enable = 1'b1;
      if (!pc_sel_jal) begin 
        data_rd = alu_output;
      end else begin
        data_rd = pc_for_jal_to_write_back + 4;
      end

    end
  end
endmodule

    // lb_cntr = 0;
    // pc_sel_jal = 1'b0;