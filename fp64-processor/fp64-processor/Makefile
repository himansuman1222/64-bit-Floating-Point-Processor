# Icarus Verilog flow (open-source).  Vivado flow: see vivado/create_project.tcl
RTL = $(wildcard rtl/*.v)

all: vectors asm test_alu test_proc

vectors:
	python3 scripts/gen_vectors.py
asm:
	python3 sw/assembler.py programs/demo.asm programs/program.hex
test_alu: vectors
	iverilog -g2005 -Irtl -Isim -o sim/alu.vvp tb/tb_fp64_alu.v rtl/fp64_alu.v rtl/fp64_addsub.v rtl/fp64_mul.v rtl/fp64_cmp.v
	vvp sim/alu.vvp
test_proc: asm
	iverilog -g2005 -Irtl -o sim/proc.vvp tb/tb_fp64_processor.v $(RTL)
	vvp sim/proc.vvp
clean:
	rm -f sim/*.vvp sim/*.vcd sim/vectors.mem sim/vector_count.vh
.PHONY: all vectors asm test_alu test_proc clean
