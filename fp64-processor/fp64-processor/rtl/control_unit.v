// ---------------------------------------------------------------------------
// control_unit : opcode decoder -> datapath control signals
// ---------------------------------------------------------------------------
`include "fp64_defs.vh"
module control_unit (
    input      [4:0] opcode,
    output reg       reg_write,
    output reg       mem_read,
    output reg       mem_write,
    output reg       jump,
    output reg       branch,
    output reg       halt,
    output reg [3:0] alu_op
);
    always @* begin
        reg_write = 0; mem_read = 0; mem_write = 0;
        jump = 0; branch = 0; halt = 0; alu_op = `ALU_ADD;
        case (opcode)
            `OP_FADD: begin reg_write = 1; alu_op = `ALU_ADD; end
            `OP_FSUB: begin reg_write = 1; alu_op = `ALU_SUB; end
            `OP_FMUL: begin reg_write = 1; alu_op = `ALU_MUL; end
            `OP_FAND: begin reg_write = 1; alu_op = `ALU_AND; end
            `OP_FOR : begin reg_write = 1; alu_op = `ALU_OR;  end
            `OP_FXOR: begin reg_write = 1; alu_op = `ALU_XOR; end
            `OP_FNOT: begin reg_write = 1; alu_op = `ALU_NOT; end
            `OP_FLT : begin reg_write = 1; alu_op = `ALU_LT;  end
            `OP_FEQ : begin reg_write = 1; alu_op = `ALU_EQ;  end
            `OP_FABS: begin reg_write = 1; alu_op = `ALU_ABS; end
            `OP_FNEG: begin reg_write = 1; alu_op = `ALU_NEG; end
            `OP_FLD : begin reg_write = 1; mem_read = 1; end
            `OP_FST : begin mem_write = 1; end
            `OP_JMP : begin jump = 1; end
            `OP_BEQ : begin branch = 1; alu_op = `ALU_EQ; end
            `OP_HALT: begin halt = 1; end
            default : ; // NOP / undefined
        endcase
    end
endmodule
