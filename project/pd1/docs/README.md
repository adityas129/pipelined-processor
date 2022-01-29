# PD1

In this PD, you are required to developed a memory module as specified in the PD1 manual.

## Probes

You need to fill in the path to the following probes in `project/pd1/design/signals.h`:

```
`define PROBE_ADDR       
`define PROBE_DATA_IN    
`define PROBE_DATA_OUT   
`define PROBE_READ_WRITE 
```

- `PROBE_ADDR` is the 32-bit `address` input port.
- `PROBE_DATA_IN` is the 32-bit `data_in` input port.
- `PROBE_DATA_OUT` is the 32-bit `data_out` output port.
- `PROBE_READ_WRITE` is the `read_write` signal of the memory module.


## Tests

We provide initial tests that test for signals presence and basic timing correctness.

To run these tests, go to `project/pd1/verif/scripts` and use one of the following commands:

```
make run IVERILOG=1 TEST=test_pd1
make run VERILATOR=1 TEST=test_pd1
make run XSIM=1 TEST=test_pd1
```

## Testbench

Apart from the test we provided, you also need to write your own testbench as stated in the project manual.

Your testbench will need to be put in a module called `top`.
It should be put in a file named `project/pd1/verif/tests/test_pd.v`.
We provide a stub `test_pd.v`, you may extend from that file.

By creating `test_pd.v`, you will be able to run the test in `project/pd1/verif/scripts` using `make run TEST=test_pd YOUR_SIM=1`, where `YOUR_SIM` is either `VERILATOR` or `IVERILOG`.

Note that the output of your testbench should match exactly as specified in the project manual.

Make sure that your design will not report any warning during compilation.

### Verilator

For verilator users, we provide the `project/pd1/verif/tests/test_pd.cpp` that drives your testbench. 
However, your testbench should not depend on the modification to the `test_pd.cpp` as it will not be packaged for submission.

## Submission

In `project/pd1/verif/scripts/`, use `make package YOUR_SIM=1` to package your code.

If you use `iverilog`, use `make package IVERILOG=1` to create a `package.iverilog.tar.gz`

If you use `verilator`, use `make package VERILATOR=1` to create a `package.verilator.tar.gz`

If you use `Vivado xsim`, use `make package XSIM=1` to create a `package.xsim.tar.gz`

You will need to upload the `package.*.tar.gz` to learn when done.

Note that you must set your simulator properly as the package name will include
information about the simulator you are using.
The tests may fail if you are not providing the proper simulator name.

