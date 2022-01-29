/* Your Code Below! Enable the following define's
 * and replace ??? with actual wires */
// ----- signals -----
// You will also need to define PC properly

 `define PROBE_ADDR       addr
`define PROBE_DATA_IN    data_in
`define PROBE_DATA_OUT   data_out
`define PROBE_READ_WRITE read_write


`define PC                         addr
`define INSN                       data_out
`define REGISTER_WRITE_ENABLE      write_enable_w
`define REGISTER_WRITE_DESTINATION rd
`define REGISTER_WRITE_DATA        data_rd
`define REGISTER_READ_RS1          rs1
`define REGISTER_READ_RS2          rs2
`define REGISTER_READ_RS1_DATA     data_rs1_d
`define REGISTER_READ_RS2_DATA     data_rs2_d

// ----- signals -----

// ----- design -----
`define TOP_MODULE                 pd
// ----- design -----