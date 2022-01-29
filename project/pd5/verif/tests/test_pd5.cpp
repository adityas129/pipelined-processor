// Verilator testbench
#include <iostream>
#include <verilated.h>
#ifdef VCD
#include "verilated_vcd_c.h"
#endif
#include "Vtop.h"
#include "svdpi.h"
#include "Vtop__Dpi.h"

extern void toggleClock();

Vtop *top;
vluint64_t main_time;
double sc_time_stamp () {     // Called by $time in Verilog
  return main_time;           // converts to double, to match
}

int main(int argc, char** argv) {
  Verilated::commandArgs(argc, argv);   // Remember args
  top = new Vtop;

#ifdef VCD
  Verilated::traceEverOn(true);
  VerilatedVcdC* tfp = new VerilatedVcdC;
  top->trace(tfp, 99);
  tfp->open("dump.vcd");
#endif

  // set the scope correctly so that we can access the clock in C testbench
  svSetScope(svGetScopeFromName("TOP.top.clkg"));
  while (!Verilated::gotFinish()) {
    toggleClock();
    top->eval();
#ifdef VCD
    tfp->dump(main_time);
#endif
    main_time += 1;
  }
#ifdef VCD
  tfp->close();
#endif
  delete top;
  return 0;
}
