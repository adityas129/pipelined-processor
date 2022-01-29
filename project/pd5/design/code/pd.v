module pd(
  input clock,
  input reset
);

//----------------------------------------------------------------------
//1fetch
//----------------------------------------------------------------------
wire [31:0 ]data_out;
reg [31:0 ]addr = 0;
reg [31:0 ]data_in = 0;
reg read_write = 0;
reg [3:0] sel = 0;
reg  imm_cntrl = 0;
reg [1:0] access_size = 0;

  imemory imemory_0(
    .clock(clock), 
    .address(addr), 
    .data_in(data_in), 
    .data_out(data_out), 
    .read_write(read_write)
  );


//pr1
  reg[6:0]  op, funct7 = 0; 
  reg[31:0] im = 0;
  reg[4:0] rs1, rs2, rd, shant = 0;
  reg[2:0] funct3 = 0;
  reg[1:0] valid = 0;
  reg read_write_mem = 0;
  //pr = 0;
  reg [31:0 ]inst_d = 0;
  reg [31:0 ]pc_d = 0;
  reg read_write_d = 0;
  reg write_enable_d = 0;
  reg lb_cntr_d = 0;
  reg [4:0]  rd_w = 0;

// $display("this is the pc %x", pc_d);
//osteniocbly attempted stall -> no further
  // always@(*) begin 
  //   if ((rs_1d ==r d_w )
  // end 
//inserts nop going into decode stage, other one executes nop going into execute stage, assuming proepr handinling of a jump, your addr will not do pc +4 but alu_output
//next cycle => new pc addr (las alu ) decode nop and exec nop 
  always @(posedge clock) begin
    if (pc_sel_jal || bt) begin 
      read_write_d <= 0;
      inst_d <= 0;
      pc_d <=  0; // pc value for storing reg
    end else if (!is_stalling) begin
      read_write_d <= read_write;
      inst_d <= data_out;
      pc_d <=  addr; // pc value for storing reg
    end else begin end
  end

//----------------------------------------------------------------------
//1.5decode
//----------------------------------------------------------------------

  always @(*) begin
    valid = 0;
    op = inst_d[6:0];
    read_write_mem = 1'b0;
    case(op)
    // finish proper
      7'b0110111: begin 
        write_enable_d = 1;
        sel = 4'b0 ;
        rd = inst_d[11:7];
        funct3 = 0;
        rs1 = 0; 
        rs2 = 0; 
        funct7 = 0; 
        im = { inst_d[31:12], 12'b0}; 
        shant = 0;
      end
      //  finish proper
      7'b0010111: begin 
        write_enable_d = 1;
        sel = 4'b1 ;
        rd = inst_d[11:7];
        funct3 = 0;
        rs1 = 0; 
        rs2 = 0; 
        funct7 = 0; 
        im = { inst_d[31:12], 12'b0}; 
        shant = 0;
      end 
      //jtype... finish proper
      7'b1101111: begin
        write_enable_d = 1;
        sel = 4'b10 ;
        rd = inst_d[11:7];
        funct3 = 0;
        rs1 = 0; 
        rs2 = 0; 
        funct7 = 0; 
        im = { {12{inst_d[31]}}, inst_d[19:12], inst_d[20], inst_d[30:25], inst_d[24:21], 1'b0}; 
        shant = 0;
      end
      //jalr finish proper
      7'b1100111: begin 
        write_enable_d = 1;
        sel = 4'b11 ;
        rd = inst_d[11:7];
        funct3 = inst_d[14:12];
        rs1 = inst_d[19:15]; 
        rs2 = 0; 
        funct7 = 0; 
        im = { {21{inst_d[31]}}, inst_d[30:20]}; 
        shant = 0;
      end 
      //break bge etc. finish proper 
      7'b1100011: begin 
        sel = 4'b100 ;
        write_enable_d = 0;
        rd = 0;
        funct3 = inst_d[14:12];
        rs1 = inst_d[19:15]; 
        rs2 = inst_d[24:20 ]; 
        funct7 = 0; 
        im = {{20{inst_d[31]}}, inst_d[7],inst_d[30:25], inst_d[11:8], 1'b0}; 
        shant = 0; 

      end    
      //lw lb etc. finish proper
      7'b0000011: begin 
        read_write_mem = 1'b0;
        sel = 4'b101 ;
        write_enable_d = 1;

        rd = inst_d[11:7];
        funct3 = inst_d[14:12];
        rs1 = inst_d[19:15]; 
        rs2 = 5'b0; 
        funct7 = 7'b0; 
        im = {{21{inst_d[31]}}, inst_d[30:25], inst_d[24:21], inst_d[20]}; 
        shant = 0; 
      end    
      //sw sb etc.   finish proper
      7'b0100011: begin 
        read_write_mem = 1'b1;
        write_enable_d = 0;
        sel = 4'b110 ;
        rd = 0;
        funct3 = inst_d[14:12];
        rs1 = inst_d[19:15]; 
        rs2 =  inst_d[24:20 ];
        funct7 = 7'b0; 
        im = {{21{inst_d[31]}}, inst_d[30:25], inst_d[11:8], inst_d[7]}; 

        shant = 0;     

      end 
      //stores addi slli type  @TODO shamt stuff
      7'b0010011: begin //addi slli
        sel = 4'b111 ;
        write_enable_d = 1;

        if (inst_d[13:12] == 2'b01 ) begin
          // if (inst_d[13] == 1'b0 ) begin
            rd = inst_d[11:7];
            funct3 = inst_d[14:12];
            rs1 = inst_d[19:15]; 
            shant = inst_d[24:20 ]; 
            funct7 = inst_d[31:25]; 
            im = 0;
            rs2 = 0; 
            imm_cntrl = 1'b0;
          end else begin
            rd = inst_d[11:7];
            funct3 = inst_d[14:12];
            rs1 = inst_d[19:15]; 
            rs2 = 0; 
            funct7 = 0; 
            im = { {20{inst_d[31]}}, inst_d[31:20]}; 
            shant = 0;
            imm_cntrl = 1'b1;
          end 
        end 

      7'b0110011: begin 
        sel = 4'b1000 ;
        write_enable_d = 1;

        rd = inst_d[11:7];
        funct3 = inst_d[14:12];
        rs1 = inst_d[19:15]; 
        rs2 = inst_d[24:20 ]; 
        funct7 = inst_d[31:25]; 
        im = 0; 
        shant = 0;
      end
      //finish proper
      7'b1110011: begin 
        sel = 4'b1001 ;
        write_enable_d = 0;

        rd = 0;
        funct3 = 0;
        rs1 = 0; 
        rs2 = 0; 
        funct7 = 0; 
        im = 0; 
        shant = 0;
      end
      default: begin
        write_enable_d = 0;
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



// add x0, x1,x2

  wire [31:0 ] data_rs1_d;
  wire [31:0 ] data_rs2_d;
  reg [4:0 ] rs1_d = 0;
  reg [4:0 ] rs2_d = 0;
  reg [4:0 ] rd_d = 0;
  reg [31:0] data_rd_d = 0;
  reg is_stalling = 0;
  reg [31:0] data_rd_www = 0;
  reg write_enable_w;// = 0;
  
  // @todo reg write_enable; why does rs1 have d and rs2 have d? i thought regiser file along with decode both in decode

  always @(* ) begin //@todo clock or nah?
    rs1_d = rs1; 
    rs2_d = rs2; 
    rd_d  = rd; 
  end    

  wire a = ((rs1_d == rd_w) && (rd_w != 0));
  wire b = ((rs2_d == rd_w) && (rd_w != 0));
  wire e = (rs1_d == rd_x);
  wire f = (rs2_d == rd_x); 
  wire c = (op_x == 7'b0000011); //load
  wire d = (op != 7'b0100011); //store
  always @(*) begin
    if  (c && (e || (f && d) ) || a || b) begin 
        is_stalling = 1'b1;
      //begin
    end else begin
        is_stalling = 1'b0;
      end
  end

//N.B. data_rd is from WB stage -> it is the data that I am writing AFTER IT HAS EXECUTED ALU/WB EVERYTHIGN ELSE. OTHERWISE IF I JUST WRITE MY DECODED RD, THAT'S GRABAGE VALUE B/C I HAVEN'T DONE TUFF YE
  register_file register_file_0(
    .clock(clock),
    .addr_rs1(rs1_d),
    .addr_rs2(rs2_d), 
    .addr_rd(rd_w), 
    .data_rd(data_rd_www), // decide in the writeback
    .data_rs1(data_rs1_d),
    .data_rs2(data_rs2_d),
    .write_enable(write_enable_w)
  );

// i ostencibly have my data that I NEED to write, now i get my address and the write enable. again, not current address rd or we b/c this write is from

//should i keep the above here or move it to the top @todo




//pr2
  reg[4:0] rs1_x, rs2_x, rd_x = 0;  //d = 0
  // reg [3:0] sel;
  reg [31:0] inst_x = 0;
  reg [31:0 ]pc_x = 0;
  reg [31:0 ]im_x = 0;
  reg read_write_mem_x = 0;
  reg read_write_x = 0;
  reg [31:0] data_rs2_x = 0;
  reg[4:0] shant_x = 0;
  reg[2:0] funct3_x = 0;
  reg[6:0]  funct7_x  = 0;
  reg write_enable_x = 0;
  reg lb_cntr_x = 0;
  reg  is_signed_x = 0;
  reg [31:0] data_rs1 = 0;
  reg [31:0] data_rd_x = 0;
  reg[6:0]  op_x = 0;
  reg [3:0] sel_x = 0;
  reg [31:0] data_rs1_x = 0;
  reg imm_cntrl_x = 0;


  always @(posedge clock) begin
    if (is_stalling || bt || pc_sel_jal) begin
      lb_cntr_x <= 0; //d
      write_enable_x <= 0; //d
      inst_x <= 0; //d
      rs1_x <= 0; 
      rd_x <= 0; 
      shant_x <= 0; 
      rs2_x <= 0; 
      sel_x <= 0;
      im_x <= 0;
      read_write_mem_x <= 0;
      read_write_x <= 0; //d
      funct3_x <= 0;
      funct7_x <= 0;
      data_rs1_x <= 0;
      data_rs2_x <= 0;
      write_enable_x <= 0;
      data_rd_x <= 0;
      op_x <= 0;
      imm_cntrl_x = 0;

    end else begin
      lb_cntr_x <= lb_cntr_d; //d
      write_enable_x <= write_enable_d; //d
      inst_x <= inst_d; //d
      rs1_x <= rs1_d; 
      rd_x <= rd_d; 
      shant_x <= shant; 
      rs2_x <= rs2_d; 
      sel_x <= sel;
      im_x <= im;
      read_write_mem_x <= read_write_mem;
      read_write_x <= read_write_d; //d
      funct3_x <= funct3;
      funct7_x <= funct7;
      data_rs1_x <= data_rs1_d;
      data_rs2_x <= data_rs2_d;
      write_enable_x <= write_enable_d;
      data_rd_x <= data_rd_d;
      op_x <= op;
      imm_cntrl_x <= imm_cntrl;
      pc_x <= pc_d;
    end

  end
//----------------------------------------------------------------------
//2execute
//----------------------------------------------------------------------



// end decoder 
//start fetch/alu compute


  reg [4:0] addr_rs1 = 0;
  reg [4:0] addr_rs2 = 0;
  reg write_enable_1= 0;
  reg [31:0] alu_output = 0;
  reg [31:0] effective_address = 0;
  reg pc_sel_jal = 0; //inherently a  = 0;
  reg [31:0] pc_for_jal_to_write_back = 0;
  reg bt = 0;

  // //i think this is right? @understand 1


  //two things needed to be implemented 
 //- i would need ot select btwn alu_output, pcoutput +4, or addr
//ask about upper immediate and load and exit condition
  always @( * ) begin 
    // $display("PC: %x and reg address == %x \n rs1 == %x \n rs2 == %x", addr ,register_file_0.mem_reg[3], register_file_0.mem_reg[1], register_file_0.mem_reg[2]);
    // $display("this is  control signals control %x \n\n opcode %x \n, rd : %x \n, rs1 : %x \n, rs2 : %x \n, im : %x \n, shant : %x \n", funct3_x, op, rd, rs1_x, rs2_x, im_x, shant_x);
    //bypassing logic rs2 tal;
    if((rd_m == rs2_x) && write_enable_m) begin  //could be one of two
      if(rd_m == 5'b0) data_rs2_x = 32'b0;
      else data_rs2_x = alu_m; 
    end 
    else if((rd_w == rs1_x) && write_enable_w) begin 
      if(rd_w == 5'b0) data_rs2_x = 32'b0; 
      else data_rs2_x = alu_w; 
      end 

    
    else begin 
      data_rs2_x = data_rs2_d;
      // add x4,x1,x3
    end 



    //bypassing logic rs2 @todo ensure signals are proper esp data_rs1_d


    if((rd_m == rs1_x) && write_enable_m) begin  //could be one of two
      if(rd_m == 5'b0) data_rs1_x = 32'b0;
      else data_rs1_x = alu_m; 

    end 
    else if((rd_w == rs1_x) && write_enable_w) begin 
      if(rd_w == 5'b0) data_rs1 = 32'b0; 
      else data_rs1_x = alu_w; 

      end 

    
    else begin 
      data_rs1_x = data_rs1_d;
      // add x4,x1,x3
    end


    lb_cntr_x = 0;
    pc_for_jal_to_write_back = 32'b0;
    case(sel_x)
      4'b0: begin 
        bt = 1'b0;
        pc_sel_jal = 1'b0;
        //load upper add
        alu_output = im_x;
        // i don't htink anything needs to be done here
        // lui (Load Upper Immediate): this sets rd to a 32-bit value with the low 12 bits being 0 and the high 20 bits coming from the U-type im_xmediate.
// auipc (Add Upper Immediate to Program Counter): this sets rd to the sum of the current PC and a 32-bit v
      end 
      4'b1: begin 
          //auipc
        bt = 1'b0;
        pc_sel_jal = 1'b0;


        alu_output = pc_x  + $signed(im_x);
          //same as lui - don't think anything needs to be done on execute phase
      end 
      //jal - doesn't use alu only effective pc_x
      4'b10: begin 
        pc_sel_jal = 1'b1;
        bt = 1'b0;
        //current
        pc_for_jal_to_write_back = pc_x;
        alu_output = pc_x + $signed(im_x);
      end 
      //jalr
      4'b11: begin  
        bt = 1'b0;
        pc_sel_jal = 1'b1; 
        pc_for_jal_to_write_back = pc_x;
        //gotta save and do $ra <— PC+4  
        //$ra <— return pc_xess store return pc_xess in register file 
        // alu_output = $signed(data_rs1) + $signed(im_x);
        alu_output = ($signed(data_rs1) + $signed(im_x))  & ('hFFFFFFFE);
      end 
      //beq/other breaks
      4'b100: begin 
        write_enable_x = 1'b0;
        pc_sel_jal = 1'b0;

        case(funct3_x) 
          3'b000: begin 
            if (data_rs1 == data_rs2_x) 
              bt = 1'b1;
            else
              bt = 1'b0;
          end
          3'b001: begin
            if (data_rs1 != data_rs2_x) 
              bt = 1'b1;
            else
              bt = 1'b0;
           end
          3'b100: begin 
            if ($signed(data_rs1) < $signed(data_rs2_x)) 
              bt = 1'b1;
            else
              bt = 1'b0;
          end
          3'b101: begin 
            if ($signed(data_rs1) >= $signed(data_rs2_x)) 
              bt = 1'b1;
            else
              bt = 1'b0;
          end
          3'b110: begin 
            if ((data_rs1) < (data_rs2_x)) begin
              // $display("leggoleggoleggoleggoleggoleggoleggoleggoleggoleggoleggoleggoleggoleggoleggo");
              bt = 1'b1;
            end else begin
              // $display("shootshootshootshootshootshootshootshootshootshootshootshootshootshootshootshootshoot");
              bt = 1'b0;          
            end
          end
          3'b111: begin
            // $display("hiiiii1 alu_output %x   data_rs4  %x   im_x   %x     ", alu_output, register_file_0.mem_reg[4], im_x);

            if ((data_rs1) >= (data_rs2_x)) begin
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
      4'b101: begin  //lw ops lw
        bt = 1'b0;
        pc_sel_jal = 1'b0;

        //unsure how to do load word and store word
        // pc_x = data_rs1 + im_x;
        write_enable_x = 1'b1;
        alu_output = $signed(data_rs1) + $signed(im_x);
        lb_cntr_x = 1;
        case(funct3_x)
          3'b000: begin //signed but essentially the same logic when it comes to alu
            is_signed_x = 1'b1;

            access_size = 2'b00;
          end
          3'b001: begin
            is_signed_x = 1'b1;

            access_size = 2'b01;
            
          end
          3'b010: begin
            is_signed_x = 1'b1;

            access_size = 2'b10;
          end
          3'b100: begin // unsigned 
          is_signed_x = 1'b0;

            access_size = 2'b00;
          end
          3'b101: begin
            is_signed_x = 1'b0;
            access_size = 2'b01;
          end
          default: begin
            access_size = 2'b10;
          end

        endcase
        $display("access size lw %x", access_size );

      end 
      4'b110: begin  //sw sw sw
        $display("deadbeef123");

        bt = 1'b0;
        pc_sel_jal = 1'b0;

//unsure how to do load word and store word
        alu_output = $signed(data_rs1) + $signed(im_x);

        case(funct3_x)
          3'b000: begin
            access_size = 2'b00;
          end
          3'b001: begin
            access_size = 2'b01;
            
          end
          3'b010: begin
            access_size = 2'b10;  //sw accessize == 2
          end
          default: begin
            access_size = 2'b10;
          end
        endcase
        $display("access size sw %x", access_size );

      end 

      //arithmetics with im_x
      4'b111: begin 
        pc_sel_jal = 1'b0;

        // $display("p---------pc_x %x", pc_x);
        bt = 1'b0;
        write_enable_x = 1'b1;
        if (imm_cntrl_x == 1'b0) begin
          if (funct3_x == 3'b001) begin
            alu_output = data_rs1 << shant_x;
          end else begin
            if (funct7_x == 7'b0000000) begin
              alu_output = data_rs1 >> shant_x;
            end else begin
              alu_output = $signed(data_rs1) >>> shant_x;
            end
          end 
        end else begin
          case (funct3_x)
            3'b000: begin
              alu_output = $signed(data_rs1) + $signed(im_x);
              // $display("hiiiii alu_output %x   data_rs1  %x   im_x   %x     ", alu_output, data_rs1, im_x);
            end
            3'b010: begin
              alu_output = ($signed(data_rs1) < $signed(im_x)) ? 1 : 0;
            end 
            3'b011: begin
              alu_output = ((data_rs1) < (im_x)) ? 1 : 0;
            end 
            3'b100: begin
              alu_output = data_rs1 ^ im_x;
            end 
            3'b110: begin
              alu_output = data_rs1 | im_x;
            end   
            3'b111: begin
              alu_output = data_rs1 & im_x;
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
        case (funct3_x)
          3'b000: begin 
            if (funct7_x == 7'b0000000) begin
              alu_output = $signed(data_rs2_x) + $signed(data_rs1);
            end else begin
              alu_output = $signed(data_rs1) - $signed(data_rs2_x);
            end
          end 
          3'b001: begin 
            alu_output = $signed(data_rs1) << data_rs2_x[4:0];
          end
          3'b010: begin 
            alu_output = ($signed(data_rs1) < $signed(data_rs2_x)) ? 1 : 0;
          end
          3'b011: begin 
            alu_output = (data_rs1 < data_rs2_x) ? 1 : 0; 
          end
          3'b100: begin 
            alu_output = data_rs1 ^ data_rs2_x; 
          end
          3'b101: begin //sra
            if (funct7_x == 7'b0000000) begin
              // alu_output =  data_rs2_x>> data_rs1[4:0]; 
              alu_output =  data_rs1 >> data_rs2_x[4:0]; 
            end else begin
              alu_output = $signed(data_rs1) >>>  $signed(data_rs2_x[4:0]); 
            end
          end
          3'b110: begin 
            alu_output = data_rs1 | data_rs2_x;
          end
          3'b111: begin 
            alu_output = data_rs1 & data_rs2_x;
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
    // $display("hiiiii2 alu_output %x   data_rs4  %x   im_x   %x    \n ---------- writeen  ", alu_output, register_file_0.mem_reg[4], im_x, write_enable_x);
    effective_address = alu_output;
  end

//branch comparator logic 
// if i am in a jal condition, then my alu computes my address otherwise
// if i am in a branch condition and it is successful my address is jumped to function else i just go down the pc
  always @( posedge clock) begin
    // $display("hiiiii3 alu_output %x   data_rs4  %x   im_x   %x    \n ---------- writeen  ", alu_output, register_file_0.mem_reg[4], im_x, write_enable_x);
    
    // addr <= ((pc_sel_jal) ?  : (bt ? (addr+im_x) : (addr + 4)));
    if (pc_sel_jal) begin

      $display(" sel1  ");

      addr <= alu_output;

    end else begin

      $display(" sel2");
      $display(" value of addr + imm at this point %x  %x", addr, im_x);

      if (bt) begin
        addr <= (addr+im_x);
        
      end else begin
        addr <= (addr+4);
      end
      
    end 
    $display("these are the value of register 4 and register 5 %x   %x", register_file_0.mem_reg[4], register_file_0.mem_reg[5]);

    $display("these are the control signals here: pc_sel_jal %x \n, alu_output %x \n, bt %x\n,addragain %x \n is_stalling %x \n",pc_sel_jal,alu_output,bt, addr, is_stalling );
    $display("is stalling ------------------------ %x", is_stalling);// bt = 1'b0;
  end 

  // reg[4:0] rs1_x, rs2_x, inst_x;  //d
  // reg [3:0] sel;//d
  // reg [31:0 ]pc_x;//d
  // reg [31:0 ]im_x;//d
  // reg read_write_mem_x;//d
  // reg read_write_x;//d
  // reg [31:0] data_rs2_x;//d
  // reg[4:0] shant_x;//d
  // reg[2:0] funct3_x; //d
  // reg[6:0]  funct7_x;  //d
  // reg write_enable_x; //d
  // reg lb_cntr_x;//d
  // reg  is_signed_x;//d
  // reg [31:0] data_rs1;//d
//pr3
  reg pc_sel_jal_m = 0;//d
  reg[4:0] rs2_m, rd_m = 0;//d
  reg [31:0] inst_m = 0;
  reg [31:0 ]alu_m = 0;
  reg [31:0 ]pc_m = 0;
  reg[1:0] access_size_m = 0;
  reg read_write_mem_m = 0;
  reg [31:0] pc_for_jal_to_write_back_m = 0;
  reg [31:0] data_rs2_m = 0;
  reg [31:0] data_rs1_m = 0;
  reg[2:0] funct3_m = 0;
  reg write_enable_m = 0;
  reg lb_cntr_m = 0;
  reg is_signed_m = 0;
  reg [31:0] data_mux_rd_sel = 0; //signal added for WM bypass to be a mux select for data_rs2_m or data_rd

  always @(posedge clock) begin
    
    rd_m <= rd_x;
    is_signed_m <= is_signed_x;
    pc_sel_jal_m <= pc_sel_jal;
    lb_cntr_m <= lb_cntr_x;
    write_enable_m <= write_enable_x;
    inst_m <= inst_x;

    pc_m <= pc_x; // pc value for storing reg
    alu_m <= alu_output;
    rs2_m <= rs2_x;
    access_size_m <= access_size;
    read_write_mem_m <= read_write_mem_x;
    pc_for_jal_to_write_back_m <= pc_for_jal_to_write_back;
    data_rs1_m <= data_rs1;
    data_rs2_m <= data_rs2_x;    
    funct3_m <= funct3_x;

  end
//----------------------------------------------------------------------
//3dmemory
//----------------------------------------------------------------------
  
  
  wire [31:0 ]data_out_d;
  reg [31:0 ]data_in_d = 0;
  reg [31:0 ]data_rd = 0;

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
    .address(alu_m), 
    .data_in(data_mux_rd_sel), 
    .data_out(data_out_d), 
    .read_write(read_write_mem_m), 
    .access_size(access_size_m),
    .is_signed(is_signed_m)
  );


  always @(*) begin
    if (lb_cntr_m == 1) begin
    if (funct3_m == 3'b000) begin
        data_rd = {{24{data_out_d[7]}}, data_out_d[7:0]};
    end else if (funct3_w == 3'b001) begin
        data_rd =  {{16{data_out_d[15]}}, data_out_d[15:0]};
    // data_rd = data_out_d_w;
    end else if (funct3 == 3'b010) begin
      data_rd = data_out_d; 
    end else if (funct3 == 3'b100) begin 
      data_rd = {24'b000000000000000000000000, data_out_d[7:0]}; 
    end else if (funct3== 3'b101) begin 
      data_rd = {16'b0000000000000000, data_out_d[15:0]};
  end 
  end else begin
    write_enable_w = 1'b1;
    if (!pc_sel_jal_w) begin 
      data_rd = alu_w;
    end else begin
      data_rd = pc_for_jal_to_write_back_w + 4;
    end

  end
  end

  //checkpoint - everything seems reasonable up till memory stage
  
  //write back

  //   reg[4:0] rs2_m, inst_m;
  // reg [31:0 ]alu_m;
  // reg [31:0 ]pc_m;
  // reg[1:0] access_size_m;
  // reg read_write_mem_m;
  // reg pc_for_jal_to_write_back_m;
  // reg [31:0] data_rs2_m;
  // reg [31:0] data_rs1_m;

  // always @(posedge clock) begin
  //   inst_m <= inst_x;
  //   pc_m <= pc_x; // pc value for storing reg
  //   alu_m <= alu_output;
  //   rs2_m <= rs2_x;
  //   access_size_m <= access_size;
  //   read_write_mem_m <= read_write_mem_x;
  //   pc_for_jal_to_write_back_m <= pc_for_jal_to_write_back;
  //   data_rs1_m <= data_rs1_x;
  //   data_rs2_m <= data_rs2_x;    
  //   funct3_m <= funct3_x;

//pr4
  reg[2:0] funct3_w = 0;
  reg[31:0] pc_w = 0;
  reg[31:0]   inst_w = 0;
  reg [31:0] alu_w = 0;
  reg [31:0] pc_for_jal_to_write_back_w = 0;
  reg [31:0] data_out_d_w = 0;
  reg lb_cntr_w = 0;
  reg pc_sel_jal_w = 0;



  always @(posedge clock) begin
    pc_w <= pc_m;
    rd_w <= rd_m;
    inst_w <= inst_m;
    alu_w <= alu_m;
    pc_for_jal_to_write_back_w <= pc_for_jal_to_write_back_m;
    funct3_w <= funct3_m;
    data_out_d_w <= data_out_d;
    write_enable_w <= write_enable_m;
    lb_cntr_w <= lb_cntr_m;
    pc_sel_jal_w <= pc_sel_jal_m;
    data_rd_www <= data_rd;
  end
  
  
  //----------------------------------------------------------------------
  
  
  //4write backx
//----------------------------------------------------------------------

    //bypassing logic for WM - signals confirmed

  always @(*) begin
      if (rs2_m == rd_w) begin  
        data_mux_rd_sel = data_rd_www;
      end else begin
        data_mux_rd_sel = data_rs2_m;
      end 
  end

  always @( posedge clock  ) begin
    //wb
    // data_rd_wwww <= data_rd_mm;
    // if (lb_cntr_w == 1) begin
    //   if (funct3_w == 3'b000) begin
    //       data_rd = {{24{data_out_d_w[7]}}, data_out_d_w[7:0]};
    //   end else if (funct3_w == 3'b001) begin
    //      data_rd =  {{16{data_out_d_w[15]}}, data_out_d_w[15:0]};
    //   // data_rd = data_out_d_w;
    //   end else if (funct3_w == 3'b010) begin
    //     data_rd = data_out_d_w; 
    //   end else if (funct3_w == 3'b100) begin 
    //     data_rd = {24'b000000000000000000000000, data_out_d_w[7:0]}; 
    //   end else if (funct3_w == 3'b101) begin 
    //     data_rd = {16'b0000000000000000, data_out_d_w[15:0]};
    // end 
    // end else begin
    //   write_enable_w = 1'b1;
    //   if (!pc_sel_jal_w) begin 
    //     data_rd = alu_w;
    //   end else begin
    //     data_rd = pc_for_jal_to_write_back_w + 4;
    //   end

    // end
  end

    // lb_cntr = 0;
    // pc_sel_jal = 1'b0;




endmodule





// //adi's temp_memory
// always@(*) begin 
//   //also check for the WE of the corresponding stage 
//   if((rd_m == rs1_x) && write_enable_m) begin  //could be one of two
//     if(rd_m == 5'b0) data_rs1_x = 32'b0;
//     else data_rs1_x = alu_m; 
//   end 
//   else if((rd_w == rs1_x) && write_enable_w) begin 
//     if(rd_w == 5'b0) data_rs1 = 32'b0; 
//     else data_rs1_x = alu_w; 
//     end 
  
//   else begin 
//     data_rs1_x = data_rs1_d;
//     // add x4,x1,x3
//   end 
// end 


// always@(*) begin 
//   //also check for the WE of the corresponding stage 
//   if((rd_m == rs2_x) && write_enable_m) begin  //could be one of two
//     if(rd_m == 5'b0) data_rs2_x = 32'b0;
//     else data_rs2_x = alu_m; 
//   end 
//   else if((rd_w == rs1_x) && write_enable_w) begin 
//     if(rd_w == 5'b0) data_rs1 = 32'b0; 
//     else data_rs2_x = alu_w; 
//     end 
  
//   else begin 
//     data_rs2_x = data_rs1_d;
//     // add x4,x1,x3
//   end 
// end 









// always@(*) begin 
//   //also check for the WE of the corresponding stage 
//   if((rd_m == rs1_x) && write_enable_m) begin  //could be one of two
//     if(rd_m == 5'b0) data_rs1 = 32'b0;
//     else data_rs1_x = alu_m; 
//   end 
//   else if((rd_w == rs1_x) && write_enable_w) begin 
//     if(rd_w == 5'b0) data_rs1 = 32'b0; 
//     else data_rs1_x = alu_w; 
//     end 
  
//   else begin 
//     data_rs1_x = data_rs1_d;
//   end 
// end 

















// //stalling logic for load_use creds 
// //@todo ask about where/how they are defined

// if(stall_load_use || struc_haz1) begin
  
// end


// //in the decode stage and determine i want to stall. what i want to do is nop signal into decode pipeline registers
// //ensure nop sginal doesn't result in future pieline issue, doesn't write to memory and deosn't write to future register
// //ensure that bs value is being properly dealt with in the sense of nops



// /* 
// stalling 1
// Stall = (D/X.insn.Operation == LOAD) && 
// ((F/D.insn.rsl == D/X.insn.rd) ||
// ((F/D.insn.rs2 == D/X.insn.rd) && (F/D.insn.Operation!=STORE))) 
// */ 
// reg stall_loaduse_x; 

// always@(*) begin 
//   if ((rs_1d ==r d_w )
// end 

// //@todo add one more stallling as per connor's suggestion stalling 2
// /* decode stage bypass not permissible therefore i don't want to do something like this in
// //stalling from wb to decode is needed in the case that there is an instruction in wb stage and another in decode stage and there is a dependency
// //in this case, we just nop one cycle and then wait for wb to write to register at which point we can easily read from rgsiter for the insn. in decode stage
// */











// // bypassing logic creds  decipher 
// // @todo understand this bypassing and figure out how to
// // add for from WB to Mem but exact same logic
// //wb to exe, mem to exec


// //add x2, x1,x0
// //add x3,x2,x1 >> exp: bypass rd_data from memory to execute rs1/rs2 


// //add x2,x1,x0 
// //slli ...
// //addi x1, x1, 10
// //add x3,x2,x1  -> use two bypasses wb to exec


// //wb to mem
// //lw x3, 4(x2)
// //sw x3, 3(x1)

// //bypassing for RS2 the same way we did for RS1 
// always@(*) begin 
// if((EM_addr _rd == DE_addr_rs2) && EM_write_enable) begin
//   if(EM_addr_rd == 5'b0) ALU_datalN_rs2 = 32'b0; 
//   else ALU_datalN_rs2 = EM_ALU_data_rd; 
// end 
// else if((MW_addr_rd == DE_addr_rs2) && MW_write_enable) begin 
//   if(MW_addr_rd == 5'b0) ALU_datalN_rs2 = 32'b0; 
//   else ALU_datalN_rs2 = MW_data_rd; 
// end 
// else begin 
//   ALU_datalN_rs2 = DE_data_rs2; 
