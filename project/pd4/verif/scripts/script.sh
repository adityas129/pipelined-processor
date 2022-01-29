#!/bin/bash -eu
set -o pipefail
mkdir -p txt
mkdir -p vcd
mkdir -p txti

function interrupt() {
    exit 0
}

trap interrupt INT


#for f in /home/yyuneebu/rv32-benchmarks/simple-programs/*.x; do
#  make run VERILATOR=1 TEST=test_pd MEM_PATH=$f VCD=1 | grep "\[F\|\[D\|\[E\|\[R\|\[M\|\[W\|\[PD4" > txt/$(basename $f .x).txt
#  mv ../sim/verilator/test_pd/dump.vcd vcd/$(basename $f .x).vcd
#done

# for f in /home/a273shar/rv32-benchmarks/simple-programs/*.x; do
#   make run VERILATOR=1 TEST=test_pd MEM_PATH=$f VCD=1 > txt/$(basename $f .x).txt
#   mv ../sim/verilator/test_pd/dump.vcd vcd/$(basename $f .x).vcd
# done


for f in /home/a273shar/rv32-benchmarks/individual-instructions/*.x; do
  make run VERILATOR=1 TEST=test_pd MEM_PATH=$f > txti/$(basename $f .x).txt
done