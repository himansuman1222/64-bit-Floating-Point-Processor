// ---------------------------------------------------------------------------
// fp64_defs.vh : shared constants for the 64-bit Floating Point Processor
// ---------------------------------------------------------------------------
`ifndef FP64_DEFS_VH
`define FP64_DEFS_VH

// IEEE 754 binary64 constants
`define FP64_QNAN   64'h7FF8_0000_0000_0000
`define FP64_ONE    64'h3FF0_0000_0000_0000
`define FP64_ZERO   64'h0000_0000_0000_0000

// ALU operation codes (4-bit)
`define ALU_ADD     4'd0
`define ALU_SUB     4'd1
`define ALU_MUL     4'd2
`define ALU_AND     4'd3
`define ALU_OR      4'd4
`define ALU_XOR     4'd5
`define ALU_NOT     4'd6
`define ALU_LT      4'd7
`define ALU_EQ      4'd8
`define ALU_ABS     4'd9
`define ALU_NEG     4'd10

// Instruction opcodes (5-bit)  instr[31:27]
`define OP_NOP      5'h00
`define OP_FADD     5'h01
`define OP_FSUB     5'h02
`define OP_FMUL     5'h03
`define OP_FAND     5'h04
`define OP_FOR      5'h05
`define OP_FXOR     5'h06
`define OP_FNOT     5'h07
`define OP_FLT      5'h08
`define OP_FEQ      5'h09
`define OP_FABS     5'h0A
`define OP_FNEG     5'h0B
`define OP_FLD      5'h10
`define OP_FST      5'h11
`define OP_JMP      5'h12
`define OP_BEQ      5'h13
`define OP_HALT     5'h1F

`endif
