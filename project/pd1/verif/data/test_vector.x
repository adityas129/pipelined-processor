//
// Format: addr[31:0], data_in[31:0], (expected) data_out[31:0], read_write[3:0]
// The addr in the first line represents the number of test vector after
//
0000000A_00000000_00000000_0
// read from original content 
01000000_00000000_deadbeef_0
// write to some content and read back
01000004_abababab_00000000_1
01000004_00000000_abababab_0
// unaligned write
01000003_dededede_00000000_1
01000000_00000000_deadbeef_0

01000002_abababab_00000000_1
01000000_00000000_ababbeef_0

01000001_01010101_00000000_1
01000000_00000000_010101ef_0

01000004_00000000_abdeab01_0



