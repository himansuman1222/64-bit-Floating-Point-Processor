# 64-bit Floating Point Processor

**Tools:** Verilog HDL - Xilinx Vivado - VS Code (Icarus Verilog for open-source simulation)

A single-cycle **64-bit IEEE 754 (binary64) floating-point processor** written in Verilog.
It contains a floating-point ALU (arithmetic + logical), instruction & data memories, a
32 x 64-bit register file and a control unit that decodes opcodes and generates the
datapath control signals. It is simulated and verified in Vivado (xsim) and Icarus Verilog.

## Features
- IEEE 754 double-precision **add, subtract, multiply, compare, abs, negate**
- **Logical operations** (AND / OR / XOR / NOT) on 64-bit words
- Round-to-nearest-even with guard/round/sticky bits; NaN / Inf / signed-zero handling
- Instruction memory (256 x 32), data memory (256 x 64), 32-entry FP register file
- Control unit: opcode decoding + control-signal generation (loads, stores, jump, branch, halt)
- Python assembler + Python golden-model vector generator
- Self-checking testbenches (**5,582 ALU vectors, 0 errors**; full program test)

## Repository layout
```
rtl/        fp64_addsub.v fp64_mul.v fp64_cmp.v fp64_alu.v control_unit.v
            reg_file.v instr_mem.v data_mem.v fp64_processor_top.v fp64_defs.vh
tb/         tb_fp64_alu.v  tb_fp64_processor.v
sw/         assembler.py
programs/   demo.asm  program.hex  data.hex
scripts/    gen_vectors.py
vivado/     create_project.tcl
docs/       ARCHITECTURE.md   (block diagram, ISA, FPU details)
Makefile
```

## Quick start (Icarus Verilog)
```bash
sudo apt install iverilog      # or brew install icarus-verilog
make            # generates vectors, assembles demo, runs both testbenches
```
Expected output:
```
ALU test: 5582 vectors, 0 errors
ALU TEST PASSED
...
PROCESSOR TEST PASSED
```

## Vivado
```bash
vivado -mode batch -source vivado/create_project.tcl     # run from the repo root
```
Or open Vivado -> *Create Project*, add `rtl/*.v` (mark `fp64_defs.vh` as global include),
add `tb/*.v` as simulation sources, add `programs/*.hex` and `sim/vectors.mem` as simulation
data files, set `tb_fp64_processor` as top, then *Run Behavioral Simulation*.
If the `$readmemh` file is not found, give the absolute path in the module's `INIT_FILE` parameter.

## Writing your own program
```asm
        FLD  f1, 0        ; load operand from data memory
        FLD  f2, 1
        FMUL f3, f1, f2
        FST  f3, 16
        HALT
```
`python3 sw/assembler.py my.asm programs/program.hex` then re-run the simulation.
See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the full ISA.

## Limitations / future work
Subnormals flushed to zero, round-to-nearest-even only, no divide/sqrt, single cycle.
Planned: pipelining, FDIV/FSQRT, exception flags, FPGA constraints.
