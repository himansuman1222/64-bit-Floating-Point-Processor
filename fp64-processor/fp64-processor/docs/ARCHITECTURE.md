# Architecture

## Datapath (single-cycle)

```
        +----+   instr   +-----------+  ctrl  +---------+
 PC --> |IMEM| --------> | CONTROL   | -----> | datapath|
  ^     +----+           | UNIT      |        +---------+
  |                      +-----------+
  |   rs1/rs2 +----------+ A  +---------+ result  +------+
  +-----------| REG FILE |--->|  FP ALU |-------->| mux  |--> rd (write-back)
  next PC     | 32 x 64b |--->| add/sub |         +------+
 (pc+1/imm)   +----------+ B  | mul/cmp |            ^
                  |           | logic   |      +-----+-----+
                  +---(B)---> +---------+      |    DMEM   |
                         store data ----------> | 256 x 64b |
                                                +-----------+
```

## Instruction format (32 bit)

| 31..27 | 26..22 | 21..17 | 16..12 | 11..0 |
|--------|--------|--------|--------|-------|
| opcode | rd     | rs1    | rs2    | imm (imm[7:0] used as absolute address / jump target) |

## Instruction set

| Opcode | Mnemonic | Operation |
|-------:|----------|-----------|
| 0x00 | NOP  | no operation |
| 0x01 | FADD fd,fa,fb | fd = fa + fb |
| 0x02 | FSUB fd,fa,fb | fd = fa - fb |
| 0x03 | FMUL fd,fa,fb | fd = fa * fb |
| 0x04 | FAND fd,fa,fb | fd = fa & fb (bit-wise on the 64-bit pattern) |
| 0x05 | FOR  fd,fa,fb | fd = fa \| fb |
| 0x06 | FXOR fd,fa,fb | fd = fa ^ fb |
| 0x07 | FNOT fd,fa    | fd = ~fa |
| 0x08 | FLT  fd,fa,fb | fd = (fa < fb) ? 1.0 : 0.0 |
| 0x09 | FEQ  fd,fa,fb | fd = (fa == fb) ? 1.0 : 0.0 |
| 0x0A | FABS fd,fa    | fd = \|fa\| |
| 0x0B | FNEG fd,fa    | fd = -fa |
| 0x10 | FLD  fd,addr  | fd = DMEM[addr] |
| 0x11 | FST  fs,addr  | DMEM[addr] = fs |
| 0x12 | JMP  target   | PC = target |
| 0x13 | BEQ  fa,fb,target | if (fa == fb) PC = target |
| 0x1F | HALT | stop PC |

## Floating-point unit details

* **Format:** IEEE 754 binary64 -- 1 sign, 11 exponent (bias 1023), 52 fraction bits.
* **Adder/Subtractor:** magnitude compare & swap -> exponent alignment with
  guard/round/sticky -> add or subtract -> leading-zero normalisation ->
  round-to-nearest-even -> pack with overflow/underflow handling.
* **Multiplier:** 53x53 mantissa product (106 bit), exponent add - bias, post-normalise,
  round-to-nearest-even.
* **Comparator:** sign-magnitude aware, treats +0 == -0, NaN is unordered.
* **Special values:** NaN, +/-Inf, +/-0 follow IEEE rules (Inf-Inf = NaN, Inf*0 = NaN, ...).
* **Limitations:** subnormals are flushed to zero; only round-to-nearest-even; no division/sqrt
  and no exception flags (see Future work).

## Control unit
Pure combinational decoder (`control_unit.v`): opcode -> `reg_write, mem_read, mem_write, jump, branch, halt, alu_op`.

## Verification
1. `tb_fp64_alu` -- 5,582 vectors from a Python (IEEE 754) golden model: corner cases
   (0, -0, Inf, NaN, max/min normal) + random + heavy-cancellation cases. **0 mismatches.**
2. `tb_fp64_processor` -- assembles and runs `programs/demo.asm`, then checks data memory.

## Future work
Pipelining (5-stage), FDIV/FSQRT, subnormal support, rounding-mode & exception flags,
FPGA board constraints, base+offset addressing.
